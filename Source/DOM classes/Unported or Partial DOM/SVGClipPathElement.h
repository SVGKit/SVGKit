/**
http://www.w3.org/TR/SVG/masking.html#InterfaceSVGClipPathElement
 
 interface SVGClipPathElement : SVGElement,
 SVGTests,
 SVGLangSpace,
 SVGExternalResourcesRequired,
 SVGStylable,
 SVGTransformable,
 SVGUnitTypes {
 */

#import <UIKit/UIKit.h>

#import "SVGElement.h"
#import "SVGElement_ForParser.h"

#import "ConverterSVGToCALayer.h"
#import "SVGTransformable.h"


@interface SVGClipPathElement : SVGElement <SVGTransformable, SVGStylable, ConverterSVGToCALayer >

//@property(nonatomic, readonly) SVGAnimatedEnumeration clipPathUnits;

@end
