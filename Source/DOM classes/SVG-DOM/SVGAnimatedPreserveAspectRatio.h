/**
 http://www.w3.org/TR/SVG/coords.html#InterfaceSVGAnimatedPreserveAspectRatio
 
 readonly attribute SVGPreserveAspectRatio baseVal;
 readonly attribute SVGPreserveAspectRatio animVal;
 */
#import <Foundation/Foundation.h>
#import <SVGKit/SVGPreserveAspectRatio.h>

@interface SVGAnimatedPreserveAspectRatio : NSObject

@property(nonatomic,retain) SVGPreserveAspectRatio* baseVal;
@property(nonatomic,retain, readonly) SVGPreserveAspectRatio* animVal;

@end
