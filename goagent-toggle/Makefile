export TARGET=iphone:5.1
include theos/makefiles/common.mk

LIBRARY_NAME = Toggle
Toggle_FILES = GoagentToggle.mm
Toggle_INSTALL_PATH = /var/mobile/Library/SBSettings/Toggles/Goagent

include $(THEOS_MAKE_PATH)/library.mk

custom-package:all
	echo "packaging goagent-toggle";\
	rm -rf goagent-toggle.deb;\
	rm -rf deb-pkg-root/DEBIAN/control;\
	rm -rf deb-pkg-root/var/mobile/Library/SBSettings/Toggles/Goagent/Toggle.dylib;\
	cp -f control deb-pkg-root/DEBIAN/;\
	cp -f obj/Toggle.dylib deb-pkg-root/var/mobile/Library/SBSettings/Toggles/Goagent/;\
	dpkg-deb -b deb-pkg-root goagent-toggle.deb
