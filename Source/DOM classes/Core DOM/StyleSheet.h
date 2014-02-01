/**
 http://www.w3.org/TR/2000/REC-DOM-Level-2-Style-20001113/stylesheets.html#StyleSheets-StyleSheet
 
 interface StyleSheet {
 readonly attribute DOMString        type;
 attribute boolean          disabled;
 readonly attribute Node             ownerNode;
 readonly attribute StyleSheet       parentStyleSheet;
 readonly attribute DOMString        href;
 readonly attribute DOMString        title;
 readonly attribute MediaList        media;
 */

#import <Foundation/Foundation.h>

@class Node;
@class MediaList;

@interface StyleSheet : NSObject

@property(nonatomic, STRONG) NSString* type;
@property(nonatomic) BOOL disabled;
@property(nonatomic, STRONG) Node* ownerNode;
@property(nonatomic, STRONG) StyleSheet* parentStyleSheet;
@property(nonatomic, STRONG) NSString* href;
@property(nonatomic, STRONG) NSString* title;
@property(nonatomic, STRONG) MediaList* media;

@end
