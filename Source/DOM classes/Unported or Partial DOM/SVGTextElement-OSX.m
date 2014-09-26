#import <SVGKit/SVGTextElement.h>

#import <CoreText/CoreText.h>
#import <Cocoa/Cocoa.h>
#include <tgmath.h>

#import <SVGKit/SVGElement_ForParser.h> // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

#import <SVGKit/SVGHelperUtilities.h>

#import "SVGKCGFloatAdditions.h"
#import <SVGKit/SVGUtils.h>

@implementation SVGTextElement

@synthesize transform; // each SVGElement subclass that conforms to protocol "SVGTransformable" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols

- (void)getFontTrait:(out NSFontTraitMask*)traits weight:(out NSInteger*)weight
{
	NSParameterAssert(traits != NULL);
	NSParameterAssert(weight != NULL);
	
	*traits = 0;
	*weight = 0;
	
	//Parts of this code were taken from the SVGImageRep/libsvg project
	NSInteger SVGWeight = 0;
	
	NSString *fontWeight = [self cascadedValueForStylableProperty:@"font-weight"];
	NSString *fontStyle = [self cascadedValueForStylableProperty:@"font-style"];
	if (!fontWeight || fontWeight.length == 0) {
		fontWeight = @"normal";
	}
	if (!fontStyle || fontStyle.length == 0) {
		fontStyle = @"normal";
	}
	
	if (NSOrderedSame == [fontWeight caseInsensitiveCompare:@"normal"]) {
		SVGWeight = 400;
	} else if (NSOrderedSame == [fontWeight caseInsensitiveCompare:@"bold"]){
		SVGWeight = 700;
	}
#if 0
	else if (NSOrderedSame == [fontWeight caseInsensitiveCompare:@"lighter"])
		SVGWeight -= 100;
	else if (NSOrderedSame == [fontWeight caseInsensitiveCompare:@"bolder"])
		SVGWeight += 100;
#endif
	else {
		SVGWeight = [fontWeight integerValue];
	}
	
	if (SVGWeight < 100)
		SVGWeight = 100;
	if (SVGWeight > 900)
		SVGWeight = 900;
	
	if (SVGWeight >= 700) {
		(*traits) |= NSBoldFontMask;
	}
	*weight = ceil(SVGWeight / 80.0);
	
	if (NSOrderedSame == [fontStyle caseInsensitiveCompare:@"normal"]) {
		//Do nothing
	} else if (NSOrderedSame == [fontStyle caseInsensitiveCompare:@"italic"] || NSOrderedSame == [fontStyle caseInsensitiveCompare:@"oblique"]) {
		(*traits) |= NSItalicFontMask;
	} else {
		DDLogError(@"[%@] ERROR: unknown SVG font style %@!", [self class], fontStyle);
		DDLogInfo(@"[%@] INFO: Will set italics anyways.", [self class]);
		(*traits) |= NSItalicFontMask;
	}
	DDLogVerbose(@"[%@] INFO: Italic trait: %@, bold trait: %@, SVG weight: %li, Cocoa Weight: %li.", [self class], (*traits) & NSItalicFontMask ? @"Yes" : @"No", (*traits) & NSBoldFontMask ? @"Yes" : @"No", (long)SVGWeight, (long)(*weight));
}

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
	//FIXME: it seems that somewhere in SVGKit that spaces are removed. This is detrimental to font naming!
	NSString* actualFamily = [self cascadedValueForStylableProperty:@"font-family"];
	NSString *fillColorString = [self cascadedValueForStylableProperty:@"fill"];
	SVGColor col;
	//We won't worry about the alpha value: The opacity set via the SVGHelperUtilities class to the layer will be sufficient.
	if (fillColorString.length > 0) {
		col = SVGColorFromString([fillColorString UTF8String]);
	} else {
		col = SVGColorMake(0, 0, 0, 255);
	}
#if 1
	CGFloat effectiveFontSize = 12; // I chose 12. I couldn't find an official "default" value in the SVG spec.
	if (actualSize.length > 0) {
		SVGLength *sizeLen = [SVGLength svgLengthFromNSString:actualSize];
		//[sizeLen convertToSpecifiedUnits:SVG_LENGTHTYPE_PX];
		effectiveFontSize = [sizeLen pixelsValue];
	}
#else
	CGFloat effectiveFontSize = (actualSize.length > 0) ? [actualSize SVGKCGFloatValue] : 12; // I chose 12. I couldn't find an official "default" value in the SVG spec.
