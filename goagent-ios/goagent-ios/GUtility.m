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

+(BOOL)setProxyForDynamicStore
{
    BOOL result = NO;
    
    NSLog(@"==> setProxyForDynamicStore");
    
    void* libHandle = dlopen("/System/Library/Frameworks/SystemConfiguration.framework/SystemConfiguration", RTLD_LAZY);
    if (!libHandle) {
        NSLog(@"<== dlopen SystemConfiguration failed");
        return result;
    }
    
    // Set dynamic store, current proxy
    SCDynamicStoreRef
    (*_SCDynamicStoreCreate)(CFAllocatorRef,CFStringRef,SCDynamicStoreCallBack,SCDynamicStoreContext*)
    = dlsym(libHandle, "SCDynamicStoreCreate");
    CFStringRef(*_SCDynamicStoreKeyCreateProxies)(CFAllocatorRef)
    = dlsym(libHandle, "SCDynamicStoreKeyCreateProxies");
    Boolean
    (*_SCDynamicStoreSetValue)(SCDynamicStoreRef,CFStringRef,CFPropertyListRef)
    = dlsym(libHandle, "SCDynamicStoreSetValue");
    CFDictionaryRef(*_SCDynamicStoreCopyProxies)(SCDynamicStoreRef)
    = dlsym(libHandle, "SCDynamicStoreCopyProxies");
    
    SCDynamicStoreRef dynamicStore = _SCDynamicStoreCreate(NULL, CFSTR("goagent-ios"), NULL, NULL);
    CFDictionaryRef dynamicProxies = _SCDynamicStoreCopyProxies(dynamicStore);
    CFStringRef proxyKey = _SCDynamicStoreKeyCreateProxies(NULL);
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary*)dynamicProxies];
    
    dict[@"HTTPSEnable"] = @NO;
    dict[@"HTTPEnable"] = @NO;
    dict[@"ProxyAutoConfigEnable"] = @YES;
    dict[@"ProxyAutoConfigURLString"] = @"http://127.0.0.1:8086/proxy.pac";
    
    // should be only one
    if (dict.count == 1) {
        NSArray* keys = [dict[@"__SCOPED__"] allKeys];
        NSString* key = [keys firstObject];
        NSLog(@"==> check %@",key);
        NSMutableDictionary* interDict = [dict[@"__SCOPED__"][key] mutableCopy];
        interDict[@"HTTPSEnable"] = @NO;
        interDict[@"HTTPEnable"] = @NO;
        interDict[@"ProxyAutoConfigEnable"] = @YES;
        interDict[@"ProxyAutoConfigURLString"] = @"http://127.0.0.1:8086/proxy.pac";
        [dict setValue:interDict forKeyPath:[NSString stringWithFormat:@"__SCOPED__.%@",key]];
    }
    
    NSLog(@"==> previous dynamicStore proxy:%@",(__bridge NSDictionary*)dynamicProxies);
    NSLog(@"==> set dynamicStore proxy with:%@",dict);
    if(_SCDynamicStoreSetValue(dynamicStore, proxyKey, (__bridge CFPropertyListRef)dict)){
        NSLog(@"<== set current proxy successfully");
    } else{
        NSLog(@"<== set current proxy failed");
    }
    
    CFRelease(proxyKey);
    CFRelease(dynamicProxies);
    CFRelease(dynamicStore);
    
    dlclose(libHandle);
    
    return result;
}

+(BOOL) setProxyForPreferences
{
    BOOL result = NO;
    
    NSLog(@"==> setProxyForPreferences");
    
    void* libHandle = dlopen("/System/Library/Frameworks/SystemConfiguration.framework/SystemConfiguration", RTLD_LAZY);
    if (!libHandle) {
        NSLog(@"<== dlopen SystemConfiguration failed");
        return result;
    }

    //set preference file
    SCPreferencesRef(*_SCPreferencesCreate)(CFAllocatorRef,CFStringRef,CFStringRef)
        = dlsym(libHandle, "SCPreferencesCreate");
    CFPropertyListRef(*_SCPreferencesGetValue)(SCPreferencesRef,CFStringRef)
        = dlsym(libHandle, "SCPreferencesGetValue");
    
    Boolean(*_SCPreferencesSetValue)(SCPreferencesRef,CFStringRef,CFPropertyListRef)
        = dlsym(libHandle, "SCPreferencesSetValue");
    Boolean(*_SCPreferencesApplyChanges)(SCPreferencesRef)
        = dlsym(libHandle, "SCPreferencesApplyChanges");
    Boolean(*_SCPreferencesCommitChanges)(SCPreferencesRef)
        = dlsym(libHandle, "SCPreferencesCommitChanges");
    void(*_SCPreferencesSynchronize)(SCPreferencesRef)
        = dlsym(libHandle, "SCPreferencesSynchronize");
    
    SCPreferencesRef preferenceRef = _SCPreferencesCreate(NULL, CFSTR("goagent-ios"), NULL);
    CFPropertyListRef networkServices = _SCPreferencesGetValue(preferenceRef, CFSTR("NetworkServices"));
    NSDictionary* services = (__bridge NSDictionary*)networkServices;
    
    for (NSString* key in [services allKeys]) {
        NSLog(@"==> check device:%@", key);
        NSMutableDictionary* obj = [services[key] mutableCopy];
        NSString* hardware = [obj valueForKeyPath:@"Interface.Hardware"];
        
        if ([hardware isEqualToString:@"AirPort"] || [hardware isEqualToString:@"com.apple.CommCenter"]) {
            NSDictionary* proxies = [obj valueForKey:@"Proxies"];
            //NSLog(@"<== previous proxy:%@", proxies);
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
                //NSLog(@"==> set interface:%@ with proxy:%@",[obj valueForKeyPath:@"Interface"], dict);
                if(_SCPreferencesSetValue(preferenceRef, (__bridge CFStringRef)key, (__bridge CFPropertyListRef)obj)){
                    NSLog(@"<== set proxy preference successfully");
                } else{
                    NSLog(@"<== set proxy preference failed");
                }
            }
            @catch (NSException *exception) {
                NSLog(@"<== set proxy preference failed:%@",[exception description]);
            }
        }
    }
    
    if(_SCPreferencesCommitChanges(preferenceRef)) {
        NSLog(@"<== commit proxy preference changes successfully");
        if(_SCPreferencesApplyChanges(preferenceRef)) {
            NSLog(@"<== apply proxy preference changes successfully");
            result = YES;
        } else {
            NSLog(@"<== apply proxy preference changes failed!");
        }
    } else {
        NSLog(@"<== commit proxy preference changes failed!");
    }
    _SCPreferencesSynchronize(preferenceRef);
    
    CFRelease(preferenceRef);
    dlclose(libHandle);
    
    return result;
}

@end