TARGET := iphone:clang:latest:7.0
ARCHS = arm64

DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

TWEAK_NAME = AnogsTitanium

AnogsTitanium_FILES = Tweak.xm
AnogsTitanium_FRAMEWORKS = UIKit Foundation Security
AnogsTitanium_LIBRARIES = z c++

AnogsTitanium_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
AnogsTitanium_CCFLAGS = -std=c++11

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
