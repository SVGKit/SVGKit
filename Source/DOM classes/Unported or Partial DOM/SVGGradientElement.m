 /* FIXME: very different from SVG Spec */

#import "SVGGradientElement.h"
#import "SVGGradientStop.h"
#import "SVGElement_ForParser.h"

#import "SVGGroupElement.h"

@implementation SVGGradientElement

@synthesize stops = _stops;

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
	if( [self.parentNode isKindOfClass:[SVGGroupElement class]] )
		return [self hasAttribute:attrName] ? [self getAttribute:attrName] : [self.parentNode getAttribute:attrName];
	else
		return [self getAttribute:attrName]; // will return blank if there was no value AND no parent value
}

-(CALayer *)newLayer
{
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    
	float testObjectX = [[self getAttributeInheritedIfNil:@"x1"] floatValue];
    float testObjectY = [[self getAttributeInheritedIfNil:@"x2"] floatValue];
	   
    CGPoint startPoint = CGPointMake( testObjectX, testObjectY); //default value is 0.0f, so if the attribute is nil, we will end up with the correct values
    
    testObjectX = ([self getAttributeInheritedIfNil:@"y1"].length > 0) ? [[self getAttributeInheritedIfNil:@"y1"] floatValue] : 1.0f; // it will be a blank string if not set; default from SVG Spec is 1.0
    testObjectY = [[self getAttributeInheritedIfNil:@"y2"] floatValue];
	   
	//    if(testObjectY == nil ) //y2 defaults to 0.0f by SVG spec
	//        testObjectY = [NSNumber numberWithFloat:1.0f];
    
	CGPoint endPoint = CGPointMake( testObjectX, testObjectY );
	//    endPoint = CGPointMake(1.0f,1.0f);
    
    NSString* gradientUnits = [self getAttributeInheritedIfNil:@"gradientUnits"];
    
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
            [colorBuilder addObject:(id)CGColorWithSVGColor([theStop stopColor])];
            //        CGColorRelease(alphaColor);
        }
        
        colors = [[NSArray alloc] initWithArray:colorBuilder];
        [colorBuilder release];
        
        locations = [[NSArray alloc] initWithArray:locationBuilder];
        [locationBuilder release];
        
        [_stops release];
        _stops = nil;
    }
    
//    NSLog(@"Setting gradient shiz");
    [gradientLayer setColors:colors];
    [gradientLayer setLocations:locations];
	
	NSLog(@"[%@] set gradient layer colors = %@", [self class], colors);
	NSLog(@"[%@] set gradient layer locations = %@", [self class], locations);
//    gradientLayer.colors = colors;
//    gradientLayer.locations = locations;
    
//    for( id colorRef in colors )
//        CGColorRelease((CGColorRef)colorRef);
    
    
//    gradientLayer.type = kCAGradientLayerAxial;
    
    return gradientLayer;
}


-(void)dealloc
{
    [_stops release];
    _stops = nil;
    
    [colors release];
    [locations release];
    
    [super dealloc];
}

@end
