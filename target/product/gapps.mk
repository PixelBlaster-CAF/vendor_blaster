# Gapps
ifeq ($(BUILD_GAPPS),GAPPS)
$(call inherit-product, vendor/gms/gms_full.mk)

# Common Overlay
DEVICE_PACKAGE_OVERLAYS += \
    vendor/blaster/overlay-gapps/common

# Exclude RRO Enforcement
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS +=  \
    vendor/blaster/overlay-gapps

$(call inherit-product, vendor/blaster/target/product/rro_overlays.mk)
endif