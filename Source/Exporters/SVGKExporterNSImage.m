#import "SVGKExporterNSImage.h"

#if SVGKIT_MAC
#import "SVGUtils.h"
#import "SVGKImage+CGContext.h" // needed for Context calls
#import <objc/runtime.h>

@implementation SVGKExporterNSImage

+(NSImage*) exportAsNSImage:(SVGKImage *)image
{
	return [self exportAsNSImage:image antiAliased:TRUE curveFlatnessFactor:1.0 interpolationQuality:kCGInterpolationDefault];
}

+(NSImage*) exportAsNSImage:(SVGKImage*) image antiAliased:(BOOL) shouldAntialias curveFlatnessFactor:(CGFloat) multiplyFlatness interpolationQuality:(CGInterpolationQuality) interpolationQuality
{
	if( [image hasSize] )
	{
		SVGKitLogVerbose(@"[%@] DEBUG: Generating a NSImage using the current root-object's viewport (may have been overridden by user code): {0,0,%2.3f,%2.3f}", [self class], image.size.width, image.size.height);

		SVGKGraphicsBeginImageContextWithOptions( image.size, FALSE, [NSScreen mainScreen].backingScaleFactor);
		CGContextRef context = SVGKGraphicsGetCurrentContext();
		
		[image renderToContext:context antiAliased:shouldAntialias curveFlatnessFactor:multiplyFlatness interpolationQuality:interpolationQuality flipYaxis:TRUE];
		
		NSImage* result = SVGKGraphicsGetImageFromCurrentImageContext();
		SVGKGraphicsEndImageContext();
		
		
		return result;
	}
	else
	{
		NSAssert(FALSE, @"You asked to export an SVG to bitmap, but the SVG file has infinite size. Either fix the SVG file, or set an explicit size you want it to be exported at (by calling .size = something on this SVGKImage instance");
		
		return nil;
	}
}

static void *kNSGraphicsContextScaleFactorKey;

static CGContextRef SVGKCreateBitmapContext(CGSize size, BOOL opaque, CGFloat scale) {
    size_t width = ceil(size.width * scale);
    size_t height = ceil(size.height * scale);
    if (width < 1 || height < 1) return NULL;
    
    //pre-multiplied BGRA for non-opaque, BGRX for opaque, 8-bits per component, as Apple's doc
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGImageAlphaInfo alphaInfo = kCGBitmapByteOrder32Host | (opaque ? kCGImageAlphaNoneSkipFirst : kCGImageAlphaPremultipliedFirst);
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, kCGBitmapByteOrderDefault | alphaInfo);
    CGColorSpaceRelease(space);
    if (!context) {
        return NULL;
    }
    if (scale == 0) {
        // Match `UIGraphicsBeginImageContextWithOptions`, reset to the scale factor of the device’s main screen if scale is 0.
        scale = [NSScreen mainScreen].backingScaleFactor;
    }
    CGContextScaleCTM(context, scale, scale);
    
    return context;
}

static void SVGKGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale) {
    CGContextRef context = SVGKCreateBitmapContext(size, opaque, scale);
    if (!context) {
        return;
    }
    NSGraphicsContext *graphicsContext;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    if ([NSGraphicsContext respondsToSelector:@selector(graphicsContextWithGraphicsPort:flipped:)]) {
        graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
    } else {
        graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
    }
#pragma clang diagnostic pop
    objc_setAssociatedObject(graphicsContext, &kNSGraphicsContextScaleFactorKey, @(scale), OBJC_ASSOCIATION_RETAIN);
    CGContextRelease(context);
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext.currentContext = graphicsContext;
}

static CGContextRef SVGKGraphicsGetCurrentContext(void) {
    NSGraphicsContext *context = NSGraphicsContext.currentContext;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    if ([context respondsToSelector:@selector(CGContext)]) {
        return context.CGContext;
    } else {
        return context.graphicsPort;
    }
#pragma clang diagnostic pop
}

static void SVGKGraphicsEndImageContext(void) {
    [NSGraphicsContext restoreGraphicsState];
}

static NSImage * SVGKGraphicsGetImageFromCurrentImageContext(void) {
    NSGraphicsContext *context = NSGraphicsContext.currentContext;
    CGContextRef contextRef;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    if ([context respondsToSelector:@selector(CGContext)]) {
        contextRef = context.CGContext;
    } else {
        contextRef = context.graphicsPort;
    }
#pragma clang diagnostic pop
    if (!contextRef) {
        return nil;
    }
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    if (!imageRef) {
        return nil;
    }
    CGFloat scale = 0;
    NSNumber *scaleFactor = objc_getAssociatedObject(context, &kNSGraphicsContextScaleFactorKey);
    if ([scaleFactor isKindOfClass:[NSNumber class]]) {
        scale = scaleFactor.doubleValue;
    }
    if (!scale) {
        // reset to the scale factor of the device’s main screen if scale is 0.
        scale = [NSScreen mainScreen].backingScaleFactor;
    }
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    CGFloat pixelWidth = imageRep.pixelsWide;
    CGFloat pixelHeight = imageRep.pixelsHigh;
    NSSize size = NSMakeSize(pixelWidth / scale, pixelHeight / scale);
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image addRepresentation:imageRep];
    CGImageRelease(imageRef);
    return image;
}

@end

#endif /* SVGKIT_MAC */
