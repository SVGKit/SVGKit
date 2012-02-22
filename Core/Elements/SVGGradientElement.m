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

@implementation SVGGradientElement

@synthesize stops = _stops;

-(void)addStop:(SVGGradientStop *)gradientStop
{
    if( _stops == nil )
        _stops = [NSMutableArray new];
    [_stops addObject:gradientStop];
}

-(void)parseAttributes:(NSDictionary *)attributes
{
    
    id testObjectX = [attributes objectForKey:@"x1"];
    id testObjectY = [attributes objectForKey:@"y1"];
    if( testObjectX != nil && testObjectY != nil )
        startPoint = CGPointMake( [testObjectX floatValue], [testObjectY floatValue]);
    
    
    testObjectX = [attributes objectForKey:@"x2"];
    testObjectY = [attributes objectForKey:@"y2"];
    if( testObjectX != nil && testObjectY != nil )
        endPoint = CGPointMake( [testObjectX floatValue], [testObjectY floatValue]);
    
    gradientUnits = [attributes objectForKey:@"gradientUnits"];
    
    [super parseAttributes:attributes];
}


-(CALayer *)newLayer
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    
    NSMutableArray *colors = [NSMutableArray new];
    NSMutableArray *locations = [NSMutableArray new];
    for (SVGGradientStop *theStop in _stops) 
    {
        [locations addObject:[NSNumber numberWithFloat:theStop.offset]];
        [colors addObject:(id)CGColorCreateCopyWithAlpha(CGColorWithSVGColor([theStop stopColor]), [theStop stopOpacity])];
    }
    
    [gradientLayer setColors:colors];
    [gradientLayer setLocations:locations];
//    gradientLayer.colors = colors;
//    gradientLayer.locations = locations;
    
    [colors release];
    [locations release];
    
//    gradientLayer.type = kCAGradientLayerAxial;
    
    return gradientLayer;
}


-(void)dealloc
{
    [_stops release];
    _stops = nil;
    
    
    
    [super dealloc];
}

@end
