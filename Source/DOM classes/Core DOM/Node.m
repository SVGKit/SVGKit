//
//  Node.m
//  SVGKit
//
//  Created by adam on 22/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Node.h"
#import "Node+Mutable.h"

#import "NodeList+Mutable.h"
#import "NamedNodeMap.h"

@implementation Node

@synthesize nodeName;
@synthesize nodeValue;

@synthesize nodeType;
@synthesize parentNode;
@synthesize childNodes;
@synthesize firstChild;
@synthesize lastChild;
@synthesize previousSibling;
@synthesize nextSibling;
@synthesize attributes;

// Modified in DOM Level 2:
@synthesize ownerDocument;

@synthesize hasAttributes, hasChildNodes;

@synthesize localName;

- (void)dealloc {
    [nodeName release];
    [nodeValue release];
    [childNodes release];
    [attributes release];
    [prefix release];
    [namespaceURI release];
    [localName release];
    [super dealloc];
}

- (id)init
{
    NSAssert( FALSE, @"This class has no init method - it MUST NOT be init'd via init - you MUST use one of the multi-argument constructors instead" );
	
    return nil;
}

- (id)initType:(DOMNodeType) nt name:(NSString*) n value:(NSString*) v
{
	if( [v isKindOfClass:[NSMutableString class]])
	{
		/** Apple allows this, but it breaks the whole of Obj-C / cocoa, which is damn stupid
		 So we have to fix it.*/
		v = [NSString stringWithString:v];
	}
	
    self = [super init];
    if (self) {
		self.nodeType = nt;
        switch( nt )
		{
				
			case DOMNodeType_ATTRIBUTE_NODE:
			case DOMNodeType_CDATA_SECTION_NODE:
			case DOMNodeType_COMMENT_NODE:
			case DOMNodeType_PROCESSING_INSTRUCTION_NODE:
			case DOMNodeType_TEXT_NODE:
			{
				self.nodeName = n;
				self.nodeValue = v;
			}break;
			
				
			case DOMNodeType_DOCUMENT_NODE:
			case DOMNodeType_DOCUMENT_TYPE_NODE:
			case DOMNodeType_DOCUMENT_FRAGMENT_NODE:
			case DOMNodeType_ENTITY_REFERENCE_NODE:
			case DOMNodeType_ENTITY_NODE:
			case DOMNodeType_NOTATION_NODE:
			case DOMNodeType_ELEMENT_NODE:
			{
				NSAssert( FALSE, @"NodeType = %i cannot be init'd with a value; nodes of that type have no value in the DOM spec", nt);
				
				self = nil;
			}break;
		}
		{
			NodeList *tmpList = [[NodeList alloc] init];
			self.childNodes = tmpList;
			[tmpList release];
		}
    }
    return self;
}

- (id)initType:(DOMNodeType) nt name:(NSString*) n
{
    self = [super init];
    if (self) {
		self.nodeType = nt;
        switch( nt )
		{
				
			case DOMNodeType_ATTRIBUTE_NODE:
			case DOMNodeType_CDATA_SECTION_NODE:
			case DOMNodeType_COMMENT_NODE:
			case DOMNodeType_PROCESSING_INSTRUCTION_NODE:
			case DOMNodeType_TEXT_NODE:
			{
				NSAssert( FALSE, @"NodeType = %i cannot be init'd without a value; nodes of that type MUST have a value in the DOM spec", nt);
				
				self = nil;
			}break;
				
				
			case DOMNodeType_DOCUMENT_NODE:
			case DOMNodeType_DOCUMENT_TYPE_NODE:
			case DOMNodeType_DOCUMENT_FRAGMENT_NODE:
			case DOMNodeType_ENTITY_REFERENCE_NODE:
			case DOMNodeType_ENTITY_NODE:
			case DOMNodeType_NOTATION_NODE:
			{
				self.nodeName = n;
			}break;
				
			case DOMNodeType_ELEMENT_NODE:
			{
				
				self.nodeName = n;
				{
					NamedNodeMap *tmpMap = [[NamedNodeMap alloc] init];
					self.attributes = tmpMap;
					[tmpMap release];
				}
			}break;
		}
		{
			NodeList *tmpList = [[NodeList alloc] init];
			self.childNodes = tmpList;
			[tmpList release];
		}
    }
    return self;
}