#endif
	/** Convert the size down using the SVG transform at this point, before we calc the frame size etc */
	//	effectiveFontSize = CGSizeApplyAffineTransform( CGSizeMake(0,effectiveFontSize), textTransformAbsolute ).height; // NB important that we apply a transform to a "CGSize" here, so that Apple's library handles worrying about whether to ignore skew transforms etc
	
	NSFontManager *fm = [NSFontManager sharedFontManager];
	
	NSFontTraitMask traitMask = 0;
	NSInteger fontWeightCG = 0;
	
	[self getFontTrait:&traitMask weight:&fontWeightCG];
	
	//Parts of this code were taken from the SVGImageRep project
	if (NSOrderedSame == [actualFamily caseInsensitiveCompare:@"serif"])
		actualFamily = @"Times";
	else if ((NSOrderedSame == [actualFamily caseInsensitiveCompare:@"sans-serif"]) ||
			 (NSOrderedSame == [actualFamily caseInsensitiveCompare:@"sans"]))
		actualFamily = @"Helvetica";
	else if (NSOrderedSame == [actualFamily caseInsensitiveCompare:@"monospace"])
		actualFamily = @"Courier";
	
	NSFont *font = [fm fontWithFamily:actualFamily traits:traitMask weight:fontWeightCG size:effectiveFontSize];
	if (!font) {
		//Maybe the "Font family" passed was a full font name. Check for that.
		font = [NSFont fontWithName:actualFamily size:effectiveFontSize];
	}
	if (!font) {
		//Match the iOS side and use Verdana for when we can't find fonts.
		font = [fm fontWithFamily:@"Verdana" traits:traitMask weight:fontWeightCG size:effectiveFontSize];
	}
	
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
	NSMutableAttributedString* tempString = [[NSMutableAttributedString alloc] initWithString:effectiveText];
	[tempString addAttribute:NSFontAttributeName
					   value:font
					   range:NSMakeRange(0, tempString.string.length)];
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (__bridge CFMutableAttributedStringRef) tempString );
	CGSize suggestedUntransformedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), NULL);
	CFRelease(framesetter);
	
	CGRect unTransformedFinalBounds = { CGPointZero, suggestedUntransformedSize}; // everything's been pre-scaled by [self transformAbsolute]
	
	CATextLayer *label = [[CATextLayer alloc] init];
	[SVGHelperUtilities configureCALayer:label usingElement:self];
	
	label.font = (__bridge CFTypeRef)font;
	
	NSString *alignmentMode = kCAAlignmentLeft;
	NSString *alignment = [self cascadedValueForStylableProperty:@"text-align"];
	if (alignment.length > 0) {
		if (NSOrderedSame == [alignment caseInsensitiveCompare:@"middle"]) {
			alignmentMode = kCAAlignmentCenter;
		} else if (NSOrderedSame == [alignment caseInsensitiveCompare:@"start"]) {
			//Do nothing, the default is already set
			//alignmentMode = kCAAlignmentLeft;
		} else if (NSOrderedSame == [alignment caseInsensitiveCompare:@"end"]) {
			alignmentMode = kCAAlignmentRight;
		} else {
			DDLogWarn(@"[%@] WARNING: Unknown alignment %@, using default (start(left))", [self class], alignment);
			//Do nothing, the default is already set
		}
	} 	
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
	CGFloat offsetToConvertSVGOriginToAppleOrigin = - suggestedUntransformedSize.height;
	CGSize fakeSizeToApplyNonTranslatingPartsOfTransform = CGSizeMake( 0, offsetToConvertSVGOriginToAppleOrigin);
	
	label.position = CGPointMake( 0,
								 0 + CGSizeApplyAffineTransform( fakeSizeToApplyNonTranslatingPartsOfTransform, textTransformAbsoluteWithLocalPositionOffset).height);
	label.anchorPoint = CGPointZero; // WARNING: SVG applies transforms around the top-left as origin, whereas Apple defaults to center as origin, so we tell Apple to work "like SVG" here.
	label.affineTransform = textTransformAbsoluteWithLocalPositionOffset;
	label.fontSize = effectiveFontSize;
	label.string = effectiveText;
	label.alignmentMode = alignmentMode;
    {
        CGColorRef tmpColor = CreateCGColorWithSVGColor(col);
        label.foregroundColor = tmpColor;
        CGColorRelease(tmpColor);
    }
	
	/** VERY USEFUL when trying to debug text issues:
	label.backgroundColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:0.5].CGColor;
	label.borderColor = [UIColor redColor].CGColor;
	//DEBUG: DDLogVerbose(@"font size %2.1f at %@ ... final frame of layer = %@", effectiveFontSize, NSStringFromPoint(transformedOrigin), NSStringFromRect(label.frame));
	*/
	
	return label;
}

- (void)layoutLayer:(CALayer *)layer
{
	
}

@end
