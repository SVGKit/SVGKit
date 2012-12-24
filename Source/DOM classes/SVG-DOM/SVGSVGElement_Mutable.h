#import "SVGSVGElement.h"

@interface SVGSVGElement ()

@property (nonatomic, retain, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* x;
@property (nonatomic, retain, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* y;
@property (nonatomic, retain, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* width;
@property (nonatomic, retain, readwrite) /*FIXME: should be SVGAnimatedLength instead*/ SVGLength* height;
@property (nonatomic, retain, readwrite) NSString* contentScriptType;
@property (nonatomic, retain, readwrite) NSString* contentStyleType;
@property (nonatomic, readwrite) SVGRect viewport;
@property (nonatomic, readwrite) float pixelUnitToMillimeterX;
@property (nonatomic, readwrite) float pixelUnitToMillimeterY;
@property (nonatomic, readwrite) float screenPixelToMillimeterX;
@property (nonatomic, readwrite) float screenPixelToMillimeterY;
@property (nonatomic, readwrite) BOOL useCurrentView;
@property (nonatomic, retain, readwrite) SVGViewSpec* currentView;
@property (nonatomic, readwrite) float currentScale;
@property (nonatomic, retain, readwrite) SVGPoint* currentTranslate;

@end
