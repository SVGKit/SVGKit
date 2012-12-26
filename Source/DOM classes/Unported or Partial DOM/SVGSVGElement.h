/**
 SVGSVGElement.m
 
 Represents the "<svg>" tag in an SVG file
 
 http://www.w3.org/TR/SVG/struct.html#InterfaceSVGSVGElement
 
 readonly attribute SVGAnimatedLength x;
 readonly attribute SVGAnimatedLength y;
 readonly attribute SVGAnimatedLength width;
 readonly attribute SVGAnimatedLength height;
 attribute DOMString contentScriptType setraises(DOMException);
 attribute DOMString contentStyleType setraises(DOMException);
 readonly attribute SVGRect viewport;
 readonly attribute float pixelUnitToMillimeterX;
 readonly attribute float pixelUnitToMillimeterY;
 readonly attribute float screenPixelToMillimeterX;
 readonly attribute float screenPixelToMillimeterY;
 readonly attribute boolean useCurrentView;
 readonly attribute SVGViewSpec currentView;
 attribute float currentScale;
 readonly attribute SVGPoint currentTranslate;
 
 unsigned long suspendRedraw(in unsigned long maxWaitMilliseconds);
 void unsuspendRedraw(in unsigned long suspendHandleID);
 void unsuspendRedrawAll();
 void forceRedraw();
 void pauseAnimations();
 void unpauseAnimations();
 boolean animationsPaused();
 float getCurrentTime();
 void setCurrentTime(in float seconds);
 NodeList getIntersectionList(in SVGRect rect, in SVGElement referenceElement);
 NodeList getEnclosureList(in SVGRect rect, in SVGElement referenceElement);
 boolean checkIntersection(in SVGElement element, in SVGRect rect);
 boolean checkEnclosure(in SVGElement element, in SVGRect rect);
 void deselectAll();
 SVGNumber createSVGNumber();
 SVGLength createSVGLength();
 SVGAngle createSVGAngle();
 SVGPoint createSVGPoint();
 SVGMatrix createSVGMatrix();
 SVGRect createSVGRect();
 SVGTransform createSVGTransform();
 SVGTransform createSVGTransformFromMatrix(in SVGMatrix matrix);
 Element getElementById(in DOMString elementId);
 */

#import "DocumentCSS.h"

#import "SVGElement.h"
#import "SVGViewSpec.h"

#pragma mark - the SVG* types (SVGLength, SVGNumber, etc)
#import "SVGAngle.h"
#import "SVGLength.h"
#import "SVGNumber.h"
#import "SVGPoint.h"
#import "SVGRect.h"
#import "SVGTransform.h"

#pragma mark - a few raw DOM imports are required for SVG DOM, but not many
#import "Element.h"
#import "NodeList.h"

#import "SVGLayeredElement.h"

@interface SVGSVGElement : SVGElement < DocumentCSS, /* FIXME: refactor and delete this, it's in violation of the spec: */ SVGLayeredElement >



@property (nonatomic, retain, readonly) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* x;
@property (nonatomic, retain, readonly) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* y;
@property (nonatomic, retain, readonly) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* width;
@property (nonatomic, retain, readonly) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* height;
@property (nonatomic, retain, readonly) NSString* contentScriptType;
@property (nonatomic, retain, readonly) NSString* contentStyleType;
@property (nonatomic, readonly) SVGRect viewport;
@property (nonatomic, readonly) float pixelUnitToMillimeterX;
@property (nonatomic, readonly) float pixelUnitToMillimeterY;
@property (nonatomic, readonly) float screenPixelToMillimeterX;
@property (nonatomic, readonly) float screenPixelToMillimeterY;
@property (nonatomic, readonly) BOOL useCurrentView;
@property (nonatomic, retain, readonly) SVGViewSpec* currentView;
@property (nonatomic, readonly) float currentScale;
@property (nonatomic, retain, readonly) SVGPoint* currentTranslate;

-(long) suspendRedraw:(long) maxWaitMilliseconds;
-(void) unsuspendRedraw:(long) suspendHandleID;
-(void) unsuspendRedrawAll;
-(void) forceRedraw;
-(void) pauseAnimations;
-(void) unpauseAnimations;
-(BOOL) animationsPaused;
-(float) getCurrentTime;
-(void) setCurrentTime:(float) seconds;
-(NodeList*) getIntersectionList:(SVGRect) rect referenceElement:(SVGElement*) referenceElement;
-(NodeList*) getEnclosureList:(SVGRect) rect referenceElement:(SVGElement*) referenceElement;
-(BOOL) checkIntersection:(SVGElement*) element rect:(SVGRect) rect;
-(BOOL) checkEnclosure:(SVGElement*) element rect:(SVGRect) rect;
-(void) deselectAll;
-(SVGNumber) createSVGNumber;
-(SVGLength*) createSVGLength __attribute__((ns_returns_retained));
-(SVGAngle*) createSVGAngle;
-(SVGPoint*) createSVGPoint;
-(SVGMatrix*) createSVGMatrix;
-(SVGRect) createSVGRect;
-(SVGTransform*) createSVGTransform;
-(SVGTransform*) createSVGTransformFromMatrix:(SVGMatrix*) matrix;
-(Element*) getElementById:(NSString*) elementId;

#pragma mark - below here VIOLATES THE STANDARD, but needs to be CAREFULLY merged with spec

@property (nonatomic, readonly) CGRect viewBoxFrame; // FIXME: this has NON TRIVIAL relationship to the viewport property above

- (SVGElement *)findFirstElementOfClass:(Class)class; /*< temporary convenience method until SVGDocument support is complete */

@end
