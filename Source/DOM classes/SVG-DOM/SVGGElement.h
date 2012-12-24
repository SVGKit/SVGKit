/**
 http://www.w3.org/TR/SVG/struct.html#InterfaceSVGGElement
 
 interface SVGGElement : SVGElement,
 SVGTests,
 SVGLangSpace,
 SVGExternalResourcesRequired,
 SVGStylable,
 SVGTransformable {
 */

#import "SVGElement.h"
#import "SVGElement_ForParser.h"

#import "SVGLayeredElement.h"

@interface SVGGElement : SVGElement < SVGLayeredElement >

@property (nonatomic, readonly) CGFloat opacity;

@end
