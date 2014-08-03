DEVICE_IP=$(THEOS_DEVICE_IP)
DEVICE_IP?=192.168.1.13

APPS = goagent-ios

PKG_ROOT = package
APP_ROOT = $(PKG_ROOT)/Applications/goagent-ios.app
OUTPUT = output

PLIST_BUDDY = /usr/libexec/PlistBuddy

VERSION = $(shell grep Version $(PKG_ROOT)/DEBIAN/control | cut -d ":" -f2 | tr -d " ")
DEB_NAME = $(DEB_ID)_$(VERSION)_iphoneos-arm.deb 
DEB_ID = org.goagent.local.ios

.PHONY : $(APPS)

all: build_apps

build_apps:
	@for i in $(APPS) ; do \
		echo "building [$$i]" ; \
		make -C $$i || exit 1; \
	done

install: all
	@for i in $(APPS) ; do \
		echo "install [$$i] to $(PKG_ROOT) dir" ; \
		make -C $$i custom-install || exit 1; \
	done

package: install
	@echo "*** packaging $(DEB_NAME)"
	rm -Rf $(OUTPUT)/*.deb
	$(PLIST_BUDDY) -c "Set :CFBundleShortVersionString $(VERSION)" $(APP_ROOT)/Info.plist
	@if [ ! -e $(APP_ROOT)/goagent-ios_ ]; \
	then \
		mv $(APP_ROOT)/goagent-ios $(APP_ROOT)/goagent-ios_ ; \
		mv $(APP_ROOT)/goagent $(APP_ROOT)/goagent-ios ; \
	fi;
	extra/dpkg-deb -b $(PKG_ROOT) $(OUTPUT)/$(DEB_NAME)
	@echo "packaging done"

deploy: 
	@#ssh -p 22 root\@$(DEVICE_IP) "dpkg -r $(DEB_ID)" ;
	scp $(OUTPUT)/$(DEB_NAME) root\@$(DEVICE_IP):~/; \
	ssh -p 22 root\@$(DEVICE_IP) "dpkg -i ~/$(DEB_NAME)" ; \

clean:
	@for i in $(APPS) ; do \
		echo "cleaning $$i" ; \
		make -C $$i clean || exit 1; \
		rm -rf $$PRJDIR/build ; \
	done
	echo "cleaning $(PKG_ROOT)"
	rm -Rf $(PKG_ROOT)/Applications
	rm -Rf $(PKG_ROOT)/Library
	rm -Rf $(OUTPUT)/*.deb
