//
//  SVGKitImageRep.m
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import "SVGKitImageRep.h"

@implementation SVGKitImageRep

@synthesize image = _image;

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
	NSInputStream* stream = [NSInputStream inputStreamWithData:d];
	[stream open];

	SVGKSource *sour = [[SVGKSource alloc] initWithInputSteam:stream];
	SVGKImage *tmpImage = [[SVGKImage alloc] initWithSource:sour];
	[sour release];
	//SVGDocument *tempDoc = [[SVGDocument alloc] initWithData:d];
	if (tmpImage == nil) {
		return NO;
	}
	if (tmpImage.parseErrorsAndWarnings.libXMLFailed || [tmpImage.parseErrorsAndWarnings.errorsFatal count]) {
		[tmpImage release];
		return NO;
	}
	[tmpImage release];
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
		
		NSInputStream* stream = [NSInputStream inputStreamWithData:theData];
		[stream open];
		@autoreleasepool {
			SVGKSource *sour = [[SVGKSource alloc] initWithInputSteam:stream];
			_image = [[SVGKImage alloc] initWithSource:sour];
			[sour release];
		}

		
		if (_image == nil || _image.parseErrorsAndWarnings.libXMLFailed || [_image.parseErrorsAndWarnings.errorsFatal count]) {
			[self autorelease];
			return nil;
		}
		if (![_image hasSize]) {
			_image.size = CGSizeMake(32, 32);
		}

		[self setColorSpaceName:NSCalibratedRGBColorSpace];
		[self setAlpha:YES];
		[self setBitsPerSample:0];
		[self setOpaque:NO];
		{
			
			NSSize renderSize = _image.size;
			[self setSize:renderSize];
			[self setPixelsHigh:ceil(renderSize.height)];
			[self setPixelsWide:ceil(renderSize.width)];

		}

	}
	return self;
}

- (void)dealloc
{
	[_image release];
	
	[super dealloc];
}

- (BOOL)draw
{
	@autoreleasepool {
		CGContextRef CGCtx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
		
		CGAffineTransform scaleTrans = CGContextGetCTM(CGCtx);
		
		_image.scale = MIN(scaleTrans.a, scaleTrans.d);
		
		NSImage *tmpImage = _image.NSImage;
		
		NSRect imageRect;
		imageRect.size = _image.size;
		imageRect.origin = NSMakePoint(0, 0);
		
		[tmpImage drawAtPoint:NSMakePoint(0, 0) fromRect:imageRect operation:NSCompositeCopy fraction:1];
		
		return YES;
	}
}

@end
