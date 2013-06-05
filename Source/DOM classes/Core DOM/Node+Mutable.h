/**
 Makes the writable properties all package-private, effectively
 */
#import "Node.h"

@interface Node()
@property(nonatomic,copy,readwrite) NSString* nodeName;
@property(nonatomic,copy,readwrite) NSString* nodeValue;

@property(nonatomic,readwrite) DOMNodeType nodeType;
@property(nonatomic,assign,readwrite) Node* parentNode;
@property(nonatomic,retain,readwrite) NodeList* childNodes;
@property(nonatomic,assign,readwrite) Node* firstChild;
@property(nonatomic,assign,readwrite) Node* lastChild;
@property(nonatomic,assign,readwrite) Node* previousSibling;
@property(nonatomic,assign,readwrite) Node* nextSibling;
@property(nonatomic,retain,readwrite) NamedNodeMap* attributes;

@property(nonatomic,assign,readwrite) Document* ownerDocument;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readwrite) NSString* namespaceURI;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readwrite) NSString* prefix;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readwrite) NSString* localName;

@end
