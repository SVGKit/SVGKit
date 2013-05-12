//
//  SVGGradientStop
//  SVGPad
//
//  Created by Kevin Stich on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "SVGGradientStop.h"
#import "SVGElement_ForParser.h"

#import "SVGUtils.h"
#import "SVGKParser.h"

#import "SVGLength.h"

#import "SVGKCGFloatAdditions.h"

@implementation SVGGradientStop

@synthesize offset = _offset;
@synthesize stopColor = _stopColor;
@synthesize stopOpacity = _stopOpacity;

//@synthesize style = _style;

-(void)loadDefaults
{
	_stopOpacity = 1.0f;
}

-(void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult
{
	[super postProcessAttributesAddingErrorsTo:parseResult];
	
	if( [self getAttribute:@"offset"].length > 0 )
        _offset = [[SVGLength svgLengthFromNSString:[self getAttribute:@"offset"]] numberValue];
    
	/** First, process the style - if it has one! */
    if( [self getAttribute:@"style"].length > 0 )
    {
        NSDictionary *styleDict = [SVGKParser NSDictionaryFromCSSAttributes:[self getAttributeNode:@"style"]];
		
		Attr* testObject = [styleDict objectForKey:@"stop-color"];
        if( testObject != nil )
            _stopColor = SVGColorFromString([testObject.value UTF8String]);
        
        testObject = [styleDict objectForKey:@"stop-opacity"];
		if( testObject != nil )
			_stopOpacity = [testObject.value SVGKCGFloatValue];
        _stopColor.a = (_stopOpacity * 255);
    }
	
	/** Second, over-ride the style with any locally-specified values */
	if( [self getAttribute:@"stop-color"].length > 0 )
        _stopColor = SVGColorFromString( [[self getAttribute:@"stop-color"] UTF8String] );
	
	if( [self getAttribute:@"stop-opacity"].length > 0 )
        _stopOpacity = [[self getAttribute:@"stop-opacity"] SVGKCGFloatValue];
	
	_stopColor.a = (_stopOpacity * 255);
}

//no memory allocated by this subclass
//-(void)dealloc
//{
//    
//    
//    [super dealloc];
//}

@end
