/**
 SVGGroupElement.m
 
 In SVG, every single element can contain children.
 
 However, the SVG spec defines a special (optional) "group" element, that is never rendered,
 but allows additional nesting (e.g. for programmatic / organizational purposes).
 
 This is the "G" tag.
 
 To make sure we don't lose this info when loading an SVG, we store a special element for it.
 */
#import "SVGGroupElement.h"

#import "CALayerWithChildHitTest.h"

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

@implementation SVGGroupElement

@synthesize opacity = _opacity;

- (void)dealloc {
	
    [super dealloc];
}

- (void)loadDefaults {
	_opacity = 1.0f;
}

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult {
	[super postProcessAttributesAddingErrorsTo:parseResult];
	
	if( [[self getAttribute:@"opacity"] length] > 0 )
	_opacity = [[self getAttribute:@"opacity"] floatValue];
}

- (CALayer *) newLayer
{
	
	CALayer* _layer = [[CALayerWithChildHitTest layer] retain];
		
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
	CGRect mainRect = CGRectZero;
	
	/** Adam: make a frame thats the UNION of all sublayers frames */
	for ( CALayer *currentLayer in [layer sublayers] )
	{
		CGRect subLayerFrame = currentLayer.frame;
		mainRect = CGRectUnion(mainRect, subLayerFrame);
	}
	
	layer.frame = mainRect;
	
	/** Adam:(dont know why this is here): set each sublayer to have a frame the same size as the parent frame, but with 0 offset.
	 
	 Adam: if I understand this correctly, the person who wrote it should have just written:
	 
	 "currentLayer.bounds = layer.frame"
	 
	 i.e. make every layer have the same size as the parent layer.
	 
	 But whoever wrote this didn't document their bad code, so I have no idea if thats correct or not
	 */
	for (CALayer *currentLayer in [layer sublayers]) {
		CGRect frame = currentLayer.frame;
		frame.origin.x -= mainRect.origin.x;
		frame.origin.y -= mainRect.origin.y;
		
		currentLayer.frame = frame;
	}
}

@end
