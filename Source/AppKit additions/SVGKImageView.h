#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif
#import <SVGKit/SVGKImage.h> // cannot import "SVGKit.h" because that would cause ciruclar imports

/**
 * SVGKit's version of NSImageView - with some improvements over Apple's design. There are multiple versions of this class, for different use cases.
 
 STANDARD USAGE:
   - SVGKImageView *myImageView = [[SVGKFastImageView alloc] initWithSVGKImage: [SVGKImage imageNamed:@"image.svg"]];
   - [self.view addSubview: myImageView];
 
 NB: the "SVGKFastImageView" is the one you want 9 times in 10. The alternative classes (e.g. SVGKLayeredImageView) are for advanced usage.
 
 NB: read the class-comment for each subclass carefully before deciding what to use.
 
 */
@interface SVGKImageView :
#if !TARGET_OS_IPHONE
NSView
#else
UIView
#endif

@property(nonatomic) BOOL showBorder; /*< mostly for debugging - adds a coloured 1-pixel border around the image */
//@property(nonatomic,strong) SVGKImage* image;

- (void)setImage:(SVGKImage*)image;
- (SVGKImage *)image;

- (id)initWithSVGKImage:(SVGKImage*) im;

#if !TARGET_OS_IPHONE
//Default initializer for (Cocoa) subclasses. Will set the frame of the view and init with an image
- (id)initWithSVGKImage:(SVGKImage*)im frame:(NSRect)theFrame;
#else
@property(nonatomic,readonly) NSTimeInterval timeIntervalForLastReRenderOfSVGFromMemory;
#endif

@end
