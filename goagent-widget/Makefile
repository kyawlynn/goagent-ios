export THEOS_DEVICE_IP=192.168.1.231
# export TARGET=iphone:5.1
include theos/makefiles/common.mk

BUNDLE_NAME = goagentwidget
goagentwidget_FILES = goagentwidgetController.m iniparser/iniparser.c iniparser/dictionary.c
goagentwidget_INSTALL_PATH = /Library/WeeLoader/Plugins
goagentwidget_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/bundle.mk
custom-install: package
	# cp -Rf _/Library ../deb-pkg-root/
	echo "skip goagent notification center widget"

after-install::
	install.exec "killall -9 SpringBoard"
