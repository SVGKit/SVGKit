
#import "SVGKDOMHelperUtilities.h"

#import "SVGKElement.h"
#import "SVGKNodeList.h"
#import "SVGKNodeList+Mutable.h" // needed for access to underlying array, because SVG doesnt specify how lists are made mutable

@implementation SVGKDOMHelperUtilities

/*! This useful method provides both the DOM level 1 and the DOM level 2 implementations of searching the tree for a node - because THEY ARE DIFFERENT
 yet very similar
 */
+(void) privateGetElementsByName:(NSString*) name inNamespace:(NSString*) namespaceURI childrenOfElement:(SVGKNode*) parent addToList:(SVGKNodeList*) accumulator
{
	/** According to spec, this is only valid for ELEMENT nodes */
	if( [parent isKindOfClass:[SVGKElement class]] )
	{
		if( namespaceURI != nil && ! [parent.namespaceURI isEqualToString:namespaceURI] )
		{
			// skip
		}
		else
		{
			SVGKElement* parentAsElement = (SVGKElement*) parent;
			
			/** According to spec, "tag name" for an Element is the value of its .nodeName property; that means SOMETIMES its a qualified name! */
			BOOL includeThisNode = FALSE;
			
			
			if( [name isEqualToString:@"*"] )
				includeThisNode = TRUE;
			
			if( !includeThisNode )
			{
				if( namespaceURI == nil ) // No namespace? then do a qualified compare
				{
					includeThisNode = [parentAsElement.tagName isEqualToString:name];
				}
				else // namespace? then do an UNqualified compare
				{
					includeThisNode = [parentAsElement.localName isEqualToString:name];
				}
			}
			
			if( includeThisNode )
			{
				[accumulator.internalArray addObject:parent];
			}
		}
	}
	
	for( SVGKNode* childNode in parent.childNodes )
	{
		[self privateGetElementsByName:name inNamespace:namespaceURI childrenOfElement:childNode addToList:accumulator];
	}
}

+(SVGKElement*) privateGetElementById:(NSString*) idValue childrenOfElement:(SVGKNode*) parent
{
	/** According to spec, this is only valid for ELEMENT nodes */
	if( [parent isKindOfClass:[SVGKElement class]] )
	{
		SVGKElement* parentAsElement = (SVGKElement*) parent;

		if( [[parentAsElement getAttribute:@"id"] isEqualToString:idValue])
			return parentAsElement;
#if DEBUG_DOM_MATCH_ELEMENTS_IDS_AND_NAMES
		else
		{
			DDLogVerbose(@"parent <%@ id='%@'..> does not match id='%@'", parentAsElement.nodeName, [parentAsElement getAttribute:@"id"], idValue );
			DDLogVerbose(@"parent <%@ id='%@'..> has %li child nodes = %@", parentAsElement.nodeName, [parentAsElement getAttribute:@"id"], parent.childNodes.length, parent.childNodes );
		}
#endif
	}
	
	for( SVGKNode* childNode in parent.childNodes )
	{
		SVGKElement* childResult = [self privateGetElementById:idValue childrenOfElement:childNode];
		
		if( childResult != nil )
			return childResult;
	}
	
	return nil;
}

@end
