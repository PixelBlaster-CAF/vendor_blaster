# Fonts
LOCAL_PATH := vendor/blaster/fonts
PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,vendor/blaster/fonts//prebuilts,$(TARGET_COPY_OUT_PRODUCT)/fonts)

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/fonts_customization.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/fonts_customization.xml

PRODUCT_PACKAGES += \
    FontHarmonySansOverlay \
    FontInterOverlay \
    FontLinotteSourceOverlay \
    FontManropeOverlay \
    FontOnePlusSansOverlay \
    FontOneplusSlateSourceOverlay \
    FontOppoSansOverlay
