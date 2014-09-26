#import "SVGKElement.h"

#import "SVGKNamedNodeMap.h"
#import "SVGKDOMHelperUtilities.h"

@interface SVGKElement()
@property(nonatomic,retain,readwrite) NSString* tagName;
@end

@implementation SVGKElement

@synthesize tagName;

- (void)dealloc {
    self.tagName = nil;
    [super dealloc];
}

- (id)initWithLocalName:(NSString*) n attributes:(NSMutableDictionary*) attributes {
    self = [super initType:DOMNodeType_ELEMENT_NODE name:n];
    if (self) {
        self.tagName = n;
		
		for( NSString* attributeName in attributes.allKeys )
		{
			[self setAttribute:attributeName value:[attributes objectForKey:attributeName]];
		}
    }
    return self;
}
- (id)initWithQualifiedName:(NSString*) n inNameSpaceURI:(NSString*) nsURI attributes:(NSMutableDictionary *)attributes
{
    self = [super initType:DOMNodeType_ELEMENT_NODE name:n inNamespace:nsURI];
    if (self) {
        self.tagName = n;
		
		for( SVGKAttr* attribute in attributes.allValues )
		{
			[self.attributes setNamedItemNS:attribute inNodeNamespace:nsURI];
		}
    }
    return self;
}

-(NSString*) getAttribute:(NSString*) name
{
	/**
	 WARNING: the definition in the spec WILL CORRUPT unsuspecting Objective-C code (including a lot of the original SVGKit code!).
	 
	 The spec - instead of defining 'nil' - defines "" (empty string) as the
	 correct response.
	 
	 But in most of the modern, C-based, (non-scripting) languages, "" means 0.
	 
	 Very dangerous!
	 */
	SVGKAttr* result = (SVGKAttr*) [self.attributes getNamedItem:name];
	
	if( result == nil || result.value == nil )
		return @""; // according to spec
	else
		return result.value;
}

-(void) setAttribute:(NSString*) name value:(NSString*) value
{
	SVGKAttr* att = [[[SVGKAttr alloc] initWithName:name value:value] autorelease];
	
	[self.attributes setNamedItem:att];
}

-(void) removeAttribute:(NSString*) name
{
	[self.attributes removeNamedItem:name];
	
	NSAssert( FALSE, @"Not fully implemented. Spec says: If the removed attribute is known to have a default value, an attribute immediately appears containing the default value as well as the corresponding namespace URI, local name, and prefix when applicable." );
}

-(SVGKAttr*) getAttributeNode:(NSString*) name
{
	return (SVGKAttr*) [self.attributes getNamedItem:name];
}

-(SVGKAttr*) setAttributeNode:(SVGKAttr*) newAttr
{
	SVGKAttr* oldAtt = (SVGKAttr*) [self.attributes getNamedItem:newAttr.nodeName];
	
	[self.attributes setNamedItem:newAttr];
	
	return oldAtt;
}

-(SVGKAttr*) removeAttributeNode:(SVGKAttr*) oldAttr
{
	[self.attributes removeNamedItem:oldAttr.nodeName];
	
	NSAssert( FALSE, @"Not fully implemented. Spec: If the removed Attr  has a default value it is immediately replaced. The replacing attribute has the same namespace URI and local name, as well as the original prefix, when applicable. " );
	
	return oldAttr;
}

-(SVGKNodeList*) getElementsByTagName:(NSString*) name
{
	SVGKNodeList* accumulator = [[[SVGKNodeList alloc] init] autorelease];
	[SVGKDOMHelperUtilities privateGetElementsByName:name inNamespace:nil childrenOfElement:self addToList:accumulator];
	
	return accumulator;
}

// Introduced in DOM Level 2:
-(NSString*) getAttributeNS:(NSString*) namespaceURI localName:(NSString*) localName
{
	SVGKAttr* result = (SVGKAttr*) [self.attributes getNamedItemNS:namespaceURI localName:localName];
	
	if( result == nil || result.value == nil )
		return @""; // according to spec
	else
		return result.value;
}

// Introduced in DOM Level 2:
-(void) setAttributeNS:(NSString*) namespaceURI qualifiedName:(NSString*) qualifiedName value:(NSString*) value
{
	SVGKAttr* att = [[[SVGKAttr alloc] initWithNamespace:namespaceURI qualifiedName:qualifiedName value:value] autorelease];
	
	[self.attributes setNamedItemNS:att];
}

// Introduced in DOM Level 2:
-(void) removeAttributeNS:(NSString*) namespaceURI localName:(NSString*) localName
{
	NSAssert( FALSE, @"Not implemented yet" );
}

// Introduced in DOM Level 2:
-(SVGKAttr*) getAttributeNodeNS:(NSString*) namespaceURI localName:(NSString*) localName
{
	SVGKAttr* result = (SVGKAttr*) [self.attributes getNamedItemNS:namespaceURI localName:localName];
	
	return result;
}

// Introduced in DOM Level 2:
-(SVGKAttr*) setAttributeNodeNS:(SVGKAttr*) newAttr
{
	NSAssert( FALSE, @"Not implemented yet" );
	return nil;
}

// Introduced in DOM Level 2:
-(SVGKNodeList*) getElementsByTagNameNS:(NSString*) namespaceURI localName:(NSString*) localName
{
	SVGKNodeList* accumulator = [[[SVGKNodeList alloc] init] autorelease];
	[SVGKDOMHelperUtilities privateGetElementsByName:localName inNamespace:namespaceURI childrenOfElement:self addToList:accumulator];
	
	return accumulator;
}

// Introduced in DOM Level 2:
-(BOOL) hasAttribute:(NSString*) name
{
	SVGKAttr* result = (SVGKAttr*) [self.attributes getNamedItem:name];
	
	return result != nil;
}

// Introduced in DOM Level 2:
-(BOOL) hasAttributeNS:(NSString*) namespaceURI localName:(NSString*) localName
{
	NSAssert( FALSE, @"Not implemented yet" );
	return FALSE;
}

@end
