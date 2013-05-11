#import <Foundation/Foundation.h>

#import <SVGKit/SVGElement.h>
#import <SVGKit/SVGTransformable.h>
#import <SVGKit/SVGFitToViewBox.h>

#import <SVGKit/SVGElement_ForParser.h> // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

@interface SVGImageElement : SVGElement <SVGTransformable, SVGStylable, SVGLayeredElement, SVGFitToViewBox>

@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;

@property (nonatomic, retain, readonly) NSString *href;

@end
