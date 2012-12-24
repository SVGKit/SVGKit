#import "SVGKParserDOM.h"

#import "Node+Mutable.h"

@implementation SVGKParserDOM

/**
 This is a special, magical parser that matches "no namespace" - i.e. matches what happens when no namespace was declared\
 */
-(NSArray*) supportedNamespaces
{
	return [NSArray array];
}

/** 
 This is a special, magical parser that matches "all tags"
 */
-(NSArray*) supportedTags
{
	return [NSMutableArray array];
}

- (Node*) handleStartElement:(NSString *)name document:(SVGKSource*) SVGKSource namePrefix:(NSString*)prefix namespaceURI:(NSString*) XMLNSURI attributes:(NSMutableDictionary *)attributeObjects parseResult:(SVGKParseResult *)parseResult parentNode:(Node*) parentNode
{
	if( [[self supportedNamespaces] count] == 0
	|| [[self supportedNamespaces] containsObject:XMLNSURI] ) // unnecesary here, but allows safe updates to this parser's matching later
	{	
		NSString* qualifiedName = (prefix == nil) ? name : [NSString stringWithFormat:@"%@:%@", prefix, name];
		
		/** NB: must supply a NON-qualified name if we have no specific prefix here ! */
		// FIXME: we always return an empty Element here; for DOM spec, should we be detecting things like "comment" nodes? I dont know how libxml handles those and sends them to us. I've never seen one in action...
		Element *blankElement = [[[Element alloc] initWithQualifiedName:qualifiedName inNameSpaceURI:XMLNSURI attributes:attributeObjects] autorelease];
		
		return blankElement;
	}
	
	return nil;
}

-(BOOL) createdNodeShouldStoreContent:(Node*) item
{
	switch( item.nodeType )
	{
		case SKNodeType_ATTRIBUTE_NODE:
		case SKNodeType_DOCUMENT_FRAGMENT_NODE:
		case SKNodeType_DOCUMENT_NODE:
		case SKNodeType_DOCUMENT_TYPE_NODE:
		case SKNodeType_ELEMENT_NODE:
		case SKNodeType_ENTITY_NODE:
		case SKNodeType_ENTITY_REFERENCE_NODE:
		case SKNodeType_NOTATION_NODE:
		{
			return FALSE; // do nothing, according to the table in : http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-1950641247
		} break;
			
		case SKNodeType_CDATA_SECTION_NODE:
		case SKNodeType_COMMENT_NODE:
		case SKNodeType_PROCESSING_INSTRUCTION_NODE:
		case SKNodeType_TEXT_NODE:
		{
			return TRUE;
		} break;
	}
}

-(void) handleStringContent:(NSMutableString*) content forNode:(Node*) node
{
	switch( node.nodeType )
	{
		case SKNodeType_ATTRIBUTE_NODE:
		case SKNodeType_DOCUMENT_FRAGMENT_NODE:
		case SKNodeType_DOCUMENT_NODE:
		case SKNodeType_DOCUMENT_TYPE_NODE:
		case SKNodeType_ELEMENT_NODE:
		case SKNodeType_ENTITY_NODE:
		case SKNodeType_ENTITY_REFERENCE_NODE:
		case SKNodeType_NOTATION_NODE:
		{
			// do nothing, according to the table in : http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-1950641247
		} break;
			
		case SKNodeType_CDATA_SECTION_NODE:
		case SKNodeType_COMMENT_NODE:
		case SKNodeType_PROCESSING_INSTRUCTION_NODE:
		case SKNodeType_TEXT_NODE:
		{
			node.nodeValue = content;
		} break;
	}
}

@end
