/**
 http://www.w3.org/TR/SVG/shapes.html#InterfaceSVGRectElement
 
 interface SVGRectElement : SVGElement,
 SVGTests,
 SVGLangSpace,
 SVGExternalResourcesRequired,
 SVGStylable,
 SVGTransformable {
 readonly attribute SVGAnimatedLength x;
 readonly attribute SVGAnimatedLength y;
 readonly attribute SVGAnimatedLength width;
 readonly attribute SVGAnimatedLength height;
 readonly attribute SVGAnimatedLength rx;
 readonly attribute SVGAnimatedLength ry;
 */
#import <SVGKit/BaseClassForAllSVGBasicShapes.h>
#import <SVGKit/BaseClassForAllSVGBasicShapes_ForSubclasses.h>
#import <SVGKit/SVGLength.h>
#import <SVGKit/SVGTransformable.h>

@interface SVGRectElement : BaseClassForAllSVGBasicShapes <SVGStylable, SVGTransformable>
{ }

@property (nonatomic, retain, readonly) SVGLength* x;
@property (nonatomic, retain, readonly) SVGLength* y;
@property (nonatomic, retain, readonly) SVGLength* width;
@property (nonatomic, retain, readonly) SVGLength* height;

@property (nonatomic, retain, readonly) SVGLength* rx;
@property (nonatomic, retain, readonly) SVGLength* ry;

#pragma mark - Properties not in spec but are needed by ObjectiveC implementation to maintain

@end
