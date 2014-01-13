//
//  GSettingViewController.h
//  goagent-ios
//
//  Created by hewig on 6/3/12.
//  Copyright (c) 2012 goagent project. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iniparser.h"

@interface GSettingViewController : UIViewController

@property (nonatomic,weak) IBOutlet UITableView* settingTableView;
@property (nonatomic,strong) UIBarButtonItem *BackBtn;
@property (nonatomic,strong) UIBarButtonItem *EditBtn;
@property (nonatomic,strong) NSMutableArray* settingSections;
@property (nonatomic,strong) NSMutableDictionary* settingDic;
@property (nonatomic,strong) UIDocumentInteractionController *docInteractionController;

- (IBAction)performBackAction:(id)sender;
- (IBAction)performEditAction:(id)sender;
- (void)openIniFile:(NSString*)filepath;
@end
