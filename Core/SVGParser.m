//
//  SVGParser.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGParser.h"

//#import "libxml/parser.h"
#import <libxml/parser.h>


#import "SVGDocument.h"

@interface SVGParserStackItem : NSObject
@property(nonatomic,retain) NSObject<SVGParserExtension>* parserForThisItem;
@property(nonatomic,retain) NSObject* item;

@end

@implementation SVGParserStackItem
@synthesize item;
@synthesize parserForThisItem;

- (void) dealloc 
{
    self.item = nil;
    self.parserForThisItem = nil;
    [super dealloc];
}

@end

@implementation SVGParser

static BOOL inUse = NO;

@synthesize parserExtensions = _parserExtensions;

static xmlSAXHandler SAXHandler;
//static xmlParserCtxtPtr sharedCtx; //libxml2.2 is not thread safe anyways, will see if this stems the memory leaks <= too unstable, fixed memory leaks by clearing parser context after completion

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void	charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

static NSString *NSStringFromLibxmlString (const xmlChar *string);
static NSMutableDictionary *NSDictionaryCreateFromLibxmlAttributes (const xmlChar **attrs, int attr_ct);

#define READ_CHUNK_SZ 1024*10

//+(void)initialize
//{
//    sharedCtx = xmlCreatePushParserCtxt(&SAXHandler, [self sharedParser], NULL, 0, NULL);
//}

-(SVGParser *)init
{
    return [self initWithPath:nil document:nil];
}

static SVGParser * _sharedParser = nil;
static NSMutableSet *_parserExtensions = nil;
+(SVGParser *)sharedParser
{
    if( _sharedParser == nil ) 
    {
        _sharedParser = [[SVGParser alloc] init];
        if( _parserExtensions != nil )
            [_sharedParser setParserExtensions:[_parserExtensions allObjects]];
    }
    return _sharedParser;
}

+(void)addSharedParserExtensions:(NSSet *)extensions
{
    if( _parserExtensions == nil ) 
        _parserExtensions = [[NSMutableSet alloc] initWithSet:extensions];
    else if( ![extensions isSubsetOfSet:_parserExtensions] )
        [_parserExtensions intersectSet:extensions];
    
    if( _sharedParser != nil )
        [_sharedParser setParserExtensions:[_parserExtensions allObjects]];
}

- (id)initWithPath:(NSString *)aPath document:(SVGDocument *)document {
	self = [super init];
	if (self) {
		_parserExtensions = [NSMutableArray new];
		_path = [aPath copy];
		_document = document;
		_storedChars = [NSMutableString new];
		_elementStack = [NSMutableArray new];
		_failed = NO;
		
	}
	return self;
}

- (void)dealloc {
	[_path release];
	[_storedChars release];
	[_elementStack release];
    _document = nil;
	[_parserExtensions release];
	[super dealloc];
}

- (BOOL)parseFileAtPath:(NSString *)filePath toDocument:(SVGDocument *)destinationDocument
{
    _path = [filePath copy];
    _document = [destinationDocument retain];
    
    NSError *error = nil;
    [self parse:&error];
    
    BOOL didFail = _failed;
    
    [_storedChars setString:@""];
    [_elementStack removeAllObjects];
    _failed = NO;
    
    [_path release], _path = nil;
    [_document release], _document = nil;
    
    return didFail || (error != nil);
}

- (BOOL)parse:(NSError **)outError {
//    if( sharedCtx == nil ) {
//        NSLog(@"[%@] - %s failed: No context found", [self class], (char *)_cmd);
//        return NO;
//    }
    
	const char *cPath = [_path fileSystemRepresentation];
	FILE *file = fopen(cPath, "r");
	
	if (!file)
		return NO;
	
	inUse = YES;
	xmlParserCtxtPtr sharedCtx = xmlCreatePushParserCtxt(&SAXHandler, self, NULL, 0, NULL);
	if (!sharedCtx) {
		fclose(file);
        NSLog(@"[%@] - %s File not found!", [self class], cPath);
		return NO;
	}
	
	size_t read = 0;
	char buff[READ_CHUNK_SZ];
	
	while ((read = fread(buff, 1, READ_CHUNK_SZ, file)) > 0) {
		if (xmlParseChunk(sharedCtx, buff, read, 0) != 0) {
			_failed = YES;
			NSLog(@"An error occured while parsing the current XML chunk");
			
			break;
		}
	}
	
	fclose(file);
	
	if (!_failed)
		xmlParseChunk(sharedCtx, NULL, 0, 1); // EOF
	
    xmlClearParserCtxt(sharedCtx); //should make this eligible for reuse, can pool if we want multithreading (need libxml2.4 or later)
	xmlFreeParserCtxt(sharedCtx);
    inUse = NO;
	
	return !_failed;
}

