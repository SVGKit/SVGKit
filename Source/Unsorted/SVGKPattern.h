#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#else

#import <AppKit/AppKit.h>

#endif

/** lightweight wrapper for UIColor so that we can draw with fill patterns */
@interface SVGKPattern : NSObject
{
}

#if TARGET_OS_IPHONE

+ (SVGKPattern*) patternWithUIColor:(UIColor*)color;
+ (SVGKPattern*) patternWithImage:(UIImage*)image;

@property (readwrite,nonatomic,retain) UIColor* color;

#else

@property (readwrite, nonatomic) CGColorRef color;

+ (SVGKPattern*)patternWithImage:(NSImage*)image;

#endif

+ (SVGKPattern*)patternWithCGImage:(CGImageRef)cgImage;
+ (SVGKPattern*)patternWithCGColor:(CGColorRef)cgColor;

- (CGColorRef) CGColor;

@end
