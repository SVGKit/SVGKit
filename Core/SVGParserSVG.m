#import "SVGParserSVG.h"

#import "SVGCircleElement.h"
#import "SVGDefsElement.h"
#import "SVGDescriptionElement.h"
#import "SVGDocument.h"
#import "SVGEllipseElement.h"
#import "SVGGroupElement.h"
#import "SVGImageElement.h"
#import "SVGLineElement.h"
#import "SVGPathElement.h"
#import "SVGPolygonElement.h"
#import "SVGPolylineElement.h"
#import "SVGRectElement.h"
#import "SVGTitleElement.h"
#import "SVGElement+Private.h"

#import "SVGPointsAndPathsParser.h"

@implementation SVGParserSVG

static NSDictionary *elementMap;

- (id)init {
	self = [super init];
	if (self) {
		
		if (!elementMap) {
			elementMap = [[NSDictionary dictionaryWithObjectsAndKeys:
                          [SVGCircleElement class], @"circle",
                          [SVGDefsElement class], @"defs",
                          [SVGDescriptionElement class], @"description",
                          [SVGEllipseElement class], @"ellipse",
                          [SVGGroupElement class], @"g",
                          [SVGImageElement class], @"image",
                          [SVGLineElement class], @"line",
                          [SVGPathElement class], @"path",
                          [SVGPolygonElement class], @"polygon",
                          [SVGPolylineElement class], @"polyline",
                          [SVGRectElement class], @"rect",
                          [SVGTitleElement class], @"title", nil] retain];
            
		}
	}
	return self;
}

- (void)dealloc {
	[_anonymousGraphicsGroups release];
	[_graphicsGroups release];
	
	[super dealloc];
}

static NSSet *_SVGParserSVGSupportedNameSpaces;
-(NSSet*) supportedNamespaces
{
    if( _SVGParserSVGSupportedNameSpaces == nil )
        _SVGParserSVGSupportedNameSpaces = [[NSSet alloc] initWithObjects:@"http://www.w3.org/2000/svg",
        nil];
	return _SVGParserSVGSupportedNameSpaces;
}

static NSSet *_SVGParserSVGSupportedTags;
-(NSSet*) supportedTags
{
    if( _SVGParserSVGSupportedTags == nil )
    {
        NSMutableArray* result = [[NSMutableArray alloc] initWithArray:[elementMap allKeys]];
        [result addObject:@"svg"];
        [result addObject:@"defs"];
        [result addObject:@"g"];
        [result addObject:@"path"];
        _SVGParserSVGSupportedTags = [[NSSet alloc] initWithArray:result];
        [result release];
    }
	return _SVGParserSVGSupportedTags;
}

- (NSObject*) handleStartElement:(NSString *)name document:(SVGDocument*) svgDocument xmlns:(NSString*) prefix attributes:(NSMutableDictionary *)attributes {
	if( [[self supportedNamespaces] containsObject:prefix] )
	{
		NSObject* result = nil;
		
		// handle svg:svg tag separately
		if ([name isEqualToString:@"svg"]) {
			result = svgDocument;
			[svgDocument parseAttributes:attributes];
			
			return result;
		}
		
		Class elementClass = [elementMap objectForKey:name];
		
		if (!elementClass) {
			elementClass = [SVGElement class];
#ifdef SVGPARSER_WARN_UNIMPLEMENTED_TAGS
			NSLog(@"Support for '%@' element has not been implemented", name);
#endif
		}
		
		SVGElement *element = [[elementClass alloc] initWithDocument:svgDocument name:name];
        
        
        if( (result = [attributes objectForKey:@"class"]) )
        {
            if( [result isKindOfClass:[NSString class]] )
            {
                NSDictionary *thisClassStyle = [svgDocument styleForElement:element withClassName:(NSString *)result];
                if( thisClassStyle != nil ) //we should 
                {
                    [attributes addEntriesFromDictionary:thisClassStyle];
                }
            }
        }
        
		id style = nil;
		if ((style = [attributes objectForKey:@"style"])) { //style overrides class attributes, this is almost correct, it's actually supposed to merge them based on property type (somethings are blended, somethings override)
			[attributes removeObjectForKey:@"style"];
			[attributes addEntriesFromDictionary:[SVGParser NSDictionaryFromCSSAttributes:style]];
		}
        
		[element parseAttributes:attributes];
		
		return [element autorelease];
	}
	
	return nil;
}

-(BOOL) createdItemShouldStoreContent:(NSObject*) item
{
	if( [item isKindOfClass:[SVGElement class]] )
	{
        return [[item class] shouldStoreContent];
//		if () {
//			return TRUE;
//		}
//		else {
//			return FALSE;
//		}
	}
	else
		return false;
}

-(void) addChildObject:(NSObject*)child toObject:(NSObject*)parent inDocument:(SVGDocument*) svgDocument
{
	SVGElement *parentElement = (SVGElement*) parent;
	
	if( [child isKindOfClass:[SVGElement class]] )
	{
		SVGElement *childElement = (SVGElement*) child;
        
		if ( parent == nil ) // i.e. the root SVG tag
		{
#ifdef SVGPARSER_NOTIFY_COMPLETE
			NSLog(@"[%@] PARSER_INFO: asked to add object to nil parent; i.e. we've hit the root of the tree; setting global variables on the SVG Document now", [self class]);
#endif
			[svgDocument setGraphicsGroups:_graphicsGroups];
			[svgDocument setAnonymousGraphicsGroups:_anonymousGraphicsGroups];
			
			[_graphicsGroups release];
			[_anonymousGraphicsGroups release];
			_graphicsGroups = nil;
			_anonymousGraphicsGroups = nil;
		}
		else
		{
			[parentElement addChild:childElement];
			
			/*!
			 SVG Spec attaches special meaning to the "g" tag - and applications
			 need to be able to pull-out the "g"-tagged items later on
			 */
			if( [childElement.localName isEqualToString:@"g"] )
			{
				if( childElement.identifier == nil )
				{
					if( _anonymousGraphicsGroups == nil )
						_anonymousGraphicsGroups = [NSMutableArray new];
					
					[_anonymousGraphicsGroups addObject:childElement];
					
#if PARSER_WARN_FOR_ANONYMOUS_SVG_G_TAGS
					NSLog(@"[%@] PARSER_WARN: Found anonymous g tag (tag has no XML 'id=' attribute). Loading OK, but check your SVG file (id tags are highly recommended!)...", [self class] );
#endif
				}
				else
				{
					if( _graphicsGroups == nil )
						_graphicsGroups = [NSMutableDictionary new];
					
					[_graphicsGroups setValue:childElement forKey:childElement.identifier];
				}
			}
		}
	}
	else
	{
		/*!
		 Unknown metadata
		 */
		
		[parentElement addMetadataChild:child];
	}
}

-(void) parseContent:(NSMutableString*) content forItem:(NSObject*) item
{
	SVGElement* element = (SVGElement*) item;
	
	[element parseContent:content];
}

+(void)trim
{
    //not enough payout for the danger here, the other two are automatically regenerated but elementMap is not
//    [elementMap release];
//    elementMap = nil;
    [SVGPointsAndPathsParser trim];
    
    [_SVGParserSVGSupportedNameSpaces release];
    _SVGParserSVGSupportedNameSpaces = nil;
    
    [_SVGParserSVGSupportedTags release];
    _SVGParserSVGSupportedTags = nil;
}

@end
