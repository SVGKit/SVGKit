#import "SVGTextElement.h"

#import <CoreText/CoreText.h>
#if SVGKIT_MAC
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif
#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)
#import "SVGGradientLayer.h"
#import "SVGHelperUtilities.h"
#import "SVGUtils.h"

@implementation SVGTextElement

@synthesize transform; // each SVGElement subclass that conforms to protocol "SVGTransformable" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols


- (CALayer *) newLayer
{
	/**
	 BY DESIGN: we work out the positions of all text in ABSOLUTE space, and then construct the Apple CALayers and CATextLayers around
	 them, as required.
	 
	 Because: Apple's classes REQUIRE us to provide a lot of this info up-front. Sigh
	 And: SVGKit works by pre-baking everything into position (its faster, and avoids Apple's broken CALayer.transform property)
	 */
	CGAffineTransform textTransformAbsolute = [SVGHelperUtilities transformAbsoluteIncludingViewportForTransformableOrViewportEstablishingElement:self];
	/** add on the local x,y that will NOT BE iNCLUDED IN THE TRANSFORM
	 AUTOMATICALLY BECAUSE THEY ARE NOT TRANSFORM COMMANDS IN SVG SPEC!!
	 -- but they ARE part of the "implicit transform" of text elements!! (bad SVG Spec design :( )
	 
	 NB: the local bits (x/y offset) have to be pre-transformed by
	 */
	CGAffineTransform textTransformAbsoluteWithLocalPositionOffset = CGAffineTransformConcat( CGAffineTransformMakeTranslation( [self.x pixelsValue], [self.y pixelsValue]), textTransformAbsolute);
	
	/**
	 Apple's CATextLayer is poor - one of those classes Apple hasn't finished writing?
	 
	 It's incompatible with UIFont (Apple states it is so), and it DOES NOT WORK by default:
	 
	 If you assign a font, and a font size, and text ... you get a blank empty layer of
	 size 0,0
	 
	 Because Apple requires you to ALSO do all the work of calculating the font size, shape,
	 position etc.
	 
	 But its the easiest way to get FULL control over size/position/rotation/etc in a CALayer
	 */
	NSString* actualSize = [self cascadedValueForStylableProperty:@"font-size"];
	NSString* actualFamily = [self cascadedValueForStylableProperty:@"font-family"];
    
    // TODO `font-family` is an array, parse it and loop all posible value until we get a font which match the correct name (or all failed fallback)
	
	CGFloat effectiveFontSize = (actualSize.length > 0) ? [actualSize floatValue] : 12; // I chose 12. I couldn't find an official "default" value in the SVG spec.
	/** Convert the size down using the SVG transform at this point, before we calc the frame size etc */
//	effectiveFontSize = CGSizeApplyAffineTransform( CGSizeMake(0,effectiveFontSize), textTransformAbsolute ).height; // NB important that we apply a transform to a "CGSize" here, so that Apple's library handles worrying about whether to ignore skew transforms etc
	
	/** find a valid font reference, or Apple's APIs will break later */
	/** undocumented Apple bug: CTFontCreateWithName cannot accept nil input*/
	CTFontRef font = NULL;
	if( actualFamily != nil)
		font = CTFontCreateWithName( (CFStringRef)actualFamily, effectiveFontSize, NULL);
	if( font == NULL ) {
		// Spec says to use "whatever default font-family is normal for your system". Use HelveticaNeue, the default since iOS 7.
		font = CTFontCreateWithName( (CFStringRef) @"HelveticaNeue", effectiveFontSize, NULL);
	}

	/** Convert all whitespace to spaces, and trim leading/trailing (SVG doesn't support leading/trailing whitespace, and doesnt support CR LF etc) */
	
	NSString* effectiveText = self.textContent; // FIXME: this is a TEMPORARY HACK, UNTIL PROPER PARSING OF <TSPAN> ELEMENTS IS ADDED
	
	effectiveText = [effectiveText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	effectiveText = [effectiveText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    /**
     Stroke color && stroke width
     Apple's `CATextLayer` can not stroke gradient on the layer (we can only fill the layer)
     */
    CGColorRef strokeColor = [SVGHelperUtilities parseStrokeForElement:self];
    CGFloat strokeWidth = 0;
    NSString* actualStrokeWidth = [self cascadedValueForStylableProperty:@"stroke-width"];
    if (actualStrokeWidth)
    {
        SVGRect r = ((SVGSVGElement*)self.viewportElement).viewport;
        strokeWidth = [[SVGLength svgLengthFromNSString:actualStrokeWidth]
                       pixelsValueWithDimension: hypot(r.width, r.height)];
    }
    
    /**
     Fill color
     Apple's `CATextLayer` can be filled using mask.
     */
    CGColorRef fillColor = [SVGHelperUtilities parseFillForElement:self];
	
	/** Calculate 
	 
	 1. Create an attributed string (Apple's APIs are hard-coded to require this)
	 2. Set the font to be the correct one + correct size for whole string, inside the string
	 3. Ask apple how big the final thing should be
	 4. Use that to provide a layer.frame
	 */
	NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:effectiveText];
    NSRange stringRange = NSMakeRange(0, attributedString.string.length);
	[attributedString addAttribute:(NSString *)NSFontAttributeName
					  value:(__bridge id)font
					  range:stringRange];
    if (fillColor) {
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:(__bridge id)fillColor
                                 range:stringRange];
    }
    if (strokeWidth != 0 && strokeColor) {
        [attributedString addAttribute:NSStrokeColorAttributeName
                                 value:(__bridge id)strokeColor
                                 range:stringRange];
        // If both fill && stroke, pass negative value; only fill, pass positive value
        // A typical value for outlined text is 3.0. Actually this is not so accurate, but until we directly draw the text glyph using Core Text, we cat not control the detailed stroke width follow SVG spec
        CGFloat strokeValue = strokeWidth / 3.0;
        if (fillColor) {
            strokeValue = -strokeValue;
        }
        [attributedString addAttribute:NSStrokeWidthAttributeName
                                 value:@(strokeValue)
                                 range:stringRange];
    }
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) attributedString );
    CGSize suggestedUntransformedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);
	
	CGRect unTransformedFinalBounds = CGRectMake( 0,
											  0,
											  suggestedUntransformedSize.width,
											  suggestedUntransformedSize.height); // everything's been pre-scaled by [self transformAbsolute]
	
    CATextLayer *label = [[CATextLayer alloc] init];
    [SVGHelperUtilities configureCALayer:label usingElement:self];
	
	/** This is complicated for three reasons.
	 Partly: Apple and SVG use different defitions for the "origin" of a piece of text
	 Partly: Bugs in Apple's CoreText
	 Partly: flaws in Apple's CALayer's handling of frame,bounds,position,anchorPoint,affineTransform
	 
	 1. CALayer.frame DOES NOT EXIST AS A REAL PROPERTY - if you read Apple's docs you eventually realise it is fake. Apple explicitly says it is "not defined". They should DELETE IT from their API!
	 2. CALayer.bounds and .position ARE NOT AFFECTED BY .affineTransform - only the contents of the layer is affected
	 3. SVG defines two SEMI-INCOMPATIBLE ways of positioning TEXT objects, that we have to correctly combine here.
	 4. So ... to apply a transform to the layer text:
	     i. find the TRANSFORM
	     ii. merge it with the local offset (.x and .y from SVG) - which defaults to (0,0)
	     iii. apply that to the layer
	     iv. set the position to 0
	     v. BECAUSE SVG AND APPLE DEFINE ORIGIN DIFFERENTLY: subtract the "untransformed" height of the font ... BUT: pre-transformed ONLY BY the 'multiplying (non-translating)' part of the TRANSFORM.
	     vi. set the bounds to be (whatever Apple's CoreText says is necessary to render TEXT at FONT SIZE, with NO TRANSFORMS)
	 */
    label.bounds = unTransformedFinalBounds;
	
	/** NB: specific to Apple: the "origin" is the TOP LEFT corner of first line of text, whereas SVG uses the font's internal origin
	 (which is BOTTOM LEFT CORNER OF A LETTER SUCH AS 'a' OR 'x' THAT SITS ON THE BASELINE ... so we have to make the FRAME start "font leading" higher up
	 
	 WARNING: Apple's font-rendering system has some nasty bugs (c.f. StackOverflow)
	 
	 We TRIED to use the font's built-in numbers to correct the position, but Apple's own methods often report incorrect values,
	 and/or Apple has deprecated REQUIRED methods in their API (with no explanation - e.g. "font leading")
	 
	 If/when Apple fixes their bugs - or if you know enough about their API's to workaround the bugs, feel free to fix this code.
	 */
    CTLineRef line = CTLineCreateWithAttributedString( (CFMutableAttributedStringRef) attributedString );
    CGFloat ascent = 0;
    CTLineGetTypographicBounds(line, &ascent, NULL, NULL);
    CFRelease(line);
	CGFloat offsetToConvertSVGOriginToAppleOrigin = -ascent;
	CGSize fakeSizeToApplyNonTranslatingPartsOfTransform = CGSizeMake( 0, offsetToConvertSVGOriginToAppleOrigin);
	
	label.position = CGPointMake( 0,
								 0 + CGSizeApplyAffineTransform( fakeSizeToApplyNonTranslatingPartsOfTransform, textTransformAbsoluteWithLocalPositionOffset).height);
    
    NSString *textAnchor = [self cascadedValueForStylableProperty:@"text-anchor"];
    if( [@"middle" isEqualToString:textAnchor] )
        label.anchorPoint = CGPointMake(0.5, 0.0);
    else if( [@"end" isEqualToString:textAnchor] )
        label.anchorPoint = CGPointMake(1.0, 0.0);
    else
        label.anchorPoint = CGPointZero; // WARNING: SVG applies transforms around the top-left as origin, whereas Apple defaults to center as origin, so we tell Apple to work "like SVG" here.
    
	label.affineTransform = textTransformAbsoluteWithLocalPositionOffset;
    label.string = [attributedString copy];
    label.alignmentMode = kCAAlignmentLeft;
    
