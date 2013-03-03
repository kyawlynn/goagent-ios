//
//  GSettingViewController.h
//  goagent-ios
//
//  Created by hewig on 6/3/12.
//  Copyright (c) 2012 goagent project. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iniparser.h"

@interface GSettingViewController : UIViewController<UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    UITextFieldDelegate,
                                                    UIDocumentInteractionControllerDelegate,
                                                    UIAlertViewDelegate>

@property (nonatomic,strong) IBOutlet UITableView* settingTableView;
@property (nonatomic,strong) IBOutlet UINavigationItem *titleBar;
@property (nonatomic,strong) IBOutlet UIBarItem *BackBtn;
@property (nonatomic,strong) IBOutlet UIBarItem *EditBtn;
@property (nonatomic,retain) NSMutableArray* settingSections;
@property (nonatomic,retain) NSMutableDictionary* settingDic;
@property (nonatomic,strong) UIDocumentInteractionController *docInteractionController;

- (IBAction)performBackAction:(id)sender;
- (IBAction)performEditAction:(id)sender;
- (void)openIniFile:(NSString*)filepath;
@end
