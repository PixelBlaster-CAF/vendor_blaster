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

#
# Handle various build version information.
#
# Guarantees that the following are defined:
#     AOSPA_MAJOR_VERSION
#     AOSPA_MINOR_VERSION
#     BLASTER_BUILD_VARIANT
#

# This is the global AOSPA version flavor that determines the focal point
# behind our releases. This is bundled alongside $(AOSPA_MINOR_VERSION)
# and only changes per major Android releases.
BLASTER_BUILD_VERSION := 6.2

BUILD_GAPPS := Vanilla

CAF_SYSTEM_TAG := LA.QSSI.13.0.r1-07800-qssi.0
CAF_VENDOR_TAG := LA.UM.9.14.2.r1-03000-QCM6490.QSSI12.0

# Build Date
BUILD_DATE := $(shell date -u +%Y%m%d)

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.pb.version=$(BLASTER_BUILD_VERSION) \
    ro.pb.build_date=$(BUILD_DATE) \
    ro.pb.build_type=$(BLASTER_BUILD_VARIANT) \
    ro.caf.system.tag=$(CAF_SYSTEM_TAG) \
    ro.caf.vendor.tag=$(CAF_VENDOR_TAG)