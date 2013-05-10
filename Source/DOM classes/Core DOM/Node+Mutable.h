/**
 Makes the writable properties all package-private, effectively
 */
#import "Node.h"

@interface Node()
@property(nonatomic,strong,readwrite) NSString* nodeName;
@property(nonatomic,strong,readwrite) NSString* nodeValue;

@property(nonatomic,readwrite) DOMNodeType nodeType;
@property(nonatomic,unsafe_unretained,readwrite) Node* parentNode;
@property(nonatomic,strong,readwrite) NodeList* childNodes;
@property(nonatomic,unsafe_unretained,readwrite) Node* firstChild;
@property(nonatomic,unsafe_unretained,readwrite) Node* lastChild;
@property(nonatomic,unsafe_unretained,readwrite) Node* previousSibling;
@property(nonatomic,unsafe_unretained,readwrite) Node* nextSibling;
@property(nonatomic,strong,readwrite) NamedNodeMap* attributes;

@property(nonatomic,unsafe_unretained,readwrite) Document* ownerDocument;

// Introduced in DOM Level 2:
@property(nonatomic,strong,readwrite) NSString* namespaceURI;

// Introduced in DOM Level 2:
@property(nonatomic,strong,readwrite) NSString* prefix;

// Introduced in DOM Level 2:
@property(nonatomic,strong,readwrite) NSString* localName;

@end
