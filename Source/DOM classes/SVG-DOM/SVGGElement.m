#import "SVGGElement.h"

#import "CALayerWithChildHitTest.h"

#import "SVGHelperUtilities.h"

@implementation SVGGElement 

@synthesize transform; // each SVGElement subclass that conforms to protocol "SVGTransformable" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols

- (CALayer *) newLayer
{
	
	CALayer* _layer = [[CALayerWithChildHitTest layer] RETAIN];
	
	[SVGHelperUtilities configureCALayer:_layer usingElement:self];
	
	return _layer;
}

- (void)layoutLayer:(CALayer *)layer {
	
	CGRect mainRect = CGRectZero;
	
	/** we don't want the rect to be union'd with 0,0, so we need to initialize it to one of the subrects */
	if( layer.sublayers.count > 0 )
		mainRect = ((CALayer*)[layer.sublayers objectAtIndex:0]).frame;
	
	/** make mainrect the UNION of all sublayer's frames (i.e. their individual "bounds" inside THIS layer's space) */
	for ( CALayer *currentLayer in [layer sublayers] )
	{
		CGRect subLayerFrame = currentLayer.frame;
		mainRect = CGRectUnion(mainRect, subLayerFrame);
	}
	
	/** use mainrect (union of all sub-layer bounds) this layer's FRAME
	 
	 i.e. top-left-corner of this layer will be "the top left corner of the convex-hull rect of all sublayers"
	 AND: bottom-right-corner of this layer will be "the bottom-right corner of the convex-hull rect of all sublayers"
	 */
	layer.frame = mainRect;

	/** Changing THIS layer's frame now means all DIRECT sublayers are offset by too much (because when we change the offset
	 of the parent frame (this.frame), Apple *does not* shift the sublayers around to keep them in same place.
	 
	 NB: there are bugs in some Apple code in Interface Builder where it attempts to do exactly that (incorrectly, as the API
	 is specifically designed NOT to do this), and ... Fails. But in code, thankfully, Apple *almost* never does this (there are a few method
	 calls where it appears someone at Apple forgot how their API works, and tried to do the offsetting automatically. "Paved
	 with good intentions...".
	 	 */
	for (CALayer *currentLayer in [layer sublayers]) {
		CGRect frame = currentLayer.frame;
		frame.origin.x -= mainRect.origin.x;
		frame.origin.y -= mainRect.origin.y;
		currentLayer.frame = frame;
	}
}

@end
