//
//  SVGStyleParser.m
//  SVGPad
//
//  Created by Kevin Stich on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SVGKParserStyles.h"

#import "CSSStyleSheet.h"
#import "StyleSheetList+Mutable.h"

@implementation SVGKParserStyles


static NSSet *_svgParserStylesSupportedNamespaces = nil;
-(NSSet *) supportedNamespaces
{
    if( _svgParserStylesSupportedNamespaces == nil )
        _svgParserStylesSupportedNamespaces = [[NSSet alloc] initWithObjects:
        @"http://www.w3.org/2000/svg",
        nil];
	return _svgParserStylesSupportedNamespaces;
}

static NSSet *_svgParserStylesSupportedTags = nil;
-(NSSet *)supportedTags
{
    if( _svgParserStylesSupportedTags == nil )
        _svgParserStylesSupportedTags = [[NSSet alloc] initWithObjects:@"style", nil];
    return _svgParserStylesSupportedTags;
}

-(Node *)handleStartElement:(NSString *)name document:(SVGKSource *)document namePrefix:(NSString *)prefix namespaceURI:(NSString *)XMLNSURI attributes:(NSMutableDictionary *)attributes parseResult:(SVGKParseResult *)parseResult parentNode:(Node *)parentNode
{
	if( [[self supportedNamespaces] containsObject:XMLNSURI] )
	{
		/**
		 
		 NB: this section of code is copy/pasted from SVGKParserDOM -- we don't want anything special, we want an ordinary DOM node,
		 ...but we need this standalone parser-extension because a <style> tag needs some custom *post-processing*
		 
		 
		 
		 */
		
		NSString* qualifiedName = (prefix == nil) ? name : [NSString stringWithFormat:@"%@:%@", prefix, name];
		
		/** NB: must supply a NON-qualified name if we have no specific prefix here ! */
		// FIXME: we always return an empty Element here; for DOM spec, should we be detecting things like "comment" nodes? I dont know how libxml handles those and sends them to us. I've never seen one in action...
		Element *blankElement = [[Element alloc] initWithQualifiedName:qualifiedName inNameSpaceURI:XMLNSURI attributes:attributes];
		
		return blankElement;
	}
	else
		return nil;
}

-(void)handleEndElement:(Node *)newNode document:(SVGKSource *)document parseResult:(SVGKParseResult *)parseResult
{
	/** This is where the magic happens ... */
		NSString* c = [newNode.textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		if( c.length > 0 )
		{
			CSSStyleSheet* parsedStylesheet = [[CSSStyleSheet alloc] initWithString:c];
			
			[parseResult.parsedDocument.rootElement.styleSheets.internalArray addObject:parsedStylesheet];
			
			[parsedStylesheet release];
		}

}

+(void)trim
{
    _svgParserStylesSupportedTags = nil;
    
    _svgParserStylesSupportedNamespaces = nil;
}

@end
