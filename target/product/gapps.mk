# Gapps
ifeq ($(BUILD_GAPPS),GAPPS)
$(call inherit-product, vendor/gms/products/gms.mk)

# Common Overlay
DEVICE_PACKAGE_OVERLAYS += \
    vendor/blaster/overlay-gapps/common

# Exclude RRO Enforcement
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS +=  \
    vendor/blaster/overlay-gapps

endif