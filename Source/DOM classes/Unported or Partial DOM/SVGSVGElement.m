#import "SVGSVGElement.h"

#import "SVGSVGElement_Mutable.h"
#import "CALayerWithChildHitTest.h"
#import "DOMHelperUtilities.h"

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@interface SVGSVGElement()
@property (nonatomic, readwrite) CGRect viewBoxFrame;
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

#pragma mark - NON SPEC, violating, properties
@synthesize viewBoxFrame = _viewBoxFrame;

-(void)dealloc
{
	self.viewBoxFrame = CGRectNull;
	[super dealloc];	
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
	
	NSAssert( [[self getAttribute:@"width"] length] > 0, @"Not supported yet: <svg> tag that is missing an explicit width attribute");
	NSAssert( [[self getAttribute:@"height"] length] > 0, @"Not supported yet: <svg> tag that is missing an explicit height attribute");
	
	self.width = [SVGLength svgLengthFromNSString:[self getAttribute:@"width"]];
	
	self.height = [SVGLength svgLengthFromNSString:[self getAttribute:@"height"]];
	
	if( [[self getAttribute:@"viewBox"] length] > 0 )
	{
		NSArray* boxElements = [[self getAttribute:@"viewBox"] componentsSeparatedByString:@" "];
		
		_viewBoxFrame = CGRectMake([[boxElements objectAtIndex:0] floatValue], [[boxElements objectAtIndex:1] floatValue], [[boxElements objectAtIndex:2] floatValue], [[boxElements objectAtIndex:3] floatValue]);
        
        //osx logging
#if TARGET_OS_IPHONE        
        NSLog(@"[%@] DEBUG INFO: set document viewBox = %@", [self class], NSStringFromCGRect(self.viewBoxFrame));
#else
        //mac logging
     NSLog(@"[%@] DEBUG INFO: set document viewBox = %@", [self class], NSStringFromRect(self.viewBoxFrame));    
#endif   
        
	}
}

- (SVGElement *)findFirstElementOfClass:(Class)class {
	for (SVGElement *element in self.childNodes)
	{
		if ([element isKindOfClass:class])
			return element;
	}
	
	return nil;
}

- (CALayer *) newLayer
{
	
	CALayer* _layer = [[CALayerWithChildHitTest layer] retain];
	
	_layer.name = self.identifier;
	[_layer setValue:self.identifier forKey:kSVGElementIdentifier];
	
	if ([_layer respondsToSelector:@selector(setShouldRasterize:)]) {
		[_layer performSelector:@selector(setShouldRasterize:)
					 withObject:[NSNumber numberWithBool:YES]];
	}
	
	return _layer;
}

- (void)layoutLayer:(CALayer *)layer {
	NSArray *sublayers = [layer sublayers];
	CGRect mainRect = CGRectZero;
	
	for (NSUInteger n = 0; n < [sublayers count]; n++) {
		CALayer *currentLayer = [sublayers objectAtIndex:n];
		
		if (n == 0) {
			mainRect = currentLayer.frame;
		}
		else {
			mainRect = CGRectUnion(mainRect, currentLayer.frame);
		}
	}
	
	layer.frame = mainRect;
	
	// TODO: this code looks insanely wrong to me. WTF is it doing? Why? WHY?
	for (CALayer *currentLayer in sublayers) {
		CGRect frame = currentLayer.frame;
		frame.origin.x -= mainRect.origin.x;
		frame.origin.y -= mainRect.origin.y;
		
		currentLayer.frame = frame;
	}
}

@end
