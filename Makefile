ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
# استهداف أي عملية يتم الحقن داخلها
INSTALL_TARGET_PROCESSES = *

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

# نكتفي بملف التويك وملف الحماية المعدل
SovereignSecurity_FILES = Tweak.xm SovereignSecurity.m
SovereignSecurity_FRAMEWORKS = UIKit Foundation Security
SovereignSecurity_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
