TARGET := iphone:clang:latest:15.0
ARCHS = arm64
GO_EASY_ON_ME = 1

# هذه الإعدادات تضمن أن الملف الناتج (dylib) يعمل بشكل مستقل
DEBUG = 0
FINALPACKAGE = 1

TWEAK_NAME = AnogsTitanium
AnogsTitanium_FILES = Tweak.xm

# إضافة مكتبات النظام الأساسية فقط
AnogsTitanium_FRAMEWORKS = UIKit Foundation

# إعدادات الأمان
AnogsTitanium_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -O3

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
