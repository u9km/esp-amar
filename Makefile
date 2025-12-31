ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
# يتم الحقن داخل اللعبة مباشرة، لذا لا نحتاج لتعريف عمليات النظام
INSTALL_TARGET_PROCESSES = *

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

# ندمج ملف الـ Tweak مع محرك الحماية
SovereignSecurity_FILES = Tweak.xm SovereignSecurity.m
SovereignSecurity_FRAMEWORKS = UIKit Foundation Security QuartzCore
SovereignSecurity_CFLAGS = -fobjc-arc
SovereignSecurity_CCFLAGS = -std=c++17

include $(THEOS_MAKE_PATH)/tweak.mk
