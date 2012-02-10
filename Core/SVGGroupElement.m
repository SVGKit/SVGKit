//
//  SVGGroupElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGGroupElement.h"

#import "SVGDocument.h"

#import "SVGElement+Private.h"
#import "CALayerWithChildHitTest.h"

@implementation SVGGroupElement

@synthesize opacity = _opacity;

- (void)dealloc {
	
    [super dealloc];
}

- (void)loadDefaults {
	_opacity = 1.0f;
}

- (void)parseAttributes:(NSDictionary *)attributes {
	[super parseAttributes:attributes];
	
	id value = nil;
	
	if ((value = [attributes objectForKey:@"opacity"])) {
		_opacity = [value floatValue];
	}
}

- (CALayer *)newLayer {
	
	CALayer* _layer = [CALayerWithChildHitTest layer];
		
		_layer.name = self.identifier;
		[_layer setValue:self.identifier forKey:kSVGElementIdentifier];
		_layer.opacity = _opacity;
		
		if ([_layer respondsToSelector:@selector(setShouldRasterize:)]) {
			[_layer performSelector:@selector(setShouldRasterize:)
						withObject:[NSNumber numberWithBool:YES]];
		}
	
	return _layer;
}

- (void)layoutLayer:(CALayer *)layer {
	NSArray *sublayers = [layer sublayers];
	CGRect mainRect = CGRectZero;
	
	for (NSUInteger n = 0; n < [sublayers count]; n++) {
		CALayer *currentLayer = [sublayers objectAtIndex:n];
		
		if (n == 0) {
			mainRect = currentLayer.frame;
		}
		else {
			mainRect = CGRectUnion(mainRect, currentLayer.frame);
		}
	}
	
	mainRect = CGRectIntegral(mainRect); // round values to integers
	
	layer.frame = mainRect;
	
	for (CALayer *currentLayer in sublayers) {
		CGRect frame = currentLayer.frame;
		frame.origin.x -= mainRect.origin.x;
		frame.origin.y -= mainRect.origin.y;
		
		currentLayer.frame = CGRectIntegral(frame);
	}
}

@end
