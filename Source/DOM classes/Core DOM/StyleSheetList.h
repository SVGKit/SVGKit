/**
 http://www.w3.org/TR/2000/REC-DOM-Level-2-Style-20001113/stylesheets.html#StyleSheets-StyleSheetList
 
 interface StyleSheetList {
 readonly attribute unsigned long    length;
 StyleSheet         item(in unsigned long index);
 */

#import <Foundation/Foundation.h>

#import <SVGKit/StyleSheet.h>

@interface StyleSheetList : NSObject

@property(nonatomic,readonly) NSUInteger length;

-(StyleSheet*) item:(NSUInteger) index;

@end
