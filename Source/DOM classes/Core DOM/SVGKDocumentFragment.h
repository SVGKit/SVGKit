/*
 From SVG-DOM, via Core DOM:
 
 http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-B63ED1A3
 
 interface DocumentFragment : Node {
 };
*/

#import <Foundation/Foundation.h>

/** objc won't allow this: @class Node;*/
#import "SVGKNode.h"

@interface SVGKDocumentFragment : SVGKNode

@end
