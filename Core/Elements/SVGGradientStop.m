//
//  SVGGradientStop.m
//  SVGPad
//
//  Created by Kevin Stich on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SVGUtils.h"
#import "SVGGradientStop.h"
#import "SVGParser.h"
#import "SVGElement+Private.h"

@implementation SVGGradientStop

@synthesize offset = _offset;
@synthesize stopColor = _stopColor;
@synthesize stopOpacity = _stopOpacity;

//@synthesize style = _style;


-(void)parseAttributes:(NSDictionary *)attributes
{
    id testObject = nil;
    
    testObject = [attributes objectForKey:@"offset"];
    if( testObject != nil )
        _offset = [testObject floatValue];
    
    testObject = [attributes objectForKey:@"style"];
    if( testObject != nil )
    {
        NSDictionary *styleDict = [SVGParser NSDictionaryFromCSSAttributes:testObject];
                testObject = [styleDict objectForKey:@"stop-color"];
        if( testObject != nil )
            _stopColor = SVGColorFromString([testObject UTF8String]);
        
        testObject = [styleDict objectForKey:@"stop-opacity"];
        _stopOpacity = (testObject != nil) ? [testObject floatValue] : 1.0f;
        _stopColor.a = (_stopOpacity * 255);
    }
    
    [super parseAttributes:attributes];
}

//no memory allocated by this subclass
//-(void)dealloc
//{
//    
//    
//    [super dealloc];
//}

@end
