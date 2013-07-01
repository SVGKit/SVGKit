#import <SVGKit/SVGKParserSVG.h>

#import <SVGKit/SVGSVGElement.h>
#import <SVGKit/SVGCircleElement.h>
#import <SVGKit/SVGDefsElement.h>
#import <SVGKit/SVGDescriptionElement.h>
//#import <SVGKit/SVGKSource.h>
#import <SVGKit/SVGEllipseElement.h>
#import <SVGKit/SVGGElement.h>
#import <SVGKit/SVGImageElement.h>
#import <SVGKit/SVGLineElement.h>
#import <SVGKit/SVGPathElement.h>
#import <SVGKit/SVGPolygonElement.h>
#import <SVGKit/SVGPolylineElement.h>
#import <SVGKit/SVGRectElement.h>
#import <SVGKit/SVGTitleElement.h>
#import <SVGKit/SVGTextElement.h>

#import <SVGKit/SVGDocument_Mutable.h>

@implementation SVGKParserSVG

static NSDictionary *elementMap = nil;

- (id)init {
	self = [super init];
	if (self) {
		
		if (!elementMap) {
			elementMap = [[NSDictionary alloc] initWithObjectsAndKeys:
						  [SVGSVGElement class], @"svg",
						  [SVGCircleElement class], @"circle",
						  [SVGDescriptionElement class], @"description",
						  [SVGEllipseElement class], @"ellipse",
						  [SVGGElement class], @"g",
						  [SVGImageElement class], @"image",
						  [SVGLineElement class], @"line",
						  [SVGPathElement class], @"path",
						  [SVGPolygonElement class], @"polygon",
						  [SVGPolylineElement class], @"polyline",
						  [SVGRectElement class], @"rect",
						  [SVGTitleElement class], @"title",
						  [SVGTextElement class], @"text",
						  nil];
		}
	}
	return self;
}

-(NSArray*) supportedNamespaces
{
	return @[@"http://www.w3.org/2000/svg"];
}

/** "tags supported" is exactly the set of all SVGElement subclasses that already exist */
-(NSArray*) supportedTags
{
	return [NSMutableArray arrayWithArray:[elementMap allKeys]];
}

- (Node*) handleStartElement:(NSString *)name document:(SVGKSource*) SVGKSource namePrefix:(NSString*)prefix namespaceURI:(NSString*) XMLNSURI attributes:(NSMutableDictionary *)attributes parseResult:(SVGKParseResult *)parseResult parentNode:(Node*) parentNode
{
	if( [[self supportedNamespaces] containsObject:XMLNSURI] )
	{
		Class elementClass = elementMap[name];
		
		if (!elementClass) {
			elementClass = [SVGElement class];
			DDLogWarn(@"Support for '%@' element has not been implemented", name);
		}
		
		/**
		 NB: following the SVG Spec, it's critical that we ONLY use the DOM methods for creating
		 basic 'Element' nodes.
		 
		 Our SVGElement root class has an implementation of init that delegates to the same
		 private methods that the DOM methods use, so it's safe...
		 
		 FIXME: ...but in reality we ought to be using the DOMDocument createElement/NS methods, although "good luck" trying to find a DOMDocument if your SVG is embedded inside a larger XML document :(
		 */
		
		
		NSString* qualifiedName = (prefix == nil) ? name : [NSString stringWithFormat:@"%@:%@", prefix, name];
		/** NB: must supply a NON-qualified name if we have no specific prefix here ! */
		SVGElement *element = [[elementClass alloc] initWithQualifiedName:qualifiedName inNameSpaceURI:XMLNSURI attributes:attributes];
		
		/** NB: all the interesting handling of shared / generic attributes - e.g. the whole of CSS styling etc - takes place in this method: */
		[element postProcessAttributesAddingErrorsTo:parseResult];
		
		/** special case: <svg:svg ... version="XXX"> */
		if( [@"svg" isEqualToString:name] )
		{
			NSString* svgVersion = nil;
			
			/** According to spec, if the first XML node is an SVG node, then it
			 becomes TWO THINGS:
			 
			 - An SVGSVGElement
			 *and*
			 - An SVGDocument
			 - ...and that becomes "the root SVGDocument"
			 
			 If it's NOT the first XML node, but it's the first SVG node, then it ONLY becomes:
			 
			 - An SVGSVGElement
			 
			 If it's NOT the first SVG node, then it becomes:
			 
			 - An SVGSVGElement
			 *and*
			 - An SVGDocument
			 
			 Yes. It's Very confusing! Go read the SVG Spec!
			 */
			
			BOOL generateAnSVGDocument = FALSE;
			BOOL overwriteRootSVGDocument = FALSE;
			BOOL overwriteRootOfTree = FALSE;
			
			if( parentNode == nil )
			{
				/** This start element is the first item in the document
				 PS: xcode has a new bug for Lion: it can't format single-line comments with two asterisks. This line added because Xcode sucks.
				 */
				generateAnSVGDocument = overwriteRootSVGDocument = overwriteRootOfTree = TRUE;
				
			}
			else if( parseResult.rootOfSVGTree == nil )
			{
				/** It's not the first XML, but it's the first SVG node */
				overwriteRootOfTree = TRUE;
			}
			else
			{
				/** It's not the first SVG node */
				// ... so: do nothing special
			}
			
			/**
			 Handle the complex stuff above about SVGDocument and SVG node
			 */
			if( overwriteRootOfTree )
			{
				parseResult.rootOfSVGTree = (SVGSVGElement*) element;
				
				/** Post-processing of the ROOT SVG ONLY (doesn't apply to embedded SVG's )
				 */
				if ((svgVersion = attributes[@"version"])) {
					SVGKSource.svgLanguageVersion = svgVersion;
				}
			}
			if( generateAnSVGDocument )
			{
				NSAssert( [element isKindOfClass:[SVGSVGElement class]], @"Trying to create a new internal SVGDocument from a Node that is NOT of type SVGSVGElement (tag: svg). Node was of type: %@", NSStringFromClass([element class]));
				
				SVGDocument* newDocument = [[SVGDocument alloc] init];
				newDocument.rootElement = (SVGSVGElement*) element;
				
				if( overwriteRootSVGDocument )
				{
					parseResult.parsedDocument = newDocument;
				}
				else
				{
					NSAssert( FALSE, @"Currently not supported: multiple SVG Document nodes in a single SVG file" );
				}
				[newDocument release];
			}
			
		}
		
		
		return [element autorelease];
	}
	
	return nil;
}

-(void)handleEndElement:(Node *)newNode document:(SVGKSource *)document parseResult:(SVGKParseResult *)parseResult
{
	
}

@end
