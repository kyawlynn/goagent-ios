//
//  GAppDelegate.m
//  goagent-ios
//
//  Created by hewig on 6/3/12.
//  Copyright (c) 2012 goagent project. All rights reserved.
//

#import "GAppDelegate.h"
#import "GConfig.h"
#import "iniparser.h"

#import <Crashlytics/Crashlytics.h>

static dictionary* iniDic = NULL;

@implementation GAppDelegate

@synthesize window = _window;

-(void)dealloc
{
    if (iniDic) {
        iniparser_freedict(iniDic);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    freopen([GOAGENT_LOCAL_LOG UTF8String],"a",stderr);
    NSLog(@"redirect logs to %@", GOAGENT_LOCAL_LOG);
    [Crashlytics startWithAPIKey:@"00294b074c27a6569db329a72df442fbff108a8c"];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [_window.rootViewController viewWillAppear:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

+ (GAppDelegate*)getInstance
{
    return [[UIApplication sharedApplication] delegate];
}

+ (dictionary*)loadGoAgentSettings
{
    if (iniDic) {
        return iniDic;
    }
    else{
        NSString* iniFile = [[NSBundle mainBundle] pathForResource:CONFIG_FILE_NAME
                                                            ofType:CONFIG_FILE_TYPE
                                                       inDirectory:GOAGENT_LOCAL_PATH];
        iniDic = iniparser_load([iniFile UTF8String]);
        return iniDic;
    }
}

- (void)showAlert:(NSString*)message withTitle:(NSString*)title;
{
    UIAlertView *baseAlert = [[UIAlertView alloc]
							  initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[baseAlert show];
}

@end