- (void)handleStartElement:(NSString *)name xmlns:(NSString*) prefix attributes:(NSMutableDictionary *)attributes {
	
		for( NSObject<SVGParserExtension>* subParser in self.parserExtensions )
		{
			if( [[subParser supportedTags] containsObject:name]
			&& [[subParser supportedNamespaces] containsObject:prefix] )
			{
				NSObject* subParserResult = nil;
				
                if( nil != (subParserResult = [subParser handleStartElement:name document:_document xmlns:prefix attributes:attributes]) )
                {
#ifdef SVGPARSER_NOTIFY_SUBPARSER_HANDOFF
                    NSLog(@"[%@] tag: <%@:%@> -- handled by subParser: %@", [self class], prefix, name, subParser );
#endif
				
                    SVGParserStackItem* stackItem = [[SVGParserStackItem alloc] init];
                    stackItem.parserForThisItem = subParser;
                    stackItem.item = subParserResult;
                    
                    [_elementStack addObject:stackItem];
                    [stackItem release];
                    
                    if ([subParser createdItemShouldStoreContent:stackItem.item]) {
                        [_storedChars setString:@""];
                        _storingChars = YES;
                    }
                    else {
                        _storingChars = NO;
                    }
                    return;
                }
				
			}
		}
	
#ifdef SVG_PARSER_ERROR_UNPARSED_TAG
	NSLog(@"[%@] ERROR: could not find a parser for tag: <%@:%@>; adding empty placeholder", [self class], prefix, name );
#endif
	
	SVGParserStackItem* emptyItem = [[SVGParserStackItem alloc] init];
	[_elementStack addObject:emptyItem];
    [emptyItem release];
}


static void startElementSAX (void *ctx, const xmlChar *localname, const xmlChar *prefix,
							 const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces,
							 int nb_attributes, int nb_defaulted, const xmlChar **attributes) {
	SVGParser *self = (SVGParser *) ctx;
	
	NSString *name = [[NSString alloc] initWithUTF8String:(const char *)localname];//NSStringFromLibxmlString(localname);
	NSMutableDictionary *attrs = NSDictionaryCreateFromLibxmlAttributes(attributes, nb_attributes);
	
	//NSString *url = NSStringFromLibxmlString(URI);
    
    /* unused currently
	NSString *prefix2 = nil;
	if( prefix != NULL )
		prefix2 = NSStringFromLibxmlString(prefix);
	*/
     
     
	NSString *objcURIString = nil;
	if( URI != NULL )
		objcURIString = [[NSString alloc] initWithUTF8String:(const char *)URI];// NSStringFromLibxmlString(URI);
	
#if DEBUG_VERBOSE_LOG_EVERY_TAG
	NSLog(@"[%@] DEBUG_VERBOSE: <%@%@> (namespace URL:%@), attributes: %i", [self class], (prefix2==nil)?@"":[NSString stringWithFormat:@"%@:",prefix2], name, (URI==NULL)?@"n/a":objcURIString, nb_attributes );
    
	if( prefix2 == nil )
	{
		/* The XML library allows this, although it's very unhelpful when writing application code */
		
		/* Let's find out what namespaces DO exist... */
		
		/*
		 
		 TODO / DEVELOPER WARNING: the library says nb_namespaces is the number of elements in the array,
		 but it keeps returning nil pointer (not always, but often). WTF? Not sure what we're doing wrong
		 here, but commenting it out for now...
		 
		if( nb_namespaces > 0 )
		{
			for( int i=0; i<nb_namespaces; i++ )
			{
				NSLog(@"[%@] DEBUG: found namespace [%i] : %@", [self class], i, namespaces[i] );
			}
		}
		else
			NSLog(@"[%@] DEBUG: there are ZERO namespaces!", [self class] );
		 */
	}
#endif
	
	[self handleStartElement:name xmlns:objcURIString attributes:attrs];
    [attrs release];
    [name release];
    if( objcURIString != nil )
        [objcURIString release];
}

