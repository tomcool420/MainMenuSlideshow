//
//  SMSlideshow.m
//  SoftwareMenu
//
//  Created by Thomas Cool on 3/12/10.
//  Copyright 2010 Thomas Cool. All rights reserved.
//

#import <SMFramework/SMFramework.h>
#import "SMSlideshow.h"
#import "SMSlideshowController.h"
#import <QuartzCore/QuartzCore2.h>
#define DEFAULT_IMAGES_PATH		@"/System/Library/PrivateFrameworks/AppleTV.framework/DefaultFlowerPhotos/"
//#define DEFAULT_IMAGES_PATH @"/var/mobile/Library/Preferences/nature"
//#define DEFAULT_IMAGES_PATH @"/nature"
#define plitFile [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.tomcool.weather.plist"]
#define myDomain                (CFStringRef)@"com.apple.frontrow.appliance.SoftwareMenu.Slideshow"
#define SoftwareMenuDomain      (CFStringRef)@"com.apple.frontrow.appliance.SoftwareMenu"
//#define DEBUG
@interface ATVSettingsFacade
@end
@class CATransition;
@implementation SMImageControl
@end


//static int _imageNb =0;
static SMSlideshowControl *_control = nil;
@implementation SMSlideshowMext
//static BRImageControl *_control = nil;
+(BRMenuController *)configurationMenu
{
    return [[[SMSlideshowController alloc]init] autorelease];
}
+(BRController *)pluginOptions;
{
    return nil;
}
+(NSString *)displayName
{
    return @"Main Menu Slideshow";
}
+(BOOL)hasPluginSpecificOptions
{
    return YES;
}
+(void)reload
{
    
}
-(BRControl *)backgroundControl
{
    if (_control == nil) {
        _control = [[SMSlideshowControl alloc] init];
        [_control setAutoresizingMask:1];
        [_control retain];
        [_control retain];
        //_control.opacity=0.4f;
        [_control setTargetOpacity:0.4f];
        [_control setTransitionStyle:[SMSlideshowController transitionStyle]];
        [_control setFolder:[SMSlideshowController imageFolder]];
        [_control setRandomOrder:NO];
    }
#ifdef DEBUG
    [_control setTargetOpacity:0.4f];
    [_control setTransitionDuration:3];
    [_control setTransitionStyle:SlideshowCAFilterPageCurlTransitionStyle];
    [_control setSlideshowInterval:(NSTimeInterval)20];
//    [_control setRandomOrder:NO];
//    [_control setAutoRotateEffect:YES];
#endif

    //_control.slideshowInterval=(NSTimeInterval)10;

    CGRect a;
    a.origin.x=0.0f;
    a.origin.y=0.0f;
    a.size=[BRWindow maxBounds];
    [_control setFrame:a];
    [_control startSlideshowTimer];
    //NSLog(@"%@",_lastFireDate);
    //[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(callU) userInfo:nil repeats:NO];
    return _control;
}



-(BOOL)hasPluginSpecificOptions
{
    return NO;
}
+(NSString *)pluginSummary
{
    return @"Displays the first image of your photo folder in background and on menu press returns a slideshow of the folder";
}
-(BRController *)controller
{
    id mext = [[SMSlideshowMext alloc] init];
    id controller = [BRController controllerWithContentControl:[mext backgroundControl]];
    [mext release];
    return controller;
}
+(NSString *)developer
{
    return @"Thomas Cool";
}

@end


