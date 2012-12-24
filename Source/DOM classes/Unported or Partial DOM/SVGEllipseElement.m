//
//  SVGEllipseElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGEllipseElement.h"

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

@interface SVGEllipseElement()
@property (nonatomic, readwrite) CGFloat cx;
@property (nonatomic, readwrite) CGFloat cy;
@property (nonatomic, readwrite) CGFloat rx;
@property (nonatomic, readwrite) CGFloat ry;
@end

@implementation SVGEllipseElement

@synthesize cx = _cx;
@synthesize cy = _cy;
@synthesize rx = _rx;
@synthesize ry = _ry;

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult {
	[super postProcessAttributesAddingErrorsTo:parseResult];
	
	if( [[self getAttribute:@"cx"] length] > 0 )
	self.cx = [[self getAttribute:@"cx"] floatValue];
	
	if( [[self getAttribute:@"cy"] length] > 0 )
	self.cy = [[self getAttribute:@"cy"] floatValue];
	
	if( [[self getAttribute:@"rx"] length] > 0 )
	self.rx = [[self getAttribute:@"rx"] floatValue];
	
	if( [[self getAttribute:@"ry"] length] > 0 )
	self.ry = [[self getAttribute:@"ry"] floatValue];
	
	if( [[self getAttribute:@"r"] length] > 0 ) { // circle
		self.ry = self.rx = [[self getAttribute:@"r"] floatValue];
	}
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddEllipseInRect(path, NULL, CGRectMake(_cx - _rx, _cy - _ry, _rx * 2, _ry * 2));
	
	[self setPathByCopyingPathFromLocalSpace:path];
	CGPathRelease(path);
}

@end
