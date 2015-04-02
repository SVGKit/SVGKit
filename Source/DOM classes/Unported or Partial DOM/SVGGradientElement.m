 /* FIXME: very different from SVG Spec */

#import "SVGGradientElement.h"
#import "SVGGradientStop.h"
#import "SVGElement_ForParser.h"

#import "SVGGElement.h"
@interface SVGGradientElement ()

@property (nonatomic) BOOL hasSynthesizedProperties;

@end

@implementation SVGGradientElement

@synthesize stops = _stops;
@synthesize transform;
@synthesize locations = _locations;
@synthesize colors = _colors;

-(void)addStop:(SVGGradientStop *)gradientStop
{
    if( _stops == nil )
	{
		_stops = [[NSArray arrayWithObject:gradientStop] retain];
	}
	else
	{
		[_stops autorelease];
		_stops = [[_stops arrayByAddingObjectsFromArray:[NSArray arrayWithObject:gradientStop]] retain];
	}
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

-(SVGGradientLayer *)newGradientLayerForObjectRect:(CGRect) objectRect
									  viewportRect:(SVGRect)viewportRect
										 transform:(CGAffineTransform)transformAbsolute
{
    SVGGradientLayer *gradientLayer = [[SVGGradientLayer alloc] init];
	BOOL inUserSpace = NO;
	
	CGRect rectForRelativeUnits;
	NSString* gradientUnits = [self getAttributeInheritedIfNil:@"gradientUnits"];
	if( ![gradientUnits length]
	|| [gradientUnits isEqualToString:@"objectBoundingBox"])
		rectForRelativeUnits = objectRect;
	else
	{
		inUserSpace = YES;
		rectForRelativeUnits = CGRectFromSVGRect( viewportRect );
	}
	
	gradientLayer.frame = objectRect;
	
	if ([self.tagName isEqualToString:@"radialGradient"]) {
        SVGLength* svgX1 = [SVGLength svgLengthFromNSString:[self getAttributeInheritedIfNil:@"cx"]];
        SVGLength* svgY1 = [SVGLength svgLengthFromNSString:[self getAttributeInheritedIfNil:@"cy"]];
        CGPoint startPoint = CGPointMake(svgX1.value, svgY1.value);
        startPoint = CGPointApplyAffineTransform(startPoint, self.transform);
        gradientLayer.transform = CGAffineTransformMake(self.transform.a, self.transform.b, self.transform.c, self.transform.d, 0, 0);
        
        SVGLength* svgX2 = [SVGLength svgLengthFromNSString:[self getAttributeInheritedIfNil:@"r"]];
        SVGLength* svgY2 = [SVGLength svgLengthFromNSString:[self getAttributeInheritedIfNil:@"r"]];
        
        CGPoint endPoint = [self normalizeGradientCoordinate:svgX2 y:svgY2 rectToFill:rectForRelativeUnits];
        
#ifdef SVG_DEBUG_GRADIENTS
    DDLogVerbose(@"Gradient start point %@ end point %@", NSStringFromCGPoint(startPoint), NSStringFromCGPoint(endPoint));
    
    DDLogVerbose(@"SVGGradientElement gradientUnits == %@", gradientUnits);
#endif
        
        //    return gradientLayer;
        gradientLayer.startPoint = startPoint;
        gradientLayer.endPoint = endPoint;
        gradientLayer.type = kExt_CAGradientLayerRadial;
    } else {
        SVGLength* svgX1 = [SVGLength svgLengthFromNSString:[self getAttributeInheritedIfNil:@"x1"]];
        SVGLength* svgY1 = [SVGLength svgLengthFromNSString:[self getAttributeInheritedIfNil:@"y1"]];
		CGFloat x1;
		CGFloat y1;
		
		// these should really be two separate code paths (objectBoundingBox and userSpaceOnUse)
		if (!inUserSpace)
		{
			x1 = [svgX1 pixelsValueWithDimension:1.0];
			y1 = [svgY1 pixelsValueWithDimension:1.0];
		}
		else
		{
			x1 = [svgX1 pixelsValueWithDimension:CGRectGetWidth(rectForRelativeUnits)];
			y1 = [svgY1 pixelsValueWithDimension:CGRectGetHeight(rectForRelativeUnits)];
		}
        CGPoint startPoint = CGPointMake(x1, y1);
		
        startPoint = CGPointApplyAffineTransform(startPoint, self.transform);
		if (inUserSpace)
		{
			startPoint = CGPointApplyAffineTransform(startPoint, transformAbsolute);
		}
		CGPoint gradientStartPoint = startPoint;
		
		if (inUserSpace)
		{
			gradientStartPoint.x = (startPoint.x - CGRectGetMinX(objectRect))/CGRectGetWidth(objectRect);
			gradientStartPoint.y = (startPoint.y - CGRectGetMinY(objectRect))/CGRectGetHeight(objectRect);
		}
		
		NSString* s = [self getAttributeInheritedIfNil:@"x2"];
        SVGLength* svgX2 = [SVGLength svgLengthFromNSString:s];
        SVGLength* svgY2 = [SVGLength svgLengthFromNSString:[self getAttributeInheritedIfNil:@"y2"]];
		CGFloat x2;
		CGFloat y2;

		if (!inUserSpace)
		{
			x2 = [svgX2 pixelsValueWithDimension:1.0];
			y2 = [svgY2 pixelsValueWithDimension:1.0];
			if (![s length])
				x2 = 1.0;
		}
		else
		{
			x2 = [svgX2 pixelsValueWithDimension:CGRectGetWidth(rectForRelativeUnits)];
			y2 = [svgY2 pixelsValueWithDimension:CGRectGetHeight(rectForRelativeUnits)];
			if (![s length])
				x2 = CGRectGetMaxX(rectForRelativeUnits);
		}
		
		
        CGPoint endPoint = CGPointMake(x2, y2);
        endPoint = CGPointApplyAffineTransform(endPoint, self.transform);
		if (inUserSpace)
		{
			endPoint = CGPointApplyAffineTransform(endPoint, transformAbsolute);
		}
		CGPoint gradientEndPoint = endPoint;
		
		if (inUserSpace)
		{
			gradientEndPoint.x = ((endPoint.x - CGRectGetMaxX(objectRect))/CGRectGetWidth(objectRect))+1;
			gradientEndPoint.y = ((endPoint.y - CGRectGetMaxY(objectRect))/CGRectGetHeight(objectRect))+1;
		}
		
#ifdef SVG_DEBUG_GRADIENTS
        DDLogVerbose(@"Gradient start point %@ end point %@", NSStringFromCGPoint(startPoint), NSStringFromCGPoint(endPoint));
        
        DDLogVerbose(@"SVGGradientElement gradientUnits == %@", gradientUnits);
#endif
        
        //    return gradientLayer;
        gradientLayer.startPoint = gradientStartPoint;
        gradientLayer.endPoint = gradientEndPoint;
        gradientLayer.type = kCAGradientLayerAxial;
    }
    
    if(_colors == nil ) //these can't be determined until parsing is complete, need to update SVGGradientParser and do this on end element
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
            [colorBuilder addObject:(id)CGColorWithSVGColor([theStop stopColor])];
            //        CGColorRelease(alphaColor);
        }
        
        _colors = [[NSArray alloc] initWithArray:colorBuilder];
        [colorBuilder release];
        
        _locations = [[NSArray alloc] initWithArray:locationBuilder];
        [locationBuilder release];
        
        [_stops release];
        _stops = nil;
    }
    