@implementation SMSlideshowControl
@synthesize slideshowInterval;
@synthesize transitionStyle;
@synthesize useTimer;
@synthesize transitionDuration;
@synthesize files;
@synthesize randomOrder;
@synthesize targetOpacity;
@synthesize autoRotateEffect;
@synthesize crop;
@synthesize activate;
-(id)init
{
    self=[super init];
    self.targetOpacity=0.3f;
    [self advanceSlideshow:nil force:YES];
    self.useTimer=YES;
    self.crop=YES;
    self.activate=YES;
    self.randomOrder=[SMSlideshowController randomizeOrder];
    self.autoRotateEffect=[SMSlideshowController autoRotateTransitions];
    
    self.transitionDuration=[SMSlideshowController transitionDuration];
    self.transitionStyle=[SMSlideshowController transitionStyle];
    self.files=[NSArray array];
    currentImage=0;
    [self updateSubviewsTransition];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(folderChanged:)
                                                 name:kSMSlideshowChangedFolderNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vncConnected:) 
                                                 name:@"BHVNCServerClientConnected" 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vncDisconnected:) 
                                                 name:@"BHVNCServerClientDisconnected" 
                                               object:nil];
    BRImageControl *control = [[BRImageControl alloc] init];
    [control setImage:[[SMFThemeInfo sharedTheme]blackImage]];
    CGRect frame = [BRWindow interfaceFrame];
    [control setFrame:frame];
    [control setOpacity:0.5];
    [self addControl:control];
    return self;
}
- (void)vncConnected:(NSNotification *)note
{
    //self.activate=NO;
    [self setHidden:YES];
    //BRImage *bI = [BRImage imageWithPath:[[NSBundle bundleForClass:[self class]]pathForResource:@"black" ofType:@"png"]];
    [self setActions:[NSDictionary dictionary]];
    [self advanceSlideshow:slideshowTimer];
    [slideshowTimer fire];
//    [self setCurrentImage:bI];
//    [self setNeedsDisplay];
//    [self setNeedsDisplayInRect:[BRWindow interfaceFrame]];
    //[self setCurrentImage:nil];
}
- (void)vncDisconnected:(NSNotification *)note
{
    //self.activate=YES;
    [self setHidden:NO];
    //[self setCurrentImage:nil];
    [self updateSubviewsTransition];
//    [self advanceSlideshow:nil];
//    [self setNeedsDisplay];
//    [self setNeedsDisplayInRect:[BRWindow interfaceFrame]];

//    [self stopSlideshowTimer];
//    [self startSlideshowTimer];
}
- (void)folderChanged:(NSNotification *)note
{
    [self setFolder:[SMSlideshowController imageFolder]];
    
}
- (void)startSlideshowTimer {
    if (slideshowTimer == nil && self.slideshowInterval > 0.0) 
    {
        slideshowTimer = [[NSTimer scheduledTimerWithTimeInterval:[self slideshowInterval] target:self selector:@selector(advanceSlideshow:) userInfo:nil repeats:YES] retain];
        [self advanceSlideshow:slideshowTimer force:TRUE];
    }
}
-(void)controlWasActivated
{
    self.slideshowInterval=[SMSlideshowController imageDuration] ;
    [super controlWasActivated];
    

}
-(void)advanceSlideshow:(NSTimer *)timer force:(BOOL)force
{
    int count = [self.files count];
    BOOL isVisible=NO;
    BOOL done=NO;
    id parent=[self parent];
    if (force) {
        //done=TRUE;
        isVisible=TRUE;
    }
    else
        while (done==FALSE) {
            if (parent) 
            {
                if ([parent isKindOfClass:[BRController class]]) {
                    if ([parent topOfStack])                
                        isVisible=TRUE;
                    done=TRUE;
                }
                else if([parent isKindOfClass:[BRControl class]])
                {
                    parent=[parent parent];
                }
            }
            else
                done=TRUE;
        }
    if (self.files != nil && count > 0 && isVisible) {
        // Find the next Asset in the slideshow.
        int startIndex = currentImagePath ? [self.files indexOfObject:currentImagePath] : 0;
        int index = (startIndex + 1) % count;
        while (index != startIndex) {
            NSString *asset = [self.files objectAtIndex:index];
            
            BRImage *image = [BRImage imageWithPath:asset];
            
            [self setCurrentImage:image];
            
            [currentImagePath release];
            
            currentImagePath = [asset retain];
            return;
            
            index = (index + 1) % count;
        }
        
    }

}

- (void)advanceSlideshow:(NSTimer *)timer {
    if(self.activate)
        [self advanceSlideshow:timer force:FALSE];
}
- (void)stopSlideshowTimer {
    if (slideshowTimer != nil) {
        // Cancel and release the slideshow advance timer.
        [slideshowTimer invalidate];
        [slideshowTimer release];
        slideshowTimer = nil;
    }
}
- (void)setSlideshowInterval:(NSTimeInterval)newSlideshowInterval {
    if (slideshowInterval != newSlideshowInterval) {
        // Stop the slideshow, change the interval as requested, and then restart the slideshow (if it was running already).
        [self stopSlideshowTimer];
        slideshowInterval = newSlideshowInterval;
        if (slideshowInterval > 0.0) {
            [self startSlideshowTimer];
        }
    }
}

-(void)setFolder:(NSString *)folder
{
//    NSLog(@"setFolder: %@",folder);
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&isDir]&&isDir) 
    {
        NSArray *a = [SMFPhotoMethods photoPathsForPath:folder];
        self.files = a;
    }
}

-(void)setFiles:(NSArray *)f
{
//    NSLog(@"setFiles: %@",f);
    if (files!=nil) {
        [files release];
        files=nil;
    }
    if (!self.randomOrder) {
        files = [[f sortedArrayUsingSelector:@selector(compare:)] retain];
    }
    else {
        files = [[f SMFShuffled] retain];
    }

}

-(void)setTransitionDuration:(float)transitionTime
{
    if (transitionTime>=0.0f) {
        transitionDuration=transitionTime;
    }
}

-(void)setTransitionStyle:(SlideshowTransitionStyle)st
{
    transitionStyle=st;
    [self updateSubviewsTransition];
}

