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


typedef enum SVG_CLIPPATHUNITS
{
    // Unit Types
    SVG_UNIT_TYPE_UNKNOWN = 0,
    SVG_UNIT_TYPE_USERSPACEONUSE = 1,
    SVG_UNIT_TYPE_OBJECTBOUNDINGBOX = 2
} SVG_CLIPPATHUNITS;


// Does NOT implement ConverterSVGToCALayer because <clipPath> elements are never rendered directly; they're only referenced via clip-path attributes in other elements
@interface SVGClipPathElement : SVGElement <SVGTransformable, SVGStylable>

@property(nonatomic, readonly) SVG_CLIPPATHUNITS clipPathUnits;

- (CALayer *) newLayer;
- (void)layoutLayer:(CALayer *)layer toMaskLayer:(CALayer *)maskThis;

@end
