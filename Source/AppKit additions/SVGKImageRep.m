//
//  SVGKitImageRep.m
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import "SVGKit.h"
#import "SVGKSourceData.h"
#import "SVGKSourceLocalFile.h"
#import "SVGKSourceURL.h"

#import "SVGKImageRep.h"
#import <Lumberjack/Lumberjack.h>

@interface SVGKImage ()
-(void) renderToContext:(CGContextRef) context antiAliased:(BOOL) shouldAntialias curveFlatnessFactor:(CGFloat) multiplyFlatness interpolationQuality:(CGInterpolationQuality) interpolationQuality flipYaxis:(BOOL) flipYaxis;
@end

@interface SVGKImageRep ()
@property (nonatomic, retain, readwrite, setter = setTheSVG:) SVGKImage *image;
@end

@implementation SVGKImageRep

- (NSData *)TIFFRepresentationWithSize:(NSSize)theSize
{
	self.image.size = theSize;
	return [self.image.bitmapImageRep TIFFRepresentation];
}

- (NSData *)TIFFRepresentation
{
	return [self TIFFRepresentationWithSize:self.size];
}

- (NSData *)TIFFRepresentationUsingCompression:(NSTIFFCompression)comp factor:(float)factor
{
	return [self TIFFRepresentationUsingCompression:comp factor:factor size:self.size];
}

- (NSData *)TIFFRepresentationUsingCompression:(NSTIFFCompression)comp factor:(float)factor size:(NSSize)asize
{
	self.image.size = asize;
	return [self.image.bitmapImageRep TIFFRepresentationUsingCompression:comp factor:factor];
}

+ (NSArray *)imageUnfilteredFileTypes
{
	static NSArray *types = nil;
	if (types == nil) {
		types = [[NSArray alloc] initWithObjects:@"svg", nil];
	}
	return types;
}

+ (NSArray *)imageUnfilteredTypes
{
	static NSArray *UTItypes = nil;
	if (UTItypes == nil) {
		UTItypes = [[NSArray alloc] initWithObjects:@"public.svg-image", nil];
	}
	return UTItypes;
}

+ (NSArray *)imageUnfilteredPasteboardTypes
{
	/* TODO */
	return nil;
}

+ (BOOL)canInitWithData:(NSData *)d
{
	SVGKParseResult *parseResult = nil;
	@autoreleasepool {
		parseResult = [[SVGKParser parseSourceUsingDefaultSVGKParser:[SVGKSourceData sourceFromData:d]] retain];
	}
	if (parseResult == nil) {
		return NO;
	}
	if (!parseResult.parsedDocument) {
		[parseResult release];
		return NO;
	}
	[parseResult release];
	return YES;
}

+ (id)imageRepWithData:(NSData *)d
{
	return [[[self alloc] initWithData:d] autorelease];
}

+ (id)imageRepWithContentsOfFile:(NSString *)filename
{
	return [[[self alloc] initWithContentsOfFile:filename] autorelease];
}

+ (id)imageRepWithContentsOfURL:(NSURL *)url
{
	return [[[self alloc] initWithContentsOfURL:url] autorelease];
}

+ (id)imageRepWithSVGSource:(SVGKSource*)theSource
{
	return [[[self alloc] initWithSVGSource:theSource] autorelease];
}

+ (id)imageRepWithSVGImage:(SVGKImage*)theImage
{
	return [[[self alloc] initWithSVGImage:theImage] autorelease];
}

+ (void)load
{
	[self loadSVGKImageRep];
}

- (id)initWithData:(NSData *)theData
{
	return [self initWithSVGSource:[SVGKSourceData sourceFromData:theData]];
}

- (id)initWithContentsOfURL:(NSURL *)theURL
{
	return [self initWithSVGSource:[SVGKSourceURL sourceFromURL:theURL]];
}

- (id)initWithContentsOfFile:(NSString *)thePath
{
	return [self initWithSVGSource:[SVGKSourceLocalFile sourceFromFilename:thePath]];
}

