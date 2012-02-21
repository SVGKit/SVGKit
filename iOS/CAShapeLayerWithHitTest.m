#import "CAShapeLayerWithHitTest.h"

/*! Used by the main ShapeElement (and all subclasses) to do perfect "containsPoint" calculations via Apple's API calls
 
 This will only be called if it's the root of an SVG document and the hit was in the parent view on screen,
 OR if it's inside an SVGGroupElement that contained the hit
 */
@implementation CAShapeLayerWithHitTest

- (BOOL) containsPoint:(CGPoint)p
{
	BOOL frameContains = CGRectContainsPoint(self.frame, p);
	BOOL boundsContains = CGRectContainsPoint(self.bounds, p);
	BOOL pathContains = CGPathContainsPoint(self.path, NULL, p, false);
	
	if( boundsContains && pathContains )
	{
			for( CALayer* subLayer in self.sublayers )
			{
				NSLog(@"...contains point, Apple will now check sublayer: %@", subLayer);
			}
		return TRUE;
	}
	return NO;
}

@end
