#import "SVGSVGElement.h"

#import "SVGSVGElement_Mutable.h"
#import "CALayerWithChildHitTest.h"
#import "DOMHelperUtilities.h"
#import "SVGHelperUtilities.h"

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@interface SVGSVGElement()
#pragma mark - elements REQUIRED to implement the spec but not included in SVG Spec due to bugs in the spec writing!
@property(nonatomic,readwrite) SVGRect requestedViewport;
@end

@implementation SVGSVGElement

@synthesize x;
@synthesize y;
@synthesize width;
@synthesize height;
@synthesize contentScriptType;
@synthesize contentStyleType;
@synthesize viewport;
@synthesize pixelUnitToMillimeterX;
@synthesize pixelUnitToMillimeterY;
@synthesize screenPixelToMillimeterX;
@synthesize screenPixelToMillimeterY;
@synthesize useCurrentView;
@synthesize currentView;
@synthesize currentScale;
@synthesize currentTranslate;
@synthesize source;

@synthesize viewBox = _viewBox; // each SVGElement subclass that conforms to protocol "SVGFitToViewBox" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols
@synthesize preserveAspectRatio; // each SVGElement subclass that conforms to protocol "SVGFitToViewBox" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols

#pragma mark - NON SPEC, violating, properties

-(void)dealloc
{
	self.viewBox = SVGRectUninitialized();
    [x release];
    [y release];
    [width release];
    [height release];
    [contentScriptType release];
    [contentStyleType release];
    self.preserveAspectRatio = nil;
    self.currentView = nil;
    self.currentTranslate = nil;
    self.styleSheets = nil;
    self.source = nil;
	[super dealloc];	
}

#pragma mark - CSS Spec methods (via the DocumentCSS protocol)

-(void)loadDefaults
{
	self.styleSheets = [[[StyleSheetList alloc] init] autorelease];
}
@synthesize styleSheets;

-(CSSStyleDeclaration *)getOverrideStyle:(Element *)element pseudoElt:(NSString *)pseudoElt
{
	NSAssert(FALSE, @"Not implemented yet");
	
	return nil;
}

#pragma mark - SVG Spec methods

-(long) suspendRedraw:(long) maxWaitMilliseconds { NSAssert( FALSE, @"Not implemented yet" ); return 0; }
-(void) unsuspendRedraw:(long) suspendHandleID { NSAssert( FALSE, @"Not implemented yet" ); }
-(void) unsuspendRedrawAll { NSAssert( FALSE, @"Not implemented yet" ); }
-(void) forceRedraw { NSAssert( FALSE, @"Not implemented yet" ); }
-(void) pauseAnimations { NSAssert( FALSE, @"Not implemented yet" ); }
-(void) unpauseAnimations { NSAssert( FALSE, @"Not implemented yet" ); }
-(BOOL) animationsPaused { NSAssert( FALSE, @"Not implemented yet" ); return TRUE; }
-(float) getCurrentTime { NSAssert( FALSE, @"Not implemented yet" ); return 0.0; }
-(void) setCurrentTime:(float) seconds { NSAssert( FALSE, @"Not implemented yet" ); }
-(NodeList*) getIntersectionList:(SVGRect) rect referenceElement:(SVGElement*) referenceElement { NSAssert( FALSE, @"Not implemented yet" ); return nil; }
-(NodeList*) getEnclosureList:(SVGRect) rect referenceElement:(SVGElement*) referenceElement { NSAssert( FALSE, @"Not implemented yet" ); return nil; }
-(BOOL) checkIntersection:(SVGElement*) element rect:(SVGRect) rect { NSAssert( FALSE, @"Not implemented yet" ); return FALSE; }
-(BOOL) checkEnclosure:(SVGElement*) element rect:(SVGRect) rect { NSAssert( FALSE, @"Not implemented yet" ); return FALSE; }
-(void) deselectAll { NSAssert( FALSE, @"Not implemented yet" );}
-(SVGNumber) createSVGNumber
{
	SVGNumber n = { 0 };
	return n;
}
-(SVGLength*) createSVGLength
{
	return [SVGLength new];
}
-(SVGAngle*) createSVGAngle { NSAssert( FALSE, @"Not implemented yet" ); return nil; }
-(SVGPoint*) createSVGPoint { NSAssert( FALSE, @"Not implemented yet" ); return nil; }
-(SVGMatrix*) createSVGMatrix { NSAssert( FALSE, @"Not implemented yet" ); return nil; }
-(SVGRect) createSVGRect
{
	SVGRect r = { 0.0, 0.0, 0.0, 0.0 };
	return r;
}
-(SVGTransform*) createSVGTransform { NSAssert( FALSE, @"Not implemented yet" ); return nil; }
-(SVGTransform*) createSVGTransformFromMatrix:(SVGMatrix*) matrix { NSAssert( FALSE, @"Not implemented yet" ); return nil; }

-(Element*) getElementById:(NSString*) elementId
{
	return [DOMHelperUtilities privateGetElementById:elementId childrenOfElement:self];
}


