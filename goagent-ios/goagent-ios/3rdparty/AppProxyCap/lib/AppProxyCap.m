//
//  AppProxyCap.m
//  AppProxyCap
//
//  Created by Du Song on 11-10-22.
//  Copyright (c) 2011年 FreeWheel Inc. All rights reserved.
//

#import "AppProxyCap.h"
#import "interpose.h"
#include <SystemConfiguration/SCDynamicStore.h> 
#include <SystemConfiguration/SCSchemaDefinitions.h> 

@implementation AppProxyCap

typedef CFDictionaryRef (*_SCDynamicStoreCopyProxies) (SCDynamicStoreRef store);
static _SCDynamicStoreCopyProxies origin_SCDynamicStoreCopyProxies;

static bool activated = NO;
static NSDictionary *proxyPref = NULL;
extern CFDictionaryRef SCDynamicStoreCopyProxies (SCDynamicStoreRef store);
static CFDictionaryRef new_SCDynamicStoreCopyProxies (SCDynamicStoreRef store) {
	if (!activated || !proxyPref) 
		return origin_SCDynamicStoreCopyProxies(store);
	NSLog(@"AppProxyCap: proxify configuration applied: %@", proxyPref);
	return CFDictionaryCreateCopy(NULL, (CFDictionaryRef)proxyPref);
}

+ (void) activate {
	if (activated) return;
	activated = YES;
	origin_SCDynamicStoreCopyProxies = &SCDynamicStoreCopyProxies;
	if (!interpose("_SCDynamicStoreCopyProxies", new_SCDynamicStoreCopyProxies)) NSLog(@"AppProxyCap: error override _SCDynamicStoreCopyProxies");
}

+ (void) setProxy:(AppProxyType)type Host:(NSString *)host Port:(int)port {
	//[proxyPref release];
	switch (type) {
		case AppProxy_HTTP:
			proxyPref = [[NSDictionary alloc] initWithObjectsAndKeys:
							//[NSNumber numberWithInt:1], @"HTTPProxyType",
							//[NSNumber numberWithInt:0], @"ProxyAutoConfigEnable",
							[NSNumber numberWithInt:1], @"HTTPEnable",
							host, @"HTTPProxy",
							[NSNumber numberWithInt:port], @"HTTPPort",
							[NSNumber numberWithInt:1], @"HTTPSEnable",
							host, @"HTTPSProxy",
							[NSNumber numberWithInt:port], @"HTTPSPort",
							nil];

			break;
        case AppProxy_SOCKS:
			proxyPref = [[NSDictionary alloc ]initWithObjectsAndKeys:
                          [NSNumber numberWithInt:1], @"SOCKSEnable",
                          host, @"SOCKSProxy",
                          [NSNumber numberWithInt:port], @"SOCKSPort",
                          nil];
            break;
            
			
		default:
			/*
			proxyType = NULL;
			proxySetting = NULL;
			 */
			proxyPref = NULL;
			break;
	}
}

@end
