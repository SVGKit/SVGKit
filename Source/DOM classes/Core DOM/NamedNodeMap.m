//
//  NamedNodeMap.m
//  SVGKit
//
//  Created by adam on 22/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SVGKit/NamedNodeMap.h>
#import <SVGKit/Node.h>
#import "NamedNodeMap_Iterable.h"

@interface NamedNodeMap()
@property(nonatomic,retain) NSMutableDictionary* internalDictionary;
@property(nonatomic,retain) NSMutableDictionary* internalDictionaryOfNamespaces;
@end

@implementation NamedNodeMap

@synthesize internalDictionary;
@synthesize internalDictionaryOfNamespaces;

- (id)init {
    self = [super init];
    if (self) {
        self.internalDictionary = [NSMutableDictionary dictionary];
		self.internalDictionaryOfNamespaces = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.internalDictionary = nil;
	self.internalDictionaryOfNamespaces = nil;
	
    [super dealloc];
}

-(Node*) getNamedItem:(NSString*) name
{
	Node* simpleResult = (self.internalDictionary)[name];
	
	if( simpleResult == nil )
	{
		/**
		 Check the namespaces in turn, to see if we can find this node in one of them
		 
		 NB: according to spec, this behaviour is:
		 
		 "The result depends on the implementation"
		 
		 I've chosen to implement it the most user-friendly way possible. It is NOT the best
		 solution IMHO - the spec authors should have defined the outcome!
		 */
		
		for( NSString* key in self.internalDictionaryOfNamespaces )
		{
			simpleResult = [self getNamedItemNS:key localName:name];
			if( simpleResult != nil )
				break;
		}
	}
	
	return simpleResult;
}

-(Node*) setNamedItem:(Node*) arg
{
	NSAssert( [[self.internalDictionaryOfNamespaces allKeys] count] < 1, @"WARNING: you are using namespaced attributes in parallel with non-namespaced. According to the DOM Spec, this leads to UNDEFINED behaviour. This is insane - you do NOT want to be doing this! Crashing deliberately...." );
	
	Node* oldNode = (self.internalDictionary)[arg.localName];
	
	(self.internalDictionary)[arg.localName] = arg;
	
	return oldNode;
}

-(Node*) removeNamedItem:(NSString*) name
{
	NSAssert( [[self.internalDictionaryOfNamespaces allKeys] count] < 1, @"WARNING: you are using namespaced attributes in parallel with non-namespaced. According to the DOM Spec, this leads to UNDEFINED behaviour. This is insane - you do NOT want to be doing this! Crashing deliberately...." );
	
	Node* oldNode = (self.internalDictionary)[name];
	
	[self.internalDictionary removeObjectForKey:name];
	
	return oldNode;
}

-(unsigned long)length
{
	NSUInteger count = [self.internalDictionary count];
	
	for( NSDictionary* namespaceDict in [self.internalDictionaryOfNamespaces allValues] )
	{
		count += [namespaceDict count];
	}
	
	return count;
}

-(Node*) item:(unsigned long) index
{
	NSAssert(FALSE, @"This method is broken; Apple does not consistently return ordered values in dictionary.allValues. Apple DOES NOT SUPPORT ordered Maps/Hashes/Tables/Hashtables - we have to re-implement this wheel from scratch");
	
	if( index < [self.internalDictionary count] )
		return (self.internalDictionary.allValues)[index];
	else
	{
		index -= self.internalDictionary.count;
		
		for( NSDictionary* namespaceDict in [self.internalDictionaryOfNamespaces allValues] )
		{
			if( index < [namespaceDict count] )
				return (namespaceDict.allValues)[index];
			else
				index -= [namespaceDict count];
		}
	}
	
	return nil;
}

// Introduced in DOM Level 2:
-(Node*) getNamedItemNS:(NSString*) namespaceURI localName:(NSString*) localName
{
	NSMutableDictionary* namespaceDict = (self.internalDictionaryOfNamespaces)[namespaceURI];
	
	return namespaceDict[localName];
}

// Introduced in DOM Level 2:
-(Node*) setNamedItemNS:(Node*) arg
{
	return [self setNamedItemNS:arg inNodeNamespace:nil];
}

// Introduced in DOM Level 2:
-(Node*) removeNamedItemNS:(NSString*) namespaceURI localName:(NSString*) localName
{
	NSMutableDictionary* namespaceDict = (self.internalDictionaryOfNamespaces)[namespaceURI];
	Node* oldNode = namespaceDict[localName];
	
	[namespaceDict removeObjectForKey:localName];
	
	return oldNode;
}

#pragma mark - MISSING METHOD FROM SVG Spec, without which you cannot parse documents (don't understand how they intended you to fulfil the spec without this method)

-(Node*) setNamedItemNS:(Node*) arg inNodeNamespace:(NSString*) nodesNamespace
{
	NSString* effectiveNamespace = arg.namespaceURI != nil ? arg.namespaceURI : nodesNamespace;
	if( effectiveNamespace == nil )
	{
		return [self setNamedItem:arg]; // this should never happen, but there's a lot of malformed SVG files out in the wild
	}
	
	NSMutableDictionary* namespaceDict = (self.internalDictionaryOfNamespaces)[effectiveNamespace];
	if( namespaceDict == nil )
	{
		namespaceDict = [NSMutableDictionary dictionary];
		(self.internalDictionaryOfNamespaces)[effectiveNamespace] = namespaceDict;
	}
	Node* oldNode = namespaceDict[arg.localName];
	
	namespaceDict[arg.localName] = arg;
	
	return oldNode;
}

#pragma mark - ADDITIONAL to SVG Spec: useful debug / output / description methods

-(NSString *)description
{
	/** test (and output) both the "DOM 1" and "DOM 2" dictionaries, if they're non-empty */
	
	NSString* dom1 = self.internalDictionary.count > 0 ? [NSString stringWithFormat:@"DOM-v1(%@)", self.internalDictionary] : nil;
	NSString* dom2 = self.internalDictionaryOfNamespaces.count > 0 ? [NSString stringWithFormat:@"DOM-v2(%@)", self.internalDictionaryOfNamespaces] : nil;
	
	return [NSString stringWithFormat:@"NamedNodeMap: %@%@%@", dom1, dom1 != nil && dom2 != nil ? @"\n" : @"", dom2  ];
}

#pragma mark - Implementation of category: NamedNodeMap_Iterable

-(NSArray*) allNodesUnsortedDOM1
{
	/** Using DOM1 - no namespace support */
	
	return self.internalDictionary.allValues;
}

-(NSDictionary*) allNodesUnsortedDOM2
{
	/** Using DOM2 - every item has a namespace*/
	
	return self.internalDictionaryOfNamespaces;
}

#pragma mark - Needed to implement XML DOM effectively: ability to shallow-Clone an instance

-(id)copyWithZone:(NSZone *)zone
{
	NamedNodeMap* clone = [[NamedNodeMap allocWithZone:zone] init];
	clone.internalDictionary = [[self.internalDictionary copyWithZone:zone] autorelease];
	clone.internalDictionaryOfNamespaces = [[self.internalDictionaryOfNamespaces copyWithZone:zone] autorelease];
	
	return clone;
}

@end
