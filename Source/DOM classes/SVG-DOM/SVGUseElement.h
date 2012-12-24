/*
 http://www.w3.org/TR/SVG/struct.html#InterfaceSVGUseElement
 
 interface SVGUseElement : SVGElement,
 SVGURIReference,
 SVGTests,
 SVGLangSpace,
 SVGExternalResourcesRequired,
 SVGStylable,
 SVGTransformable {
 readonly attribute SVGAnimatedLength x;
 readonly attribute SVGAnimatedLength y;
 readonly attribute SVGAnimatedLength width;
 readonly attribute SVGAnimatedLength height;
 readonly attribute SVGElementInstance instanceRoot;
 readonly attribute SVGElementInstance animatedInstanceRoot;
 };
 
 */
#import "SVGLength.h"
#import "SVGElement.h"

@class SVGElementInstance;
#import "SVGElementInstance.h"

#import "SVGLayeredElement.h"

@interface SVGUseElement : SVGElement <SVGLayeredElement>

@property(nonatomic, retain, readonly) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* x;
@property(nonatomic, retain, readonly) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* y;
@property(nonatomic, retain, readonly) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* width;
@property(nonatomic, retain, readonly) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* height;
@property(nonatomic, retain, readonly) SVGElementInstance* instanceRoot;
@property(nonatomic, retain, readonly) SVGElementInstance* animatedInstanceRoot;

@end
