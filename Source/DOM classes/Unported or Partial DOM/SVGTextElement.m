//
//  SVGTextElement.m
//  SVGPad
//
//  Created by Steven Fusco on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SVGTextElement.h"

#import <CoreText/CoreText.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)


@implementation SVGTextElement

@synthesize x = _x;
@synthesize y = _y;
@synthesize fontFamily = _fontFamily;
@synthesize fontSize = _fontSize;

- (void)dealloc {
    [_fontFamily release];
    [super dealloc];
}

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult
{
    [super postProcessAttributesAddingErrorsTo:parseResult];
    
	if( [[self getAttribute:@"x"] length] > 0 )
	_x = [[self getAttribute:@"x"] floatValue];
    
	if( [[self getAttribute:@"y"] length] > 0 )
	_y = [[self getAttribute:@"y"] floatValue];
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
	/** Convert the size down using the SVG transform at this point, before we calc the frame size etc */
	effectiveFontSize = CGSizeApplyAffineTransform( CGSizeMake(0,effectiveFontSize), [self transformAbsolute]).height;
	CGPoint transformedOrigin = CGPointApplyAffineTransform( CGPointMake(self.x, self.y), [self transformAbsolute]);
	
	/** find a valid font reference, or Apple's APIs will break later */
	/** undocumented Apple bug: CTFontCreateWithName cannot accept nil input*/
	CTFontRef font = NULL;
	if( actualFamily != nil)
		font = CTFontCreateWithName( (CFStringRef)actualFamily, effectiveFontSize, NULL);
	if( font == NULL )
		font = CTFontCreateWithName( (CFStringRef) @"Verdana", effectiveFontSize, NULL); // Spec says to use "whatever default font-family is normal for your system". On iOS, that's Verdana
	
	/** Convert all whitespace to spaces, and trim leading/trailing (SVG doesn't support leading/trailing whitespace, and doesnt support CR LF etc) */
	
	NSString* effectiveText = self.textContent; // FIXME: this is a TEMPORARY HACK, UNTIL PROPER PARSING OF <TSPAN> ELEMENTS IS ADDED
	
	effectiveText = [effectiveText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	effectiveText = [effectiveText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	
	/** Calculate 
	 
	 1. Create an attributed string (Apple's APIs are hard-coded to require this)
	 2. Set the font to be the correct one + correct size for whole string, inside the string
	 3. Ask apple how big the final thing should be
	 4. Use that to provide a layer.frame
	 */
	NSMutableAttributedString* tempString = [[[NSMutableAttributedString alloc] initWithString:effectiveText] autorelease];
	[tempString addAttribute:(NSString *)kCTFontAttributeName
					  value:(id)font
					  range:NSMakeRange(0, tempString.string.length)];
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) tempString );
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);
	
    CATextLayer *label = [[CATextLayer alloc] init];
    label.name = self.identifier;
    label.font = font; /** WARNING: Apple docs say you "CANNOT" assign a UIFont instance here, for some reason they didn't bridge it with CGFont */
    label.frame = CGRectMake( transformedOrigin.x,
							 transformedOrigin.y - suggestedSize.height, /** NB: specific to SVG: the "origin" is the bottom LEFT corner of first line of text, so we have to make the FRAME start "height" higher up */
							 suggestedSize.width,
							 suggestedSize.height); // everything's been pre-scaled by [self transformAbsolute]
	label.fontSize = effectiveFontSize;
    label.string = effectiveText;
    label.alignmentMode = kCAAlignmentLeft;
    label.foregroundColor = [UIColor blackColor].CGColor;
    
	//DEBUG: label.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.2].CGColor;
	
	//DEBUG: NSLog(@"font size %2.1f at %@ ... final frame of layer = %@", effectiveFontSize, NSStringFromCGPoint(transformedOrigin), NSStringFromCGRect(label.frame));
	
    return label;
}

- (void)layoutLayer:(CALayer *)layer
{
	
}

@end
