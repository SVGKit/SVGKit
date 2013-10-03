#import <SVGKit/SVGUseElement.h>

@interface SVGUseElement ()
@property(nonatomic, retain, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* x;
@property(nonatomic, retain, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* y;
@property(nonatomic, retain, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* width;
@property(nonatomic, retain, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* height;
@property(nonatomic, retain, readwrite) SVGElementInstance* instanceRoot;
@property(nonatomic, retain, readwrite) SVGElementInstance* animatedInstanceRoot;

@end
