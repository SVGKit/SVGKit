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
	//SVGDocument *tempDoc = [[SVGDocument alloc] initWithData:d];
	if (tmpImage == nil) {
		return NO;
	}
	if (tmpImage.parseErrorsAndWarnings.libXMLFailed || [tmpImage.parseErrorsAndWarnings.errorsFatal count] || /*SVGs with no size will cause issues!*/![tmpImage hasSize]) {
		return NO;
	}
	return YES;
}

+ (NSImageRep *)imageRepWithData:(NSData *)d
{
	return [[self alloc] initWithData:d];
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
		
		SVGKSource *sour = [[SVGKSource alloc] initWithInputSteam:stream];
		_image = [[SVGKImage alloc] initWithSource:sour];

		
		if (_image == nil || _image.parseErrorsAndWarnings.libXMLFailed || [_image.parseErrorsAndWarnings.errorsFatal count] || /*SVGs with no size will cause issues!*/![_image hasSize]) {
			//[self autorelease];
			return nil;
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


- (BOOL)draw
{
	CGContextRef CGCtx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];

	CGAffineTransform scaleTrans = CGContextGetCTM(CGCtx);
	
	self.image.scale = MIN(scaleTrans.a, scaleTrans.d);

	NSImage *tmpImage = self.image.NSImage;
		
	NSRect imageRect;
	imageRect.size = _image.size;
	imageRect.origin = NSMakePoint(0, 0);
	
	[tmpImage drawAtPoint:NSMakePoint(0, 0) fromRect:imageRect operation:NSCompositeCopy fraction:1];
	
	return YES;
}

@end
