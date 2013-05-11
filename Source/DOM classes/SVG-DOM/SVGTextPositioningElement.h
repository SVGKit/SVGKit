/**
 http://www.w3.org/TR/2011/REC-SVG11-20110816/text.html#InterfaceSVGTextPositioningElement
 
 interface SVGTextPositioningElement : SVGTextContentElement {
 readonly attribute SVGAnimatedLengthList x;
 readonly attribute SVGAnimatedLengthList y;
 readonly attribute SVGAnimatedLengthList dx;
 readonly attribute SVGAnimatedLengthList dy;
 readonly attribute SVGAnimatedNumberList rotate;
 */
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#import <SVGKit/SVGTextContentElement.h>
@class SVGLength;
//#import "SVGLength.h"

@interface SVGTextPositioningElement : SVGTextContentElement

@property(nonatomic,retain,readonly) SVGLength* /* FIXME: should be SVGAnimatedLengthList */ x;
@property(nonatomic,retain,readonly) SVGLength* /* FIXME: should be SVGAnimatedLengthList */ y;
@property(nonatomic,retain,readonly) SVGLength* /* FIXME: should be SVGAnimatedLengthList */ dx;
@property(nonatomic,retain,readonly) SVGLength* /* FIXME: should be SVGAnimatedLengthList */ dy;
@property(nonatomic,retain,readonly) SVGLength* /* FIXME: should be SVGAnimatedLengthList */ rotate;

@end
