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

@interface GViewController ()

@end

@implementation GViewController

@synthesize titleBar,startBtn,settingBtn,settingViewController,webViewRef,statusMessage,copyleftMessage;

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
    
    [webViewRef setHidden:YES];
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
    [GUtility runTaskWithArgs:[NSMutableArray arrayWithObjects:controlSh,actionCmd,nil] taskType:ShellTask waitExit:YES];
    
    [self updateUIStatus];
}

-(IBAction)performSettingAction:(id)sender
{
    NSLog(@"setting button pushed");
    [self presentModalViewController:settingViewController animated:NO];
}

-(void)updateUIStatus;
{
    if ([self isRunning])
    {
        [startBtn setTitle:@"Stop"];
        [statusMessage setText:[NSString stringWithFormat:@"GoAgent is Runing"]];
        
        [webViewRef setHidden:NO];
        [statusMessage setHidden:YES];
        [copyleftMessage setHidden:YES];
        
        [self loadHomePage];
    }
    else
    {
        [startBtn setTitle:@"Start"];
        [statusMessage setText:[NSString stringWithFormat:@"GoAgent is Stopped"]];
        
        [webViewRef setHidden:YES];
        [statusMessage setHidden:NO];
        [copyleftMessage setHidden:NO];
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
    NSURL* url = [NSURL URLWithString:@"http://code.google.com/p/goagent"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [webViewRef loadRequest:request];
    [webViewRef setNeedsDisplay];
}
@end
