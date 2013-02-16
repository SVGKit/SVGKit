#import "SVGTextElement.h"

#import <CoreText/CoreText.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

#import "SVGHelperUtilities.h"

@implementation SVGTextElement

@synthesize transform; // each SVGElement subclass that conforms to protocol "SVGTransformable" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols

- (void)dealloc {
    [super dealloc];
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
	
	CGFloat effectiveFontSize = (actualSize.length > 0) ? [actualSize floatValue] : 12; // I chose 12. I couldn't find an official "default" value in the SVG spec.
	/** Convert the size down using the SVG transform at this point, before we calc the frame size etc */
//	effectiveFontSize = CGSizeApplyAffineTransform( CGSizeMake(0,effectiveFontSize), textTransformAbsolute ).height; // NB important that we apply a transform to a "CGSize" here, so that Apple's library handles worrying about whether to ignore skew transforms etc
	
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
    CGSize suggestedUntransformedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);
	
	CGRect unTransformedFinalFrame = CGRectMake( [self.x pixelsValue],
											  [self.y pixelsValue] - suggestedUntransformedSize.height, /** NB: specific to Apple: the "origin" is the TOP LEFT corner of first line of text, whereas SVG uses the font's internal origin (which is BOTTOM LEFT CORNER OF A LETTER SUCH AS 'a' OR 'x' THAT SITS ON THE BASELINE ... so we have to make the FRAME start "font leading" higher up
																										 
																										 
												WARNING: Apple's whole font-rendering system has MANY BUGS (c.f. StackOverflow for the large
																										 number of undocumented, unfixed bugs from Apple)
												
												We TRIED to use the font's built-in numbers to correct the position, but Apple's own methods often report incorrect values, and/or Apple has deprecated REQUIRED methods in their API (with no explanation - e.g. "font leading").
																										 
												
												If/when Apple fixes their bugs - or if you know enough about their API's to workaround the bugs, feel free to fix this code. But if not ... probably best not to bother.
																										 */
											  suggestedUntransformedSize.width,
											  suggestedUntransformedSize.height); // everything's been pre-scaled by [self transformAbsolute]
	CGRect transformedFinalFrame = CGRectApplyAffineTransform( unTransformedFinalFrame, textTransformAbsolute );
	
    CATextLayer *label = [[CATextLayer alloc] init];
    label.name = self.identifier;
    label.font = font; /** WARNING: Apple docs say you "CANNOT" assign a UIFont instance here, for some reason they didn't bridge it with CGFont */
    label.bounds = CGRectMake( 0, 0,  unTransformedFinalFrame.size.width, unTransformedFinalFrame.size.height );
	label.position = CGPointMake( transformedFinalFrame.origin.x, transformedFinalFrame.origin.y ); // WARNING: c.f. the note on anchorPoint - changing the anchorPoint RE-DEFINES THE MEANING OF .position (thank Apple for their misleading naming scheme + API design)
	label.anchorPoint = CGPointZero; // WARNING: SVG applies transforms around the top-left as origin, whereas Apple defaults to center as origin
	label.affineTransform = textTransformAbsolute;
	label.fontSize = effectiveFontSize;
    label.string = effectiveText;
    label.alignmentMode = kCAAlignmentLeft;
    label.foregroundColor = [UIColor blackColor].CGColor;

	//DEBUG: NSLog(@"font size %2.1f at %@ ... final frame of layer = %@", effectiveFontSize, NSStringFromCGPoint(transformedOrigin), NSStringFromCGRect(label.frame));
	
    return label;
}

- (void)layoutLayer:(CALayer *)layer
{
	
}

@end
