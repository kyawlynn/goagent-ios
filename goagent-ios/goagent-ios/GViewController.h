//
//  GViewController.h
//  goagent-ios
//
//  Created by hewig on 6/3/12.
//  Copyright (c) 2012 goagent project. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iniparser.h"

@interface GViewController : UIViewController

@property (nonatomic,strong) UIBarButtonItem *startBtn;
@property (nonatomic,strong) UIBarButtonItem *settingBtn;
@property (nonatomic,weak) IBOutlet UIWebView* webViewRef;
@property (nonatomic,weak) IBOutlet UITextField* addressField;
@property (nonatomic,weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *backBtn;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *fowardBtn;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *busyWebIcon;
@property (nonatomic,strong) UIViewController* settingViewController;


-(IBAction)performStartAction:(id)sender;
-(IBAction)performSettingAction:(id)sender;
-(IBAction)performBackAction:(id)sender;
-(IBAction)performFowardAction:(id)sender;
-(IBAction)performReloadAction:(id)sender;
-(IBAction)performShareAction:(id)sender;
-(BOOL)isRunning;
-(void)loadWelcomeMessage;
-(void)loadHomePage;
-(void)loadURL:(NSString*)urlString;

@end
