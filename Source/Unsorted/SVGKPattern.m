#import "SVGKPattern.h"

@implementation SVGKPattern

#if TARGET_OS_IPHONE

@synthesize color;

+ (SVGKPattern *)patternWithUIColor:(UIColor *)color
{
    SVGKPattern* p = [[[SVGKPattern alloc] init] autorelease];
    p.color = color;
    return p;
}

+ (SVGKPattern*)patternWithImage:(UIImage*)image
{
    UIColor* patternImage = [UIColor colorWithPatternImage:image];
    return [self patternWithUIColor:patternImage];
}

+ (SVGKPattern*)patternWithCGImage:(CGImageRef)cgImage
{
	return [self patternWithImage:[UIImage imageWithCGImage:cgImage]];
}

+ (SVGKPattern*)patternWithCGColor:(CGColorRef)cgColor
{
	return [self patternWithUIColor:[UIColor colorWithCGColor:cgColor]];
}

#else

//Code taken from TBColor from https://github.com/zrxq/TBColor
static void ImagePatternCallback (void *imagePtr, CGContextRef ctx) {
    CGContextDrawImage(ctx, CGRectMake(0, 0, CGImageGetWidth(imagePtr), CGImageGetHeight(imagePtr)), imagePtr);
}

static void ImageReleaseCallback(void *imagePtr) {
    CGImageRelease(imagePtr);
}

static CGColorRef CGColorMakeFromImage(CGImageRef CF_CONSUMED image) {
    static const CGPatternCallbacks callback = {0, ImagePatternCallback, ImageReleaseCallback};
    CGPatternRef pattern = CGPatternCreate(image, NSMakeRect(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), CGAffineTransformIdentity, CGImageGetWidth(image), CGImageGetHeight(image), kCGPatternTilingConstantSpacing, true, &callback);
    CGColorSpaceRef coloredPatternColorSpace = CGColorSpaceCreatePattern(NULL);
    CGFloat dummy = 1.0f;
    CGColorRef color = CGColorCreateWithPattern(coloredPatternColorSpace, pattern, &dummy);
    CGColorSpaceRelease(coloredPatternColorSpace);
    CGPatternRelease(pattern);
    return color;
}
//end taken code

+ (SVGKPattern*)patternWithImage:(NSImage*)image
{
	CGImageRef quartzImage = [image CGImageForProposedRect:NULL context:NULL hints:NULL];
	SVGKPattern *p = [self patternWithCGImage:quartzImage];
	CGImageRelease(quartzImage);
	return p;
}

+ (SVGKPattern*)patternWithCGImage:(CGImageRef)cgImage
{
	SVGKPattern *p = nil;
	
	CGImageRetain(cgImage);
	CGColorRef tmpColor = CGColorMakeFromImage(cgImage);
	p = [SVGKPattern patternWithCGColor:tmpColor];
	CGColorRelease(tmpColor);
	
	return p;
}

+ (SVGKPattern*)patternWithCGColor:(CGColorRef)cgColor
{
	SVGKPattern *p = [[SVGKPattern alloc] init];
	
	p.color = cgColor;
	
	return [p autorelease];
}

+ (SVGKPattern*)patternWithNSColor:(NSColor*)color
{
	if ([color respondsToSelector:@selector(CGColor)]) {
		return [self patternWithCGColor:color.CGColor];
	} else {
		if ([[color colorSpace] colorSpaceModel] == NSPatternColorSpaceModel) {
			return [self patternWithImage:[color patternImage]];
		} else {
			CGColorSpaceRef spaceRef = [[color colorSpace] CGColorSpace];
			CGFloat * components = malloc(sizeof(CGFloat) * [color numberOfComponents]);
			[color getComponents:components];
			CGColorRef tmpColor = CGColorCreate(spaceRef, components);
			free(components);
			SVGKPattern *p = [SVGKPattern patternWithCGColor:tmpColor];
			CGColorRelease(tmpColor);
			return p;
		}
	}
}

#endif

- (CGColorRef)CGColor
{
#if TARGET_OS_IPHONE
    return [self.color CGColor];
#else
    return self.color;
#endif
}

- (void)dealloc
{
#if TARGET_OS_IPHONE
	[color release];
#else
	self.color = NULL;
#endif
	
	[super dealloc];
}

#if !TARGET_OS_IPHONE
- (void)finalize
{
	self.color = NULL;
	
	[super finalize];
}
#endif

@end
