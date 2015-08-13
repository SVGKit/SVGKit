/**
 Makes the writable properties all package-private, effectively
 */
#import "Node.h"

@interface Node()
@property(nonatomic,retain,readwrite) NSString* nodeName;
@property(nonatomic,retain,readwrite) NSString* nodeValue;

@property(nonatomic,readwrite) DOMNodeType nodeType;
@property(nonatomic,assign,readwrite) Node* parentNode;
@property(nonatomic,retain,readwrite) NodeList* childNodes;
@property(nonatomic,retain,readwrite) NamedNodeMap* attributes;

@property(nonatomic,assign,readwrite) Document* ownerDocument;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readwrite) NSString* namespaceURI;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readwrite) NSString* prefix;

// Introduced in DOM Level 2:
@property(nonatomic,retain,readwrite) NSString* localName;

@end
