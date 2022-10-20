#
# Copyright (C) 2018 The LineageOS Project
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
#

ifeq (blaster_nicky,$(TARGET_PRODUCT))

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Inherit from nicky device
$(call inherit-product, device/oplus/nicky/device.mk)

# Inherit qcom common stuff
$(call inherit-product, device/qcom/common/common.mk)

# Inherit from the PixelBlaster configuration.
$(call inherit-product, vendor/blaster/target/product/blaster-target.mk)

# Boot Animation
TARGET_BOOT_ANIMATION_RES := 1080

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := blaster_nicky
PRODUCT_DEVICE := nicky
PRODUCT_MANUFACTURER := realme
PRODUCT_BRAND := realme
PRODUCT_MODEL := RMX1851

PRODUCT_SYSTEM_NAME := RMX1851
PRODUCT_SYSTEM_DEVICE := RMX1851

PRODUCT_GMS_CLIENTID_BASE := android-oppo

BUILD_FINGERPRINT := "Realme/RMX1851/RMX1851:11/RKQ1.201217.002/1645426024988:user/release-keys"

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="RMX1851-user 11 RKQ1.201217.002 1645426024988 release-keys" \
    TARGET_DEVICE=RMX1851 \
    TARGET_PRODUCT=RMX1851
endif