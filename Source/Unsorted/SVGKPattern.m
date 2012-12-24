#import "SVGKPattern.h"

@implementation SKPattern

#if TARGET_OS_IPHONE

@synthesize color;

+ (SKPattern *)patternWithUIColor:(UIColor *)color
{
    SKPattern* p = [[[SKPattern alloc] init] autorelease];
    p.color = color;
    return p;
}

+ (SKPattern*)patternWithImage:(UIImage*)image
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
