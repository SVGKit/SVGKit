/*
//  Document.h

 NOT a Cocoa / Apple document,
 NOT an SVG document,
 BUT INSTEAD: a DOM document (blame w3.org for the too-generic name).
 
 Required for SVG-DOM
 
 c.f.:
 
 http://www.w3.org/TR/DOM-Level-2-Core/core.html#i-Document
 
 interface Document : Node {
 readonly attribute DocumentType     doctype;
 readonly attribute DOMImplementation  implementation;
 readonly attribute Element          documentElement;
 Element            createElement(in DOMString tagName)
 raises(DOMException);
 DocumentFragment   createDocumentFragment();
 Text               createTextNode(in DOMString data);
 Comment            createComment(in DOMString data);
 CDATASection       createCDATASection(in DOMString data)
 raises(DOMException);
 ProcessingInstruction createProcessingInstruction(in DOMString target, 
 in DOMString data)
 raises(DOMException);
 Attr               createAttribute(in DOMString name)
 raises(DOMException);
 EntityReference    createEntityReference(in DOMString name)
 raises(DOMException);
 NodeList           getElementsByTagName(in DOMString tagname);
 // Introduced in DOM Level 2:
 Node               importNode(in Node importedNode, 
 in boolean deep)
 raises(DOMException);
 // Introduced in DOM Level 2:
 Element            createElementNS(in DOMString namespaceURI, 
 in DOMString qualifiedName)
 raises(DOMException);
 // Introduced in DOM Level 2:
 Attr               createAttributeNS(in DOMString namespaceURI, 
 in DOMString qualifiedName)
 raises(DOMException);
 // Introduced in DOM Level 2:
 NodeList           getElementsByTagNameNS(in DOMString namespaceURI, 
 in DOMString localName);
 // Introduced in DOM Level 2:
 Element            getElementById(in DOMString elementId);
 };

 
 */

#import <Foundation/Foundation.h>

/** ObjectiveC won't allow this: @class Node; */
#import "SVGKNode.h"
@class SVGKElement;
#import "SVGKElement.h"
@class SVGKComment;
#import "SVGKComment.h"
@class SVGKCDATASection;
#import "SVGKCDATASection.h"
@class SVGKDocumentFragment;
#import "SVGKDocumentFragment.h"
@class SVGKEntityReference;
#import "SVGKEntityReference.h"
@class SVGKNodeList;
#import "SVGKNodeList.h"
@class SVGKProcessingInstruction;
#import "SVGKProcessingInstruction.h"
@class SVGKDocumentType;
#import "SVGKDocumentType.h"
@class SVGKAppleSucksDOMImplementation;
#import "SVGKAppleSucksDOMImplementation.h"

@interface SVGKDocument : SVGKNode

@property(nonatomic,retain,readonly) SVGKDocumentType*     doctype;
@property(nonatomic,retain,readonly) SVGKAppleSucksDOMImplementation*  implementation;
@property(nonatomic,retain,readonly) SVGKElement*          documentElement;


-(SVGKElement*) createElement:(NSString*) tagName __attribute__((ns_returns_retained));
-(SVGKDocumentFragment*) createDocumentFragment __attribute__((ns_returns_retained));
-(SVGKText*) createTextNode:(NSString*) data __attribute__((ns_returns_retained));
-(SVGKComment*) createComment:(NSString*) data __attribute__((ns_returns_retained));
-(SVGKCDATASection*) createCDATASection:(NSString*) data __attribute__((ns_returns_retained));
-(SVGKProcessingInstruction*) createProcessingInstruction:(NSString*) target data:(NSString*) data __attribute__((ns_returns_retained));
-(SVGKAttr*) createAttribute:(NSString*) data __attribute__((ns_returns_retained));
-(SVGKEntityReference*) createEntityReference:(NSString*) data __attribute__((ns_returns_retained));

-(SVGKNodeList*) getElementsByTagName:(NSString*) data;

// Introduced in DOM Level 2:
-(SVGKNode*) importNode:(SVGKNode*) importedNode deep:(BOOL) deep;

// Introduced in DOM Level 2:
-(SVGKElement*) createElementNS:(NSString*) namespaceURI qualifiedName:(NSString*) qualifiedName __attribute__((ns_returns_retained));

// Introduced in DOM Level 2:
-(SVGKAttr*) createAttributeNS:(NSString*) namespaceURI qualifiedName:(NSString*) qualifiedName;

// Introduced in DOM Level 2:
-(SVGKNodeList*) getElementsByTagNameNS:(NSString*) namespaceURI localName:(NSString*) localName;

// Introduced in DOM Level 2:
-(SVGKElement*) getElementById:(NSString*) elementId;

@end
