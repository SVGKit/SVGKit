//
//  SVGKitImageRep.m
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

//This will cause problems...
#define Comment AIFFComment
#include <CoreServices/CoreServices.h>
#undef Comment

#import "SVGKit.h"

#import "SVGKitImageRep.h"
#import "SVGKSourceLocalFile.h"
#import "SVGKSourceURL.h"

@interface SVGKitImageRep ()
- (id)initWithSVGSource:(SVGKSource*)theSource;

@property (nonatomic, strong, readwrite, setter = setTheSVG:) SVGKImage *image;
@end

@implementation SVGKitImageRep

- (NSData *)TIFFRepresentation
{
	return [self.image.bitmapImageRep TIFFRepresentation];
}

- (NSData *)TIFFRepresentationUsingCompression:(NSTIFFCompression)comp factor:(float)factor
{
	return [self.image.bitmapImageRep TIFFRepresentationUsingCompression:comp factor:factor];
}

+ (NSArray *)imageUnfilteredFileTypes
{
	static NSArray *types = nil;
	if (types == nil) {
		types = @[@"svg"];
	}
	return types;
}

+ (NSArray *)imageUnfilteredTypes
{
	static NSArray *UTItypes = nil;
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
	SVGKParseResult *parseResult = nil;
	@autoreleasepool {
		parseResult = [SVGKParser parseSourceUsingDefaultSVGKParser:[SVGKSource sourceFromData:d]];
	}
	if (parseResult == nil) {
		return NO;
	}
	if (parseResult.libXMLFailed || [parseResult.errorsFatal count]) {
		return NO;
	}
	return YES;
}

+ (NSImageRep *)imageRepWithData:(NSData *)d
{
	return [[self alloc] initWithData:d];
}

+ (id)imageRepWithContentsOfFile:(NSString *)filename
{
	return [[self alloc] initWithPath:filename];
}

+ (id)imageRepWithContentsOfURL:(NSURL *)url
{
	return [[self alloc] initWithURL:url];
}

+ (void)load
{
	[NSImageRep registerImageRepClass:[SVGKitImageRep class]];
}

- (id)initWithData:(NSData *)theData
{
	return [self initWithSVGSource:[SVGKSource sourceFromData:theData]];
}

- (id)initWithURL:(NSURL *)theURL
{
	return [self initWithSVGSource:[SVGKSourceURL sourceFromURL:theURL]];
}

- (id)initWithPath:(NSString *)thePath
{
	return [self initWithSVGSource:[SVGKSourceLocalFile sourceFromFilename:thePath]];
}

- (id)initWithSVGString:(NSString *)theString
{
	return [self initWithSVGSource:[SVGKSource sourceFromContentsOfString:theString]];
}

- (id)initWithSVGSource:(SVGKSource*)theSource
{
	if (self = [super init]) {
		self.image = [[SVGKImage alloc] initWithSource:theSource];
		if (self.image == nil || self.image.parseErrorsAndWarnings.libXMLFailed || [self.image.parseErrorsAndWarnings.errorsFatal count]) {
			return nil;
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
			[self setSize:renderSize];
			[self setPixelsHigh:ceil(renderSize.height)];
			[self setPixelsWide:ceil(renderSize.width)];
		}
	}
	return self;
}

- (BOOL)draw
{
	//Just in case someone resized the image rep.
	NSSize scaledSize = self.size;
	if (!CGSizeEqualToSize(self.image.size, scaledSize)) {
		[self.image scaleToFitInside:scaledSize];
	}
	
	NSImage *tmpImage = self.image.NSImage;
	if (!tmpImage) {
		return NO;
	}
	
	NSRect imageRect;
	imageRect.size = self.size;
	imageRect.origin = NSZeroPoint;
	
	[tmpImage drawAtPoint:NSZeroPoint fromRect:imageRect operation:NSCompositeCopy fraction:1];
	
	return YES;
}

@end
