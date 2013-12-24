TARGET = :clang
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = RadiSpot
RadiSpot_FILES = Tweak.xm
RadiSpot_FRAMEWORKS = UIKit

RESPRING = 0

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support/RadiSpot.bundle
	cp -r Resources/* $(THEOS_STAGING_DIR)/Library/Application\ Support/RadiSpot.bundle