- (void)handleEndElement:(NSString *)name {
	//DELETE DEBUG NSLog(@"ending element, name = %@", name);
	
	SVGParserStackItem* stackItem = [[_elementStack lastObject] retain];
	
	[_elementStack removeLastObject];
	
	if( stackItem.parserForThisItem == nil )
	{
		/*! this was an unmatched tag - we have no parser for it, so we're pruning it from the tree */
#ifdef SVGPARSER_WARN_NONPARSED_TAG
		NSLog(@"[%@] WARN: ended non-parsed tag (</%@>) - this will NOT be added to the output tree", [self class], name );
#endif
	}
	else
	{
		SVGParserStackItem* parentStackItem = [_elementStack lastObject];
		
		NSObject<SVGParserExtension>* parserHandlingTheParentItem = parentStackItem.parserForThisItem;

		if( parentStackItem.item == nil )
		{
			/**
			 Special case: we've hit the closing of the root tag.
			 
			 Because each parser-extension MIGHT need to do cleanup / post-processing on the end tag,
			 we need to ensure that whichever class parsed the root tag gets one final callback to tell it that the end
			 tag has been reached
			 */
			
			parserHandlingTheParentItem = stackItem.parserForThisItem;
		}
		
#ifdef SVGPARSER_NOTIFY_END_TAG
		NSLog(@"[%@] DEBUG-PARSER: ended tag (</%@>): telling parser (%@) to add that item to tree-parent = %@", [self class], name, parserHandlingTheParentItem, parentStackItem.item );
#endif
		[parserHandlingTheParentItem addChildObject:stackItem.item toObject:parentStackItem.item inDocument:_document];
		
		if ( [stackItem.parserForThisItem createdItemShouldStoreContent:stackItem.item]) {
			[stackItem.parserForThisItem parseContent:_storedChars forItem:stackItem.item];
			
			[_storedChars setString:@""];
			_storingChars = NO;
		}
	}
    
    [stackItem release];
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

- (void)addStylesToDocument:(NSDictionary *)theStyleKeyedById
{
    
    for( NSString *idName in [theStyleKeyedById keyEnumerator] )
    {
        [_document setStyle:[theStyleKeyedById objectForKey:idName] forClassName:idName]; 
    }
}

static void errorEncounteredSAX (void *ctx, const char *msg, ...) 
{
	[ (SVGParser *) ctx handleError];
	NSLog(@"Error encountered during parse: %s", msg);
}


static void handleCdataBlockSAX(void *ctx, const xmlChar *value, int len) 
{
    
    NSString *cssString = [[NSString alloc] initWithUTF8String:(const char *)value];//[NSStringFromLibxmlString(value) substringToIndex:len];
    //    NSLog(@"Cdata block: %@", cssString);
    
    [(SVGParser *) ctx addStylesToDocument:[SVGParser NSDictionaryFromCDataCSSStyles:[cssString substringToIndex:len]]];
    [cssString release];
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
    handleCdataBlockSAX,                       /* cdataBlock */
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

static NSMutableDictionary *NSDictionaryCreateFromLibxmlAttributes (const xmlChar **attrs, int attr_ct) {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//	NSString *keyString = nil; //less peak memory than multiple auto-released strings, since key is copied
    
    NSUInteger limit = attr_ct * 5;
	for (int i = 0; i < limit/*attr_ct * 5*/; i += 5) {
		const char *begin = (const char *) attrs[i + 3];
		const char *end = (const char *) attrs[i + 4];
		int vlen = strlen(begin) - strlen(end);
		
		char val[vlen + 1];
		strncpy(val, begin, vlen);
		val[vlen] = '\0';
		
//        keyString = [[NSString alloc] initWithUTF8String:(const char*)attrs[i]];
		[dict setObject:[NSString stringWithUTF8String:val]
				 forKey:[NSString stringWithUTF8String:(const char*)attrs[i]]];
        
//        [keyString release];
	}
	
	return dict;
}

#define MAX_ACCUM 256
#define MAX_NAME 256

+(NSDictionary *) NSDictionaryFromCSSAttributes: (NSString *)css {
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
            if( accumIdx > 0 ) //if there is a ';' and '\0' to end the style, avoid adding an empty key-value pair
            {
                accum[accumIdx] = '\0';
                
                NSString *keyString = [[NSString alloc] initWithUTF8String:name]; //key is copied anyways, autoreleased object creates clutter
                [dict setObject:[NSString stringWithUTF8String:accum]
                         forKey:keyString];
                [keyString release];
                
                bzero(name, MAX_NAME);
                
                bzero(accum, MAX_ACCUM);
                accumIdx = 0;
            }
			
			continue;
		}
		
		accum[accumIdx++] = c;
	}
	
	return [dict autorelease];
}

+(NSDictionary *) NSDictionaryFromCDataCSSStyles: (NSString *)cdataBlock //probably should be almost entirely c, blocking gradient implementation, disconnect cdataSAX
{
    NSMutableDictionary *returnSet = [NSMutableDictionary new];
    
    
    NSArray *stringSplitContainer;
    NSString *className, *styleContent;
    
//    NSDictionary *classStyle;
    
    @autoreleasepool { //creating lots of autoreleased strings, not helpful for older devices
        
        NSArray *classNameAndStyleStrings = [cdataBlock componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"}"]];
        
        NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        for( NSString *idStyleString in classNameAndStyleStrings )
        {
            if( [idStyleString length] > 1 ) //not necessary unless using shitty svgs
            {
                idStyleString = [idStyleString stringByTrimmingCharactersInSet:whitespaceSet];
                
                //             NSLog(@"A substringie %@", idStyleString);
                
                stringSplitContainer = [idStyleString componentsSeparatedByString:@"{"];
                if( [stringSplitContainer count] >= 2 ) //not necessary unless using shitty svgs
                {
                    className = [[stringSplitContainer objectAtIndex:0] substringFromIndex:1];
                    styleContent = [stringSplitContainer objectAtIndex:1];
                    
                    //                classStyle = [SVGParser NSDictionaryFromCSSAttributes:styleContent];
                    //                 NSLog(@"Class Style:\n%@", classStyle);
                    [returnSet setObject:[SVGParser NSDictionaryFromCSSAttributes:styleContent] forKey:className];
                }
            }
            
        }
    }
    
    
    return [returnSet autorelease];
}

+(void)trim
{
    //for clearing statically allocated memory, not currently implemented (obviously)
    [_sharedParser release];
    _sharedParser = nil;
    
    if( !inUse )
        xmlCleanupParser();
}

@end
