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

ifeq (blaster_opkona,$(TARGET_PRODUCT))

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Inherit from opkona device
$(call inherit-product, device/oneplus/opkona/device.mk)

# Inherit qcom common stuff
$(call inherit-product, device/qcom/common/common.mk)

# Inherit from the PixelBlaster configuration.
$(call inherit-product, vendor/blaster/target/product/blaster-target.mk)

# Boot Animation
TARGET_BOOT_ANIMATION_RES := 1080

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := blaster_opkona
PRODUCT_DEVICE := opkona
PRODUCT_MANUFACTURER := OnePlus
PRODUCT_BRAND := OnePlus
PRODUCT_MODEL := LE2101

PRODUCT_GMS_CLIENTID_BASE := android-oneplus

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="OnePlus9R_IND-user 12 RKQ1.211119.001 R.202207300316 release-keys" \
    TARGET_DEVICE=OnePlus9R \
    TARGET_PRODUCT=OnePlus9R_IND

BUILD_FINGERPRINT := OnePlus/OnePlus9R_IND/OnePlus9R:12/RKQ1.211119.001/R.202207300316:user/release-keys
endif