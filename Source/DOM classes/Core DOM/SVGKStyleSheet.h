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

@class SVGKNode;
@class SVGKMediaList;

@interface SVGKStyleSheet : NSObject

@property(nonatomic,retain) NSString* type;
@property(nonatomic) BOOL disabled;
@property(nonatomic,retain) SVGKNode* ownerNode;
@property(nonatomic,retain) SVGKStyleSheet* parentStyleSheet;
@property(nonatomic,retain) NSString* href;
@property(nonatomic,retain) NSString* title;
@property(nonatomic,retain) SVGKMediaList* media;

@end
