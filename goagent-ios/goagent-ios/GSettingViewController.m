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

@interface GSettingViewController()<UITableViewDelegate,UITableViewDataSource,
                                    UITextFieldDelegate,UIDocumentInteractionControllerDelegate,
                                    UIAlertViewDelegate,UIActionSheetDelegate>

@end

@implementation GSettingViewController

-(void)awakeFromNib
{
    [self prepareSettingForDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.BackBtn = [[UIBarButtonItem alloc] init];
    self.BackBtn.title = NSLocalizedString(@"BUTTON_TITLE_BACK",nil);
    self.BackBtn.target = self;
    self.BackBtn.action = @selector(performBackAction:);
    
    self.EditBtn = [[UIBarButtonItem alloc] init];
    self.EditBtn.title = NSLocalizedString(@"BUTTON_TITLE_EDIT",nil);
    self.EditBtn.target = self;
    self.EditBtn.action = @selector(performEditAction:);
    
    self.navigationItem.leftBarButtonItem = self.BackBtn;
    self.navigationItem.rightBarButtonItem = self.EditBtn;
    
    self.navigationItem.title = NSLocalizedString(@"BUTTON_TITLE_SETTING",nil);

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark UIDocumentInteractionControllerDelegate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


#pragma mark UITableViewDelegate
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
    return NSLocalizedString(_settingSections[section],nil);
}

#pragma mark UITextFieldDelegate

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
    
    NSLog(@"<== textFieldShouldReturn tag:%d,section:%d,row:%d",textTag,section,row);
    
    
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
            iniKey="gae:mode";
            break;
        case 12:
            iniKey="pac:profile";
            break;
        default:
            break;
    }
    if (iniKey)
    {
        NSLog(@"==> set %@ = %@", @(iniKey), [textField text]);
        
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

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [GUtility setProxyForPreferences];
    }
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* apnConfig = nil;
    switch (buttonIndex) {
        case 0:
            apnConfig = REMOTE_APN_MOBILE;
            break;
        case 1:
            apnConfig = REMOTE_APN_UNICOM;
            break;
        case 2:
            apnConfig = REMOTE_APN_TELECOM;
            break;
        default:
            break;
    }
    if (apnConfig) {
        NSLog(@"==> try to install config:%@", [apnConfig lastPathComponent]);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:apnConfig]];
    }
}


#pragma mark IBActions

-(IBAction)performBackAction:(id)sender
{
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
    NSString* appTitle = NSLocalizedString(@"APPLICATION_NAME",nil);
    switch (button.tag)
    {
        //change proxy
        case 100:
        {
            NSLog(@"==> perform change system proxy action");
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:appTitle
                                                             message:NSLocalizedString(@"CHANGE_PROXY_ALERT_MESSAGE",nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"BUTTON_TITLE_CANCEL",nil)
                                                   otherButtonTitles:NSLocalizedString(@"BUTTON_TITLE_OK",nil),nil];
            [alert show];
            
            break;
        }
        //install cert
        case 101:
        {
            NSLog(@"==> perform install CA action");
            NSString* CA_URL = REMOTE_CA_URL;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CA_URL]];
            break;
        }
        //install apn config
        case 102:
        {
            NSLog(@"==> perform install APN action");
            UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:appTitle
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"BUTTON_TITLE_CANCEL",nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"CARRIER_CHINA_MOBILE",nil), NSLocalizedString(@"CARRIER_CHINA_UNICOM",nil), NSLocalizedString(@"CARRIER_CHINA_TELECOM",nil), nil];
            [sheet showInView:self.view];
            break;
        }
        case 103:
        {
            NSLog(@"==> open goagent ios log");
            [self openIniFile:GOAGENT_LOCAL_LOG];
            break;
        }
        case 104:
        {
            NSLog(@"==> open goagent log");
            [self openIniFile:GOAGENT_LOG];
            break;
        }
        default:
            break;
    }
}

