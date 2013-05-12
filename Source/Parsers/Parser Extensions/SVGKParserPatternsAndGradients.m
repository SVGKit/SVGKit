//
//  SVGKParserPatternsAndGradients.m
//  SVGKit
//
//  Created by adam applecansuckmybigtodger on 28/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SVGKit/SVGKParserPatternsAndGradients.h>

#import <SVGKit/SVGSVGElement.h>
#import <SVGKit/SVGCircleElement.h>
#import <SVGKit/SVGDefsElement.h>
#import <SVGKit/SVGDescriptionElement.h>
//#import <SVGKit/SVGKSource.h>
#import <SVGKit/SVGEllipseElement.h>
#import <SVGKit/SVGImageElement.h>
#import <SVGKit/SVGLineElement.h>
#import <SVGKit/SVGPathElement.h>
#import <SVGKit/SVGPolygonElement.h>
#import <SVGKit/SVGPolylineElement.h>
#import <SVGKit/SVGRectElement.h>
#import <SVGKit/SVGTitleElement.h>

@implementation SVGKParserPatternsAndGradients

/*
 * We don't have any extra data to release
- (void)dealloc {
	
	[super dealloc];
}
 */

-(NSArray*) supportedNamespaces
{
	return [NSArray arrayWithObjects:
			@"http://www.w3.org/2000/svg",
			nil];
}

/** "tags supported" is exactly the set of all SVGElement subclasses that already exist */
-(NSArray*) supportedTags
{
	return [NSMutableArray arrayWithObjects:@"pattern", nil];
}

- (Node*)handleStartElement:(NSString *)name document:(SVGKSource*) document namePrefix:(NSString*)prefix namespaceURI:(NSString*) XMLNSURI attributes:(NSMutableDictionary *)attributes parseResult:(SVGKParseResult*) parseResult parentNode:(Node*) parentNode
{
		
	NSAssert( FALSE, @"Patterns are not supported by SVGKit yet - no-one has implemented them" );
	
	return nil;
}

-(void)handleEndElement:(Node *)newNode document:(SVGKSource *)document parseResult:(SVGKParseResult *)parseResult
{
	
}

@end
