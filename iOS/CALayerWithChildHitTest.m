//
//  CALayerWithChildHitTest.m
//  SVGKit
//
//  Created by adam on 27/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CALayerWithChildHitTest.h"


#import <UIKit/UIKit.h>

@implementation CALayerWithChildHitTest

- (BOOL) containsPoint:(CGPoint)p
{
	BOOL boundsContains = CGRectContainsPoint(self.bounds, p);
	
	if( boundsContains )
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

