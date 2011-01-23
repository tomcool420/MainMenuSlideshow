//
//  SMSlideshowController.h
//  MMSlideshow
//
//  Created by Thomas Cool on 10/25/10.
//  Copyright 2010 tomcool.org. All rights reserved.
//

#import <SMFramework/SMFramework.h>
#import "SMSlideshow.h"
extern NSString * const kSMSlideshowChangedFolderNotification;
@interface SMSlideshowController : SMFMediaMenuController<SMFFolderBrowserDelegate,SMFListDropShadowDatasource,SMFListDropShadowDelegate> {

}
+(float)transitionDuration;
+(int)imageDuration;
+(float)opacity;
+(NSString *)imageFolder;
+(BOOL)randomizeOrder;
+(BOOL)autoRotateTransitions;
+(SlideshowTransitionStyle)transitionStyle;

/*
 *  Delegate methods for the folder browser
 */
-(BOOL)hasActionForFile:(NSString *)path;
-(void)executeActionForFile:(NSString *)path;
@end
