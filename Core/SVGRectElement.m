//
//  SVGRectElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGRectElement.h"

#import "SVGElement+Private.h"
#import "SVGShapeElement+Private.h"

@interface SVGRectElement ()

void CGPathAddRoundedRect (CGMutablePathRef path, CGRect rect, CGFloat radius);

@end

@implementation SVGRectElement

@synthesize x = _x;
@synthesize y = _y;
@synthesize width = _width;
@synthesize height = _height;

@synthesize rx = _rx;
@synthesize ry = _ry;

// adapted from http://www.cocoanetics.com/2010/02/drawing-rounded-rectangles/

void CGPathAddRoundedRect (CGMutablePathRef path, CGRect rect, CGFloat radius) {
	CGRect innerRect = CGRectInset(rect, radius, radius);
	
	CGFloat innerRight = innerRect.origin.x + innerRect.size.width;
	CGFloat right = rect.origin.x + rect.size.width;
	CGFloat innerBottom = innerRect.origin.y + innerRect.size.height;
	CGFloat bottom = rect.origin.y + rect.size.height;
	
	CGFloat innerTop = innerRect.origin.y;
	CGFloat top = rect.origin.y;
	CGFloat innerLeft = innerRect.origin.x;
	CGFloat left = rect.origin.x;
	
	CGPathMoveToPoint(path, NULL, innerLeft, top);
	
	CGPathAddLineToPoint(path, NULL, innerRight, top);
	CGPathAddArcToPoint(path, NULL, right, top, right, innerTop, radius);
	CGPathAddLineToPoint(path, NULL, right, innerBottom);
	CGPathAddArcToPoint(path, NULL,  right, bottom, innerRight, bottom, radius);
	
	CGPathAddLineToPoint(path, NULL, innerLeft, bottom);
	CGPathAddArcToPoint(path, NULL,  left, bottom, left, innerBottom, radius);
	CGPathAddLineToPoint(path, NULL, left, innerTop);
	CGPathAddArcToPoint(path, NULL,  left, top, innerLeft, top, radius);
	
	CGPathCloseSubpath(path);
}

- (void)parseAttributes:(NSDictionary *)attributes {
	[super parseAttributes:attributes];
	
	id value = nil;
	
	if ((value = [attributes objectForKey:@"x"])) {
		_x = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"y"])) {
		_y = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"width"])) {
		_width = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"height"])) {
		_height = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"rx"])) {
		_rx = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"ry"])) {
		_ry = [value floatValue];
	}
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect rect = CGRectMake(_x, _y, _width, _height);
	
	if (_rx == 0 && _ry == 0) {
		CGPathAddRect(path, NULL, rect);
	}
	else if (_rx == _ry) {
		CGPathAddRoundedRect(path, rect, _rx);
	}
	else {
		NSLog(@"Unsupported corner-radius configuration: rx differs from ry");
	}
	
	[self loadPath:path];
	CGPathRelease(path);
}

@end
