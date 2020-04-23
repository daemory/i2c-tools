# Copyright 2005 The Android Open Source Project
#
# Android.mk for adb
#

LOCAL_PATH:= $(call my-dir)

#include $(LOCAL_PATH)/../platform_tools_tool_version.mk

adb_host_sanitize :=
adb_target_sanitize :=

ADB_COMMON_CFLAGS := \
    -frtti \
    -Wall -Wextra -Werror \
    -Wno-unused-parameter \
    -Wno-missing-field-initializers \
    -Wvla \
    -DADB_VERSION="\"$(tool_version)\"" \

ADB_COMMON_posix_CFLAGS := \
    -Wexit-time-destructors \
    -Wthread-safety \

ADB_COMMON_linux_CFLAGS := \
    $(ADB_COMMON_posix_CFLAGS) \

ADB_COMMON_darwin_CFLAGS := \
    $(ADB_COMMON_posix_CFLAGS) \

# Define windows.h and tchar.h Unicode preprocessor symbols so that
# CreateFile(), _tfopen(), etc. map to versions that take wchar_t*, breaking the
# build if you accidentally pass char*. Fix by calling like:
#   std::wstring path_wide;
#   if (!android::base::UTF8ToWide(path_utf8, &path_wide)) { /* error handling */ }
#   CreateFileW(path_wide.c_str());
ADB_COMMON_windows_CFLAGS := \
    -DUNICODE=1 -D_UNICODE=1 \
    -D_POSIX_SOURCE

# libadb
# =========================================================

# Much of adb is duplicated in bootable/recovery/minadb and fastboot. Changes
# made to adb rarely get ported to the other two, so the trees have diverged a
# bit. We'd like to stop this because it is a maintenance nightmare, but the
# divergence makes this difficult to do all at once. For now, we will start
# small by moving common files into a static library. Hopefully some day we can
# get enough of adb in here that we no longer need minadb. https://b/17626262
LIBADB_SRC_FILES := \
    adb.cpp \
    adb_io.cpp \
    adb_listeners.cpp \
    adb_trace.cpp \
    adb_utils.cpp \
    fdevent.cpp \
    sockets.cpp \
    socket_spec.cpp \
    sysdeps/errno.cpp \
    transport.cpp \
    transport_local.cpp \
    transport_usb.cpp \

LIBADB_TEST_SRCS := \
    adb_io_test.cpp \
    adb_listeners_test.cpp \
    adb_utils_test.cpp \
    fdevent_test.cpp \
    socket_spec_test.cpp \
    socket_test.cpp \
    sysdeps_test.cpp \
    sysdeps/stat_test.cpp \
    transport_test.cpp \

LIBADB_CFLAGS := \
    $(ADB_COMMON_CFLAGS) \
    -fvisibility=hidden \

LIBADB_linux_CFLAGS := \
    $(ADB_COMMON_linux_CFLAGS) \

LIBADB_darwin_CFLAGS := \
    $(ADB_COMMON_darwin_CFLAGS) \

LIBADB_windows_CFLAGS := \
    $(ADB_COMMON_windows_CFLAGS) \

LIBADB_darwin_SRC_FILES := \
    sysdeps_unix.cpp \
    sysdeps/posix/network.cpp \
    client/usb_dispatch.cpp \
    client/usb_libusb.cpp \
    client/usb_osx.cpp \

LIBADB_linux_SRC_FILES := \
    sysdeps_unix.cpp \
    sysdeps/posix/network.cpp \
    client/usb_dispatch.cpp \
    client/usb_libusb.cpp \
    client/usb_linux.cpp \

LIBADB_windows_SRC_FILES := \
    sysdeps_win32.cpp \
    sysdeps/win32/errno.cpp \
    sysdeps/win32/stat.cpp \
    client/usb_dispatch.cpp \
    client/usb_libusb.cpp \
    client/usb_windows.cpp \

LIBADB_TEST_windows_SRCS := \
    sysdeps/win32/errno_test.cpp \
    sysdeps_win32_test.cpp \

#remove by xiwang.dang =====start=======
#include $(CLEAR_VARS)
#LOCAL_MODULE := libadbd_usb
#LOCAL_CFLAGS := $(LIBADB_CFLAGS) -DADB_HOST=0
#LOCAL_SRC_FILES := daemon/usb.cpp

