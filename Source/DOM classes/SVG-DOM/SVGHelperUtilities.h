/**
 To implement the official SVG Spec, some "extra" methods are needed that are SHARED between classes, but
 which in the SVG Spec the classes aren't subclass/superclass of each other - so that there's no way to
 implement it without copy/pasting the code.
 
 To improve maintainability, we put those methods here, and then each place we need them has a 1-line method
 that delegates to a method body in this class.
 */
#import <Foundation/Foundation.h>

#import <QuartzCore/QuartzCore.h>
#import "SVGElement.h"
#import "SVGTransformable.h"

@interface SVGHelperUtilities : NSObject

/**
 According to the SVG Spec, there are two types of element that affect the on-screen size/shape/position/rotation/skew of shapes/images:
 
 1. Any ancestor that implements SVGTransformable
 2. Any "element that establishes a new viewport" - i.e. the <svg> tag and a few others
 
This method ONLY looks at current node to establish the above two things, to do a RELATIVE transform (relative to parent node)
 */
+(CGAffineTransform) transformRelativeIncludingViewportForTransformableOrViewportEstablishingElement:(SVGElement*) transformableOrSVGSVGElement;
/**
 According to the SVG Spec, there are two types of element that affect the on-screen size/shape/position/rotation/skew of shapes/images:
 
 1. Any ancestor that implements SVGTransformable
 2. Any "element that establishes a new viewport" - i.e. the <svg> tag and a few others
 
 This method recurses upwards to combine the above two things for everything in the tree, to establish an ABSOLUTE transform
 */
+(CGAffineTransform) transformAbsoluteIncludingViewportForTransformableOrViewportEstablishingElement:(SVGElement*) transformableOrSVGSVGElement;

+(CALayer *) newCALayerForPathBasedSVGElement:(SVGElement*) svgElement withPath:(CGPathRef) path;

@end
