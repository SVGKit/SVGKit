//
//  SVGLineElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGLineElement.h"

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

#import "SVGHelperUtilities.h"

@implementation SVGLineElement

@synthesize x1 = _x1;
@synthesize y1 = _y1;
@synthesize x2 = _x2;
@synthesize y2 = _y2;

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult {
	[super postProcessAttributesAddingErrorsTo:parseResult];
	
	if( [[self getAttribute:@"x1"] length] > 0 )
	_x1 = [[self getAttribute:@"x1"] floatValue];
	
	if( [[self getAttribute:@"y1"] length] > 0 )
	_y1 = [[self getAttribute:@"y1"] floatValue];
	
	if( [[self getAttribute:@"x2"] length] > 0 )
	_x2 = [[self getAttribute:@"x2"] floatValue];
	
	if( [[self getAttribute:@"y2"] length] > 0 )
	_y2 = [[self getAttribute:@"y2"] floatValue];
}

-(CALayer *)newLayer
{
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, _x1, _y1);
	CGPathAddLineToPoint(path, NULL, _x2, _y2);
	
	CALayer* result = [SVGHelperUtilities newCALayerForPathBasedSVGElement:self withPath:path];
	CGPathRelease(path);
	return result;
}

@end
