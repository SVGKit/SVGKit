//
//  SVGPattern.m
//  SVGKit
//

#import "SVGPattern.h"

@implementation SVGPattern

#if TARGET_OS_IPHONE

@synthesize color;

+ (SVGPattern *)patternWithUIColor:(UIColor *)color
{
    SVGPattern* p = [[[SVGPattern alloc] init] autorelease];
    p.color = color;
    return p;
}

+ (SVGPattern*)patternWithImage:(UIImage*)image
{
    UIColor* patternImage = [UIColor colorWithPatternImage:image];
    return [self patternWithUIColor:patternImage];
}

#endif

- (CGColorRef)CGColor
{
#if TARGET_OS_IPHONE
    return [self.color CGColor];
#else
    return NULL;
#endif
}

@end
