TARGET := iphone:clang:latest:7.0
ARCHS = arm64
GO_EASY_ON_ME = 1

DEBUG = 0
FINALPACKAGE = 1

TWEAK_NAME = AnogsTitanium
AnogsTitanium_FILES = Tweak.xm
AnogsTitanium_FRAMEWORKS = UIKit Foundation
AnogsTitanium_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -O3

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
