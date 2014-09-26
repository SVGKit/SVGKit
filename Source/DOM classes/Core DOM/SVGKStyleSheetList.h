/**
 http://www.w3.org/TR/2000/REC-DOM-Level-2-Style-20001113/stylesheets.html#StyleSheets-StyleSheetList
 
 interface StyleSheetList {
 readonly attribute unsigned long    length;
 StyleSheet         item(in unsigned long index);
 */

#import <Foundation/Foundation.h>

#import "SVGKStyleSheet.h"

@interface SVGKStyleSheetList : NSObject

@property(nonatomic,readonly) unsigned long length;

-(SVGKStyleSheet*) item:(unsigned long) index;

@end
