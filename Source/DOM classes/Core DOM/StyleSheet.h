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

#import "Node.h"
#import "MediaList.h"

@interface StyleSheet : NSObject

@property(nonatomic,retain) NSString* type;
@property(nonatomic) BOOL disabled;
@property(nonatomic,retain) Node* ownerNode;
@property(nonatomic,retain) StyleSheet* parentStyleSheet;
@property(nonatomic,retain) NSString* href;
@property(nonatomic,retain) NSString* title;
@property(nonatomic,retain) MediaList* media;

@end
