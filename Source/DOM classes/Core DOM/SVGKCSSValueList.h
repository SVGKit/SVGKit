/**
 http://www.w3.org/TR/2000/REC-DOM-Level-2-Style-20001113/css.html#CSS-CSSValueList
 
 interface CSSValueList : CSSValue {
 readonly attribute unsigned long    length;
 CSSValue           item(in unsigned long index);
 */

#import "SVGKCSSValue.h"

@interface SVGKCSSValueList : SVGKCSSValue

@property(nonatomic,readonly) unsigned long length;

-(SVGKCSSValue*) item:(unsigned long) index;

@end
