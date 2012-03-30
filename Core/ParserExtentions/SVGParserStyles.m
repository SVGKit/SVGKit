//
//  SVGStyleParser.m
//  SVGPad
//
//  Created by Kevin Stich on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SVGParserStyles.h"
#import "SVGDocument.h"

@implementation SVGParserStyles


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

- (NSObject *)handleStartElement:(NSString *)name document:(SVGDocument *)document xmlns:(NSString *)namespaceURI attributes:(NSMutableDictionary *)attributes
{
//    NSLog(@"Parsing style object %@", attributes);
    //This needs to link with external style sheets per spec... internal styles are represented as inline CDATA and are parsed seperately (styles added to document directly from SVGParser)... definitely one of the hairier parts of this process currently
    
    //Would be a good idea to route that functionality through this class for consistency
    return nil;
}


-(void) parseContent:(NSMutableString *)content forItem:(NSObject *)item
{
    
}

-(BOOL) createdItemShouldStoreContent:(NSObject *)item
{
    
    return false;
}

-(void) addChildObject:(NSObject *)child toObject:(NSObject *)parent inDocument:(SVGDocument *)svgDocument
{
    
}

-(void) dealloc
{
//    [_tags release];
//    [_namespaces release];
    
    [super dealloc];
}

+(void)trim
{
    [_svgParserStylesSupportedTags release];
    _svgParserStylesSupportedTags = nil;
    
    [_svgParserStylesSupportedNamespaces release];
    _svgParserStylesSupportedNamespaces = nil;
}

@end
