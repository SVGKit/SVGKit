/**
 Makes the writable properties all package-private, effectively
 */
#import "DomNode.h"

@interface DomNode()
@property(nonatomic,strong,readwrite) NSString* nodeName;
@property(nonatomic,strong,readwrite) NSString* nodeValue;

@property(nonatomic,readwrite) DOMNodeType nodeType;
@property(nonatomic,weak,readwrite) DomNode* parentNode;
@property(nonatomic,strong,readwrite) NodeList* childNodes;
@property(nonatomic,strong,readwrite) NamedNodeMap* attributes;

@property(nonatomic,weak,readwrite) Document* ownerDocument;

// Introduced in DOM Level 2:
@property(nonatomic,strong,readwrite) NSString* namespaceURI;

// Introduced in DOM Level 2:
@property(nonatomic,strong,readwrite) NSString* prefix;

// Introduced in DOM Level 2:
@property(nonatomic,strong,readwrite) NSString* localName;

@end
