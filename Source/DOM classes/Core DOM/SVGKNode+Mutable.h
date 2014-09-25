/**
 Makes the writable properties all package-private, effectively
 */
#import "SVGKNode.h"

@interface SVGKNode()
@property(nonatomic,retain,readwrite) NSString* nodeName;
@property(nonatomic,retain,readwrite) NSString* nodeValue;

@property(nonatomic,readwrite) DOMNodeType nodeType;
@property(nonatomic,assign,readwrite) SVGKNode* parentNode;
@property(nonatomic,retain,readwrite) SVGKNodeList* childNodes;
@property(nonatomic,assign,readwrite) SVGKNode* firstChild;
@property(nonatomic,assign,readwrite) SVGKNode* lastChild;
@property(nonatomic,assign,readwrite) SVGKNode* previousSibling;
@property(nonatomic,assign,readwrite) SVGKNode* nextSibling;
@property(nonatomic,retain,readwrite) SVGKNamedNodeMap* attributes;

@property(nonatomic,assign,readwrite) SVGKDocument* ownerDocument;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readwrite) NSString* namespaceURI;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readwrite) NSString* prefix;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readwrite) NSString* localName;

@end
