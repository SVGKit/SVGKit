#import "CAShapeLayerWithHitTest.h"


@implementation CAShapeLayerWithHitTest

- (BOOL) containsPoint:(CGPoint)p
{
	CALayer* modelLayer = self.modelLayer;
	
	if (CGRectContainsPoint(self.bounds, p))
	{
		BOOL result = CGPathContainsPoint(self.path, NULL, p, false);
		NSLog(@"BOUNDS with model ref = %@ contains point; path contains point? %i", modelLayer, result );
		
		if( result )
		{
			for( CALayer* subLayer in self.sublayers )
			{
				NSLog(@"...contains point, Apple will now check sublayer: %@", subLayer);
			}
		}
		return result;
	}
	return NO;
}

@end
