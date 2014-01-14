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
#define GOAGENT_JOB_LABEL               @"org.goagent.local.ios"
#define GOAGENT_STOP_LABEL              @"org.goagent.local.ios.stop"
#define GOAGENT_HOME                    @"/Applications/goagent-ios.app"
#define GOAGENT_LOCAL_PATH              @"goagent-local"
#define GOAGENT_PID_PATH                @"/var/mobile/goagent/goagent.pid"
#define GOAGENT_LOCAL_LOG               @"/var/mobile/goagent/goagent-ios.log"
#define GOAGENT_LOG                     @"/var/mobile/goagent/goagent.log"
#define CONTROL_SCRIPT_NAME             @"proxy"
#define CONTROL_SCRIPT_PY               @"py"
#define CONTROL_CMD_START               @"start"
#define CONTROL_CMD_STOP                @"stop"
#define CONTROL_CMD_RESTART             @"restart"

#define KEY_SETTING_BASIC               @"KEY_SETTING_BASIC"
#define KEY_SETTING_CUSTOM              @"KEY_SETTING_CUSTOM"
#define KEY_SETTING_ADVANCED            @"KEY_SETTING_ADVANCED"
#define KEY_SETTING_APPID               @"KEY_SETTING_APPID"
#define KEY_SETTING_PROFILE             @"KEY_SETTING_PROFILE"
#define KEY_SETTING_MODE                @"KEY_SETTING_MODE"
#define KEY_SETTING_PAC                 @"KEY_SETTING_PAC"
#define KEY_SETTING_SET_SYSPROXY        @"KEY_SETTING_SET_SYSPROXY"
#define KEY_SETTING_INSTALL_CERT        @"KEY_SETTING_INSTALL_CERT"
#define KEY_SETTING_INSTALL_APN         @"KEY_SETTING_INSTALL_APN"
#define KEY_SETTING_OPEN_LOCAL_LOG      @"KEY_SETTING_OPEN_LOCAL_LOG"
#define KEY_SETTING_OPEN_LOG            @"KEY_SETTING_OPEN_LOG"
#define APPLICATION_NAME                @"APPLICATION_NAME"

#define LOCAL_CA_URL                    @"http://127.0.0.1:8086/CA.crt"
#define REMOTE_CA_URL                   @"https://github.com/goagent/goagent/raw/3.0/local/CA.crt"
#define REMOTE_APN_TELECOM              @"https://github.com/goagent/goagent-ios/raw/master/extra/apns/ChinaTelecom.mobileconfig"
#define REMOTE_APN_MOBILE               @"https://github.com/goagent/goagent-ios/raw/master/extra/apns/ChinaMobile.mobileconfig"
#define REMOTE_APN_UNICOM               @"https://github.com/goagent/goagent-ios/raw/master/extra/apns/ChinaUnicom.mobileconfig"
#define GOAGENT_HOME_PAGE               @"http://www.goagent.org"

#endif