#LOCAL_SANITIZE := $(adb_target_sanitize)

# Even though we're building a static library (and thus there's no link step for
# this to take effect), this adds the includes to our path.
#LOCAL_STATIC_LIBRARIES := libcrypto_utils libcrypto libbase libasyncio

#include $(BUILD_STATIC_LIBRARY)
#remove by xiwang.dang =====end=======


#add 20200423
#start commit id:0cadafa030496f913dc44ace38513dc57db15c4e
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    tools/i2cdetect.c \
    lib/smbus.c \
    tools/i2cbusses.c \

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/include \

LOCAL_CFLAGS := \
    $(ADB_COMMON_CFLAGS) \
    $(ADB_COMMON_linux_CFLAGS) \
    -DADB_HOST=0 \
    -D_GNU_SOURCE \
    -Wno-deprecated-declarations \

#remove by xiwang.dang =====start=======
#LOCAL_CFLAGS += -DALLOW_ADBD_NO_AUTH=$(if $(filter userdebug eng,$(TARGET_BUILD_VARIANT)),1,0)

#ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
#LOCAL_CFLAGS += -DALLOW_ADBD_DISABLE_VERITY=1
#LOCAL_CFLAGS += -DALLOW_ADBD_ROOT=1
#endif
#remove by xiwang.dang =====end=======

LOCAL_MODULE := i2cdetect

LOCAL_FORCE_STATIC_EXECUTABLE := true

LOCAL_SANITIZE := $(adb_target_sanitize)
LOCAL_STRIP_MODULE := keep_symbols
#remove by xiwang.dang =====start=======
#LOCAL_STATIC_LIBRARIES := \
#    libadbd \
#remove by xiwang.dang =====end=======

include $(BUILD_EXECUTABLE)


include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    tools/i2cdump.c \
    lib/smbus.c \
    tools/i2cbusses.c \
    tools/util.c \

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/include \

LOCAL_CFLAGS := \
    $(ADB_COMMON_CFLAGS) \
    $(ADB_COMMON_linux_CFLAGS) \
    -DADB_HOST=0 \
    -D_GNU_SOURCE \
    -Wno-deprecated-declarations \

LOCAL_MODULE := i2cdump

LOCAL_FORCE_STATIC_EXECUTABLE := true

LOCAL_SANITIZE := $(adb_target_sanitize)
LOCAL_STRIP_MODULE := keep_symbols

include $(BUILD_EXECUTABLE)


include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    tools/i2cget.c \
    lib/smbus.c \
    tools/i2cbusses.c \
    tools/util.c \

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/include \

LOCAL_CFLAGS := \
    $(ADB_COMMON_CFLAGS) \
    $(ADB_COMMON_linux_CFLAGS) \
    -DADB_HOST=0 \
    -D_GNU_SOURCE \
    -Wno-deprecated-declarations \

LOCAL_MODULE := i2cget

LOCAL_FORCE_STATIC_EXECUTABLE := true

LOCAL_SANITIZE := $(adb_target_sanitize)
LOCAL_STRIP_MODULE := keep_symbols

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    tools/i2cset.c \
    lib/smbus.c \
    tools/i2cbusses.c \
    tools/util.c \

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/include \

LOCAL_CFLAGS := \
    $(ADB_COMMON_CFLAGS) \
    $(ADB_COMMON_linux_CFLAGS) \
    -DADB_HOST=0 \
    -D_GNU_SOURCE \
    -Wno-deprecated-declarations \

LOCAL_MODULE := i2cset

LOCAL_FORCE_STATIC_EXECUTABLE := true

LOCAL_SANITIZE := $(adb_target_sanitize)
LOCAL_STRIP_MODULE := keep_symbols

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    tools/i2ctransfer.c \
    lib/smbus.c \
    tools/i2cbusses.c \
    tools/util.c \

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/include \

LOCAL_CFLAGS := \
    $(ADB_COMMON_CFLAGS) \
    $(ADB_COMMON_linux_CFLAGS) \
    -DADB_HOST=0 \
    -D_GNU_SOURCE \
    -Wno-deprecated-declarations \

LOCAL_MODULE := i2ctransfer

LOCAL_FORCE_STATIC_EXECUTABLE := true

LOCAL_SANITIZE := $(adb_target_sanitize)
LOCAL_STRIP_MODULE := keep_symbols

include $(BUILD_EXECUTABLE)