#pragma mark helper functions

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
            [appDelegate showAlert:[NSString stringWithFormat:NSLocalizedString(@"EDIT_FILE_ERROR",nil),filepath] withTitle:APPLICATION_NAME];
        }
    }
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
    NSMutableDictionary* appidDic = [NSMutableDictionary new];
    appidDic[[NSString stringWithFormat:@"%@_0_key",KEY_SETTING_BASIC]] = NSLocalizedString(KEY_SETTING_APPID,nil);
    appidDic[[NSString stringWithFormat:@"%@_0_value",KEY_SETTING_BASIC]] = @(iniparser_getstring(iniDic, "gae:appid", NULL));
    
    
    NSMutableDictionary* modeDic = [NSMutableDictionary new];
    modeDic[[NSString stringWithFormat:@"%@_1_key",KEY_SETTING_BASIC]] = NSLocalizedString(KEY_SETTING_MODE,nil);
    modeDic[[NSString stringWithFormat:@"%@_1_value",KEY_SETTING_BASIC]] = @(iniparser_getstring(iniDic, "gae:mode", NULL));
    
    
    NSMutableDictionary* profileDic = [NSMutableDictionary new];
    profileDic[[NSString stringWithFormat:@"%@_2_key",KEY_SETTING_BASIC]] = NSLocalizedString(KEY_SETTING_PROFILE,nil);
    profileDic[[NSString stringWithFormat:@"%@_2_value",KEY_SETTING_BASIC]] = @(iniparser_getstring(iniDic, "gae:profile", NULL));
    
    NSArray* basicArray = @[appidDic,modeDic,profileDic];
    
    self.settingDic[KEY_SETTING_BASIC] = basicArray;
    
    //advanced settings
    NSMutableDictionary* sysproxyDic = [NSMutableDictionary new];
    sysproxyDic[[NSString stringWithFormat:@"%@_0_key",KEY_SETTING_ADVANCED]] = KEY_SETTING_SET_SYSPROXY;
    sysproxyDic[[NSString stringWithFormat:@"%@_0_value",KEY_SETTING_ADVANCED]] = NSLocalizedString(KEY_SETTING_SET_SYSPROXY,nil);
    
    
    NSMutableDictionary* installCertDic = [NSMutableDictionary new];
    installCertDic[[NSString stringWithFormat:@"%@_1_key",KEY_SETTING_ADVANCED]] = KEY_SETTING_INSTALL_CERT;
    installCertDic[[NSString stringWithFormat:@"%@_1_value",KEY_SETTING_ADVANCED]] = NSLocalizedString(KEY_SETTING_INSTALL_CERT,nil);
    
    NSMutableDictionary* installAPNDic = [NSMutableDictionary new];
    installAPNDic[[NSString stringWithFormat:@"%@_2_key",KEY_SETTING_ADVANCED]] = KEY_SETTING_INSTALL_APN;
    installAPNDic[[NSString stringWithFormat:@"%@_2_value",KEY_SETTING_ADVANCED]] = NSLocalizedString(KEY_SETTING_INSTALL_APN,nil);
    
    NSMutableDictionary* openLocalLogDic = [NSMutableDictionary new];
    openLocalLogDic[[NSString stringWithFormat:@"%@_3_key",KEY_SETTING_ADVANCED]] = KEY_SETTING_OPEN_LOCAL_LOG;
    openLocalLogDic[[NSString stringWithFormat:@"%@_3_value",KEY_SETTING_ADVANCED]] = NSLocalizedString(KEY_SETTING_OPEN_LOCAL_LOG,nil);
    
    NSMutableDictionary* openGoAgentLogDic = [NSMutableDictionary new];
    openGoAgentLogDic[[NSString stringWithFormat:@"%@_4_key",KEY_SETTING_ADVANCED]] = KEY_SETTING_OPEN_LOG;
    openGoAgentLogDic[[NSString stringWithFormat:@"%@_4_value",KEY_SETTING_ADVANCED]] = NSLocalizedString(KEY_SETTING_OPEN_LOG,nil);
    
    NSArray* advancedArray = @[sysproxyDic, installCertDic, installAPNDic, openLocalLogDic, openGoAgentLogDic];
    
    self.settingDic[KEY_SETTING_ADVANCED] = advancedArray;
    
    [self.settingSections addObject:KEY_SETTING_BASIC];
    [self.settingSections addObject:KEY_SETTING_ADVANCED];
}

@end
