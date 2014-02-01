/**
 Makes the writable properties all package-private, effectively
 */
#import "Node.h"

@interface Node()
@property(nonatomic, STRONG,readwrite) NSString* nodeName;
@property(nonatomic, STRONG,readwrite) NSString* nodeValue;

@property(nonatomic,readwrite) DOMNodeType nodeType;
@property(nonatomic,assign,readwrite) Node* parentNode;
@property(nonatomic, STRONG,readwrite) NodeList* childNodes;
@property(nonatomic,assign,readwrite) Node* firstChild;
@property(nonatomic,assign,readwrite) Node* lastChild;
@property(nonatomic,assign,readwrite) Node* previousSibling;
@property(nonatomic,assign,readwrite) Node* nextSibling;
@property(nonatomic, STRONG,readwrite) NamedNodeMap* attributes;

@property(nonatomic,assign,readwrite) Document* ownerDocument;

// Introduced in DOM Level 2:
@property(nonatomic, STRONG,readwrite) NSString* namespaceURI;

// Introduced in DOM Level 2:
@property(nonatomic, STRONG,readwrite) NSString* prefix;

// Introduced in DOM Level 2:
@property(nonatomic, STRONG,readwrite) NSString* localName;

@end