#pragma mark - Objective-C init methods DOM LEVEL 2 (preferred init - safer/better!)
-(void) postInitNamespaceHandling:(NSString*) nsURI
{
	NSArray* nameSpaceParts = [self.nodeName componentsSeparatedByString:@":"];
	self.localName = [nameSpaceParts lastObject];
	if( [nameSpaceParts count] > 1 )
		self.prefix = [nameSpaceParts objectAtIndex:0];
		
	self.namespaceURI = nsURI;
}

- (id)initType:(DOMNodeType) nt name:(NSString*) n inNamespace:(NSString*) nsURI
{
	self = [self initType:nt name:n];
	
	if( self )
	{
		[self postInitNamespaceHandling:nsURI];
	}
	
	return self;
}

- (id)initType:(DOMNodeType) nt name:(NSString*) n value:(NSString*) v inNamespace:(NSString*) nsURI
{
	if( [v isKindOfClass:[NSMutableString class]])
	{
		/** Apple allows this, but it breaks the whole of Obj-C / cocoa, which is damn stupid
		 So we have to fix it.*/
		v = [NSString stringWithString:v];
	}
	
	self = [self initType:nt name:n value:v];
	
	if( self )
	{
		[self postInitNamespaceHandling:nsURI];
	}
	
	return self;
}

#pragma mark - Official DOM method implementations

-(Node*) insertBefore:(Node*) newChild refChild:(Node*) refChild
{
	if( refChild == nil )
	{
		[self.childNodes.internalArray addObject:newChild];
		newChild.parentNode = self;
	}
	else
	{
		[self.childNodes.internalArray insertObject:newChild atIndex:[self.childNodes.internalArray indexOfObject:refChild]];
	}
	
	return newChild;
}

-(Node*) replaceChild:(Node*) newChild oldChild:(Node*) oldChild
{
	if( newChild.nodeType == DOMNodeType_DOCUMENT_FRAGMENT_NODE )
	{
		/** Spec:
		 
		 "If newChild is a DocumentFragment object, oldChild is replaced by all of the DocumentFragment children, which are inserted in the same order. If the newChild is already in the tree, it is first removed."
		 */
		
		NSInteger oldIndex = [self.childNodes.internalArray indexOfObject:oldChild];
		
		NSAssert( FALSE, @"We should be recursing down the tree to find 'newChild' at any location, and removing it - required by spec - but we have no convenience method for that search, yet" );
		
		for( Node* child in newChild.childNodes.internalArray )
		{
			[self.childNodes.internalArray insertObject:child atIndex:oldIndex++];
		}
		
		newChild.parentNode = self;
		oldChild.parentNode = nil;
		
		return oldChild;
	}
	else
	{
		[self.childNodes.internalArray replaceObjectAtIndex:[self.childNodes.internalArray indexOfObject:oldChild] withObject:newChild];
		
		newChild.parentNode = self;
		oldChild.parentNode = nil;
		
		return oldChild;
	}
}
-(Node*) removeChild:(Node*) oldChild
{
	[self.childNodes.internalArray removeObject:oldChild];
	
	oldChild.parentNode = nil;
	
	return oldChild;
}

-(Node*) appendChild:(Node*) newChild
{
	[self.childNodes.internalArray removeObject:newChild]; // required by spec
	[self.childNodes.internalArray addObject:newChild];
	
	newChild.parentNode = self;
	
	return newChild;
}

-(BOOL)hasChildNodes
{
	return (self.childNodes.length > 0);
}

-(Node*) cloneNode:(BOOL) deep
{
	NSAssert( FALSE, @"Not implemented yet - read the spec. Sounds tricky. I'm too tired, and would probably screw it up right now" );
	return nil;
}

// Modified in DOM Level 2:
-(void) normalize
{
	NSAssert( FALSE, @"Not implemented yet - read the spec. Sounds tricky. I'm too tired, and would probably screw it up right now" );
}

// Introduced in DOM Level 2:
-(BOOL) isSupportedFeature:(NSString*) feature version:(NSString*) version
{
	NSAssert( FALSE, @"Not implemented yet - read the spec. I have literally no idea what this is supposed to do." );
	return FALSE;
}

// Introduced in DOM Level 2:
@synthesize namespaceURI;

// Introduced in DOM Level 2:
@synthesize prefix;

