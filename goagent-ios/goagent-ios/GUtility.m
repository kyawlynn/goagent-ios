//
//  GUtility.m
//  goagent-ios
//
//  Created by hewig on 8/15/12.
//  Copyright (c) 2012 goagent project. All rights reserved.
//

#import "GUtility.h"
#import "NSTask.h"
#import "GConfig.h"

#import <dlfcn.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation GUtility

+(BOOL) runTaskWithArgs:(NSMutableArray *)args taskType:(enum GTaskType)type waitExit:(BOOL)waitExit
{
    if (args == nil)
    {
        return NO;
    }
    
    //we are running as root now
    NSString* workingDir = GOAGENT_HOME;
    @try
    {
        NSTask* task = [NSTask alloc];
        if (type == PythonTask) {
            [args insertObject:[NSString stringWithFormat:@"%@/python/bin/python",workingDir] atIndex:0];
            [task setEnvironment:@{@"PYTHONHOME": [NSString stringWithFormat:@"%@/python",workingDir]}];
        }
        else{
            [args insertObject:@"/bin/sh" atIndex:0];
        }
        [task setLaunchPath:[NSString stringWithFormat:@"%@/authrunner",workingDir]];
        [task setArguments:args];
        [task setCurrentDirectoryPath:workingDir];
        [task launch];
        if (waitExit)
        {
            [task waitUntilExit];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"<== NSTask error occured, exception:%@, args:%@",[exception description],args);
        return NO;
    }

    return YES;
}

+(BOOL) setSystemProxy
{
    BOOL result = NO;
    
    NSLog(@"==> setSystemProxy");
    
    void* libHandle = dlopen("/System/Library/Frameworks/SystemConfiguration.framework/SystemConfiguration", RTLD_LAZY);
    if (!libHandle) {
        NSLog(@"<== dlopen SystemConfiguration failed");
        return result;
    }
    SCPreferencesRef(*_SCPreferencesCreate)(CFAllocatorRef,CFStringRef,CFStringRef) = dlsym(libHandle, "SCPreferencesCreate");
    CFPropertyListRef(*_SCPreferencesGetValue)(SCPreferencesRef,CFStringRef) = dlsym(libHandle, "SCPreferencesGetValue");
    Boolean(*_SCPreferencesApplyChanges)(SCPreferencesRef) = dlsym(libHandle, "SCPreferencesApplyChanges");
    Boolean(*_SCPreferencesCommitChanges)(SCPreferencesRef) = dlsym(libHandle, "SCPreferencesCommitChanges");
    void(*_SCPreferencesSynchronize)(SCPreferencesRef) = dlsym(libHandle, "SCPreferencesSynchronize");
    
    SCPreferencesRef preferenceRef = _SCPreferencesCreate(NULL, CFSTR("goagent-ios"), NULL);
    CFPropertyListRef networkServices = _SCPreferencesGetValue(preferenceRef, CFSTR("NetworkServices"));
    NSMutableDictionary* services = (__bridge NSMutableDictionary*)networkServices;
    
    for (NSString* key in [services allKeys]) {
        NSMutableDictionary* obj = [services[key] mutableCopy];
        NSString* hardware = [obj valueForKeyPath:@"Interface.Hardware"];
        
        if ([hardware isEqualToString:@"AirPort"] || [hardware isEqualToString:@"com.apple.CommCenter"]) {
            NSDictionary* proxies = [obj valueForKey:@"Proxies"];
            NSLog(@"<== previous proxy:%@", proxies);
            NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:proxies];
            if (!dict[@"ExceptionsList"]) {
                dict[@"ExceptionsList"] = @[@"*.local",@"169.254/16",@"127.0.0.1"];
            }
            dict[@"HTTPSEnable"] = @NO;
            dict[@"HTTPEnable"] = @NO;
            dict[@"ProxyAutoConfigEnable"] = @YES;
            dict[@"ProxyAutoConfigURLString"] = @"http://127.0.0.1:8086/proxy.pac";
            [obj setObject:dict forKey:@"Proxies"];
            @try {
                NSLog(@"==> set interface:%@ with proxy:%@",[obj valueForKeyPath:@"Interface"], dict);
                services[key] = obj;
            }
            @catch (NSException *exception) {
                NSLog(@"<== set proxy dict failed:%@",[exception description]);
            }
        }
    }
    
    if(_SCPreferencesCommitChanges(preferenceRef)) {
        NSLog(@"<== commit proxy changes successfully");
        if(_SCPreferencesApplyChanges(preferenceRef)) {
            NSLog(@"<== apply proxy changes successfully");
            result = YES;
        } else {
            NSLog(@"<== commit proxy changes failed!");
        }
    } else {
        NSLog(@"<== commit proxy changes failed!");
    }
    _SCPreferencesSynchronize(preferenceRef);
    
    CFRelease(preferenceRef);
    dlclose(libHandle);
    
    return result;
}

@end