- (id)initWithSVGString:(NSString *)theString
{
	return [self initWithSVGSource:[SVGKSourceData sourceFromContentsOfString:theString]];
}

- (void)setSize:(NSSize)aSize sizeImage:(BOOL)theSize
{
	[super setSize:aSize];
	[self setPixelsHigh:ceil(aSize.height)];
	[self setPixelsWide:ceil(aSize.width)];
	if (theSize) {
		self.image.size = aSize;
	}
}

- (id)initWithSVGSource:(SVGKSource*)theSource
{
	if (self = [super init]) {
		self.image = [SVGKImage imageWithSource:theSource];
		if (self.image == nil) {
			[self autorelease];
			return nil;
		}
		
		BOOL hasGrad = ![SVGKFastImageView svgImageHasNoGradients:self.image];
		BOOL hasText = ![SVGKFastImageView svgImageHasNoText:self.image];
		
		if (hasGrad || hasText) {
			NSString *errstuff = nil;
			
			if (hasGrad) {
				errstuff = @"gradients";
				if (hasText) {
					errstuff = [errstuff stringByAppendingString:@" and text"];
				}
			} else if (hasText) {
				errstuff = @"text";
			}
			
			if (errstuff == nil) {
				//We shouldn't get here!
				errstuff = @"";
			}
			
			DDLogWarn(@"[%@] The image \"%@\" might have problems rendering correctly due to %@.", [self class], [self image], errstuff);
		}
		
		if (![self.image hasSize]) {
			self.image.size = CGSizeMake(32, 32);
		}
		
		[self setColorSpaceName:NSCalibratedRGBColorSpace];
		[self setAlpha:YES];
		[self setBitsPerSample:0];
		[self setOpaque:NO];
		{
			NSSize renderSize = self.image.size;
			[self setSize:renderSize sizeImage:NO];
		}
	}
	return self;
}


- (void)setSize:(NSSize)aSize
{
	[self setSize:aSize sizeImage:YES];
}

+ (void)loadSVGKImageRep
{
	[NSImageRep registerImageRepClass:[SVGKImageRep class]];
}

+ (void)unloadSVGKImageRep
{
	[NSImageRep unregisterImageRepClass:[SVGKImageRep class]];
}

- (id)initWithSVGImage:(SVGKImage*)theImage
{
	return [self initWithSVGSource:[[theImage.source copy] autorelease]];
}

- (void)dealloc
{
	self.image = nil;
	
	[super dealloc];
}

- (BOOL)drawInRect:(NSRect)rect
{
	NSSize scaledSize = rect.size;
	if (!CGSizeEqualToSize(self.image.size, scaledSize)) {
		//For when we're at the full size.
		if (CGSizeEqualToSize(CGSizeMake(self.pixelsWide, self.pixelsHigh), scaledSize)) {
			return [super drawInRect:rect];
		} else {
			[self.image scaleToFitInside:scaledSize];
		}
	} else if (CGSizeEqualToSize(CGSizeMake(self.pixelsWide, self.pixelsHigh), scaledSize) &&
			   CGSizeEqualToSize(self.image.size, CGSizeMake(self.pixelsWide, self.pixelsHigh))) {
		return [super drawInRect:rect];
	}
	if ([self.image respondsToSelector:@selector(renderToContext:antiAliased:curveFlatnessFactor:interpolationQuality:flipYaxis:)]) {
		//We'll use this because it's probably faster, and we're drawing almost directly to the graphics context...
		CGContextRef imRepCtx = [[NSGraphicsContext currentContext] graphicsPort];
		CGLayerRef layerRef = CGLayerCreateWithContext(imRepCtx, rect.size, NULL);
		if (!layerRef) {
			return NO;
		}
		
		CGContextRef layerCont = CGLayerGetContext(layerRef);
		CGContextSaveGState(layerCont);
		[self.image renderToContext:layerCont antiAliased:YES curveFlatnessFactor:1.0 interpolationQuality:kCGInterpolationDefault flipYaxis:YES];
		CGContextRestoreGState(layerCont);
		
		CGContextDrawLayerInRect(imRepCtx, rect, layerRef);
		CGLayerRelease(layerRef);
	} else {
		//...But should the method be removed in a future version, fall back to the old method
		NSImage *tmpImage = [[NSImage alloc] initWithSize:scaledSize];
		if (!tmpImage) {
			return NO;
		}
		
		NSBitmapImageRep *bitRep = self.image.bitmapImageRep;
		if (!bitRep) {
			return NO;
		}
		[tmpImage addRepresentation:bitRep];
		
		NSRect imageRect;
		imageRect.size = rect.size;
		imageRect.origin = NSZeroPoint;
		
		[tmpImage drawAtPoint:rect.origin fromRect:imageRect operation:NSCompositeCopy fraction:1];
		[tmpImage release];
	}
	
	return YES;
}