// Introduced in DOM Level 2:
-(BOOL)hasAttributes
{
	if( self.attributes == nil )
		return FALSE;
	
	return (self.attributes.length > 0 );
}

#pragma mark - SPECIAL CASE: DOM level 3 method

/** 
 
 Note that the DOM 3 spec defines this as RECURSIVE:
 
 http://www.w3.org/TR/2004/REC-DOM-Level-3-Core-20040407/core.html#Node3-textContent
 */
-(NSString *)textContent
{
	switch( self.nodeType )
	{
		case DOMNodeType_ELEMENT_NODE:
		case DOMNodeType_ATTRIBUTE_NODE:
		case DOMNodeType_ENTITY_NODE:
		case DOMNodeType_ENTITY_REFERENCE_NODE:
		case DOMNodeType_DOCUMENT_FRAGMENT_NODE:
		{
			/** DOM 3 Spec:
			 "concatenation of the textContent attribute value of every child node, excluding COMMENT_NODE and PROCESSING_INSTRUCTION_NODE nodes. This is the empty string if the node has no children."
			 */
			NSMutableString* stringAccumulator = [[NSMutableString alloc] init];
			for( Node* subNode in self.childNodes.internalArray )
			{
				NSString* subText = subNode.textContent; // don't call this method twice; it's expensive to calculate!
				if( subText != nil ) // Yes, really: Apple docs require that you never append a nil substring. Sigh
					[stringAccumulator appendString:subText];
			}
			
			NSString *tmpStr = [NSString stringWithString:stringAccumulator];
			[stringAccumulator release];
			return tmpStr;
		}
			
		case DOMNodeType_TEXT_NODE:
		case DOMNodeType_CDATA_SECTION_NODE:
		case DOMNodeType_COMMENT_NODE:
		case DOMNodeType_PROCESSING_INSTRUCTION_NODE:
		{
			return self.nodeValue; // should never be nil; anything with a valid value will be at least an empty string i.e. ""
		}
			
		case DOMNodeType_DOCUMENT_NODE:
		case DOMNodeType_NOTATION_NODE:
		case DOMNodeType_DOCUMENT_TYPE_NODE:
		{
			return nil;
		}
	}
}

#pragma mark - ADDITIONAL to SVG Spec: useful debug / output / description methods

-(NSString *)description
{
	NSString* nodeTypeName;
	switch( self.nodeType )
	{
		case DOMNodeType_ELEMENT_NODE:
			nodeTypeName = @"ELEMENT";
			break;
		case DOMNodeType_TEXT_NODE:
			nodeTypeName = @"TEXT";
			break;
		case DOMNodeType_ENTITY_NODE:
			nodeTypeName = @"ENTITY";
			break;
		case DOMNodeType_COMMENT_NODE:
			nodeTypeName = @"COMMENT";
			break;
		case DOMNodeType_DOCUMENT_NODE:
			nodeTypeName = @"DOCUMENT";
			break;
		case DOMNodeType_NOTATION_NODE:
			nodeTypeName = @"NOTATION";
			break;
		case DOMNodeType_ATTRIBUTE_NODE:
			nodeTypeName = @"ATTRIBUTE";
			break;
		case DOMNodeType_CDATA_SECTION_NODE:
			nodeTypeName = @"CDATA";
			break;
		case DOMNodeType_DOCUMENT_TYPE_NODE:
			nodeTypeName = @"DOC TYPE";
			break;
		case DOMNodeType_ENTITY_REFERENCE_NODE:
			nodeTypeName = @"ENTITY REF";
			break;
		case DOMNodeType_DOCUMENT_FRAGMENT_NODE:
			nodeTypeName = @"DOC FRAGMENT";
			break;
		case DOMNodeType_PROCESSING_INSTRUCTION_NODE:
			nodeTypeName = @"PROCESSING INSTRUCTION";
			break;
			
		default:
			nodeTypeName = @"N/A (DATA IS MISSING FROM NODE INSTANCE)";
	}
	return [NSString stringWithFormat:@"Node: %@ (%@) value:[%@] @@%ld attributes + %ld x children", self.nodeName, nodeTypeName, [self.nodeValue length]<11 ? self.nodeValue : [NSString stringWithFormat:@"%@...",[self.nodeValue substringToIndex:10]], self.attributes.length, self.childNodes.length];
}

@end
