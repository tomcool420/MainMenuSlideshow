//
//  SMSlideshowController.m
//  MMSlideshow
//
//  Created by Thomas Cool on 10/25/10.
//  Copyright 2010 tomcool.org. All rights reserved.
//
#define DEFAULT_IMAGES_PATH		@"/System/Library/PrivateFrameworks/AppleTV.framework/DefaultFlowerPhotos/"
#define BRLocalizedString(key, comment)								[BRLocalizedStringManager appliance:self localizedStringForKey:(key) inFile:nil]
#define BRLocalizedStringFromTable(key, tbl, comment)				[BRLocalizedStringManager appliance:self localizedStringForKey:(key) inFile:(tbl)]
#define BRLocalizedStringFromTableInBundle(key, tbl, obj, comment)	[BRLocalizedStringManager appliance:(obj) localizedStringForKey:(key) inFile:(tbl)]
#import "SMSlideshowController.h"

#define PREFS [SMSlideshowController preferences]
typedef enum _SMRowType{
    transitionDuration=0,
    transitionEffect,
    imageDuration,
    randomize,
    selectFolder,
    selectFolderRoot,
    opacity,
    autoRotate,
    
} SMRowType;

static NSString * const kEnabledBool                            = @"enabled";
static NSString * const kTransitionDurationFloat                = @"transitionDuration";
static NSString * const kImageDurationInteger                   = @"imageDuration";
static NSString * const kFolderString                           = @"folder";
static NSString * const kOpacityFloat                           = @"opacity";
static NSString * const kRandomizeBool                          = @"randomize";
static NSString * const kAutoRotateTransitionsBool              = @"autoRotateTransitions";
static NSString * const kTransitionStyleInteger                 = @"transitionStyle";

NSString * const kSMSlideshowChangedFolderNotification          = @"kSMSlideshowChangedFolderNotification";
@implementation SMSlideshowController
+(SMFPreferences *)preferences {
    static SMFPreferences *_slideshowPreferences = nil;
    
    if(!_slideshowPreferences)
    {
        _slideshowPreferences = [[SMFPreferences alloc] initWithPersistentDomainName:@"org.tomcool.mainmenu.slideshow"];
        [_slideshowPreferences registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithFloat:3.5f],kTransitionDurationFloat,
                                                 [NSNumber numberWithBool:YES],kEnabledBool,
                                                 [NSNumber numberWithInt:60],kImageDurationInteger,
                                                 [NSNumber numberWithFloat:0.3f],kOpacityFloat,
                                                 [NSNumber numberWithBool:YES],kAutoRotateTransitionsBool,
                                                 [NSNumber numberWithInt:SlideshowViewFadeTransitionStyle],kTransitionStyleInteger,
                                                 DEFAULT_IMAGES_PATH,kFolderString,
                                                 [NSNumber numberWithBool:NO],kRandomizeBool,
                                               nil]];
    }
    
    return _slideshowPreferences;
}


+(float)transitionDuration
{
    float tf = [[PREFS objectForKey:kTransitionDurationFloat] floatValue];
    if (tf<0 || tf>5) {
        tf=3.5f;
    }
    return tf;
}
+(void)setTransitionDuration:(float)td
{
    if (td<0 || td>5) {
        td=3.5f;
    }
    [PREFS setObject:[NSNumber numberWithFloat:td] forKey:kTransitionDurationFloat];
}

+(SlideshowTransitionStyle)transitionStyle
{
    return (SlideshowTransitionStyle)[[PREFS objectForKey:kTransitionStyleInteger] intValue];
}
+(void)setTransitionStyle:(SlideshowTransitionStyle)style
{
    style=(style %NumberOfSlideshowViewTransitionStyles);
    [PREFS setInteger:style forKey:kTransitionStyleInteger];
}
+(int)imageDuration
{
    return [[PREFS objectForKey:kImageDurationInteger] intValue];
}
+(float)opacity
{
    float tf = [(NSNumber *)[PREFS objectForKey:kOpacityFloat] floatValue];
    if (tf<0.0f || tf>1.0f) {
        tf=0.3f;
    }
    return tf;
}
+(void)setOpacity:(float)o
{
    [PREFS setObject:[NSNumber numberWithFloat:o] forKey:kOpacityFloat];
}

