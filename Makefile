ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

SovereignSecurity_FILES = Tweak.xm main.cpp SovereignSecurity.m
SovereignSecurity_FRAMEWORKS = UIKit Foundation OpenGLES GLKit
SovereignSecurity_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
SovereignSecurity_CCFLAGS = -std=c++17 -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"