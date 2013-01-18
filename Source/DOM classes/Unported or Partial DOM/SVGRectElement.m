//
//  SVGRectElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGRectElement.h"

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

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

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult {
	[super postProcessAttributesAddingErrorsTo:parseResult];
	
	if( [[self getAttribute:@"x"] length] > 0 )
	_x = [[self getAttribute:@"x"] floatValue];
	
	if( [[self getAttribute:@"y"] length] > 0 )
	_y = [[self getAttribute:@"y"] floatValue];
	
	if( [[self getAttribute:@"width"] length] > 0 )
	_width = [[self getAttribute:@"width"] floatValue];
	
	if( [[self getAttribute:@"height"] length] > 0 )
	_height = [[self getAttribute:@"height"] floatValue];
	
	if( [[self getAttribute:@"rx"] length] > 0 )
	_rx = [[self getAttribute:@"rx"] floatValue];
	
	if( [[self getAttribute:@"ry"] length] > 0 )
	_ry = [[self getAttribute:@"ry"] floatValue];
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect rect = CGRectMake(0, 0, _width, _height);
	
	if (_rx == 0 && _ry == 0) {
		CGPathAddRect(path, NULL, rect);
	}
	else if (_rx == _ry) {
		CGPathAddRoundedRect(path, rect, _rx);
	}
	else {
		NSLog(@"Unsupported corner-radius configuration: rx differs from ry");
	}
	
	[self setPathByCopyingPathFromLocalSpace:path];
	CGPathRelease(path);
}

@end
