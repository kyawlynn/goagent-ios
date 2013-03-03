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
#import "3rdparty/AppProxyCap/lib/AppProxyCap.h"

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

@synthesize titleBar,
            startBtn,
            settingBtn,
            settingViewController,
            webViewRef,
            addressField,
            toolBar,
            backBtn,
            fowardBtn;


- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)awakeFromNib
{
    settingViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"SettingViewController"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    addressField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    addressField.borderStyle = UITextBorderStyleRoundedRect;
    addressField.font = [UIFont systemFontOfSize:17];
    addressField.keyboardType = UIKeyboardTypeURL;
    addressField.returnKeyType = UIReturnKeyGo;
    addressField.autocorrectionType = UITextAutocorrectionTypeNo;
    addressField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    addressField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    [addressField setDelegate:self];
    [webViewRef setDelegate:self];
    [self.busyWebIcon setHidden:YES];
    
    if (![self isRunning]) {
        [self loadWelcomeMessage];
    }
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
    }
    else
    {
        actionCmd = CONTROL_CMD_START;
    }
    
    NSString* controlSh = [[NSBundle mainBundle] pathForResource:CONTROL_SCRIPT_NAME
                                                          ofType:CONTROL_SCRIPT_TYPE
                                                     inDirectory:GOAGENT_LOCAL_PATH];
    if (![GUtility runTaskWithArgs:[NSMutableArray arrayWithObjects:controlSh,actionCmd,nil] taskType:ShellTask waitExit:YES])
    {
        [appDelegate showAlert:@"Please check Logs for details." withTitle:@"Start GoAgent failed"];
        return;
    }
    
    if ([actionCmd isEqualToString:CONTROL_CMD_STOP])
    {
        [addressField setHidden:YES];
        [self loadWelcomeMessage];
    }
    else
    {
        [addressField setHidden:NO];
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
    [self presentModalViewController:settingViewController animated:NO];
}

-(IBAction)performBackAction:(id)sender
{
    NSLog(@"%@",sender);
    if ([webViewRef canGoBack]) {
        [webViewRef goBack];
        
        [fowardBtn setEnabled:YES];
    }
    else{
        [self loadWelcomeMessage];
    }
}
-(IBAction)performFowardAction:(id)sender
{
    NSLog(@"%@",sender);
    if ([webViewRef canGoForward]) {
        [webViewRef goForward];
        
        if (![webViewRef canGoForward]) {
            [fowardBtn setEnabled:NO];
            [self.view setNeedsDisplay];
        }
    }
    else{
        [fowardBtn setEnabled:NO];
    }
}
-(IBAction)performReloadAction:(id)sender
{
    NSLog(@"%@",sender);
    [webViewRef reload];
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
	[menu showFromToolbar:toolBar];
}

-(void)updateUIStatus;
{
    if ([self isRunning])
    {
        [startBtn setTitle:@"Stop"];
        [addressField setHidden:NO];
    }
    else
    {
        [startBtn setTitle:@"Start"];
        [addressField setHidden:YES];
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
        [webViewRef loadHTMLString:@"<html>\
         <body>\
         <center>\
         <p><strong>GoAgent is Stopped</strong></p>\
         <p>GoAgent for iOS is open source and freely distributable.</p>\
         </center>\
         </body>\
         </html>" baseURL:nil];
        [webViewRef setNeedsDisplay];
    }
    else
    {
        if (![urlString hasPrefix:@"http"]) {
            urlString = [NSString stringWithFormat:@"http://%@",urlString];
        }
        NSURL* url = [NSURL URLWithString:urlString];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [webViewRef loadRequest:request];
        [webViewRef setNeedsDisplay];
    
    }
}

#pragma mark UIActionSheetDelegate delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0){
		[[UIApplication sharedApplication] openURL:[[webViewRef request] URL]];
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
	
	if (![webViewRef canGoForward]){
		// disable the forward button
		[fowardBtn setEnabled:NO];
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
    [addressField setText:url];
    return YES;
}

@end
