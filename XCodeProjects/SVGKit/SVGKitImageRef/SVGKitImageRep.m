//
//  SVGKitImageRep.m
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import "SVGKitImageRep.h"

@implementation SVGKitImageRep

@synthesize document = _document;

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
	SVGDocument *tempDoc = [[SVGDocument alloc] initWithData:d];
	if (tempDoc == nil) {
		return NO;
	}
	[tempDoc release];
	return YES;
}

+ (NSImageRep *)imageRepWithData:(NSData *)d
{
	return [[[self alloc] initWithData:d] autorelease];
}

+ (void)load
{
	[NSImageRep registerImageRepClass:[SVGKitImageRep class]];
}

- (id)initWithData:(NSData *)theData
{
	if (self = [super init]) {
		_document = [[SVGDocument alloc] initWithData:theData];
		[self setColorSpaceName:NSCalibratedRGBColorSpace];
		[self setAlpha:YES];
		[self setBitsPerSample:0];
		[self setOpaque:NO];
		{
			
			NSSize renderSize = NSMakeSize(_document.width, _document.height);
			[self setSize:renderSize];
#if CGFLOAT_IS_DOUBLE
			[self setPixelsHigh:ceil(renderSize.height)];
			[self setPixelsWide:ceil(renderSize.width)];
#else
			[self setPixelsHigh:ceilf(renderSize.height)];
			[self setPixelsWide:ceilf(renderSize.width)];
#endif

		}

	}
	return self;
}

- (void)dealloc
{
	[_document release];
	
	[super dealloc];
}

- (BOOL)draw
{
	CGContextRef CGCtx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];

	[self drawLayer:[_document layerTree] inContext:CGCtx];
	
	return NO;
}

@end
