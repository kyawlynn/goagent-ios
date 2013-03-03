//
//  GAppDelegate.h
//  goagent-ios
//
//  Created by hewig on 6/3/12.
//  Copyright (c) 2012 goagent project. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iniparser.h"

@interface GAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic,strong) UIWindow *window;

+ (GAppDelegate*)getInstance;
+ (dictionary*)loadGoAgentSettings;
- (void)showAlert:(NSString*)message withTitle:(NSString*)title;
@end
