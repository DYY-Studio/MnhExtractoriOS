TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Reader(Sony)

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libssziparchive

libssziparchive_FILES = $(wildcard ZipArchive/SSZipArchive/*.m) $(wildcard ZipArchive/SSZipArchive/minizip/*.c) $(wildcard ZipArchive/SSZipArchive/minizip/compat/*.c)

libssziparchive_CFLAGS = -fobjc-arc -Os -DHAVE_ZLIB -DHAVE_WZAES -DZLIB_COMPAT -IZipArchive/SSZipArchive -IZipArchive/SSZipArchive/minizip -IZipArchive/SSZipArchive/minizip/compat
libssziparchive_LIBRARIES = z iconv

libssziparchive_LINKAGE_TYPE := static
libssziparchive_INSTALL := 0

include $(THEOS_MAKE_PATH)/library.mk

TWEAK_NAME = readersonydumper

readersonydumper_FILES = Tweak.x
readersonydumper_CFLAGS = -fobjc-arc

ifneq ($(DEBUG), 0)
	readersonydumper_CFLAGS += -O0
else
	readersonydumper_CFLAGS += -Os
endif

readersonydumper_FRAMEWORKS = UIKit
readersonydumper_OBJ_FILES = $(THEOS_OBJ_DIR)/libssziparchive.a

include $(THEOS_MAKE_PATH)/tweak.mk
