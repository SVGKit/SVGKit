#import <SVGKit/SVGKPattern.h>

//Code taken from TBColor from https://github.com/zrxq/TBColor
static void ImagePatternCallback (void *imagePtr, CGContextRef ctx) {
    CGContextDrawImage(ctx, CGRectMake(0, 0, CGImageGetWidth(imagePtr), CGImageGetHeight(imagePtr)), imagePtr);
}

static void ImageReleaseCallback(void *imagePtr) {
    CGImageRelease(imagePtr);
}

static CGColorRef CGColorMakeFromImage(CGImageRef image) {
    static const CGPatternCallbacks callback = {0, ImagePatternCallback, ImageReleaseCallback};
    CGPatternRef pattern = CGPatternCreate(CGImageRetain(image), CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), CGAffineTransformIdentity, CGImageGetWidth(image), CGImageGetHeight(image), kCGPatternTilingConstantSpacing, true, &callback);
    CGColorSpaceRef coloredPatternColorSpace = CGColorSpaceCreatePattern(NULL);
    CGFloat dummy = 1.0f;
    CGColorRef color = CGColorCreateWithPattern(coloredPatternColorSpace, pattern, &dummy);
    CGColorSpaceRelease(coloredPatternColorSpace);
    CGPatternRelease(pattern);
    return color;
}
//end taken code

@implementation SVGKPattern

@synthesize color;
- (void)setColor:(CGColorRef)aColor
{
	if (color != aColor) {
		if (color) {
			CGColorRelease(color);
		}
		if (aColor) {
			color = CGColorRetain(aColor);
		} else {
			color = NULL;
		}
	}
}

+ (SVGKPattern*)patternWithCGImage:(CGImageRef)cgImage
{
	SVGKPattern *p;
	
	CGColorRef tmpColor = CGColorMakeFromImage(cgImage);
	p = [SVGKPattern patternWithCGColor:tmpColor];
	CGColorRelease(tmpColor);
	
	return p;
}

+ (SVGKPattern*)patternWithCGColor:(CGColorRef)cgColor
{
	SVGKPattern *p = [[SVGKPattern alloc] init];
	
	p.color = cgColor;
	
	return p;
}

#if TARGET_OS_IPHONE

+ (SVGKPattern *)patternWithUIColor:(UIColor *)color
{
	return [self patternWithCGColor:[color CGColor]];
}

+ (SVGKPattern*)patternWithImage:(UIImage*)image
{
    return [self patternWithUIColor:[[UIColor alloc] initWithPatternImage:image]];
}

#else

+ (SVGKPattern*)patternWithImage:(NSImage*)image
{
	CGImageRef quartzImage = [image CGImageForProposedRect:NULL context:NULL hints:NULL];
	return [self patternWithCGImage:quartzImage];
}


+ (SVGKPattern*)patternWithNSColor:(NSColor*)color
{
	if ([color respondsToSelector:@selector(CGColor)]) {
		return [self patternWithCGColor:color.CGColor];
	} else {
		if ([[color colorSpace] colorSpaceModel] == NSPatternColorSpaceModel) {
			return [self patternWithImage:[color patternImage]];
		} else {
			DDLogWarn(@"The color %@ is not a pattern color. Attempting to convert to CGColor", [color description]);
			CGColorSpaceRef spaceRef = [[color colorSpace] CGColorSpace];
			if (!spaceRef) {
				DDLogError(@"Could not get CGColorSpace from the color %@", [color description]);
				return nil;
			}
			NSInteger colorComponents = 0;
			@try {
				colorComponents = [color numberOfComponents];
			}
			@catch (NSException *exception) {
				DDLogError(@"Color %@ does not have components", [color description]);
				return nil;
			}
			CGFloat * components = malloc(sizeof(CGFloat) * colorComponents);
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
    return self.color;
}

- (void)dealloc
{
	self.color = NULL;
}

@end
