//
//  GUtility.h
//  goagent-ios
//
//  Created by hewig on 8/15/12.
//  Copyright (c) 2012 goagent project. All rights reserved.
//

#import <Foundation/Foundation.h>

enum GTaskType{
    ShellTask = 1,
    PythonTask
};

@interface GUtility : NSObject

+(BOOL) runTaskWithArgs:(NSMutableArray*)args taskType:(enum GTaskType)type waitExit:(BOOL)waitExit;
@end
