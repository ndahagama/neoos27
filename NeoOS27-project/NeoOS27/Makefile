ARCHS = arm64
TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NeoOS27
NeoOS27_FILES = Tweak.xm
NeoOS27_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
NeoOS27_FRAMEWORKS = UIKit QuartzCore
NeoOS27_PRIVATE_FRAMEWORKS = SpringBoardServices
NeoOS27_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

ifeq ($(ROOTLESS),1)
  THEOS_PACKAGE_SCHEME = rootless
endif

include $(THEOS_MAKE_PATH)/aggregate.mk
