//
//  ComparisonView.m
//  SVGTester
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "ComparisonView.h"

@implementation ComparisonView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shouldDrawRedGreenOverlay = YES;
    }
    return self;
}

- (void)compareImage:(NSBitmapImageRep *)image withOriginal:(NSBitmapImageRep *)original {
	if (!NSEqualSizes([image size], [original size])) {
		NSLog(@"Invalid image sizes");
		return;
	}
	
	_original = [image retain];
	
	_output = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
													  pixelsWide:image.size.width
													  pixelsHigh:image.size.height
												   bitsPerSample:8
												 samplesPerPixel:3
														hasAlpha:NO
														isPlanar:NO
												  colorSpaceName:NSCalibratedRGBColorSpace
													 bytesPerRow:4 * image.size.width
													bitsPerPixel:32];
	
    for (NSUInteger x = 0; x < _original.size.width; x++) {
		for (NSUInteger y = 0; y < _original.size.height; y++) {
			NSUInteger comps[3];
			[_original getPixel:comps atX:x y:y];
			
			NSUInteger compsTwo[3];
			[_original getPixel:compsTwo atX:x y:y];
			
			if (comps[0] == compsTwo[0] && comps[1] == compsTwo[1] && comps[2] == compsTwo[2]) {
				[_output setColor:[NSColor greenColor] atX:x y:y];
			}
			else {
				[_output setColor:[NSColor redColor] atX:x y:y];
			}
		}
	}
	
	[self setNeedsDisplay:YES];
}

- (void) showOverlay
{
    _shouldDrawRedGreenOverlay = YES;
    [self setNeedsDisplay:YES];
}

- (void) hideOverlay
{
    _shouldDrawRedGreenOverlay = NO;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
	NSSize size = _original.size;
	
	NSPoint origin = NSMakePoint((int) (self.bounds.size.width - size.width) / 2,
								 (int) (self.bounds.size.height - size.height) / 2);
	
	[_original drawAtPoint:origin];
	
    if (_shouldDrawRedGreenOverlay) {
        if (!_output)
            return;
        
        [_output drawInRect:NSMakeRect(origin.x, origin.y, size.width, size.height)
                   fromRect:NSZeroRect
                  operation:NSCompositeSourceOver
                   fraction:0.4f
             respectFlipped:NO
                      hints:nil];
    }
}

@end
