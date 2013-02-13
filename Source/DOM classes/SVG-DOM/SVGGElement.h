/**
 http://www.w3.org/TR/SVG/struct.html#InterfaceSVGGElement
 
 interface SVGGElement : SVGElement,
 SVGTests,
 SVGLangSpace,
 SVGExternalResourcesRequired,
 SVGStylable,
 SVGTransformable {
 */

#import <UIKit/UIKit.h>

#import "SVGElement.h"
#import "SVGElement_ForParser.h"

#import "SVGLayeredElement.h"
#import "SVGTransformable.h"

#define OUTLINE_SHAPES 1

@interface SVGGElement : SVGElement <SVGTransformable, SVGLayeredElement >

@end
