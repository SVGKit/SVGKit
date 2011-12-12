//
//  SVGParser.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGParser.h"

#import <libxml/parser.h>

#import "SVGCircleElement.h"
#import "SVGDefsElement.h"
#import "SVGDescriptionElement.h"
#import "SVGDocument.h"
#import "SVGElement+Private.h"
#import "SVGEllipseElement.h"
#import "SVGGroupElement.h"
#import "SVGImageElement.h"
#import "SVGLineElement.h"
#import "SVGPathElement.h"
#import "SVGPolygonElement.h"
#import "SVGPolylineElement.h"
#import "SVGRectElement.h"
#import "SVGTitleElement.h"
#import "SVGTextElement.h"

@implementation SVGParser

static xmlSAXHandler SAXHandler;

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void	charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

static NSString *NSStringFromLibxmlString (const xmlChar *string);
static NSMutableDictionary *NSDictionaryFromLibxmlAttributes (const xmlChar **attrs, int attr_ct);
static NSDictionary *NSDictionaryFromCSSAttributes (NSString *css);

#define READ_CHUNK_SZ 1024*10

static NSDictionary *elementMap;

- (id)initWithPath:(NSString *)aPath document:(SVGDocument *)document {
	self = [super init];
	if (self) {
		_path = [aPath copy];
		_document = document;
		_storedChars = [[NSMutableString alloc] init];
		_elementStack = [[NSMutableArray alloc] init];
		_failed = NO;
		_graphicsGroups = [[NSMutableDictionary dictionary] retain];
		
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
						   [SVGTextElement class], @"text",
						   [SVGTitleElement class], @"title", nil] retain];
		}
	}
	return self;
}

- (void)dealloc {
	[_path release];
	[_storedChars release];
	[_elementStack release];
	[_graphicsGroups release];
	
	[super dealloc];
}

- (BOOL)parse:(NSError **)outError {
	const char *cPath = [_path fileSystemRepresentation];
	FILE *file = fopen(cPath, "r");
	
	if (!file)
		return NO;
	
	xmlParserCtxtPtr ctx = xmlCreatePushParserCtxt(&SAXHandler, self, NULL, 0, NULL);
	
	if (!ctx) {
		fclose(file);
		return NO;
	}
	
	size_t read = 0;
	char buff[READ_CHUNK_SZ];
	
	while ((read = fread(buff, 1, READ_CHUNK_SZ, file)) > 0) {
		if (xmlParseChunk(ctx, buff, read, 0) != 0) {
			_failed = YES;
			NSLog(@"An error occured while parsing the current XML chunk");
			
			break;
		}
	}
	
	fclose(file);
	
	if (!_failed)
		xmlParseChunk(ctx, NULL, 0, 1); // EOF
	
	xmlFreeParserCtxt(ctx);
	
	return !_failed;
}

