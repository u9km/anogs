TARGET := iphone:clang:latest:14.0
ARCHS = arm64

DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

TWEAK_NAME = AnogsTitanium

AnogsTitanium_FILES = Tweak.xm
AnogsTitanium_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -O3
AnogsTitanium_CCFLAGS = -std=c++11 -O3

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
