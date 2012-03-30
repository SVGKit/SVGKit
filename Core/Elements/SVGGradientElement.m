//
//  SVGGradientElement.m
//  SVGPad
//
//  Created by Kevin Stich on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SVGGradientElement.h"
#import "SVGGradientStop.h"
#import "SVGElement+Private.h"

#import "SVGGroupElement.h"

@implementation SVGGradientElement

@synthesize stops = _stops;

-(void)addStop:(SVGGradientStop *)gradientStop
{
    if( _stops == nil )
        _stops = [[NSMutableArray alloc] initWithCapacity:1];
    [_stops addObject:gradientStop];
}

-(void)parseAttributes:(NSDictionary *)attributes
{
    [super parseAttributes:attributes];
    
    if( [self.parent isKindOfClass:[SVGGroupElement class]] )
        attributes = [(SVGGroupElement *)self.parent fillBlanksInDictionary:attributes];
        
    
    NSNumber *testObjectX = [attributes objectForKey:@"x1"];
    NSNumber *testObjectY = [attributes objectForKey:@"y1"];
    
    startPoint = CGPointMake( [testObjectX floatValue], [testObjectY floatValue]); //default value is 0.0f, so if the attribute is nil, we will end up with the correct values
    
    testObjectX = [attributes objectForKey:@"x2"];
    testObjectY = [attributes objectForKey:@"y2"];
    if(testObjectX == nil )
        testObjectX = [NSNumber numberWithFloat:1.0f];
    
//    if(testObjectY == nil ) //y2 defaults to 0.0f by SVG spec
//        testObjectY = [NSNumber numberWithFloat:1.0f];
    
    endPoint = CGPointMake( [testObjectX floatValue], [testObjectY floatValue]);
//    endPoint = CGPointMake(1.0f,1.0f);
    
    gradientUnits = [[attributes objectForKey:@"gradientUnits"] copy];
    
#ifdef SVG_DEBUG_GRADIENTS
    NSLog(@"Gradient start point %@ end point %@", NSStringFromCGPoint(startPoint), NSStringFromCGPoint(endPoint));
    
    NSLog(@"SVGGradientElement gradientUnits == %@", gradientUnits);
#endif
}


-(CALayer *)autoreleasedLayer
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
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
    
    [gradientUnits release];
    
    
    [super dealloc];
}

@end
