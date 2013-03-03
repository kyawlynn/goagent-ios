//
//  GConfig.h
//  goagent-ios
//
//  Created by hewig on 8/10/12.
//  Copyright (c) 2012 goagent project. All rights reserved.
//

#ifndef goagent_ios_GConfig_h
#define goagent_ios_GConfig_h

#define CONFIG_FILE_NAME                @"proxy"
#define CONFIG_FILE_TYPE                @"ini"
#define GOAGENT_HOME                    @"/Applications/goagent-ios.app"
#define GOAGENT_LOCAL_PATH              @"goagent-local"
#define GOAGENT_PID_PATH                @"/var/mobile/goagent/goagent.pid"
#define GOAGENT_LOCAL_LOG               @"/var/mobile/goagent/goagent-ios.log"
#define GOAGENT_LOG                     @"/var/mobile/goagent/goagent.log"
#define CONTROL_SCRIPT_NAME             @"proxy"
#define CONTROL_SCRIPT_TYPE             @"sh"
#define CONTROL_SCRIPT_PY               @"py"
#define CONTROL_CMD_START               @"start"
#define CONTROL_CMD_STOP                @"stop"
#define CONTROL_CMD_RESTART             @"restart"
#define CHANGE_SYSPROXY_SCRIPT          @"change_sysproxy"

#define KEY_SETTING_BASIC               @"Basic"
#define KEY_SETTING_CUSTOM              @"Custom URL"
#define KEY_SETTING_ADVANCED            @"Advanced"
#define KEY_SETTING_APPID               @"AppID"
#define KEY_SETTING_PROFILE             @"GAE Profile"
#define KEY_SETTING_PAC                 @"PAC Server"
#define KEY_SETTING_SET_SYSPROXY        @"Change System Proxy"
#define KEY_SETTING_INSTALL_CERT        @"Install GoAgent CA"
#define KEY_SETTING_OPEN_LOCAL_LOG      @"Open GoAgent iOS Log"
#define KEY_SETTING_OPEN_LOG            @"Open GoAgent Log"

#define APPLICATION_NAME                @"GoAgent for iOS"
#define LOCAL_CA_URL                    @"http://127.0.0.1:8086/CA.crt"
#define REMOTE_CA_URL                   @"http://goagent.googlecode.com/files/CA.crt"
#define GOAGENT_HOME_PAGE               @"http://www.goagent.org"

#endif
