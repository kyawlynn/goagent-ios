#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"

#import <sys/stat.h>

#define GOAGENT_PID "/var/mobile/goagent/goagent.pid"
#define GOAGENT_STOP "/var/mobile/goagent/stop"

@interface GoAgentSwitchSwitch : NSObject <FSSwitchDataSource>
@end

@implementation GoAgentSwitchSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	struct stat st;
    if(stat(GOAGENT_PID,&st) == 0) {
        return FSSwitchStateOn;
    } else{
        return FSSwitchStateOff;
    }
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
	if (newState == FSSwitchStateIndeterminate){
		return;
    }
    else if (newState == FSSwitchStateOn) {
        system("touch /var/mobile/goagent/goagent.pid");
    }
    else if (newState == FSSwitchStateOff) {
        system("echo 'stop' >> /var/mobile/goagent/stop");
    }
}

@end