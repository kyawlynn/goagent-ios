//
//  GViewController.m
//  goagent-ios
//
//  Created by hewig on 6/3/12.
//  Copyright (c) 2012 goagent project. All rights reserved.
//

#import "GViewController.h"
#import "GSettingViewController.h"
#import "GConfig.h"
#import "GUtility.h"
#import "GAppDelegate.h"
#import "AppProxyCap.h"
#import "launchctl_lite.h"

#pragma mark ignore ssl error, private API
@interface NSURLRequest (NSURLRequestWithIgnoreSSL)
+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
@end

@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)
+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    return YES;
}
@end

@interface GViewController ()

@end

@implementation GViewController


- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)awakeFromNib
{
    self.settingViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"SettingViewController"];
    
    self.startBtn = [[UIBarButtonItem alloc] init];
    self.startBtn.title = @"Start";
    self.startBtn.target = self;
    self.startBtn.action = @selector(performStartAction:);
    
    self.settingBtn = [[UIBarButtonItem alloc] init];
    self.settingBtn.title = @"Setting";
    self.settingBtn.target = self;
    self.settingBtn.action = @selector(performSettingAction:);
    
    self.navigationItem.leftBarButtonItem = self.startBtn;
    self.navigationItem.rightBarButtonItem = self.settingBtn;
    
    self.addressField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.addressField.borderStyle = UITextBorderStyleRoundedRect;
    self.addressField.font = [UIFont systemFontOfSize:17];
    self.addressField.keyboardType = UIKeyboardTypeURL;
    self.addressField.returnKeyType = UIReturnKeyGo;
    self.addressField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.addressField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.addressField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.addressField setDelegate:self];
    [self.webViewRef setDelegate:self];
    [self.busyWebIcon setHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.backBtn setTitleTextAttributes:@{UITextAttributeFont: [UIFont systemFontOfSize:28]} forState:UIControlStateNormal];
    [self.fowardBtn setTitleTextAttributes:@{UITextAttributeFont:[UIFont systemFontOfSize:28]} forState:UIControlStateNormal];
    
    if (![self isRunning]) {
        [self loadWelcomeMessage];
    }
    
    [self.busyWebIcon setHidesWhenStopped:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateUIStatus];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(IBAction)performStartAction:(id)sender
{
    NSLog(@"start button pushed");
    
    GAppDelegate* appDelegate = [GAppDelegate getInstance];
    
    dictionary* iniDic = [GAppDelegate loadGoAgentSettings];
    
    NSString* appid = [NSString stringWithFormat:@"%s",iniparser_getstring(iniDic, "gae:appid", "goagent")];
    if ([appid isEqualToString:@"goagent"]) {
        [appDelegate showAlert:@"Have you edit your appid?" withTitle:@"Default appid detected"];
        return;
    }

    NSString* actionCmd = nil;
    if ([self isRunning])
    {
        actionCmd = CONTROL_CMD_STOP;
        launchctl_remove_cmd([GOAGENT_JOB_LABEL UTF8String]);
    }
    else
    {
        actionCmd = CONTROL_CMD_START;
        //XXXXXX launchctl_lite not implement yet.
        if (0 != system("launchctl load org.goagent.local.ios"))
        {
            [appDelegate showAlert:@"Please check Logs for details." withTitle:@"Start GoAgent failed"];
            return;
        }
    }
    
    if ([actionCmd isEqualToString:CONTROL_CMD_STOP])
    {
        [self.addressField setHidden:YES];
        [self loadWelcomeMessage];
    }
    else
    {
        [self.addressField setHidden:NO];
        dictionary* iniDic = [GAppDelegate loadGoAgentSettings];
        NSString* host = [NSString stringWithFormat:@"%s", iniparser_getstring(iniDic, "listen:ip", "127.0.0.1")];
        int port = iniparser_getint(iniDic, "listen:port" , 8087);
        [AppProxyCap activate];
        [AppProxyCap setProxy:AppProxy_HTTP Host:host Port:port];
        
        [self loadHomePage];
    }
    [self updateUIStatus];
}

