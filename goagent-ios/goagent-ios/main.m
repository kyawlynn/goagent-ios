//
//  main.m
//  goagent-ios
//
//  Created by hewig on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        if(!setuid(0)){
            NSLog(@"goagent is not running as root!");
        };
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([GAppDelegate class]));
    }
}
