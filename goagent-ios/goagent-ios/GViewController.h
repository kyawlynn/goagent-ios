//
//  GViewController.h
//  goagent-ios
//
//  Created by hewig on 6/3/12.
//  Copyright (c) 2012 goagent project. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iniparser.h"

@interface GViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic,strong) IBOutlet UINavigationItem *titleBar;
@property (nonatomic,strong) IBOutlet UINavigationItem *startBtn;
@property (nonatomic,strong) IBOutlet UINavigationItem *settingBtn;
@property (nonatomic,strong) IBOutlet UIWebView* webViewRef;
@property (nonatomic,strong) IBOutlet UITextField* addressField;
@property (nonatomic,strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *backBtn;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *fowardBtn;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *busyWebIcon;
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
