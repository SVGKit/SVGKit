//
//  SVGPolylineElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "SVGPolylineElement.h"

#import "SVGElement+Private.h"
#import "SVGShapeElement+Private.h"
#import "SVGUtils.h"

@implementation SVGPolylineElement

- (void)parseAttributes:(NSDictionary *)attributes {
	[super parseAttributes:attributes];
	
	id value = nil;
	
	if ((value = [attributes objectForKey:@"points"])) {
		CGMutablePathRef path = SVGPathFromPointsInString([value UTF8String], NO);
		
		[self loadPath:path];
		CGPathRelease(path);
	}
}

@end