//    DDLogVerbose(@"Setting gradient shiz");
    [gradientLayer setColors:_colors];
    [gradientLayer setLocations:_locations];
	
	DDLogVerbose(@"[%@] set gradient layer start = %@", [self class], NSStringFromCGPoint(gradientLayer.startPoint));
	DDLogVerbose(@"[%@] set gradient layer end = %@", [self class], NSStringFromCGPoint(gradientLayer.endPoint));
	DDLogVerbose(@"[%@] set gradient layer colors = %@", [self class], _colors);
	DDLogVerbose(@"[%@] set gradient layer locations = %@", [self class], _locations);
//    gradientLayer.colors = colors;
//    gradientLayer.locations = locations;
    
//    for( id colorRef in colors )
//        CGColorRelease((CGColorRef)colorRef);
    
    
//    gradientLayer.type = kCAGradientLayerAxial;
    
    return gradientLayer;
}

- (void)synthesizeProperties
{
	if (self.hasSynthesizedProperties)
		return;
	self.hasSynthesizedProperties = YES;
	
	NSString* gradientID = [self getAttributeNS:@"http://www.w3.org/1999/xlink" localName:@"href"];
	
	if ([gradientID length])
	{
		if ([gradientID hasPrefix:@"#"])
			gradientID = [gradientID substringFromIndex:1];
		
		SVGGradientElement* baseGradient = (SVGGradientElement*) [self.rootOfCurrentDocumentFragment getElementById:gradientID];
		NSString* svgNamespace = @"http://www.w3.org/2000/svg";
		
		if (baseGradient)
		{
			[baseGradient synthesizeProperties];
			
			if (!_stops && baseGradient.stops)
			{
				for (SVGGradientStop* stop in baseGradient.stops)
					[self addStop:stop];
			}
			NSArray *keys = [NSArray arrayWithObjects:@"x1", @"y1", @"x2", @"y2", @"gradientUnits", @"gradientTransform", nil];
			
			for (NSString* key in keys)
			{
				if (![self hasAttribute:key] && [baseGradient hasAttribute:key])
					[self setAttributeNS:svgNamespace qualifiedName:key value:[baseGradient getAttribute:key]];
			}
		
		}
	}
}

-(void)layoutLayer:(CALayer *)layer
{
	
}

-(void)dealloc
{
    [_stops release];
    _stops = nil;
    
    [_colors release];
    [_locations release];
    
    [super dealloc];
}

@end
