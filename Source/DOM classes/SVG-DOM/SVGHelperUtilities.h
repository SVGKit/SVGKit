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

+(CGAffineTransform) transformAbsoluteForTransformableElement:(SVGElement<SVGTransformable>*) transformable;
+(CALayer *) newCALayerForPathBasedSVGElement:(SVGElement*) svgElement withPath:(CGPathRef) path;

@end
