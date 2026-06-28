TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Reader(Sony)


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = readersonydumper

readersonydumper_FILES = Tweak.x
readersonydumper_CFLAGS = -fobjc-arc

ifneq ($(DEBUG), 0)
	readersonydumper_CFLAGS += -O0
else
	readersonydumper_CFLAGS += -Os
endif

include $(THEOS_MAKE_PATH)/tweak.mk
