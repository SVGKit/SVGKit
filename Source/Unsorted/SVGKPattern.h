#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#else

#import <Cocoa/Cocoa.h>

#endif

/** lightweight wrapper for UIColor so that we can draw with fill patterns */
@interface SVGKPattern : NSObject
{
}
@property (readwrite, nonatomic) CGColorRef color;

+ (SVGKPattern*)patternWithCGImage:(CGImageRef)cgImage;
+ (SVGKPattern*)patternWithCGColor:(CGColorRef)cgColor;

- (CGColorRef) CGColor;

#if TARGET_OS_IPHONE

+ (SVGKPattern*) patternWithUIColor:(UIColor*)color;
+ (SVGKPattern*) patternWithImage:(UIImage*)image;

#else

+ (SVGKPattern*)patternWithNSColor:(NSColor*)color;
+ (SVGKPattern*)patternWithImage:(NSImage*)image;

#endif

@end
