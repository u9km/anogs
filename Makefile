TARGET := iphone:clang:latest:15.0
ARCHS = arm64
GO_EASY_ON_ME = 1
DEBUG = 0
FINALPACKAGE = 1

TWEAK_NAME = TitaniumInfinity
TitaniumInfinity_FILES = Tweak.xm
TitaniumInfinity_FRAMEWORKS = UIKit Foundation Security
TitaniumInfinity_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -O3

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
