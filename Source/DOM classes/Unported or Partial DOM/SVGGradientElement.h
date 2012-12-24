/*
//
 http://www.w3.org/TR/SVG/pservers.html#InterfaceSVGGradientElement
 
 interface SVGGradientElement : SVGElement,

 SVGURIReference,
 SVGExternalResourcesRequired,
 SVGStylable,
 SVGUnitTypes {
 
 // Spread Method Types
 const unsigned short SVG_SPREADMETHOD_UNKNOWN = 0;
 const unsigned short SVG_SPREADMETHOD_PAD = 1;
 const unsigned short SVG_SPREADMETHOD_REFLECT = 2;
 const unsigned short SVG_SPREADMETHOD_REPEAT = 3;
 
 readonly attribute SVGAnimatedEnumeration gradientUnits;
 readonly attribute SVGAnimatedTransformList gradientTransform;
 readonly attribute SVGAnimatedEnumeration spreadMethod;
 
 */

#import "SVGElement.h"
#import "SVGLayeredElement.h"

#import "SVGGradientStop.h"

@interface SVGGradientElement : SVGElement < SVGLayeredElement > {
    @public
    BOOL radial; /* FIXME: not in SVG Spec */
    
    @protected
    NSMutableArray *_stops; /* FIXME: not in SVG Spec */
    
    @private
    NSArray *colors, *locations; /* FIXME: not in SVG Spec */
}

@property (readonly, retain)NSArray *stops; /* FIXME: not in SVG Spec */

-(void)addStop:(SVGGradientStop *)gradientStop; /* FIXME: not in SVG Spec */

@end
