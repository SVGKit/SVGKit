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
#import "BaseClassForAllSVGBasicShapes.h"
#import "BaseClassForAllSVGBasicShapes_ForSubclasses.h"
#import "SVGLength.h"
#import "SVGTransformable.h"

@interface SVGRectElement : BaseClassForAllSVGBasicShapes <SVGStylable, SVGTransformable>
{ }

@property (nonatomic, STRONG, readonly) SVGLength* x;
@property (nonatomic, STRONG, readonly) SVGLength* y;
@property (nonatomic, STRONG, readonly) SVGLength* width;
@property (nonatomic, STRONG, readonly) SVGLength* height;

@property (nonatomic, STRONG, readonly) SVGLength* rx;
@property (nonatomic, STRONG, readonly) SVGLength* ry;

#pragma mark - Properties not in spec but are needed by ObjectiveC implementation to maintain

@end
