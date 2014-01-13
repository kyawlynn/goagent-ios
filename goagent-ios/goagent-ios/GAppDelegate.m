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

+ (GAppDelegate*)getInstance
{
    return [[UIApplication sharedApplication] delegate];
}

+ (dictionary*)loadGoAgentSettings
{
    if (iniDic)
    {
        NSLog(@"<== load proxy.ini from memory");
        return iniDic;
    }
    else
    {
        NSString* iniFile = [[NSBundle mainBundle] pathForResource:CONFIG_FILE_NAME
                                                            ofType:CONFIG_FILE_TYPE
                                                       inDirectory:GOAGENT_LOCAL_PATH];
        iniDic = iniparser_load([iniFile UTF8String]);
        NSLog(@"<== load proxy.ini from file");
        return iniDic;
    }
}

-(void)dealloc
{
    if (iniDic) {
        iniparser_freedict(iniDic);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSLog(@"==> GoAgent iOS finish launching, version:%@", infoDict[@"CFBundleShortVersionString"]);

#ifndef DEBUG
    NSLog(@"==> redirect logs to %@", GOAGENT_LOCAL_LOG);
    freopen([GOAGENT_LOCAL_LOG UTF8String],"a",stderr);
#endif

    [Crashlytics startWithAPIKey:@"00294b074c27a6569db329a72df442fbff108a8c"];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [_window.rootViewController viewWillAppear:YES];
}

- (void)showAlert:(NSString*)message withTitle:(NSString*)title;
{
    UIAlertView *baseAlert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
	[baseAlert show];
}

@end
