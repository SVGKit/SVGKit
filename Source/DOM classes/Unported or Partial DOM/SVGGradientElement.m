 /* FIXME: very different from SVG Spec */

#import "SVGGradientElement.h"
#import "SVGGradientStop.h"
#import "SVGElement_ForParser.h"

#import "SVGGElement.h"

@implementation SVGGradientElement

@synthesize stops = _stops;
@synthesize transform;

-(void)addStop:(SVGGradientStop *)gradientStop
{
    if( _stops == nil )
        _stops = [[NSMutableArray alloc] initWithCapacity:1];
    [_stops addObject:gradientStop];
}

-(void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult
{
    [super postProcessAttributesAddingErrorsTo:parseResult];
}

-(NSString*) getAttributeInheritedIfNil:(NSString*) attrName
{
	if( [self.parentNode isKindOfClass:[SVGGElement class]] )
		return [self hasAttribute:attrName] ? [self getAttribute:attrName] : [((SVGElement*)self.parentNode) getAttribute:attrName];
	else
		return [self getAttribute:attrName]; // will return blank if there was no value AND no parent value
}

-(CGPoint) normalizeGradientCoordinate:(SVGLength*) x y:(SVGLength*) y rectToFill:(CGRect) rectToFill
{
	CGFloat xNormalized, yNormalized;
	
	if( x.value == 0 )
		xNormalized = 0;
	else
	switch( x.unitType )  // SVG needs gradients measured in percent...
	{
		case SVG_LENGTHTYPE_PERCENTAGE:
		{
			 xNormalized = [x numberValue]; // will convert the percent into [0,1]
		}break;
			
		case SVG_LENGTHTYPE_NUMBER:
		case SVG_LENGTHTYPE_PX:
		{
			xNormalized = (([x pixelsValue] - rectToFill.origin.x) / rectToFill.size.width);
		} break;
			
		default:
		{
			NSAssert( FALSE, @"Unsupported input units in the SVGLength variable passed in for 'x': %i", x.unitType );
			xNormalized = 0;
		}
	}
	
	if( y.value == 0 )
		yNormalized = 0;
	else
	switch( y.unitType )  // SVG needs gradients measured in percent...
	{
		case SVG_LENGTHTYPE_PERCENTAGE:
		{
			yNormalized = [y numberValue]; // will convert the percent into [0,1]
		}break;
			
		case SVG_LENGTHTYPE_NUMBER:
		case SVG_LENGTHTYPE_PX:
		{
			yNormalized = (([y pixelsValue] - rectToFill.origin.y) / rectToFill.size.height);
		}break;
			
		default:
		{
			NSAssert( FALSE, @"Unsupported input units in the SVGLength variable passed in for 'y': %i", y.unitType );
			yNormalized = 0;
		}
	}
	
	return CGPointMake( xNormalized, yNormalized );
}

-(CAGradientLayer *)newGradientLayerForObjectRect:(CGRect) objectRect viewportRect:(SVGRect) viewportRect
{
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
	
	CGRect rectForRelativeUnits;
	NSString* gradientUnits = [self getAttributeInheritedIfNil:@"gradientUnits"];
	if( gradientUnits == nil
	|| [gradientUnits isEqualToString:@"objectBoundingBox"])
		rectForRelativeUnits = objectRect;
	else
		rectForRelativeUnits = CGRectFromSVGRect( viewportRect );
    
	gradientLayer.frame = rectForRelativeUnits;
	
	SVGLength* svgX1 = [SVGLength svgLengthFromNSString:[self getAttributeInheritedIfNil:@"x1"]];
	SVGLength* svgY1 = [SVGLength svgLengthFromNSString:[self getAttributeInheritedIfNil:@"y1"]];
	
	CGPoint startPoint = CGPointMake(svgX1.value, svgY1.value);
    startPoint = CGPointApplyAffineTransform(startPoint, self.transform);
    startPoint = [self normalizeGradientCoordinate:[SVGLength svgLengthFromNSString:[NSString stringWithFormat:@"%f",startPoint.x]] y:[SVGLength svgLengthFromNSString:[NSString stringWithFormat:@"%f",startPoint.y]] rectToFill:rectForRelativeUnits];
	
	SVGLength* svgX2 = [SVGLength svgLengthFromNSString:[self getAttributeInheritedIfNil:@"x2"]];
	SVGLength* svgY2 = [SVGLength svgLengthFromNSString:[self getAttributeInheritedIfNil:@"y2"]];
	
	CGPoint endPoint = CGPointMake(svgX2.value, svgY2.value);
    endPoint = CGPointApplyAffineTransform(endPoint, self.transform);
    endPoint = [self normalizeGradientCoordinate:[SVGLength svgLengthFromNSString:[NSString stringWithFormat:@"%f",endPoint.x]] y:[SVGLength svgLengthFromNSString:[NSString stringWithFormat:@"%f",endPoint.y]] rectToFill:rectForRelativeUnits];
    
#ifdef SVG_DEBUG_GRADIENTS
    NSLog(@"Gradient start point %@ end point %@", NSStringFromCGPoint(startPoint), NSStringFromCGPoint(endPoint));
    
    NSLog(@"SVGGradientElement gradientUnits == %@", gradientUnits);
#endif

//    return gradientLayer;
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    
    if( colors == nil ) //these can't be determined until parsing is complete, need to update SVGGradientParser and do this on end element
    {
//        CGColorRef theColor = NULL;//, alphaColor = NULL;
        NSUInteger numStops = [_stops count];
        NSMutableArray *colorBuilder = [[NSMutableArray alloc] initWithCapacity:numStops];
        NSMutableArray *locationBuilder = [[NSMutableArray alloc] initWithCapacity:numStops];
        for (SVGGradientStop *theStop in _stops) 
        {
            [locationBuilder addObject:[NSNumber numberWithFloat:theStop.offset]];
//            theColor = CGColorWithSVGColor([theStop stopColor]);
            //        alphaColor = CGColorCreateCopyWithAlpha(theColor, [theStop stopOpacity]);
            [colorBuilder addObject:CFBridgingRelease(CGColorWithSVGColor([theStop stopColor]))];
            //        CGColorRelease(alphaColor);
        }
        
        colors = [[NSArray alloc] initWithArray:colorBuilder];
        locations = [[NSArray alloc] initWithArray:locationBuilder];
        _stops = nil;
    }
    
//    NSLog(@"Setting gradient shiz");
    [gradientLayer setColors:colors];
    [gradientLayer setLocations:locations];
	
	NSLog(@"[%@] set gradient layer start = %@", [self class], NSStringFromCGPoint(gradientLayer.startPoint));
	NSLog(@"[%@] set gradient layer end = %@", [self class], NSStringFromCGPoint(gradientLayer.endPoint));
	NSLog(@"[%@] set gradient layer colors = %@", [self class], colors);
	NSLog(@"[%@] set gradient layer locations = %@", [self class], locations);
//    gradientLayer.colors = colors;
//    gradientLayer.locations = locations;
    
//    for( id colorRef in colors )
//        CGColorRelease((CGColorRef)colorRef);
    
    
//    gradientLayer.type = kCAGradientLayerAxial;
    
    return gradientLayer;
}

-(void)layoutLayer:(CALayer *)layer
{
	
}

@end