-(void)setCurrentImage:(BRImage *)imga
{
    BRImage *image = imga;
    //NSLog(@"set Current Image: %@",image);
    if(autoRotateEffect)
    {
        [self setTransitionStyle:((transitionStyle +1) %NumberOfSlideshowViewTransitionStyles)];
    }
    else {
        [self setTransitionStyle:[SMSlideshowController transitionStyle]];

    }

//    if (self.activate==NO) {
//        if (curImage!=nil) {
//            if (oldImage!=nil) {
//                [oldImage removeFromParent];
//                [oldImage release];
//                oldImage=nil;
//            }
//            [curImage removeFromParent];
//            [curImage release];
//            curImage=nil;
//        }
//    }
    if(image!=nil)
    {
        if (curImage!=nil) {
            if (oldImage!=nil) {
                [oldImage release];
                oldImage=nil;
            }
            oldImage=curImage;
        }
        curImage=[[BRImageControl alloc] init];
        [curImage setAutomaticDownsample:YES];
        [curImage setImage:image];
        if (crop && [curImage aspectRatio]>=1) {
            CGSize maxBounds= [BRWindow maxBounds];
            CGRect newFrame;
            newFrame.size.width=maxBounds.width;
            newFrame.size.height=newFrame.size.width/[curImage aspectRatio];
            newFrame.origin.x=0;
            newFrame.origin.y=(maxBounds.height-newFrame.size.height)/2.0f;
            [curImage setFrame:newFrame];
        }
        else if(crop){
            CGSize maxBounds= [BRWindow maxBounds];
            CGRect newFrame;
            newFrame.size.height=maxBounds.height;
            newFrame.size.width=newFrame.size.height*[curImage aspectRatio];
            newFrame.origin.x=(maxBounds.width-newFrame.size.width)/2.0f;
            newFrame.origin.y=0;
            [curImage setFrame:newFrame];
        }
        else {
            [curImage setFrame:[BRWindow interfaceFrame]];
        }
        //    [curImage setOpacity:targetOpacity];

        
        if (oldImage!=nil) {
            [self insertControl:curImage above:oldImage];
        }
        else {
            [self insertControl:curImage atIndex:0];
        }
       if (oldImage!=nil) {

           [oldImage removeFromParent];
           [oldImage release];
           oldImage=nil;


        }
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
    NSLog(@"controls: %@ %f",[self controls],[[[self controls] lastObject] opacity]);

}


- (void)updateSubviewsTransition {
    NSString *transitionType = nil;
    switch (transitionStyle) {
        case SlideshowViewFadeTransitionStyle:
            transitionType = @"fade";
            break;
        case SlideshowViewMoveInTransitionStyle:
            transitionType = @"moveIn";
            break;
        case SlideshowViewPushTransitionStyle:
            transitionType = @"push";
            break;
        case SlideshowViewRevealTransitionStyle:
            transitionType = @"reveal";
            break;
        case SlideshowViewSuckTransitionStyle:
            transitionType = @"suckEffect";
            break;
        case SlideshowViewSpewTransitionStyle:
            transitionType = @"spewEffect";
            break;
        case SlideshowViewGenieTransitionStyle:
            transitionType = @"genieEffect";
            break;
        case SlideshowViewUnGenieTransitionStyle:
            transitionType = @"unGenieEffect";
            break;
        case SlideshowViewRippleTransitionStyle:
            transitionType = @"rippleEffect";
            break;
        case SlideshowViewTwistTransitionStyle:
            transitionType = @"twist";
            break;
        case SlideshowViewTubeyTransitionStyle:
            transitionType = @"tubey";
            break;
        case SlideshowViewSwirlTransitionStyle:
            transitionType = @"swirl";
            break;
        case SlideshowViewCharminUltraTransitionStyle:
            transitionType = @"charminUltra";
            break;
        case SlideshowViewZoomyInTransitionStyle:
            transitionType = @"zoomyIn";
            break;
        case SlideshowViewZoomyOutTransitionStyle:
            transitionType = @"zoomyOut";
            break;
        case SlideshowCAFilterPageCurlTransitionStyle:
            transitionType = nil;
            break;
        default:
            transitionType = @"reveal";
            break;
    }
    CATransition *transition = [CATransition animation];
    
    if (transitionType==nil) {
        CAFilter* filter=nil;
        if (transitionStyle==SlideshowCAFilterPageCurlTransitionStyle) {
            filter=[CAFilter filterWithName:kCAFilterPageCurl];
        }
        [filter setDefaults];
        [transition setFilter:filter];
    }
    else {
        [transition setType:transitionType];
    }
    [transition setDuration:self.transitionDuration];
    [self setActions:[NSDictionary dictionaryWithObject:transition forKey:@"sublayers"]];
}
-(void)dealloc
{
    [super dealloc];
}
@end


