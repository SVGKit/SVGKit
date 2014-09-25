/**
 http://www.w3.org/TR/2000/REC-DOM-Level-2-Style-20001113/css.html#CSS-CSSStyleRule
 
 interface CSSStyleRule : CSSRule {
 attribute DOMString        selectorText;
 // raises(DOMException) on setting
 
 readonly attribute CSSStyleDeclaration  style;
 */
#import <Foundation/Foundation.h>

#import "SVGKCSSRule.h"
#import "SVGKCSSStyleDeclaration.h"

@interface SVGKCSSStyleRule : SVGKCSSRule

@property(nonatomic,retain) NSString* selectorText;
@property(nonatomic,retain) SVGKCSSStyleDeclaration* style;

#pragma mark - methods needed for ObjectiveC implementation

- (id)initWithSelectorText:(NSString*) selector styleText:(NSString*) styleText;

@end