#if SVGKIT_MAC
    label.contentsScale = [[NSScreen mainScreen] backingScaleFactor];
#else
    label.contentsScale = [[UIScreen mainScreen] scale];
#endif
    
    return [self newCALayerForTextLayer:label transformAbsolute:textTransformAbsolute];

	/** VERY USEFUL when trying to debug text issues:
	label.backgroundColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:0.5].CGColor;
	label.borderColor = [UIColor redColor].CGColor;
	//DEBUG: SVGKitLogVerbose(@"font size %2.1f at %@ ... final frame of layer = %@", effectiveFontSize, NSStringFromCGPoint(transformedOrigin), NSStringFromCGRect(label.frame));
	*/
}

-(CALayer *) newCALayerForTextLayer:(CATextLayer *)label transformAbsolute:(CGAffineTransform)transformAbsolute
{
    CALayer *fillLayer = label;
    NSString* actualFill = [self cascadedValueForStylableProperty:@"fill"];

    if ( [actualFill hasPrefix:@"url"] )
    {
        NSArray *fillArgs = [actualFill componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        NSString *fillIdArg = fillArgs.firstObject;
        NSRange idKeyRange = NSMakeRange(5, fillIdArg.length - 6);
        NSString* fillId = [fillIdArg substringWithRange:idKeyRange];

        /** Replace the return layer with a special layer using the URL fill */
        /** fetch the fill layer by URL using the DOM */
        SVGGradientLayer *gradientLayer = [SVGHelperUtilities getGradientLayerWithId:fillId forElement:self withRect:label.frame transform:transformAbsolute];
        if (gradientLayer) {
            gradientLayer.mask = label;
            fillLayer = gradientLayer;
        } else {
            // no gradient, fallback
        }
    }

    NSString* actualOpacity = [self cascadedValueForStylableProperty:@"opacity" inherit:NO];
    fillLayer.opacity = actualOpacity.length > 0 ? [actualOpacity floatValue] : 1; // unusually, the "opacity" attribute defaults to 1, not 0

    return fillLayer;
}

- (void)layoutLayer:(CALayer *)layer
{
	
}

@end