+(void)setImageDuration:(int)d
{
    if(d>=1)
        [PREFS setObject:[NSNumber numberWithInt:d] forKey:kImageDurationInteger];
}
+(void)setImageFolder:(NSString *)folder
{
    BOOL isDir;
    if([[NSFileManager defaultManager]fileExistsAtPath:folder isDirectory:&isDir]&&isDir)
        [PREFS setObject:folder forKey:kFolderString];
}
+(NSString *)imageFolder
{
    return [PREFS objectForKey:kFolderString];
}
+(BOOL)autoRotateTransitions
{
    return [PREFS boolForKey:kAutoRotateTransitionsBool];
}
+(void)setAutoRotateTransitions:(BOOL)ar
{
    [PREFS setBool:ar forKey:kAutoRotateTransitionsBool];
}
+(BOOL)randomizeOrder
{
    return [PREFS boolForKey:kRandomizeBool];
}
+(void)setRandomizeOrder:(BOOL)r
{
    [PREFS setBool:r forKey:kRandomizeBool];
}


-(id)init
{
    self = [super init];
    //NSArray * files = [NSArray arrayWithObjects:@"Transition"];
    [self setListTitle:BRLocalizedString(@"Slideshow Settings",@"Slideshow Settings")];
    
    id anItem=[[SMFMenuItem alloc]init];
    [anItem setTitle:BRLocalizedString(@"Transition Duration",@"Transition Duration")];
    [_items addObject:anItem];
    [anItem release];
    [_options addObject:[NSNumber numberWithInt:transitionDuration]];
    
    anItem=[[SMFMenuItem alloc]init];
    [anItem setTitle:BRLocalizedString(@"Transition Effect",@"Transition Effect")];
    [_items addObject:anItem];
    [_options addObject:[NSNumber numberWithInt:transitionEffect]];
    [anItem release];
    
    anItem=[[SMFMenuItem alloc]init];
    [anItem setTitle:BRLocalizedString(@"Auto Rotate Transitions",@"Auto Rotate Transitions")];
    [_items addObject:anItem];
    [_options addObject:[NSNumber numberWithInt:autoRotate]];
    [anItem release];
    
    anItem=[[SMFMenuItem alloc]init];
    [anItem setTitle:BRLocalizedString(@"Image Duration",@"Image Duration")];
    [_items addObject:anItem];
    [_options addObject:[NSNumber numberWithInt:imageDuration]];
    [anItem release];
    
    anItem=[[SMFMenuItem alloc]init];
    [anItem setTitle:BRLocalizedString(@"Randomize Image Order",@"Randomize Image Order")];
    [_items addObject:anItem];
    [_options addObject:[NSNumber numberWithInt:randomize]];
    [anItem release];
    
    anItem=[[SMFMenuItem alloc]init];
    [anItem setTitle:BRLocalizedString(@"Image Opacity",@"Image Opacity")];
    [_items addObject:anItem];
    [_options addObject:[NSNumber numberWithInt:opacity]];
    [anItem release];
    
    anItem=[[SMFMenuItem alloc]init];
    [anItem setTitle:BRLocalizedString(@"Select Folder",@"Select Folder")];
    [_items addObject:anItem];
    [anItem release];
    [_options addObject:[NSNumber numberWithInt:selectFolder]];
    
    anItem=[[SMFMenuItem alloc]init];
    [anItem setTitle:BRLocalizedString(@"Select Folder (Root Partition)",@"Select Folder (Root Partition)")];
    [_items addObject:anItem];
    [anItem release];
    [_options addObject:[NSNumber numberWithInt:selectFolderRoot]];
    
    return self;
}
-(NSString *)stringForTransition:(SlideshowTransitionStyle)trans
{
    NSString *transitionType = nil;
    switch (trans) {
        case SlideshowViewFadeTransitionStyle:
            transitionType = @"Fade";
            break;
        case SlideshowViewMoveInTransitionStyle:
            transitionType = @"Move In";
            break;
        case SlideshowViewPushTransitionStyle:
            transitionType = @"Push";
            break;
        case SlideshowViewRevealTransitionStyle:
            transitionType = @"Reveal";
            break;
        case SlideshowViewSuckTransitionStyle:
            transitionType = @"Suck Effect";
            break;
        case SlideshowViewSpewTransitionStyle:
            transitionType = @"Spew Effect";
            break;
        case SlideshowViewGenieTransitionStyle:
            transitionType = @"Genie Effect";
            break;
        case SlideshowViewUnGenieTransitionStyle:
            transitionType = @"Un Genie Effect";
            break;
        case SlideshowViewRippleTransitionStyle:
            transitionType = @"Ripple Effect";
            break;
        case SlideshowViewTwistTransitionStyle:
            transitionType = @"Twist";
            break;
        case SlideshowViewTubeyTransitionStyle:
            transitionType = @"Tubey";
            break;
        case SlideshowViewSwirlTransitionStyle:
            transitionType = @"Swirl";
            break;
        case SlideshowViewCharminUltraTransitionStyle:
            transitionType = @"Charmin Ultra";
            break;
        case SlideshowViewZoomyInTransitionStyle:
            transitionType = @"Zoomy In";
            break;
        case SlideshowViewZoomyOutTransitionStyle:
            transitionType = @"Zoomy Out";
            break;
        default:
            transitionType = @"Fade";
            break;
    }
    
    return transitionType;
    
}
-(id)itemForRow:(long)row
{
    if (row>=[self itemCount]) 
        return nil;
    SMRowType rowT = [[_options objectAtIndex:row] intValue];
    BRMenuItem *item = [_items objectAtIndex:row];
    if (rowT==transitionDuration)
        [item setRightJustifiedText:[NSString stringWithFormat:@"%.1f sec",[SMSlideshowController transitionDuration],nil] withAttributes:[[BRThemeInfo sharedTheme]menuItemSmallTextAttributes]];
    else if(rowT==transitionEffect)
        [item setRightJustifiedText:[self stringForTransition:[SMSlideshowController transitionStyle]]withAttributes:[[BRThemeInfo sharedTheme]menuItemSmallTextAttributes]];
    else if(rowT==imageDuration)
        [item setRightJustifiedText:[NSString stringWithFormat:@"%i min",([SMSlideshowController imageDuration]/60),nil]withAttributes:[[BRThemeInfo sharedTheme]menuItemSmallTextAttributes]];
    else if(rowT==selectFolder)
        [item setRightJustifiedText:[[SMSlideshowController imageFolder] lastPathComponent]withAttributes:[[BRThemeInfo sharedTheme]menuItemSmallTextAttributes]];
    else if(rowT==selectFolderRoot)
        [item setRightJustifiedText:[[SMSlideshowController imageFolder] lastPathComponent]withAttributes:[[BRThemeInfo sharedTheme]menuItemSmallTextAttributes]];
    else if(rowT==randomize)
        [item setRightJustifiedText:([SMSlideshowController randomizeOrder]?@"YES":@"NO")withAttributes:[[BRThemeInfo sharedTheme]menuItemSmallTextAttributes]];
    else if(rowT==opacity)
        [item setRightJustifiedText:[NSString stringWithFormat:@"%.1f",[SMSlideshowController opacity],nil]withAttributes:[[BRThemeInfo sharedTheme]menuItemSmallTextAttributes]];
    else if(rowT==autoRotate)
        [item setRightJustifiedText:([SMSlideshowController autoRotateTransitions]?@"YES":@"NO")withAttributes:[[BRThemeInfo sharedTheme]menuItemSmallTextAttributes]];
    return item;
}
-(void)itemSelected:(long)row
{

    if (row>=[self itemCount]) 
        return;
    SMRowType rowT = [[_options objectAtIndex:row] intValue];
    if (rowT==transitionDuration) 
    {
        float t = [SMSlideshowController transitionDuration]+0.5f;
        if (t>5.0f) {
            t=0.0f;
        }
        [SMSlideshowController setTransitionDuration:t];
    }
    
    else if(rowT==transitionEffect)
    {
        SlideshowTransitionStyle newStyle= (([SMSlideshowController transitionStyle]+1) %NumberOfSlideshowViewTransitionStyles);
        [SMSlideshowController setTransitionStyle:newStyle];
    }
    else if(rowT==randomize)
    {
        [SMSlideshowController setRandomizeOrder:![SMSlideshowController randomizeOrder]];
    }
    else if(rowT==imageDuration)
    {
        int t = [SMSlideshowController imageDuration]+60;
        if (t>3600) {
            t=60;
        }
        [SMSlideshowController setImageDuration:t];
    }
    else if(rowT==opacity)
    {
        
        float t = [SMSlideshowController opacity]+0.1f;
        if (t>1.0f) {
            t=0.0f;
        }
        [SMSlideshowController setOpacity:t];
    }
    else if(rowT==selectFolder)
    {
        SMFFolderBrowser * a =[[SMFFolderBrowser alloc]init];
        [a setPath:@"/var/root"];
        a.delegate=self;
        [[self stack] pushController:a];
        [a release];
    }
    else if(rowT==selectFolderRoot)
    {
        SMFFolderBrowser * a =[[SMFFolderBrowser alloc]init];
        [a setPath:@"/"];
        a.delegate=self;
        [[self stack] pushController:a];
        [a release];
    }
    else if(rowT==autoRotate)
        [SMSlideshowController setAutoRotateTransitions:![SMSlideshowController autoRotateTransitions]];
    [[self list]reload];
}
-(void)leftActionForRow:(long)row
{
    SMRowType rowT = [[_options objectAtIndex:row] intValue];
    if(rowT==transitionEffect)
    {
        SlideshowTransitionStyle currentStyle=[SMSlideshowController transitionStyle];
        if (currentStyle==0) {
            currentStyle=NumberOfSlideshowViewTransitionStyles;
        }
        SlideshowTransitionStyle newStyle= ((currentStyle-1) %NumberOfSlideshowViewTransitionStyles);
        [SMSlideshowController setTransitionStyle:newStyle];
    }
    else if(rowT==imageDuration)
    {
        int t = [SMSlideshowController imageDuration]-60;
        if (t<60) {
            t=3600;
        }
        [SMSlideshowController setImageDuration:t];
    }
    else if(rowT==transitionDuration)
    {
        float t = [SMSlideshowController transitionDuration]-0.5f;
        if (t<0.0f) {
            t=5.0f;
        }
        [SMSlideshowController setTransitionDuration:t];
    }
    else if(rowT==opacity)
    {
        float t = [SMSlideshowController opacity]-0.1f;
        if (t<0.0f) {
            t=1.0f;
        }
        [SMSlideshowController setOpacity:t];
    }
    
    [[self list]reload];
}
-(void)rightActionForRow:(long)row
{
    SMRowType rowT = [[_options objectAtIndex:row] intValue];
    if(rowT==transitionEffect)
        [self itemSelected:row];
    else if(rowT==imageDuration)
        [self itemSelected:row];
    else if(rowT==transitionDuration)
        [self itemSelected:row];
    else if(rowT==opacity)
        [self itemSelected:row];
    [[self list]reload]; 
}
-(void)wasExhumed
{
    [[self list] reload];
    [super wasExhumed];
}
#pragma mark delegate methods
-(BOOL)hasActionForFile:(NSString *)path
{
    BOOL isDir=NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]&&isDir) {
        return YES;
    }
    return NO;
}
-(void)executeActionForFile:(NSString *)path
{
    [PREFS setObject:path forKey:kFolderString];
    [[NSNotificationCenter defaultCenter]postNotificationName:kSMSlideshowChangedFolderNotification object:nil];
    [[self stack] popToController:self];
}
-(void)executePlayPauseActionForFile:(NSString *)path
{
    [self executeActionForFile:path];
}
@end
