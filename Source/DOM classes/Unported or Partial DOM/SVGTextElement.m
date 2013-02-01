//
//  SVGTextElement.m
//  SVGPad
//
//  Created by Steven Fusco on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SVGTextElement.h"
#import "UIColor-Expanded.h"

#import <CoreText/CoreText.h>

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

//default values for text element
#define DEFAULT_FONT_FAMILY @"Verdana"
#define DEFAULT_FILL [UIColor blackColor]

@implementation SVGTextElement

@synthesize x = _x;
@synthesize y = _y;
@synthesize fill = _fill;

- (UIColor *)fill
{
    if(!_fill) {
        return DEFAULT_FILL;
    } else {
        return _fill;
    }
}

- (void)dealloc {
    [super dealloc];
}

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult
{
    [super postProcessAttributesAddingErrorsTo:parseResult];
    
	if( [[self getAttribute:@"x"] length] > 0 )
	_x = [[self getAttribute:@"x"] floatValue];
    
	if( [[self getAttribute:@"y"] length] > 0 )
	_y = [[self getAttribute:@"y"] floatValue];
    
    if( [[self getAttribute:@"fill"] length] > 0 )
    self.fill = [UIColor colorWithHexString:[self getAttribute:@"fill"]];
    
    if( [[self getAttribute:@"fill-opacity"] length] > 0 )
    self.fill = [UIColor colorWithRed:self.fill.red green:self.fill.green blue:self.fill.blue alpha:[[self getAttribute:@"fill-opacity"] floatValue]];
}

- (CALayer *) newLayer
{
	/**
	 Sadly, Apple's CATextLayer is pretty rubbish - one of those classes Apple never
	 finished writing?
	 
	 It's incompatible with UIFont (Apple states it is so), and it DOES NOT WORK by default:
	 
	 If you assign a font, and a font size, and text ... you get a blank empty layer of
	 size 0,0
	 
	 Because Apple requires you to ALSO do all the work of calculating the font size, shape,
	 position etc.
	 
	 This makes CATextLayer fairly rubbish as a class; you have to write most of
	 the source code yourself to make it work AT ALL
	 */
	NSString* actualSize = [self cascadedValueForStylableProperty:@"font-size"];
	NSString* actualFamily = [self cascadedValueForStylableProperty:@"font-family"];
	
	CGFloat effectiveFontSize = (actualSize.length > 0) ? [actualSize floatValue] : 12; // I chose 12. I couldn't find an official "default" value in the SVG spec.
    
    //WHY THE HELL should we do this?! We have transform to be applied to the whole layer!
    
	/** Convert the size down using the SVG transform at this point, before we calc the frame size etc */
//	effectiveFontSize = CGSizeApplyAffineTransform( CGSizeMake(0,effectiveFontSize), [self transformAbsolute]).height;
//	CGPoint transformedOrigin = CGPointApplyAffineTransform( CGPointMake(self.x, self.y), [self transformAbsolute]);
	
	/** find a valid font reference, or Apple's APIs will break later */
	/** undocumented Apple bug: CTFontCreateWithName cannot accept nil input*/
	CTFontRef font;
	if( actualFamily == nil) {
        actualFamily = @"Verdana"; // Spec says to use "whatever default font-family is normal for your system". On iOS, that's Verdana
    }
    font = CTFontCreateWithName( (CFStringRef)actualFamily, effectiveFontSize, NULL);
	
	/** Convert all whitespace to spaces, and trim leading/trailing (SVG doesn't support leading/trailing whitespace, and doesnt support CR LF etc) */
	
	NSString* effectiveText = self.textContent; // FIXME: this is a TEMPORARY HACK, UNTIL PROPER PARSING OF <TSPAN> ELEMENTS IS ADDED
	
	effectiveText = [effectiveText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	effectiveText = [effectiveText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    UIFont* fontToDraw = [UIFont fontWithName:actualFamily
                                         size:effectiveFontSize];
    CGSize sizeOfTextRect = [effectiveText sizeWithFont:fontToDraw];
	
    CATextLayer *label = [[CATextLayer alloc] init];
    label.name = self.identifier;
    label.font = font; /** WARNING: Apple docs say you "CANNOT" assign a UIFont instance here, for some reason they didn't bridge it with CGFont */
    label.frame = CGRectMake(0, 0, sizeOfTextRect.width, sizeOfTextRect.height);
	label.fontSize = effectiveFontSize;
    label.string = effectiveText;
    label.alignmentMode = kCAAlignmentLeft;
    label.foregroundColor = [self.fill CGColor];
    
    //rotating around basepoint
    CGAffineTransform tr1 = CGAffineTransformIdentity;
    tr1 = CGAffineTransformConcat(tr1, CGAffineTransformMakeTranslation(sizeOfTextRect.width/2, sizeOfTextRect.height/2));
    CGAffineTransform tr2 = CGAffineTransformConcat(tr1, self.transformRelative);
    tr2 = CGAffineTransformConcat(tr2, CGAffineTransformInvert(tr1));
    
    tr2 = CGAffineTransformConcat(CGAffineTransformMakeTranslation(_x, _y - fontToDraw.ascender), tr2);
    
    [label setAffineTransform:tr2];
    
#if OUTLINE_SHAPES
    
    label.borderColor = [UIColor blueColor].CGColor;
    label.borderWidth = 1.0f;
    
#endif
	
    return label;
}

- (void)layoutLayer:(CALayer *)layer
{
	
}

@end
