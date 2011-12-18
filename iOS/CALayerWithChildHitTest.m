//
//  CALayerWithChildHitTest.m
//  SVGKit
//
//  Created by adam on 27/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CALayerWithChildHitTest.h"


@implementation CALayerWithChildHitTest

- (BOOL) containsPoint:(CGPoint)p
{
	//CALayer* modelLayer = self.modelLayer;
	
	if (CGRectContainsPoint(self.bounds, p))
	{
		BOOL atLeastOneChildContainsPoint = FALSE;
		
		for( CALayer* subLayer in self.sublayers )
		{
			if( [subLayer containsPoint:p] )
			{
				atLeastOneChildContainsPoint = TRUE;
				break;
			}
		}
		
		return atLeastOneChildContainsPoint;
	}
	return NO;
}

@end
