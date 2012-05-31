#import "CAShapeLayerWithHitTest.h"

/*! Used by the main ShapeElement (and all subclasses) to do perfect "containsPoint" calculations via Apple's API calls
 
 This will only be called if it's the root of an SVG document and the hit was in the parent view on screen,
 OR if it's inside an SVGGroupElement that contained the hit
 */
@implementation CAShapeLayerWithHitTest

- (BOOL) containsPoint:(CGPoint)p
{
	BOOL boundsContains = CGRectContainsPoint(self.bounds, p);
	
	if( boundsContains )
	{
        BOOL pathContains = CGPathContainsPoint(self.path, NULL, p, false);
//			for( CALayer* subLayer in self.sublayers )
//			{
//				NSLog(@"...contains point, Apple will now check sublayer: %@", subLayer);
//			}
		return pathContains;
	}
	return NO;
}

@end
