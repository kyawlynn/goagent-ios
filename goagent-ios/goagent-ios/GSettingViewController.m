//
//  GSettingViewController.m
//  goagent-ios
//
//  Created by hewig on 6/3/12.
//  Copyright (c) 2012 goagent project. All rights reserved.
//

#import "GSettingViewController.h"
#import "GConfig.h"
#import "GUtility.h"
#import "GAppDelegate.h"
#import <dlfcn.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation GSettingViewController

-(void)awakeFromNib
{
    [self prepareSettingForDisplay];
}

-(void)dealloc
{
    //
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.BackBtn = [[UIBarButtonItem alloc] init];
    self.BackBtn.title = @"Back";
    self.BackBtn.target = self;
    self.BackBtn.action = @selector(performBackAction:);
    
    self.EditBtn = [[UIBarButtonItem alloc] init];
    self.EditBtn.title = @"Edit File";
    self.EditBtn.target = self;
    self.EditBtn.action = @selector(performEditAction:);
    
    self.navigationItem.leftBarButtonItem = self.BackBtn;
    self.navigationItem.rightBarButtonItem = self.EditBtn;
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_settingSections count];
}

-(NSInteger)tableView:(UITableView *)tabbleView numberOfRowsInSection:(NSInteger)section
{
    return [_settingDic[_settingSections[section]] count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    int currentRow =[indexPath row];
    int currentSection = [indexPath section];
    int itemTag = (int)pow(10, currentSection+1)+currentRow;
    
    NSString* key = _settingSections[currentSection];
    NSArray* contents = _settingDic[key];
    NSDictionary* item = contents[currentRow];
    
    if ([key isEqualToString:KEY_SETTING_BASIC])
    {
        UITextField* valueField = [[UITextField alloc] initWithFrame:CGRectMake(0,10,125,25)];
        valueField.adjustsFontSizeToFitWidth = NO;
        valueField.backgroundColor = [UIColor clearColor];
        valueField.autocorrectionType = UITextAutocorrectionTypeNo;
        valueField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        valueField.textAlignment = NSTextAlignmentRight;
        valueField.keyboardType = UIKeyboardTypeDefault;
        valueField.returnKeyType = UIReturnKeyDone;
        valueField.clearButtonMode = UITextFieldViewModeNever;
        valueField.delegate = self;
        valueField.text = item[[NSString stringWithFormat:@"%@_%d_value",key,currentRow]];
        valueField.tag = itemTag;
        cell.accessoryView = valueField;
        cell.textLabel.text = item[[NSString stringWithFormat:@"%@_%d_key",key,currentRow]];
    }
    else if ([key isEqualToString:KEY_SETTING_ADVANCED])
    {
        UIButton *button = [[UIButton alloc] initWithFrame:[cell frame]];
        [button addTarget:self action:@selector(performPressAciton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:itemTag];
        [button setTitle:item[[NSString stringWithFormat:@"%@_%d_value",key,currentRow]] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [cell.contentView addSubview:button];
    }
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _settingSections[section];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int textTag = [textField tag];
    int section=0,row=0;
    
    row = textTag % 10;
    while (textTag)
    {
        textTag = textTag / 10;
        if (textTag>1)
        {
            section+=1;
        }
    }
    
    dictionary* iniDic = [GAppDelegate loadGoAgentSettings];
    
    NSLog(@"tag is %d,section is %d,row is %d",textTag,section,row);
    
    
    NSString* key = _settingSections[section];
    NSArray* contents = _settingDic[key];
    NSDictionary* item = contents[row];
    
    [item setValue:[textField text] forKey:[NSString stringWithFormat:@"%@_%d_value",key,row]];
    char *iniKey = NULL;
    switch ([textField tag])
    {
        case 10:
            iniKey="gae:appid";
            break;
        case 11:
            iniKey="gae:profile";
            break;
        case 12:
            iniKey="pac:enable";
            break;
        default:
            break;
    }
    if (iniKey)
    {
        iniparser_set(iniDic, iniKey,[[textField text] UTF8String]);
        FILE* fp = fopen([[[NSBundle mainBundle] pathForResource:CONFIG_FILE_NAME
                                                         ofType:CONFIG_FILE_TYPE
                                                     inDirectory:GOAGENT_LOCAL_PATH] UTF8String],"w+");
        iniparser_dump_ini(iniDic,fp);
        fclose(fp);
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

-(void)prepareSettingForDisplay
{
    self.settingSections = [[NSMutableArray alloc] init];
    self.settingDic = [[NSMutableDictionary alloc] init];
    
    dictionary* iniDic = [GAppDelegate loadGoAgentSettings];
    
    //basic settings
    NSMutableDictionary* appidDic = [NSMutableDictionary dictionaryWithObjects:
                                     @[KEY_SETTING_APPID,@(iniparser_getstring(iniDic, "gae:appid", NULL))]
                                                                       forKeys:
                                     @[[NSString stringWithFormat:@"%@_0_key",KEY_SETTING_BASIC], [NSString stringWithFormat:@"%@_0_value",KEY_SETTING_BASIC]]
                                     ];
    
    NSMutableDictionary* modeDic = [NSMutableDictionary dictionaryWithObjects:
                                       @[KEY_SETTING_MODE,@(iniparser_getstring(iniDic, "gae:mode", NULL))]
                                                                         forKeys:
                                       @[[NSString stringWithFormat:@"%@_1_key",KEY_SETTING_BASIC], [NSString stringWithFormat:@"%@_1_value",KEY_SETTING_BASIC]]
                                       ];
    
    NSMutableDictionary* profileDic = [NSMutableDictionary dictionaryWithObjects:
                                       @[KEY_SETTING_PROFILE,@(iniparser_getstring(iniDic, "gae:profile", NULL))]
                                                                         forKeys:
                                       @[[NSString stringWithFormat:@"%@_2_key",KEY_SETTING_BASIC], [NSString stringWithFormat:@"%@_2_value",KEY_SETTING_BASIC]]
                                       ];
    
    NSArray* basicArray = @[appidDic,modeDic,profileDic];
    
    (self.settingDic)[KEY_SETTING_BASIC] = basicArray;
    
    //advanced settings
    NSMutableDictionary* sysproxyDic = [NSMutableDictionary dictionaryWithObjects:
                                        @[KEY_SETTING_SET_SYSPROXY,KEY_SETTING_SET_SYSPROXY]
                                                                          forKeys:
                                        @[[NSString stringWithFormat:@"%@_0_key",KEY_SETTING_ADVANCED], [NSString stringWithFormat:@"%@_0_value",KEY_SETTING_ADVANCED]]
                                 ];
    
    NSMutableDictionary* installCertDic = [NSMutableDictionary dictionaryWithObjects:
                                        @[KEY_SETTING_INSTALL_CERT,KEY_SETTING_INSTALL_CERT]
                                                                          forKeys:
                                        @[[NSString stringWithFormat:@"%@_1_key",KEY_SETTING_ADVANCED], [NSString stringWithFormat:@"%@_1_value",KEY_SETTING_ADVANCED]]
                                        ];
    
    NSMutableDictionary* openLocalLogDic = [NSMutableDictionary dictionaryWithObjects:
                                           @[KEY_SETTING_OPEN_LOCAL_LOG,KEY_SETTING_OPEN_LOCAL_LOG]
                                                                             forKeys:
                                           @[[NSString stringWithFormat:@"%@_2_key",KEY_SETTING_ADVANCED], [NSString stringWithFormat:@"%@_2_value",KEY_SETTING_ADVANCED]]
                                           ];
    
    NSMutableDictionary* openGoAgentLogDic = [NSMutableDictionary dictionaryWithObjects:
                                           @[KEY_SETTING_OPEN_LOG,KEY_SETTING_OPEN_LOG]
                                                                             forKeys:
                                           @[[NSString stringWithFormat:@"%@_3_key",KEY_SETTING_ADVANCED], [NSString stringWithFormat:@"%@_3_value",KEY_SETTING_ADVANCED]]
                                           ];
    
    NSArray* advancedArray = @[sysproxyDic,installCertDic, openLocalLogDic, openGoAgentLogDic];
    
    (self.settingDic)[KEY_SETTING_ADVANCED] = advancedArray;
    
    [self.settingSections addObject:KEY_SETTING_BASIC];
    [self.settingSections addObject:KEY_SETTING_ADVANCED];
}

-(IBAction)performBackAction:(id)sender
{
    NSLog(@"back to main view");
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)performEditAction:(id)sender
{
    NSString* proxyIni = [[NSBundle mainBundle] pathForResource:CONFIG_FILE_NAME
                                                        ofType:CONFIG_FILE_TYPE
                                                   inDirectory:GOAGENT_LOCAL_PATH];
    [self openIniFile:proxyIni];
}

-(void)performPressAciton:(id)sender
{
    UIButton* button = (UIButton*)sender;
    switch (button.tag)
    {
        //change proxy
        case 100:
        {
            NSLog(@"perform change system proxy action");
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:APPLICATION_NAME
                                                             message:@"It won't change proxy setting for running Apps"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"OK",nil];
            [alert show];
            
            break;
        }
        //install cert
        case 101:
        {
            NSLog(@"perform install CA action");
            NSString* CA_URL = REMOTE_CA_URL;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CA_URL]];
            break;
        }
        case 102:
        {
            NSLog(@"open goagent ios log");
            [self openIniFile:GOAGENT_LOCAL_LOG];
            break;
        }
        case 103:
        {
            NSLog(@"open goagent log");
            [self openIniFile:GOAGENT_LOG];
            break;
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        void* libHandle = dlopen("/System/Library/Frameworks/SystemConfiguration.framework/SystemConfiguration", RTLD_LAZY);
        SCPreferencesRef(*_SCPreferencesCreate)(CFAllocatorRef,CFStringRef,CFStringRef) = dlsym(libHandle, "SCPreferencesCreate");
        CFPropertyListRef(*_SCPreferencesGetValue)(SCPreferencesRef,CFStringRef) = dlsym(libHandle, "SCPreferencesGetValue");
        Boolean(*_SCPreferencesApplyChanges)(SCPreferencesRef) = dlsym(libHandle, "SCPreferencesApplyChanges");
        Boolean(*_SCPreferencesCommitChanges)(SCPreferencesRef) = dlsym(libHandle, "SCPreferencesCommitChanges");
        void(*_SCPreferencesSynchronize)(SCPreferencesRef) = dlsym(libHandle, "SCPreferencesSynchronize");
        
        SCPreferencesRef preferenceRef = _SCPreferencesCreate(NULL, CFSTR("goagent-ios"), NULL);
        CFPropertyListRef networkServices = _SCPreferencesGetValue(preferenceRef, CFSTR("NetworkServices"));
        NSDictionary* services = (__bridge NSDictionary*)networkServices;
        
        for (NSString* key in [services allKeys]) {
            NSMutableDictionary* obj = [services[key] mutableCopy];
            NSString* hardware = [obj valueForKeyPath:@"Interface.Hardware"];
            
            if ([hardware isEqualToString:@"AirPort"]) {
                NSDictionary* proxies = [obj valueForKey:@"Proxies"];
                if (proxies) {
                    
                    NSMutableDictionary* dict = [proxies mutableCopy];
                    dict[@"HTTPSEnable"] = @NO;
                    dict[@"HTTPEnable"] = @NO;
                    dict[@"ProxyAutoConfigEnable"] = @YES;
                    dict[@"ProxyAutoConfigURLString"] = @"http://127.0.0.1:8086/proxy.pac";
                    [obj setObject:dict forKey:@"Proxies"];
                    NSLog(@"set interface:%@ with proxy:%@",[obj valueForKeyPath:@"Interface"], dict);
                }
            }
        }
        
        if(_SCPreferencesCommitChanges(preferenceRef)){
            NSLog(@"commit proxy changes ok");
        } else{
            NSLog(@"commit proxy changes failed!");
        }
        if(_SCPreferencesApplyChanges(preferenceRef)){
            NSLog(@"apply proxy changes ok");
        } else{
            NSLog(@"commit proxy changes failed!");
        }
        _SCPreferencesSynchronize(preferenceRef);
        CFRelease(preferenceRef);
        dlclose(libHandle);
    }
}

- (void)openIniFile:(NSString *)filepath
{
    //try iFire first, then other apps
    NSURL* ifileReq = [NSURL URLWithString:[NSString stringWithFormat:@"ifile://localhost%@",filepath]];

    if (![[UIApplication sharedApplication] openURL:ifileReq])
    {
        [self setupDocumentControllerWithURL:[NSURL fileURLWithPath:filepath]];
        
        if (![self.docInteractionController presentOpenInMenuFromRect:CGRectZero
                                                               inView:self.view.window
                                                             animated:YES])
        {
            GAppDelegate* appDelegate = [GAppDelegate getInstance];
            [appDelegate showAlert:[NSString stringWithFormat:@"Sorry, No other App can open %@",filepath] withTitle:APPLICATION_NAME];
        }
    }
}

@end
