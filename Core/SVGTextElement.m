//
//  SVGTextElement.m
//  SVGPad
//
//  Created by Steven Fusco on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SVGTextElement.h"

@implementation SVGTextElement

@synthesize x = _x;
@synthesize y = _y;
@synthesize fontFamily = _fontFamily;
@synthesize fontSize = _fontSize;

- (void)dealloc {
    [_fontFamily release];
    [super dealloc];
}

- (void)parseAttributes:(NSDictionary *)attributes {
	id value = nil;
    
	if ((value = [attributes objectForKey:@"x"])) {
		_x = [value floatValue];
	}
    
	if ((value = [attributes objectForKey:@"y"])) {
		_y = [value floatValue];
	}
    
    // TODO: class
    // TODO: style
    // TODO: externalResourcesRequired
    // TODO: transform
    // TODO: lengthAdjust
    // TODO: rotate
    // TODO: textLength
    // TODO: dx
    // TODO: dy
    // TODO: fill
}

- (CALayer *)layer {
    NSString* textToDraw = self.stringValue;
    UIFont* fontToDraw = [UIFont fontWithName:_fontFamily
                                         size:_fontSize];
    CGSize sizeOfTextRect = [textToDraw sizeWithFont:fontToDraw];
    
    CATextLayer *label = [[[CATextLayer alloc] init] autorelease];
    [label setName:self.identifier];
    [label setFont:_fontFamily];
    [label setFontSize:_fontSize];  
    [label setFrame:CGRectMake(_x, _y, sizeOfTextRect.width, sizeOfTextRect.height)];
    [label setString:textToDraw];
    [label setAlignmentMode:kCAAlignmentLeft];
    [label setForegroundColor:[[UIColor blackColor] CGColor]];
    
    return label;
}

- (void)layoutLayer:(CALayer *)layer
{
    
}

@end
