#import <Foundation/Foundation.h>
#if !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif
#import <SVGKit/SVGKImageView.h>

/**
 * SVGKit's ADVANCED version of NSImageView - for most cases, you want to use the simple version instead (SVGKImageView)
 
 This class is similar to SVGKImageView, but it DOES NOT HAVE the performance optimizations, and it WILL NOT AUTO-DRAW AT FULL RESOLUTION.
 
 However, it DOES SUPPORT CORE ANIMATION (which SVGKImageView cannot do), and in some cases that's more important.
 
 Basic usage:
 - as per SVGKImageView:
 - SVGKLayeredImageView *skv = [[SVGKLayeredImageView alloc] initWithSVGKImage: [SVGKImage imageNamed:@"image.svg"]];
 - [self.view addSubview: skv];
 
 Advanced usage:
 - to access the underlying layers, typecast the .layer property:
   - SVGKLayeredImageView *skv = [[SVGKLayeredImageView alloc] initWithSVGKImage: [SVGKImage imageNamed:@"image.svg"]];
   - SVGKLayer* layer = (SVGKLayer*) skv.layer;
 
 */

@interface SVGKLayeredImageView : SVGKImageView
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end
