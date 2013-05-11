/**
 This class is FOR IMPLEMENTATION ONLY, it is NOT part of the SVG Spec.
 
 All the SVG Basic Shapes are rendered in ObjectiveC using the same CGPath primitive - so this class provides
 a clean, OOP, way of implementing that.
 
 (the ONLY REASON this is a base class and not a Protocol is that the SVG spec defines explicit protocols, and
 does NOT define one for shapes)
 
 Sub-classes MUST write to the "pathForShapeInRelativeCoords" property, and this class will automatically generate
 the required CALayer on the fly, using that CGPath
 
 Data:
 - "pathRelative": the actual path as parsed from the original file. THIS MIGHT NOT BE NORMALISED (maybe a future feature)
 */

#import <SVGKit/SVGElement.h>
#import <SVGKit/SVGLayeredElement.h>
#import <SVGKit/SVGUtils.h>
#import <SVGKit/SVGTransformable.h>

@class SVGGradientElement;
@class SVGKPattern;

@interface BaseClassForAllSVGBasicShapes : SVGElement < SVGStylable, SVGTransformable, SVGLayeredElement >
{
	/* FIXME: are any of these private elements in the SVG spec? */
	NSString *_styleClass;
	CGRect _layerRect;
}

@property (nonatomic, readonly) CGPathRef pathForShapeInRelativeCoords;

@end
