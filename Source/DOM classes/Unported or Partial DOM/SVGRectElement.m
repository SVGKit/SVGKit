#import "SVGRectElement.h"

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

#import "SVGHelperUtilities.h"

@interface SVGRectElement ()

void CGPathAddRoundedRect (CGMutablePathRef path, CGRect rect, CGFloat radius);

@end

@implementation SVGRectElement

@synthesize transform; // each SVGElement subclass that conforms to protocol "SVGTransformable" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols

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
	_x = [SVGLength svgLengthFromNSString:[self getAttribute:@"x"]];
	
	if( [[self getAttribute:@"y"] length] > 0 )
	_y = [SVGLength svgLengthFromNSString:[self getAttribute:@"y"]];
	
	if( [[self getAttribute:@"width"] length] > 0 )
	_width = [SVGLength svgLengthFromNSString:[self getAttribute:@"width"]];
	
	if( [[self getAttribute:@"height"] length] > 0 )
	_height = [SVGLength svgLengthFromNSString:[self getAttribute:@"height"]];
	
	if( [[self getAttribute:@"rx"] length] > 0 )
	_rx = [SVGLength svgLengthFromNSString:[self getAttribute:@"rx"]];
	
	if( [[self getAttribute:@"ry"] length] > 0 )
	_ry = [SVGLength svgLengthFromNSString:[self getAttribute:@"ry"]];

	/**
	 Create a square OR rounded rectangle as a CGPath
	 
	 */
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect rect = CGRectMake([_x pixelsValue], [_y pixelsValue], [_width pixelsValue], [_height pixelsValue]);
	
	if ([_rx pixelsValue] == 0 && [_ry pixelsValue] == 0) {
		CGPathAddRect(path, NULL, rect);
	}
	else if ([_rx  pixelsValue] == [_ry  pixelsValue]) {
		CGPathAddRoundedRect(path, rect, [_rx pixelsValue]);
	}
	else {
		NSLog(@"[%@] ERROR: Unsupported corner-radius configuration: rx (%@) differs from ry (%@)", [self class], self.rx, self.ry);
		CGPathRelease(path);
		return;
	}
	self.pathForShapeInRelativeCoords = path;
	CGPathRelease(path);
}


@end
