#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#endif

/** lightweight wrapper for UIColor so that we can draw with fill patterns */
@interface SVGKPattern : NSObject
{
}

#if TARGET_OS_IPHONE

+ (SVGKPattern*) patternWithUIColor:(UIColor*)color;
+ (SVGKPattern*) patternWithImage:(UIImage*)image;

@property (readwrite,nonatomic,strong) UIColor* color;

#else

#endif

- (CGColorRef) CGColor;

@end