- (BOOL)draw
{
	//Just in case someone resized the image rep.
	NSSize scaledSize = self.size;
	if (!CGSizeEqualToSize(self.image.size, scaledSize)) {
		self.image.size = scaledSize;
	}
	if ([self.image respondsToSelector:@selector(renderToContext:antiAliased:curveFlatnessFactor:interpolationQuality:flipYaxis:)]) {
		//We'll use this because it's probably faster, and we're drawing almost directly to the graphics context...
		CGContextRef imRepCtx = [[NSGraphicsContext currentContext] graphicsPort];
		CGLayerRef layerRef = CGLayerCreateWithContext(imRepCtx, scaledSize, NULL);
		if (!layerRef) {
			return NO;
		}
		
		CGContextRef layerCont = CGLayerGetContext(layerRef);
		CGContextSaveGState(layerCont);
		[self.image renderToContext:layerCont antiAliased:YES curveFlatnessFactor:1.0 interpolationQuality:kCGInterpolationDefault flipYaxis:YES];
		CGContextRestoreGState(layerCont);
		
		CGContextDrawLayerAtPoint(imRepCtx, CGPointZero, layerRef);
		CGLayerRelease(layerRef);
	} else {
		//...But should the method be removed in a future version, fall back to the old method
		NSImage *tmpImage = [[NSImage alloc] initWithSize:scaledSize];
		if (!tmpImage) {
			return NO;
		}
		
		NSBitmapImageRep *bitRep = self.image.bitmapImageRep;
		if (!bitRep) {
			return NO;
		}
		[tmpImage addRepresentation:bitRep];
		
		NSRect imageRect;
		imageRect.size = self.size;
		imageRect.origin = NSZeroPoint;
		
		[tmpImage drawAtPoint:NSZeroPoint fromRect:imageRect operation:NSCompositeCopy fraction:1];
		[tmpImage release];
	}
	
	return YES;
}

@end

@implementation SVGKImageRep (deprecated)

#define DEPRECATE_WARN_ONCE(NewMethodSel) { \
static BOOL HasBeenWarned = NO; \
if (HasBeenWarned == NO) \
{ \
DDLogWarn(@"[%@] -[SVGKitImageRep %s] has been deprecated, use -[SVGKitImageRep %s] instead.", \
[self class], sel_getName(_cmd), sel_getName(NewMethodSel)); \
HasBeenWarned = YES; \
} \
}

- (id)initWithPath:(NSString *)thePath
{
	DEPRECATE_WARN_ONCE(@selector(initWithContentsOfPath:));
	return [self initWithContentsOfFile:thePath];
}

- (id)initWithURL:(NSURL *)theURL
{
	DEPRECATE_WARN_ONCE(@selector(initWithContentsOfURL:));
	return [self initWithContentsOfURL:theURL];
}

#undef DEPRECATE_WARN_ONCE

@end
