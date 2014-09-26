#import "SVGKDocument.h"
#import "SVGKDocument+Mutable.h"

#import "SVGKDOMHelperUtilities.h"

#import "SVGKNodeList+Mutable.h" // needed for access to underlying array, because SVG doesnt specify how lists are made mutable

@implementation SVGKDocument

@synthesize doctype;
@synthesize implementation;
@synthesize documentElement;


- (void)dealloc {
  [doctype release];
  [implementation release];
  [documentElement release];
  [super dealloc];
}

-(SVGKElement*) createElement:(NSString*) tagName
{
	SVGKElement* newElement = [[SVGKElement alloc] initWithLocalName:tagName attributes:nil];
	
	DDLogVerbose( @"[%@] WARNING: SVG Spec, missing feature: if there are known attributes with default values, Attr nodes representing them SHOULD BE automatically created and attached to the element.", [self class] );
	
	return newElement;
}

-(SVGKDocumentFragment*) createDocumentFragment
{
	return [[SVGKDocumentFragment alloc] init];
}

-(SVGKText*) createTextNode:(NSString*) data
{
	return [[SVGKText alloc] initWithValue:data];
}

-(SVGKComment*) createComment:(NSString*) data
{
	return [[SVGKComment alloc] initWithValue:data];
}

-(SVGKCDATASection*) createCDATASection:(NSString*) data
{
	return [[SVGKCDATASection alloc] initWithValue:data];
}

-(SVGKProcessingInstruction*) createProcessingInstruction:(NSString*) target data:(NSString*) data
{
	return [[SVGKProcessingInstruction alloc] initProcessingInstruction:target value:data];
}

-(SVGKAttr*) createAttribute:(NSString*) n
{
	return [[SVGKAttr alloc] initWithName:n value:@""];
}

-(SVGKEntityReference*) createEntityReference:(NSString*) data
{
	NSAssert( FALSE, @"Not implemented. According to spec: Creates an EntityReference object. In addition, if the referenced entity is known, the child list of the EntityReference  node is made the same as that of the corresponding Entity  node. Note: If any descendant of the Entity node has an unbound namespace prefix, the corresponding descendant of the created EntityReference node is also unbound; (its namespaceURI is null). The DOM Level 2 does not support any mechanism to resolve namespace prefixes." );
	return nil;
}

-(SVGKNodeList*) getElementsByTagName:(NSString*) data
{
	SVGKNodeList* accumulator = [[[SVGKNodeList alloc] init] autorelease];
	[SVGKDOMHelperUtilities privateGetElementsByName:data inNamespace:nil childrenOfElement:self.documentElement addToList:accumulator];
	
	return accumulator;
}

// Introduced in DOM Level 2:
-(SVGKNode*) importNode:(SVGKNode*) importedNode deep:(BOOL) deep
{
	NSAssert( FALSE, @"Not implemented." );
	return nil;
}

// Introduced in DOM Level 2:
-(SVGKElement*) createElementNS:(NSString*) namespaceURI qualifiedName:(NSString*) qualifiedName
{
	SVGKElement* newElement = [[SVGKElement alloc] initWithQualifiedName:qualifiedName inNameSpaceURI:namespaceURI attributes:nil];
	
	DDLogVerbose( @"[%@] WARNING: SVG Spec, missing feature: if there are known attributes with default values, Attr nodes representing them SHOULD BE automatically created and attached to the element.", [self class] );
	
	return newElement;
}

// Introduced in DOM Level 2:
-(SVGKAttr*) createAttributeNS:(NSString*) namespaceURI qualifiedName:(NSString*) qualifiedName
{
	NSAssert( FALSE, @"This should be re-implemented to share code with createElementNS: method above" );
	SVGKAttr* newAttr = [[[SVGKAttr alloc] initWithNamespace:namespaceURI qualifiedName:qualifiedName value:@""] autorelease];
	return newAttr;
}

// Introduced in DOM Level 2:
-(SVGKNodeList*) getElementsByTagNameNS:(NSString*) namespaceURI localName:(NSString*) localName
{
	SVGKNodeList* accumulator = [[[SVGKNodeList alloc] init] autorelease];
	[SVGKDOMHelperUtilities privateGetElementsByName:localName inNamespace:namespaceURI childrenOfElement:self.documentElement addToList:accumulator];
	
	return accumulator;
}

// Introduced in DOM Level 2:
-(SVGKElement*) getElementById:(NSString*) elementId
{
	return [SVGKDOMHelperUtilities privateGetElementById:elementId childrenOfElement:self.documentElement];
}

@end
