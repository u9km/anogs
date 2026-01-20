# إعدادات المعمارية والهدف (iOS 15.0+ لضمان توافق arm64e)
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
DEBUG = 0
FINALPACKAGE = 1

# اسم الأداة والملفات المصدرية
TWEAK_NAME = TitaniumFortress
TitaniumFortress_FILES = Tweak.xm
TitaniumFortress_CFLAGS = -fobjc-arc -O3

# المكتبات والإطارات الأمنية والرسومية المطلوبة
TitaniumFortress_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics
TitaniumFortress_LIBRARIES = z c++

# إعدادات الربط المتقدمة (LDFLAGS) لتجاوز القيود
TitaniumFortress_LDFLAGS = -Wl,-segalign,0x4000

# منع اللعبة من كشف الأداة عبر البحث عن الرموز (Symbols)
TitaniumFortress_STRIP_EXPORTS = YES

include $(THEOS_MAKE_PATH)/tweak.mk

# تنظيف الكاش وإعادة تشغيل العملية بعد التثبيت
after-install::
	install.exec "killall -9 ShadowTrackerExtra"
