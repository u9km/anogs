TARGET := iphone:clang:latest:7.0
ARCHS = arm64

DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

TWEAK_NAME = AnogsTitanium

# إضافة fishhook.c هنا ضروري جداً 👇
AnogsTitanium_FILES = Tweak.xm fishhook.c
AnogsTitanium_FRAMEWORKS = UIKit Foundation Security
AnogsTitanium_LIBRARIES = z c++
AnogsTitanium_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
