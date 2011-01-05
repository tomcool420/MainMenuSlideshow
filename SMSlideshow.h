//
//  SMSlideshow.h
//  SoftwareMenu
//
//  Created by Thomas Cool on 3/12/10.
//  Copyright 2010 Thomas Cool. All rights reserved.
//

#import <BackRow/BackRow.h>

@interface SMImageControl : BRImageControl
{
    int padding[32];
}

@end
typedef enum {
    // Core Animation's four built-in transition types
    SlideshowViewFadeTransitionStyle,
    SlideshowViewMoveInTransitionStyle,
    SlideshowViewPushTransitionStyle,
    SlideshowViewRevealTransitionStyle,
    SlideshowViewSuckTransitionStyle,
    SlideshowViewSpewTransitionStyle,
    SlideshowViewGenieTransitionStyle,
    SlideshowViewUnGenieTransitionStyle,
    SlideshowViewRippleTransitionStyle,
    SlideshowViewTwistTransitionStyle,
    SlideshowViewTubeyTransitionStyle,
    SlideshowViewSwirlTransitionStyle,
    SlideshowViewCharminUltraTransitionStyle,
    SlideshowViewZoomyInTransitionStyle,
    SlideshowViewZoomyOutTransitionStyle,
    NumberOfSlideshowViewTransitionStyles
    

    
    
} SlideshowTransitionStyle;
@interface SMSlideshowControl : BRControl
{
    int padding[32];
    float           targetOpacity;
    BOOL            randomOrder;
    BOOL            useTimer;
    BOOL            crop;
    unsigned int    timerTime;
    float           transitionDuration;
    unsigned int    currentImage;
    BRImage         *nextImage;
    BRImageControl  *curImage;
    BRImageControl  *oldImage;
    NSArray         *files;
    NSTimeInterval  slideshowInterval;
    NSTimer         *slideshowTimer;
    NSString        *currentImagePath;
    BOOL            autoRotateEffect;
    BOOL            active;
    id _parent;
    SlideshowTransitionStyle transitionStyle;
    
}
@property (assign) BOOL activate;
/*
 *  ImageTime
 */
@property (assign) NSTimeInterval slideshowInterval;
/*
 *   Set the transition style
 */
@property (assign)SlideshowTransitionStyle transitionStyle;
/*
 *  Should the timer be used
 */
@property (assign) BOOL useTimer;
/*
 *  Sets how long the transition will last
 */
@property (assign) float transitionDuration;
/*
 *  Should images be displayed in a random order
 */
@property (assign) BOOL randomOrder;

/*
 *  if crop == NO, the images will be stretched instead
 */
@property (assign) BOOL crop;
/*
 *  Requires an NSArray with File Paths;
 */
@property (retain) NSArray *files;

/*
 *  Displays Files in selected Folder
 */
-(void)setFolder:(NSString *)folder;

/*
 *  This is the method that should in fact be called, not setImage
 */
-(void)setCurrentImage:(BRImage *)image;

/*
 *  Sets Opacity of the Images (don't want above 0.5 for main menu really)
 */
@property (assign)float targetOpacity;


@property (assign)BOOL autoRotateEffect;

/*
 *
 */
- (void)updateSubviewsTransition;
/*
 *  Starts Slideshow
 */
- (void)startSlideshowTimer;
/*
 *  Stops Slideshow
 */
- (void)stopSlideshowTimer;
/*
 *  Method that should be called to manually advance slideshow
 */
- (void)advanceSlideshow:(NSTimer *)timer;
- (void)advanceSlideshow:(NSTimer *)timer force:(BOOL)force;
@end
NSString *const kCAMediaTimingFunctionEaseIn;
@interface SMSlideshowMext : NSObject{
//    BRImageControl *_control;
//    int _imageNb;
    
    NSMutableArray *_imagePaths;
    BRImage *_nextImage;
    NSDate *_lastFireDate;
}
@end


