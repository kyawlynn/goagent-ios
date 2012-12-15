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

@implementation GUtility

+(BOOL) runTaskWithArgs:(NSMutableArray *)args taskType:(enum GTaskType)type waitExit:(BOOL)waitExit
{
    if (args == nil)
    {
        return NO;
    }
    //NSString* workingDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //we are running as root now
    NSString* workingDir = GOAGENT_HOME;
    NSLog(@"working dir is %@",workingDir);
    @try
    {
        NSTask* task = [NSTask alloc];
        if (type == PythonTask) {
            //[task setLaunchPath:[NSString stringWithFormat:@"%@/python/bin/python",workingDir]];
            [args insertObject:[NSString stringWithFormat:@"%@/python/bin/python",workingDir] atIndex:0];
            [task setEnvironment:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@/python",workingDir] forKey:@"PYTHONHOME"]];
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
        NSLog(@"NSTask error occured, exception is %@, args is %@",exception,args);
        return NO;
    }

    return YES;
}
@end