//
//  NamedNodeMap.m
//  SVGKit
//
//  Created by adam on 22/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NamedNodeMap.h"

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
	Node* simpleResult = [self.internalDictionary objectForKey:name];
	
	if( simpleResult == nil )
	{
		/**
		 Check the namespaces in turn, to see if we can find this node in one of them
		 
		 NB: according to spec, this behaviour is:
		 
		    "The result depends on the implementation"
		 
		 I've chosen to implement it the most user-friendly way possible. It is NOT the best
		 solution IMHO - the spec authors should have defined the outcome!
		 */
		
		for( NSString* key in [self.internalDictionaryOfNamespaces allKeys] )
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
	
	Node* oldNode = [self.internalDictionary objectForKey:arg.localName];
	
	[self.internalDictionary setObject:arg forKey:arg.localName];
	
	return oldNode;
}

-(Node*) removeNamedItem:(NSString*) name
{
	NSAssert( [[self.internalDictionaryOfNamespaces allKeys] count] < 1, @"WARNING: you are using namespaced attributes in parallel with non-namespaced. According to the DOM Spec, this leads to UNDEFINED behaviour. This is insane - you do NOT want to be doing this! Crashing deliberately...." );
	
	Node* oldNode = [self.internalDictionary objectForKey:name];
	
	[self.internalDictionary removeObjectForKey:name];
	
	return oldNode;
}

-(unsigned long)length
{
	unsigned long count = [self.internalDictionary count];
	
	for( NSDictionary* namespaceDict in self.internalDictionaryOfNamespaces )
	{
		count += [namespaceDict count];
	}
	
	return count;
}

-(Node*) item:(unsigned long) index
{
	if( index < [self.internalDictionary count] )
		return [self.internalDictionary.allValues objectAtIndex:index];
	else
	{
		index -= self.internalDictionary.count;
		
		for( NSDictionary* namespaceDict in self.internalDictionaryOfNamespaces )
		{
			if( index < [namespaceDict count] )
				return [namespaceDict.allValues objectAtIndex:index];
			else
				index -= [namespaceDict count];
		}
	}
	
	return nil;
}

// Introduced in DOM Level 2:
-(Node*) getNamedItemNS:(NSString*) namespaceURI localName:(NSString*) localName
{
	NSMutableDictionary* namespaceDict = [self.internalDictionaryOfNamespaces objectForKey:namespaceURI];
	
	return [namespaceDict objectForKey:localName];
}

// Introduced in DOM Level 2:
-(Node*) setNamedItemNS:(Node*) arg
{
	return [self setNamedItemNS:arg inNodeNamespace:nil];
}

// Introduced in DOM Level 2:
-(Node*) removeNamedItemNS:(NSString*) namespaceURI localName:(NSString*) localName
{
	NSMutableDictionary* namespaceDict = [self.internalDictionaryOfNamespaces objectForKey:namespaceURI];
	Node* oldNode = [namespaceDict objectForKey:localName];
	
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
	
	NSMutableDictionary* namespaceDict = [self.internalDictionaryOfNamespaces objectForKey:effectiveNamespace];
	if( namespaceDict == nil )
	{
		namespaceDict = [NSMutableDictionary dictionary];
		[self.internalDictionaryOfNamespaces setObject:namespaceDict forKey:effectiveNamespace];
	}
	Node* oldNode = [namespaceDict objectForKey:arg.localName];
	
	[namespaceDict setObject:arg forKey:arg.localName];
	
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


@end
