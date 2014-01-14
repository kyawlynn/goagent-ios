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

@interface GViewController () <UIWebViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@end

@implementation GViewController


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)awakeFromNib
{
    self.settingViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"SettingViewController"];
    
    self.startBtn = [[UIBarButtonItem alloc] init];
    self.startBtn.title = NSLocalizedString(@"BUTTON_TITLE_START",nil);
    self.startBtn.target = self;
    self.startBtn.action = @selector(performStartAction:);
    
    self.settingBtn = [[UIBarButtonItem alloc] init];
    self.settingBtn.title = NSLocalizedString(@"BUTTON_TITLE_SETTING",nil);
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.addressField setDelegate:self];
    self.addressField.placeholder = NSLocalizedString(@"ADDRESS_BAR_PLACEHOLDER",nil);
    [self.webViewRef setDelegate:self];
    [self.busyWebIcon setHidden:YES];
    
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

#pragma mark IBActions

-(IBAction)performStartAction:(id)sender
{
    GAppDelegate* appDelegate = [GAppDelegate getInstance];
    
    dictionary* iniDic = [GAppDelegate loadGoAgentSettings];
    
    NSString* appid = [NSString stringWithFormat:@"%s",iniparser_getstring(iniDic, "gae:appid", "goagent")];
    if ([appid isEqualToString:@"goagent"]) {
        [appDelegate showAlert:NSLocalizedString(@"DEFAULT_APPID_MESSAGE",nil) withTitle:NSLocalizedString(@"DEFAULT_APPID_TITLE",nil)];
        return;
    }

    NSString* actionCmd = nil;
    if ([self isRunning])
    {
        NSLog(@"==> try stop goagent");
        actionCmd = CONTROL_CMD_STOP;
        NSError* error;
        if (![[NSFileManager defaultManager] removeItemAtPath:GOAGENT_PID_PATH error:&error]) {
            NSLog(@"<== remove pid failed:%@",[error description]);
            [appDelegate showAlert:NSLocalizedString(@"STOP_GOAGENT_ERROR_MESSAGE",nil) withTitle:NSLocalizedString(@"STOP_GOAGENT_ERROR_TITLE",nil)];
            return;
        }
        int rc = system("killall python");
        if (rc != 0) {
            NSLog(@"<== killall python returns:%d",rc);
            //[appDelegate showAlert:[NSString stringWithFormat:@"Stop python failed code:%d, Please try again", rc] withTitle:@"Stop GoAgent failed"];
        }
    }
    else
    {
        NSLog(@"==> try start goagent");
        actionCmd = CONTROL_CMD_START;
        if (![[NSFileManager defaultManager] createFileAtPath:GOAGENT_PID_PATH contents:nil attributes:nil])
        {
            NSLog(@"<== touch goagent.pid failed!");
            [appDelegate showAlert:NSLocalizedString(@"START_GOAGENT_ERROR_MESSAGE",nil) withTitle:NSLocalizedString(@"START_GOAGENT_ERROR_TITLE",nil)];
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
        NSString* host = [NSString stringWithFormat:@"%s", iniparser_getstring(iniDic, "listen:ip", "127.0.0.1")];
        int port = iniparser_getint(iniDic, "listen:port" , 8087);
        [AppProxyCap activate];
        [AppProxyCap setProxy:AppProxy_HTTP Host:host Port:port];
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self loadHomePage];
        });
    }
    [self updateUIStatus];
}

-(IBAction)performSettingAction:(id)sender
{
    [self.navigationController pushViewController:self.settingViewController animated:YES];
}

-(IBAction)performBackAction:(id)sender
{
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
    [self.webViewRef reload];
}

-(IBAction)performShareAction:(id)sender
{
    UIActionSheet *menu = [[UIActionSheet alloc]
						   initWithTitle: nil
						   delegate:self
						   cancelButtonTitle:NSLocalizedString(@"BUTTON_TITLE_CANCEL",nil)
						   destructiveButtonTitle:nil
						   otherButtonTitles:NSLocalizedString(@"VIEW_IN_SAFARI",nil), nil];
	[menu showFromToolbar:self.toolBar];
}

#pragma mark helper functions

-(void)updateUIStatus;
{

    if ([self isRunning])
    {
        NSLog(@"<== updateUIStatus, goagent is running");
        [self.startBtn setTitle:NSLocalizedString(@"BUTTON_TITLE_STOP",nil)];
        [self.addressField setHidden:NO];
    }
    else
    {
        NSLog(@"<== updateUIStatus, goagent is not running");
        [self.startBtn setTitle:NSLocalizedString(@"BUTTON_TITLE_START",nil)];
        [self.addressField setHidden:YES];
    }
}

-(BOOL)isRunning
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:GOAGENT_PID_PATH])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)loadHomePage
{
    [self loadURL:GOAGENT_HOME_PAGE];
}

-(void)loadWelcomeMessage
{
    [self loadURL:nil];
}

-(void)loadURL:(NSString *)urlString
{
    if (!urlString)
    {
        [self.webViewRef loadHTMLString:NSLocalizedString(@"WELCOME_MESSAGE",nil) baseURL:nil];
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
    if (textField == self.addressField) {
        [self resignFirstResponder];
        [self loadURL:[textField text]];
    }
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
    NSLog(@"<== load page error: %@", [error localizedDescription]);
    [appDelegate showAlert:[error localizedDescription] withTitle:NSLocalizedString(@"LOAD_PAGE_ERROR",nil)];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString* url = [[request URL] absoluteString];
    [self.addressField setText:url];
    return YES;
}

@end
