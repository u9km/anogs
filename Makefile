# تعريف مسار Theos إذا لم يكن معرفاً في النظام
THEOS ?= /opt/theos
ifeq ($(THEOS),)
  $(error "مسار THEOS غير معرف. يرجى تثبيت Theos أو ضبط المتغير THEOS")
endif

# إعدادات المعمارية والهدف لعام 2026
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
DEBUG = 0
FINALPACKAGE = 1

# اسم الأداة والملفات المصدرية من SHADOWBREAKER
TWEAK_NAME = TitaniumFortress
TitaniumFortress_FILES = Tweak.xm
TitaniumFortress_CFLAGS = -fobjc-arc -O3

# المكتبات المطلوبة للتشغيل بدون كراش
TitaniumFortress_FRAMEWORKS = UIKit Foundation Security QuartzCore
TitaniumFortress_LIBRARIES = z c++

# إعدادات الربط المتقدمة لتجاوز قيود iOS 18+
TitaniumFortress_LDFLAGS = -Wl,-segalign,0x4000

# حذف الرموز البرمجية لمنع الهندسة العكسية
TitaniumFortress_STRIP_EXPORTS = YES

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 ShadowTrackerExtra"
