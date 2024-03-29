# Copyright (C) 2021 Paranoid Android
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# PixelBlaster Versioning.
$(call inherit-product, vendor/blaster/target/product/version.mk)

BLASTER_DEVICE := $(shell echo "$(DEVICE)" | cut -d'_' -f 2,3)
LIST := $(shell cat vendor/blaster/blaster_devices)

ifeq ($(BLASTER_BUILD_TYPE),OFFICIAL)
    ifeq ($(filter $(BLASTER_DEVICE), $(LIST)), $(BLASTER_DEVICE))
          BLASTER_BUILD_TYPE := OFFICIAL
else
      $(error "Device is not officially supported!")
endif
endif

# Bootanimation
PRODUCT_COPY_FILES += vendor/blaster/bootanimation/bootanimation.zip:$(TARGET_COPY_OUT_PRODUCT)/media/bootanimation.zip

# Don't dexpreopt prebuilts. (For GMS).
DONT_DEXPREOPT_PREBUILTS := true

# Filesystem
TARGET_FS_CONFIG_GEN += vendor/blaster/target/config/config.fs

# Gapps
$(call inherit-product, vendor/blaster/target/product/gapps.mk)

# HIDL
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
     vendor/blaster/target/config/blaster_vendor_framework_compatibility_matrix.xml

# Include Common Qualcomm Device Tree.
$(call inherit-product, device/qcom/common/common.mk)

# Include definitions for Snapdragon Clang
$(call inherit-product, vendor/qcom/sdclang/config/SnapdragonClang.mk)

# Include Overlay makefile.
$(call inherit-product, vendor/blaster/overlay/overlays.mk)

# Include Packages makefile.
$(call inherit-product, vendor/blaster/target/product/packages.mk)

# Include Properties makefile.
$(call inherit-product, vendor/blaster/target/product/properties.mk)

ifeq ($(TARGET_FLATTEN_APEX), false)
$(call inherit-product-if-exists, vendor/google/modules/build/mainline_modules_s.mk)
else
$(call inherit-product-if-exists, vendor/google/modules/build/mainline_modules_s_flatten_apex.mk)
endif

# Move Wi-Fi modules to vendor.
PRODUCT_VENDOR_MOVE_ENABLED := true

# Permissions
PRODUCT_COPY_FILES += \
    vendor/blaster/target/config/permissions/privapp-permissions-qti.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-qti.xml \
    vendor/blaster/target/config/permissions/privapp-permissions-hotword.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-hotword.xml \
    vendor/blaster/target/config/permissions/qti_whitelist.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/qti_whitelist.xml \
    vendor/blaster/target/config/permissions/obdm_permissions.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/obdm_permissions.xml \
    vendor/blaster/target/config/permissions/privapp-permissions-omadm.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-omadm.xml \
    vendor/blaster/target/config/permissions/privapp-permissions-google_prebuilt.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-google_prebuilt.xml \
    vendor/blaster/target/config/permissions/privapp-permissions-pb-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-pb-product.xml \
    vendor/blaster/target/config/permissions/privapp-permissions-gms.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-gms.xml

# Sensitive phone numbers and APN configurations
PRODUCT_COPY_FILES += \
    vendor/blaster/target/config/apns-conf.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/apns-conf.xml \
    vendor/blaster/target/config/sensitive_pn.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sensitive_pn.xml

# Copy all PixelBlaster-specific init rc files
$(foreach f,$(wildcard vendor/blaster/prebuilt/etc/init/*.rc),\
	$(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

# Skip boot JAR checks.
SKIP_BOOT_JARS_CHECK := true
