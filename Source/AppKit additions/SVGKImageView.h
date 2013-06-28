#import <Foundation/Foundation.h>

#import <AppKit/AppKit.h>
#import "SVGKImage.h" // cannot import "SVGKit.h" because that would cause ciruclar imports

/**
 * SVGKit's version of NSImageView - with some improvements over Apple's design. There are multiple versions of this class, for different use cases.
 
 STANDARD USAGE:
   - SVGKImageView *myImageView = [[SVGKFastImageView alloc] initWithSVGKImage: [SVGKImage imageNamed:@"image.svg"]];
   - [self.view addSubview: myImageView];
 
 NB: the "SVGKFastImageView" is the one you want 9 times in 10. The alternative classes (e.g. SVGKLayeredImageView) are for advanced usage.
 
 NB: read the class-comment for each subclass carefully before deciding what to use.
 
 */
@interface SVGKImageView : NSView

@property(nonatomic) BOOL showBorder; /*< mostly for debugging - adds a coloured 1-pixel border around the image */
//@property(nonatomic,strong) SVGKImage* image;

- (void)setImage:(SVGKImage*)image;
- (SVGKImage *)image;

- (id)initWithSVGKImage:(SVGKImage*) im;

//Default initializer for subclasses. Will set the frame of the view and init with an image
- (id)initWithSVGKImage:(SVGKImage*)im frame:(NSRect)theFrame;


@end
