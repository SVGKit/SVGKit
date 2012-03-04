//
//  SVGPattern.h
//  SVGKit
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#endif

/** lightweight wrapper for UIColor so that we can draw with fill patterns */
@interface SVGPattern : NSObject
{
}

#if TARGET_OS_IPHONE

+ (SVGPattern*) patternWithUIColor:(UIColor*)color;
+ (SVGPattern*) patternWithImage:(UIImage*)image;

@property (readwrite,nonatomic,retain) UIColor* color;

#else

#endif

- (CGColorRef) CGColor;

@end
