/**
 http://www.w3.org/TR/SVG/types.html#InterfaceSVGStylable
 
 interface SVGStylable {
 
 readonly attribute SVGAnimatedString className;
 readonly attribute CSSStyleDeclaration style;
 
 CSSValue getPresentationAttribute(in DOMString name);
 */
#import <Foundation/Foundation.h>

#import "CSSStyleDeclaration.h"
#import "CSSValue.h"

@protocol SVGStylable <NSObject>

@property(nonatomic, STRONG) /*FIXME: should be of type: SVGAnimatedString */ NSString* className;
@property(nonatomic, STRONG)	CSSStyleDeclaration* style;

-(CSSValue*) getPresentationAttribute:(NSString*) name;

@end
