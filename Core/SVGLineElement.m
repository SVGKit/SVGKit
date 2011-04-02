//
//  SVGLineElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGLineElement.h"

#import "SVGElement+Private.h"
#import "SVGShapeElement+Private.h"

@implementation SVGLineElement

@synthesize x1 = _x1;
@synthesize y1 = _y1;
@synthesize x2 = _x2;
@synthesize y2 = _y2;

- (void)parseAttributes:(NSDictionary *)attributes {
	[super parseAttributes:attributes];
	
	id value = nil;
	
	if ((value = [attributes objectForKey:@"x1"])) {
		_x1 = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"y1"])) {
		_y1 = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"x2"])) {
		_x2 = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"y2"])) {
		_y2 = [value floatValue];
	}
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, _x1, _y1);
	CGPathAddLineToPoint(path, NULL, _x2, _y2);
	
	[self loadPath:path];
	CGPathRelease(path);
}

@end
