#import <Foundation/Foundation.h>
#if !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif

#import <SVGKit/SVGKImageView.h>

/**
 * SVGKit's version of NSImageView or UIImageView - with some improvements over Apple's design
 
 WARNING 1: CAAnimations are NOT supported
 - because of the way this class works, any animations you add to the SVGKImage's CALayerTree *will be ignored*. If you need to animate the elements of an SVG file, use SVGKLayer instead (although that class is missing some of the features of this class, and is a little harder to use)
 
 WARNING 2 (iOS only): UIScrollView requires special-case code
 - Apple's implementation of UIScrollView is badly broken for zooming. To workaround this, you MUST disable the auto-redraw on this class BEFORE zooming a UIScrollView. You can re-enable it after the zoom has finished. You MUST ALSO make a manual call to "fix" the transform of the view each time Apple sends you the "didFinishZooming:atScale" method. There is an example of this in the demo project (currently named "iOS-Demo.xcodeproj") showing exactly how to do this. It only requires 2 lines of code, but Apple's documentation makes it clear that this is the only way to work in harmony with UIScrollView's internal hacks.
 - to disable auto-redraw-on-resize, set the BOOL: disableAutoRedrawAtHighestResolution to FALSE
 
 Basic usage (OS X):
 - as per NSImageView, simpy:
 - SVGKImageView *skv = [[SVGKImageView alloc] initWithSVGKImage: [SVGKImage imageNamed:@"image.svg"]];
 - [view addSubview: skv];
 
 Basic usage (iOS):
 - as per UIImageView, simpy:
 - SVGKImageView *skv = [[SVGKImageView alloc] initWithSVGKImage: [SVGKImage imageNamed:@"image.svg"]];
 - [self.view addSubview: skv];

 Advanced usage:
 - to make the contents shrink to half their actual size, and tile to fill, set self.tileRatio = CGSizeMake( 2.0f, 2.0f );
 NOTE: I'd prefer to do this view UIViewContentMode, but Apple didn't make it extensible
 - to disable tiling (by default, it's disabled), set self.tileRatio = CGSizeZero, and all the tiling will be side-stepped
 - FOR VERY ADVANCED USAGE: instead of this class, use the lower-level "SVGKLayeredImageView" class, which lets you modify every individual layer
 
 Performance:
 - NOTE: the way this works - calling Apple's renderInContext: method - MAY BE artificially slow, because of Apple's implementation
 - NOTE: you MUST NOT call SVGKImage.CALayerTree.transform - that will have unexpected side-effects, because of Apple's implementation
 (hence: we currently use renderInContext:, even though we'd prefer not to :( )
 */
@interface SVGKFastImageView : SVGKImageView

@property(nonatomic) CGSize tileRatio;
@property(nonatomic,strong) SVGKImage* image;
#if TARGET_OS_IPHONE
@property(nonatomic) BOOL disableAutoRedrawAtHighestResolution;
#endif

/** Connvenience function to the text and gradient checkers
 */
#if !TARGET_OS_IPHONE
+(BOOL)svgImage:(SVGKImage*)theImage hasNoClass:(Class)theClass;
+(BOOL)svgElementAndDescendents:(SVGElement*)element haveNoClass:(Class)theClass;
#endif

/** Apple has a bug in CALayer where their renderInContext: method does not respect Apple's own mask layers.
 
 This is required to render SVGGradientElement's, and it is NOT a bug in SVGKit - it's in Apple's code. Until we
 can invent a workaround (or Apple fixes their bug), it's best to warn developers that their SVG will NOT render
 correctly
 */
+(BOOL)svgImageHasNoGradients:(SVGKImage*) image;
+(BOOL)svgElementAndDescendentsHaveNoGradients:(SVGElement*) element;

#if !TARGET_OS_IPHONE
/** The text implementation on OS X is different between CALayers and NSViews. If the CALayer is made in 
 SVGKLayeredImageView, it renders right-side up. Otherwise, it is upside-down.
 */
+(BOOL)svgImageHasNoText:(SVGKImage*)image;
+(BOOL)svgElementAndDescendentsHaveNoText:(SVGElement*) element DEPRECATED_ATTRIBUTE;
#endif

@end
