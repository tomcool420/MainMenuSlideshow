GO_EASY_ON_ME=1
export SDKVERSION=4.1
export FW_DEVICE_IP=appletv.local
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MainMenuSlideshow
MainMenuSlideshow_FILES = SMSlideshow.m  SMSlideshowController.m #APXML/APAttribute.m APXML/APDocument.m APXML/APElement.m APXML/APXML_SMF.m
MainMenuSlideshow_BUNDLE_EXTENSION = mext
MainMenuSlideshow_LDFLAGS = -undefined dynamic_lookup -framework ImageIO  -framework UIKit -framework CoreGraphics
MainMenuSlideshow_INSTALL_PATH = /Library/MainMenuExtensions
MainMenuSlideshow_CFLAGS = -I../ATV2Includes/
MainMenuSlideshow_OBJ_FILES = /Users/tomcool/DVLP/ATV2/SMFramework/obj/SMFramework

include $(FW_MAKEDIR)/bundle.mk


after-install::
	ssh root@$(FW_DEVICE_IP) killall Lowtide
