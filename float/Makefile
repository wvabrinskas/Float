ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = Float
Float_FILES = Float.mm RSBrightnessSlider.m RSOpacitySlider.m BGRSLoupeLayer.m RSColorFunctions.m RSColorPickerState.m RSColorPickerView.m RSGenerateOperation.m RSSelectionLayer.m ANImageBitmapRep.m BitmapContextRep.m NSImage+ANImageBitmapRep.m OSCommonImage.m UIImage+ANImageBitmapRep.m CGContextCreator.m CGImageContainer.m BitmapContextManipulator.m BitmapCropManipulator.m BitmapDrawManipulator.m BitmapRotationManipulator.m BitmapScaleManipulator.m
Float_INSTALL_PATH = /Library/PreferenceBundles
Float_FRAMEWORKS = UIKit CoreGraphics QuartzCore Accelerate Foundation CoreImage
Float_PRIVATE_FRAMEWORKS = Preferences
Float_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Float.plist$(ECHO_END)
