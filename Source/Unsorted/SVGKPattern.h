#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#endif

/** lightweight wrapper for UIColor so that we can draw with fill patterns */
@interface SKPattern : NSObject
{
}

#if TARGET_OS_IPHONE

+ (SKPattern*) patternWithUIColor:(UIColor*)color;
+ (SKPattern*) patternWithImage:(UIImage*)image;

@property (readwrite,nonatomic,retain) UIColor* color;

#else

#endif

- (CGColorRef) CGColor;

@end
