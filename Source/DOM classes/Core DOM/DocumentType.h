/*
 From SVG-DOM, via Core DOM:
 
 http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-412266927
 
 interface DocumentType : Node {
 readonly attribute DOMString        name;
 readonly attribute NamedNodeMap     entities;
 readonly attribute NamedNodeMap     notations;
 // Introduced in DOM Level 2:
 readonly attribute DOMString        publicId;
 // Introduced in DOM Level 2:
 readonly attribute DOMString        systemId;
 // Introduced in DOM Level 2:
 readonly attribute DOMString        internalSubset;
 };
*/
#import <Foundation/Foundation.h>

#import <SVGKit/Node.h>
#import <SVGKit/NamedNodeMap.h>

@interface DocumentType : Node

@property(nonatomic,retain,readonly) NSString* name;
@property(nonatomic,retain,readonly) NamedNodeMap* entities;
@property(nonatomic,retain,readonly) NamedNodeMap* notations;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readonly) NSString* publicId;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readonly) NSString* systemId;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readonly) NSString* internalSubset;


@end
