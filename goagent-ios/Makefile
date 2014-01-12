DSTROOT=../package

PROJECT=goagent-ios.xcodeproj
TARGETS=goagent-ios
XCODEBUILD=/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild 
CONFIGURATION=Release
BUILD_SDK=iphoneos5.1

.PHONY: all
all: goagent-ios	

.PHONY: $(TARGETS)
$(TARGETS):
	@echo "*** building $@"
	$(XCODEBUILD) -project $(PROJECT) -configuration $(CONFIGURATION) -target $@ build
	
.PHONY: clean
clean:
	@for i in $(TARGETS); do \
	echo "*** cleaning $$i"; \
	$(XCODEBUILD) -project $(PROJECT) -configuration $(CONFIGURATION) -target $$i clean; \
	done

.PHONY: install
install: $(TARGETS)
	@for i in $(TARGETS); do \
	echo "*** installing $$i"; \
	$(XCODEBUILD) DSTROOT=$(DSTROOT) -project $(PROJECT) -configuration $(CONFIGURATION) -target $$i install; \
	done

.PHONY: custom-install
custom-install: 
	@for i in $(TARGETS); do \
	echo "*** installing $$i"; \
	mkdir -p $(DSTROOT)/Applications; \
	cp -Rf build/$(CONFIGURATION)-iphoneos/$$i.app $(DSTROOT)/Applications/ ;\
	done

.PHONY: package
package:
	
