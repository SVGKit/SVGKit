/**
 SVGGroupElement.m
 
 In SVG, every single element can contain children.
 
 However, the SVG spec defines a special (optional) "group" element, that is never rendered,
 but allows additional nesting (e.g. for programmatic / organizational purposes).
 
 This is the "G" tag.
 */
#import "SVGGroupElement.h"

#import "CALayerWithChildHitTest.h"

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)
#import "Node.h"

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
	CGRect frameRect = CGRectZero;
    CGRect mainRect = CGRectZero;
    CGRect boundsRect = CGRectZero;

	NSArray *sublayers = [layer sublayers];
    
	for (NSUInteger n = 0; n < [sublayers count]; n++) {
		CALayer *currentLayer = [sublayers objectAtIndex:n];
		
		if (n == 0) {
			frameRect = currentLayer.frame;
		}
		else {
			frameRect = CGRectUnion(frameRect, currentLayer.frame);
		}
        mainRect = CGRectUnion(mainRect, currentLayer.frame);
	}
    
    boundsRect = CGRectOffset(frameRect, -frameRect.origin.x, -frameRect.origin.y);
    
    for (CALayer *currentLayer in sublayers) {
        [currentLayer setAffineTransform:CGAffineTransformConcat(currentLayer.affineTransform, CGAffineTransformMakeTranslation(-frameRect.origin.x, -frameRect.origin.y))];
	}
	
	layer.frame = boundsRect;
	
#if OUTLINE_SHAPES
    
    layer.borderColor = [UIColor redColor].CGColor;
    layer.borderWidth = 2.0f;
    
    NSString* textToDraw = [NSString stringWithFormat:@"%@ (%@): {%.1f, %.1f} {%.1f, %.1f}", self.identifier, [self class], layer.frame.origin.x, layer.frame.origin.y, layer.frame.size.width, layer.frame.size.height];
    
    UIFont* fontToDraw = [UIFont fontWithName:@"Helvetica"
                                         size:10.0f];
    CGSize sizeOfTextRect = [textToDraw sizeWithFont:fontToDraw];
    
    CATextLayer *debugText = [[[CATextLayer alloc] init] autorelease];
    [debugText setFont:@"Helvetica"];
    [debugText setFontSize:10.0f];
    [debugText setFrame:CGRectMake(0, 0, sizeOfTextRect.width, sizeOfTextRect.height)];
    [debugText setString:textToDraw];
    [debugText setAlignmentMode:kCAAlignmentLeft];
    [debugText setForegroundColor:[UIColor redColor].CGColor];
    [debugText setContentsScale:[[UIScreen mainScreen] scale]];
    [debugText setShouldRasterize:NO];
    [layer addSublayer:debugText];
    
#endif

    //applying transform relative to centerpoint
    CGAffineTransform tr1 = layer.affineTransform;
    tr1 = CGAffineTransformConcat(tr1, CGAffineTransformMakeTranslation(frameRect.size.width/2, frameRect.size.height/2));
    CGAffineTransform tr2 = CGAffineTransformConcat(tr1, self.transformRelative);
    tr2 = CGAffineTransformConcat(tr2, CGAffineTransformInvert(tr1));
    tr1 = CGAffineTransformConcat(CGAffineTransformMakeTranslation(frameRect.origin.x, frameRect.origin.y), tr2);
    [layer setAffineTransform:tr1];
}

/*
 FIXME: this cannot work; this is incompatible with the way that SVG spec was designed; this code comes from old SVGKit
 
 //we can't propagate opacity down unfortunately, so we need to build a set of all the properties except a few (opacity is applied differently to groups than simply inheriting it to it's children, <g opacity occurs AFTER blending all of its children
 
 BOOL attributesFound = NO;
 NSMutableDictionary *buildDictionary = [NSMutableDictionary new];
 for( Node* node in self.attributes )
 {
 if( ![node.localName isEqualToString:@"opacity"] )
 {
 attributesFound = YES;
 [buildDictionary setObject:[attributes objectForKey:key] forKey:node.localName];
 }
 }
 if( attributesFound )
 {
 _attributes = [[NSDictionary alloc] initWithDictionary:buildDictionary];
 //these properties are inherited by children of this group
 }
 [buildDictionary release];
 
 */

@end
