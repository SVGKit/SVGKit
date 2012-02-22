//
//  SVGStyleParser.m
//  SVGPad
//
//  Created by Kevin Stich on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SVGParserStyles.h"

@implementation SVGParserStyles


-(NSArray*) supportedNamespaces
{
	return [NSArray arrayWithObjects:
            @"http://www.w3.org/2000/svg",
			nil];
}

-(NSArray *)supportedTags
{
    return [NSArray arrayWithObjects:@"style", nil];
}

- (NSObject *)handleStartElement:(NSString *)name document:(SVGDocument *)document xmlns:(NSString *)namespaceURI attributes:(NSMutableDictionary *)attributes
{
//    NSLog(@"Parsing style object %@", attributes);
    //This needs to link with external style sheets per spec... internal styles are represented as inline CDATA and are parsed seperately (styles added to document directly from SVGParser)... definitely one of the hairier parts of this process currently
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

@end