#pragma mark - Objective C methods needed given our current non-compliant SVG Parser

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult {
	[super postProcessAttributesAddingErrorsTo:parseResult];
	
	/**
	 If the width + height are missing, we have to get an image width+height from the USER before we even START parsing.
	 
	 There is NO SUPPORT IN THE SVG SPEC TO ALLOW THIS. This is strange, but they specified this part badly, so it's not a surprise.
	 
	 We would need to put extra (NON STANDARD) properties on SVGDocument, for the "viewport width and height",
	 and then in *this* method, if we're missing a width or height, take the values from the SVGDocument's temporary/default width height
	 
	 (NB: the input to this method "SVGKParseResult" has a .parsedDocument variable, that's how we'd fetch those values here
	 */
	
	NSString* stringWidth = [self getAttribute:@"width"];
	NSString* stringHeight = [self getAttribute:@"height"];
	
    /**
     Ignore percetage width and heights which are only used when rendering in HTML
     */

    if ([stringWidth containsString:@"%"])
        stringWidth = nil;

    if ([stringHeight containsString:@"%"])
        stringHeight = nil;

    if( stringWidth == nil || stringWidth.length < 1 )
		self.width = nil; // i.e. undefined
	else
		self.width = [SVGLength svgLengthFromNSString:[self getAttribute:@"width"]];
	
	if( stringHeight == nil || stringHeight.length < 1 )
		self.height = nil; // i.e. undefined
	else
		self.height = [SVGLength svgLengthFromNSString:[self getAttribute:@"height"]];


	if( [[self getAttribute:@"viewBox"] length] > 0 )
	{
		NSArray* boxElements = [[self getAttribute:@"viewBox"] componentsSeparatedByString:@" "];
		if ([boxElements count] < 2) {
            /* count should be 4 -- maybe they're comma separated like (x,y,w,h) */
            boxElements = [[self getAttribute:@"viewBox"] componentsSeparatedByString:@","];
        }
		_viewBox = SVGRectMake([[boxElements objectAtIndex:0] floatValue], [[boxElements objectAtIndex:1] floatValue], [[boxElements objectAtIndex:2] floatValue], [[boxElements objectAtIndex:3] floatValue]);

        /**
         Infer width and height from viewBox if not specified
         */

        if (self.width == nil)
            self.width = [SVGLength svgLengthFromNumber:_viewBox.width];

        if (self.height == nil)
            self.height = [SVGLength svgLengthFromNumber:_viewBox.height];
    }
	else
	{
		self.viewBox = SVGRectUninitialized(); // VERY IMPORTANT: we MUST make it clear this was never initialized, instead of saying its 0,0,0,0 !		
	}


    /* set the frameRequestedViewport appropriately (NB: spec doesn't allow for this but it REQUIRES it to be done and saved!) */
    if( self.width != nil && self.height != nil )
        self.requestedViewport = SVGRectMake( 0, 0, [self.width pixelsValue], [self.height pixelsValue] );
    else
        self.requestedViewport = SVGRectUninitialized();


    /**
     NB: this is VERY CONFUSING due to badly written SVG Spec, but: the viewport MUST NOT be set by the parser,
     it MUST ONLY be set by the "renderer" -- and the renderer MAY have decided to use a different viewport from
     the one that the SVG file *implies* (e.g. if the user scales the SVG, the viewport WILL BE DIFFERENT,
     by definition!

     ...However: the renderer will ALWAYS start with the default viewport values (that are calcualted by the parsing process)
     and it makes it much cleaner and safer to implement if we have the PARSER set the viewport initially

     (and the renderer will IMMEDIATELY overwrite them once the parsing is finished IFF IT NEEDS TO)
     */
    self.viewport = self.requestedViewport; // renderer can/will change the .viewport, but .requestedViewport can only be set by the PARSER

    [SVGHelperUtilities parsePreserveAspectRatioFor:self];
}

- (SVGElement *)findFirstElementOfClass:(Class)classParameter {
	for (SVGElement *element in self.childNodes)
	{
		if ([element isKindOfClass:classParameter])
			return element;
	}
	
	return nil;
}

- (CALayer *) newLayer
{
	
	CALayer* _layer = [[CALayerWithChildHitTest layer] retain];
	
	[SVGHelperUtilities configureCALayer:_layer usingElement:self];
	
	/** <SVG> tags know exactly what size/shape their layer needs to be - it's explicit in their width + height attributes! */
	CGRect newBoundsFromSVGTag = CGRectFromSVGRect( self.viewport );
	_layer.frame = newBoundsFromSVGTag; // assign to FRAME, not to BOUNDS: Apple has some weird bugs where for particular numeric values (!) assignment to bounds will cause the origin to jump away from (0,0)!
	
	return _layer;
}

- (void)layoutLayer:(CALayer *)layer {
 	
	/**
	According to the SVG spec ... what this method originaly did is illegal. I've deleted all of it, and now a few more SVG's render correctly, that
	 previously were rendering with strange offsets at the top level
	 */
}

#pragma mark - elements REQUIRED to implement the spec but not included in SVG Spec due to bugs in the spec writing!

-(double)aspectRatioFromWidthPerHeight
{
	return [self.height pixelsValue] == 0 ? 0 : [self.width pixelsValue] / [self.height pixelsValue];
}

-(double)aspectRatioFromViewBox
{	
	return  self.viewBox.height == 0 ? 0 : self.viewBox.width / self.viewBox.height;
}


@end
