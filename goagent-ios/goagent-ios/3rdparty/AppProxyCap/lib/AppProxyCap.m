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
			proxyPref = @{@"HTTPEnable": @1,
							@"HTTPProxy": host,
							@"HTTPPort": @(port),
							@"HTTPSEnable": @1,
							@"HTTPSProxy": host,
							@"HTTPSPort": @(port)};

			break;
        case AppProxy_SOCKS:
			proxyPref = @{@"SOCKSEnable": @1,
                          @"SOCKSProxy": host,
                          @"SOCKSPort": @(port)};
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
