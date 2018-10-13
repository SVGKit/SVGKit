#import "SVGKPattern.h"

@implementation SVGKPattern

#if TARGET_OS_IPHONE

@synthesize color;

+ (SVGKPattern *)patternWithUIColor:(UIColor *)color
{
    SVGKPattern* p = [[SVGKPattern alloc] init];
    p.color = color;
    return p;
}

+ (SVGKPattern*)patternWithImage:(UIImage*)image
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