-(IBAction)performSettingAction:(id)sender
{
    NSLog(@"setting button pushed");
    [self.navigationController pushViewController:self.settingViewController animated:YES];
}

-(IBAction)performBackAction:(id)sender
{
    NSLog(@"%@",sender);
    if ([self.webViewRef canGoBack]) {
        [self.webViewRef goBack];
        
        [self.fowardBtn setEnabled:YES];
    }
    else{
        [self loadWelcomeMessage];
    }
}
-(IBAction)performFowardAction:(id)sender
{
    NSLog(@"%@",sender);
    if ([self.webViewRef canGoForward]) {
        [self.webViewRef goForward];
        
        if (![self.webViewRef canGoForward]) {
            [self.fowardBtn setEnabled:NO];
            [self.view setNeedsDisplay];
        }
    }
    else{
        [self.fowardBtn setEnabled:NO];
    }
}
-(IBAction)performReloadAction:(id)sender
{
    NSLog(@"%@",sender);
    [self.webViewRef reload];
}

-(IBAction)performShareAction:(id)sender
{
    NSLog(@"%@",sender);
    UIActionSheet *menu = [[UIActionSheet alloc]
						   initWithTitle: nil
						   delegate:self
						   cancelButtonTitle:@"Cancel"
						   destructiveButtonTitle:nil
						   otherButtonTitles:@"View in Safari", nil];
	[menu showFromToolbar:self.toolBar];
}

-(void)updateUIStatus;
{
    if ([self isRunning])
    {
        [self.startBtn setTitle:@"Stop"];
        [self.addressField setHidden:NO];
    }
    else
    {
        [self.startBtn setTitle:@"Start"];
        [self.addressField setHidden:YES];
    }
}

-(BOOL)isRunning
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:GOAGENT_PID_PATH])
    {
        return YES;
    }
    else return NO;
}

-(void)loadHomePage
{
    NSLog(@"load goagent homepage");
    //wait for goagent ready, otherwise it will connect directly
    sleep(1);
    
    [self loadURL:GOAGENT_HOME_PAGE];
}

-(void)loadWelcomeMessage
{
    NSLog(@"load welcome message");
    [self loadURL:nil];
}

-(void)loadURL:(NSString *)urlString
{
    if (!urlString)
    {
        [self.webViewRef loadHTMLString:@"<html>\
         <body>\
         <center>\
         <p><strong>GoAgent is Stopped</strong></p>\
         <p>GoAgent for iOS is open source and freely distributable.</p>\
         </center>\
         </body>\
         </html>" baseURL:nil];
        [self.webViewRef setNeedsDisplay];
    }
    else
    {
        if (![urlString hasPrefix:@"http"]) {
            urlString = [NSString stringWithFormat:@"http://%@",urlString];
        }
        NSURL* url = [NSURL URLWithString:urlString];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [self.webViewRef loadRequest:request];
        [self.webViewRef setNeedsDisplay];
    
    }
}

#pragma mark UIActionSheetDelegate delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0){
		[[UIApplication sharedApplication] openURL:[[self.webViewRef request] URL]];
	}
}

#pragma mark NSTextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self loadURL:[textField text]];
    return YES;
}

#pragma mark UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.busyWebIcon setHidden:NO];
	[self.busyWebIcon startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView1
{
    [self.busyWebIcon setHidden:YES];
 	[self.busyWebIcon stopAnimating];
	
	if (![self.webViewRef canGoForward]){
		// disable the forward button
		[self.fowardBtn setEnabled:NO];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // load error, hide the activity indicator in the status bar
	[self.busyWebIcon stopAnimating];
    
    GAppDelegate* appDelegate = [GAppDelegate getInstance];
    NSLog(@"load page error: %@", [error localizedDescription]);
    [appDelegate showAlert:[error localizedDescription] withTitle:@"Load Page Error"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString* url = [[request URL] absoluteString];
    [self.addressField setText:url];
    return YES;
}

@end
