//
//  SVGTextElement.h
//  SVGPad
//
//  Created by Steven Fusco on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#endif

#import "SVGElement.h"
#import "SVGLayeredElement.h"

/**
 http://www.w3.org/TR/2011/REC-SVG11-20110816/text.html#TextElement
 */
@interface SVGTextElement : SVGElement <SVGLayeredElement>

@property (readwrite,nonatomic,assign) CGFloat x;
@property (readwrite,nonatomic,assign) CGFloat y;
@property (readwrite,nonatomic,retain) UIColor *fill;


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

@end
