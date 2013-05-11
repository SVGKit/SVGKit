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

#import <SVGKit/SVGElement.h>
#import <SVGKit/SVGElement_ForParser.h>

#import <SVGKit/SVGLayeredElement.h>
#import <SVGKit/SVGTransformable.h>


@interface SVGGElement : SVGElement <SVGTransformable, SVGStylable, SVGLayeredElement >

@end
