#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif
#import <SVGKit/SVGKImage.h> 

/**
 * SVGKit's version of NSImageView - with some improvements over Apple's design. There are multiple versions of this class, for different use cases.
 
 STANDARD USAGE:
   - SVGKImageView *myImageView = [[SVGKFastImageView alloc] initWithSVGKImage: [SVGKImage imageNamed:@"image.svg"]];
   - [self.view addSubview: myImageView];
 
 NB: the "SVGKFastImageView" is the one you want 9 times in 10. The alternative classes (e.g. SVGKLayeredImageView) are for advanced usage.
 
 NB: read the class-comment for each subclass carefully before deciding what to use.
 
 */
#if !TARGET_OS_IPHONE
@interface SVGKImageView: NSView
#else
@interface SVGKImageView: UIView
#endif

@property(nonatomic) BOOL showBorder; /*< mostly for debugging - adds a coloured 1-pixel border around the image */
//@property(nonatomic,strong) SVGKImage* image;

@property (nonatomic) SVGKImage *image;

- (instancetype)initWithSVGKImage:(SVGKImage*) im;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

#if !TARGET_OS_IPHONE
//Default initializer for (Cocoa) subclasses. Will set the frame of the view and init with an image
- (id)initWithSVGKImage:(SVGKImage*)im frame:(NSRect)theFrame;
#else
@property(nonatomic,readonly) NSTimeInterval timeIntervalForLastReRenderOfSVGFromMemory;
#endif

@end
