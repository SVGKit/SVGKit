//
//  SVGKitImageRep.m
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import <SVGKit/SVGKit.h>
#import <SVGKit/SVGKSourceNSData.h>
#import <SVGKit/SVGKSourceLocalFile.h>
#import <SVGKit/SVGKSourceURL.h>
#include <tgmath.h>

#import <SVGKit/SVGKImageRep.h>
#import "SVGKImageRep-private.h"
#import "SVGKImage-private.h"
#import <Lumberjack/Lumberjack.h>
#import "SVGKImage+CGContext.h"
#import "BlankSVG.h"

@interface SVGKImageRep ()
@property (nonatomic, strong, readwrite, setter = setTheSVG:) SVGKImage *image;
@end

@implementation SVGKImageRep

@synthesize curveFlatness = _curveFlatness;
@synthesize antiAlias = _antiAlias;
@synthesize interpolationQuality = _interpolQuality;

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
	static NSArray *types;
	if (types == nil) {
		types = @[@"svg"];
	}
	return types;
}

+ (NSArray *)imageUnfilteredTypes
{
	static NSArray *UTItypes;
	if (UTItypes == nil) {
		UTItypes = @[@"public.svg-image"];
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
	SVGKParseResult *parseResult;
	@autoreleasepool {
		parseResult = [SVGKParser parseSourceUsingDefaultSVGKParser:[[SVGKSourceNSData alloc] initWithData:d]];
	}
	if (parseResult == nil) {
		return NO;
	}
	if (!parseResult.parsedDocument) {
		return NO;
	}
	return YES;
}

+ (instancetype)imageRepWithData:(NSData *)d
{
	return [[self alloc] initWithData:d];
}

+ (instancetype)imageRepWithContentsOfFile:(NSString *)filename
{
	return [[self alloc] initWithContentsOfFile:filename];
}

+ (instancetype)imageRepWithContentsOfURL:(NSURL *)url
{
	return [[self alloc] initWithContentsOfURL:url];
}

+ (instancetype)imageRepWithSVGSource:(SVGKSource*)theSource
{
	return [[self alloc] initWithSVGSource:theSource];
}

+ (instancetype)imageRepWithSVGImage:(SVGKImage*)theImage
{
	return [[self alloc] initWithSVGImage:theImage];
}

+ (void)load
{
	[self loadSVGKImageRep];
}

- (instancetype)initWithData:(NSData *)theData
{
	return [self initWithSVGImage:[[SVGKImage alloc] initWithData:theData] copy:NO];
}

- (instancetype)initWithContentsOfURL:(NSURL *)theURL
{
	return [self initWithSVGImage:[[SVGKImage alloc] initWithContentsOfURL:theURL] copy:NO];
}

- (instancetype)initWithContentsOfFile:(NSString *)thePath
{
	return [self initWithSVGImage:[[SVGKImage alloc] initWithContentsOfFile:thePath] copy:NO];
}

- (instancetype)initWithSVGString:(NSString *)theString
{
	return [self initWithSVGSource:[SVGKSourceNSData sourceFromContentsOfString:theString]];
}

- (instancetype)initWithSVGSource:(SVGKSource*)theSource
{
	return [self initWithSVGImage:[[SVGKImage alloc] initWithSource:theSource] copy:NO];
}

- (instancetype)initWithSVGImage:(SVGKImage*)theImage copy:(BOOL)copyImage
{
	if (self = [super init]) {
		if (theImage == nil) {
			return nil;
		}
		SVGKImage *tmpImage;
		if (copyImage) {
			tmpImage = [theImage copy];
			if (tmpImage) {
				theImage = tmpImage;
			}
		}
		
		self.image = theImage;
		
		BOOL hasGrad = ![SVGKFastImageView svgImageHasNoGradients:self.image];
		BOOL hasText = ![SVGKFastImageView svgImageHasNoText:self.image];
		
		if (hasGrad || hasText) {
			NSString *errstuff;
			
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
		
        self.colorSpaceName = NSCalibratedRGBColorSpace;
        self.alpha = YES;
        self.bitsPerSample = 0;
        self.opaque = NO;
		[self setSize:self.image.size sizeImage:NO];
		self.interpolationQuality = kCGInterpolationDefault;
		self.antiAlias = YES;
		self.curveFlatness = 1.0;
	}
	return self;
}

- (instancetype)init
{
    return self = [self initWithSVGString:SVGKGetDefaultImageStringContents()];
}

- (void)setSize:(NSSize)aSize
{
	[self setSize:aSize sizeImage:YES];
}

- (void)setSize:(NSSize)aSize sizeImage:(BOOL)theSize
{
    [super setSize:aSize];
    self.pixelsHigh = ceil(aSize.height);
    self.pixelsWide = ceil(aSize.width);
    if (theSize) {
        self.image.size = aSize;
    }
}

+ (void)loadSVGKImageRep
{
	[NSImageRep registerImageRepClass:[SVGKImageRep class]];
}

+ (void)unloadSVGKImageRep
{
	[NSImageRep unregisterImageRepClass:[SVGKImageRep class]];
}

- (instancetype)initWithSVGImage:(SVGKImage*)theImage
{
	//Copy over the image, just in case
	return [self initWithSVGImage:theImage copy:YES];
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

	CGContextRef imRepCtx = [[NSGraphicsContext currentContext] graphicsPort];
	CGLayerRef layerRef = CGLayerCreateWithContext(imRepCtx, rect.size, NULL);
	if (!layerRef) {
		return NO;
	}

	CGContextRef layerCont = CGLayerGetContext(layerRef);
	CGContextSaveGState(layerCont);
	[self.image renderToContext:layerCont antiAliased:_antiAlias curveFlatnessFactor:_curveFlatness interpolationQuality:_interpolQuality flipYaxis:YES];
	CGContextRestoreGState(layerCont);

	CGContextDrawLayerInRect(imRepCtx, rect, layerRef);
	CGLayerRelease(layerRef);
	
	return YES;
}

- (BOOL)draw
{
	//Just in case someone resized the image rep.
	NSSize scaledSize = self.size;
	if (!CGSizeEqualToSize(self.image.size, scaledSize)) {
		self.image.size = scaledSize;
	}

	CGContextRef imRepCtx = [[NSGraphicsContext currentContext] graphicsPort];
	CGLayerRef layerRef = CGLayerCreateWithContext(imRepCtx, scaledSize, NULL);
	if (!layerRef) {
		return NO;
	}

	CGContextRef layerCont = CGLayerGetContext(layerRef);
	CGContextSaveGState(layerCont);
	[self.image renderToContext:layerCont antiAliased:_antiAlias curveFlatnessFactor:_curveFlatness interpolationQuality:_interpolQuality flipYaxis:YES];
	CGContextRestoreGState(layerCont);

	CGContextDrawLayerAtPoint(imRepCtx, CGPointZero, layerRef);
	CGLayerRelease(layerRef);
	
	return YES;
}

#pragma mark - Inherited protocols

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    SVGKImageRep *toRet = [[SVGKImageRep alloc] initWithSVGImage:self.image];
    
    return toRet;
}

#pragma mark NSCoding
- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}

@end
