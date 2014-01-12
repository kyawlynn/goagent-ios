import ConfigParser

PROXY_CONFIG='/Applications/goagent-ios.app/goagent-local/proxy.ini'
BACKUP_CONFIG='/tmp/proxy.ini.bak'

def restore_setting(backupFile):
    config = ConfigParser.ConfigParser()
    config.read(backupFile)
    bak_appid   =  config.get('gae','appid')
    bak_profile = config.get('gae','profile')
    bak_pac     = config.getint('pac','enable')

    config.read(PROXY_CONFIG)
    config.set('gae','appid',bak_appid)
    config.set('gae','profile',bak_profile)
    config.set('pac','enable',bak_pac)

    with open(PROXY_CONFIG,'wb') as configfile:
        config.write(configfile)

if __name__ == '__main__':
    restore_setting(BACKUP_CONFIG)
