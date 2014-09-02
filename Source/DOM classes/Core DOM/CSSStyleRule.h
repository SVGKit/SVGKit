/**
 http://www.w3.org/TR/2000/REC-DOM-Level-2-Style-20001113/css.html#CSS-CSSStyleRule
 
 interface CSSStyleRule : CSSRule {
 attribute DOMString        selectorText;
 // raises(DOMException) on setting
 
 readonly attribute CSSStyleDeclaration  style;
 */
#import <Foundation/Foundation.h>

#import <SVGKit/CSSRule.h>
#import <SVGKit/CSSStyleDeclaration.h>

@interface CSSStyleRule : CSSRule

@property(nonatomic,strong) NSString* selectorText;
@property(nonatomic,strong) CSSStyleDeclaration* style;

#pragma mark - methods needed for ObjectiveC implementation

- (instancetype)initWithSelectorText:(NSString*) selector styleText:(NSString*) styleText NS_DESIGNATED_INITIALIZER;

@end
