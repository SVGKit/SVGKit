/**
 http://www.w3.org/TR/SVG/struct.html#InterfaceSVGGElement
 
 interface SVGGElement : SVGElement,
 SVGTests,
 SVGLangSpace,
 SVGExternalResourcesRequired,
 SVGStylable,
 SVGTransformable {
 */

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#import "SVGElement.h"
#import "SVGElement_ForParser.h"

#import "ConverterSVGToCALayer.h"
#import "SVGTransformable.h"


@interface SVGGElement : SVGElement <SVGTransformable, SVGStylable, ConverterSVGToCALayer >

@end
