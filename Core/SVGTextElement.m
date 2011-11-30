//
//  SVGTextElement.m
//  SVGPad
//
//  Created by Steven Fusco on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SVGTextElement.h"

@implementation SVGTextElement

+ (BOOL)shouldStoreContent {
    return YES;
}

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
    
    //     fill = "#000000";
//    "fill-opacity" = 1;
//    "font-family" = Sans;
//    "font-size" = "263.27566528px";
//    "font-stretch" = normal;
//    "font-style" = normal;
//    "font-variant" = normal;
//    "font-weight" = normal;
//    id = text2816;
//    "line-height" = "125%";
//    linespacing = "125%";
//    space = preserve;
//    stroke = none;
//    "text-align" = start;
//    "text-anchor" = start;
//    transform = "scale(0.80449853,1.2430103)";
//    "writing-mode" = "lr-tb";

}

- (CALayer *)layer {
#if TARGET_OS_IPHONE
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
#else
    return nil;
#endif
}

- (void)layoutLayer:(CALayer *)layer
{
    
}

@end
