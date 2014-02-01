#import "SVGSVGElement.h"

@interface SVGSVGElement ()

@property (nonatomic, STRONG, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* x;
@property (nonatomic, STRONG, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* y;
@property (nonatomic, STRONG, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* width;
@property (nonatomic, STRONG, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* height;
@property (nonatomic, STRONG, readwrite) NSString* contentScriptType;
@property (nonatomic, STRONG, readwrite) NSString* contentStyleType;
@property (nonatomic, readwrite) SVGRect viewport;
@property (nonatomic, readwrite) float pixelUnitToMillimeterX;
@property (nonatomic, readwrite) float pixelUnitToMillimeterY;
@property (nonatomic, readwrite) float screenPixelToMillimeterX;
@property (nonatomic, readwrite) float screenPixelToMillimeterY;
@property (nonatomic, readwrite) BOOL useCurrentView;
@property (nonatomic, STRONG, readwrite) SVGViewSpec* currentView;
@property (nonatomic, readwrite) float currentScale;
@property (nonatomic, STRONG, readwrite) SVGPoint* currentTranslate;

@end
