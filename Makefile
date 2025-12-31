ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

# دمج جميع الملفات المصدرية لضمان عمل النظام بالكامل
SovereignSecurity_FILES = Tweak.xm SovereignSecurity.m
SovereignSecurity_FRAMEWORKS = UIKit Foundation OpenGLES GLKit
SovereignSecurity_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
SovereignSecurity_CCFLAGS = -std=c++17 -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