- (void)handleStartElement:(NSString *)name attributes:(NSMutableDictionary *)attributes {
	// handle SVG separately
	if ([name isEqualToString:@"svg"]) {
		[_elementStack addObject:_document];
		[_document parseAttributes:attributes];
		
		return;
	}
	
	Class elementClass = [elementMap objectForKey:name];
	
	if (!elementClass) {
		elementClass = [SVGElement class];
		NSLog(@"Support for '%@' element has not been implemented", name);
	}
	
	id style = nil;
	
	if ((style = [attributes objectForKey:@"style"])) {
		[attributes removeObjectForKey:@"style"];
		[attributes addEntriesFromDictionary:NSDictionaryFromCSSAttributes(style)];
	}
	
	SVGElement *element = [[elementClass alloc] initWithDocument:_document name:name];
	[element parseAttributes:attributes];
	
    if( [element.localName isEqualToString:@"g"] && nil == element.identifier ) {
        element.identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    
	[_elementStack addObject:element];
	[element release];
	
	if ([elementClass shouldStoreContent]) {
		[_storedChars setString:@""];
		_storingChars = YES;
	}
	else {
		_storingChars = NO;
	}
}

static void startElementSAX (void *ctx, const xmlChar *localname, const xmlChar *prefix,
							 const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces,
							 int nb_attributes, int nb_defaulted, const xmlChar **attributes) {
	
	SVGParser *self = (SVGParser *) ctx;
	
	NSString *name = NSStringFromLibxmlString(localname);
	NSMutableDictionary *attrs = NSDictionaryFromLibxmlAttributes(attributes, nb_attributes);
	
	[self handleStartElement:name attributes:attrs];
}

- (void)handleEndElement:(NSString *)name {
	
	if ([name isEqualToString:@"svg"]) {
		[_elementStack removeObject:_document];
		
		/*! Add the dictionary of named "g" tags to the document, so applications can retrieve "named groups" from the SVG */
		[_document setGraphicsGroups:_graphicsGroups];
		return;
	}
	
	SVGElement *element = [[_elementStack lastObject] retain];
	
	if (![element.localName isEqualToString:name]) {
		NSLog(@"XML tag mismatch (%@, %@)", element.localName, name);
		
		[element release];
		_failed = YES;
		
		return;
	}
	
	[_elementStack removeLastObject];
	
	/*!
	 SVG Spec attaches special meaning to the "g" tag - and applications
	 need to be able to pull-out the "g"-tagged items later on
	 */
	if( [element.localName isEqualToString:@"g"] )
	{
		[_graphicsGroups setValue:element forKey:element.identifier];
		
		/*! ...we'll build up the dictionary, then add it to the document when the SVG tag is closed */
	}
	
	SVGElement *parent = [_elementStack lastObject];
	[parent addChild:element];
	
	[element release];
	
	if (_storingChars) {
		[element parseContent:_storedChars];
		
		[_storedChars setString:@""];
		_storingChars = NO;
	}
}

static void	endElementSAX (void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI) {
	SVGParser *self = (SVGParser *) ctx;
	[self handleEndElement:NSStringFromLibxmlString(localname)];
}

- (void)handleFoundCharacters:(const xmlChar *)chars length:(int)len {
	if (_storingChars) {
		char value[len + 1];
		strncpy(value, (const char *) chars, len);
		value[len] = '\0';
		
		[_storedChars appendString:[NSString stringWithUTF8String:value]];
	}
}

static void	charactersFoundSAX (void *ctx, const xmlChar *chars, int len) {
	SVGParser *self = (SVGParser *) ctx;
	[self handleFoundCharacters:chars length:len];
}

- (void)handleError {
	_failed = YES;
}

static void errorEncounteredSAX (void *ctx, const char *msg, ...) {
	[ (SVGParser *) ctx handleError];
	NSLog(@"Error encountered during parse: %s", msg);
}

static xmlSAXHandler SAXHandler = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    NULL,                       /* startDocument */
    NULL,                       /* endDocument */
    NULL,                       /* startElement*/
    NULL,                       /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    NULL,                       /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,
    NULL,
    startElementSAX,            /* startElementNs */
    endElementSAX,              /* endElementNs */
    NULL,                       /* serror */
};

#pragma mark -
#pragma mark Utility

static NSString *NSStringFromLibxmlString (const xmlChar *string) {
	return [NSString stringWithUTF8String:(const char *) string];
}

static NSMutableDictionary *NSDictionaryFromLibxmlAttributes (const xmlChar **attrs, int attr_ct) {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	for (int i = 0; i < attr_ct * 5; i += 5) {
		const char *begin = (const char *) attrs[i + 3];
		const char *end = (const char *) attrs[i + 4];
		int vlen = strlen(begin) - strlen(end);
		
		char val[vlen + 1];
		strncpy(val, begin, vlen);
		val[vlen] = '\0';
		
		[dict setObject:[NSString stringWithUTF8String:val]
				 forKey:NSStringFromLibxmlString(attrs[i])];
	}
	
	return [dict autorelease];
}

#define MAX_ACCUM 256
#define MAX_NAME 256

static NSDictionary *NSDictionaryFromCSSAttributes (NSString *css) {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	const char *cstr = [css UTF8String];
	size_t len = strlen(cstr);
	
	char name[MAX_NAME];
	bzero(name, MAX_NAME);
	
	char accum[MAX_ACCUM];
	bzero(accum, MAX_ACCUM);
	
	size_t accumIdx = 0;
	
	for (size_t n = 0; n <= len; n++) {
		char c = cstr[n];
		
		if (c == '\n' || c == '\t' || c == ' ') {
			continue;
		}
		
		if (c == ':') {
			strcpy(name, accum);
			name[accumIdx] = '\0';
			
			bzero(accum, MAX_ACCUM);
			accumIdx = 0;
			
			continue;
		}
		else if (c == ';' || c == '\0') {
			accum[accumIdx] = '\0';
			
			[dict setObject:[NSString stringWithUTF8String:accum]
					 forKey:[NSString stringWithUTF8String:name]];
			
			bzero(name, MAX_NAME);
			
			bzero(accum, MAX_ACCUM);
			accumIdx = 0;
			
			continue;
		}
		
		accum[accumIdx++] = c;
	}
	
	return [dict autorelease];
}

@end
