#import "SVGUseElement.h"

@interface SVGUseElement ()
@property(nonatomic, STRONG, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* x;
@property(nonatomic, STRONG, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* y;
@property(nonatomic, STRONG, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* width;
@property(nonatomic, STRONG, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* height;
@property(nonatomic, STRONG, readwrite) SVGElementInstance* instanceRoot;
@property(nonatomic, STRONG, readwrite) SVGElementInstance* animatedInstanceRoot;

@end
