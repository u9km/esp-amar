ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = *

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

# دمج الملفات وتجاهل التحذيرات المسببة للفشل
SovereignSecurity_FILES = Tweak.xm SovereignSecurity.m
SovereignSecurity_FRAMEWORKS = UIKit Foundation Security
SovereignSecurity_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
