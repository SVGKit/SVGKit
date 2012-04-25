//
//  SVGParser.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

/*! RECOMMENDED: leave this set to 1 to get warnings about "legal, but poorly written" SVG */
#define PARSER_WARN_FOR_ANONYMOUS_SVG_G_TAGS 1

/*! Verbose parser logging - ONLY needed if you have an SVG file that's failing to load / crashing */
#define DEBUG_VERBOSE_LOG_EVERY_TAG 0

@class SVGDocument;

@protocol SVGParserExtension <NSObject>

/*! Array of URI's as NSString's, one string for each XMLnamespace that this parser-extension can parse
 *
 * e.g. the main parser returns "[NSArray arrayWithObjects:@"http://www.w3.org/2000/svg", nil];"
 */
-(NSArray*) supportedNamespaces;

/*! Array of NSString's, one string for each XML tag (within a supported namespace!) that this parser-extension can parse
 *
 * e.g. the main parser returns "[NSArray arrayWithObjects:@"svg", @"title", @"defs", @"path", @"line", @"circle", ...etc... , nil];"
 */
-(NSArray*) supportedTags;

- (NSObject*)handleStartElement:(NSString *)name document:(SVGDocument*) document xmlns:(NSString*) namespaceURI attributes:(NSMutableDictionary *)attributes;
-(void) addChildObject:(NSObject*)child toObject:(NSObject*)parent inDocument:(SVGDocument*) svgDocument;
-(void) parseContent:(NSMutableString*) content forItem:(NSObject*) item;
-(BOOL) createdItemShouldStoreContent:(NSObject*) item;

@end

@interface SVGParser : NSObject {
  @private
	NSString *_path;
	BOOL _failed;
	BOOL _storingChars;
	NSMutableString *_storedChars;
	NSMutableArray *_elementStack;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	SVGDocument *_document;
#else
	__weak SVGDocument *_document;
#endif
	NSError* errorForCurrentParse;
}

@property(nonatomic,retain) NSURL* sourceURL;

@property(nonatomic,retain) NSMutableArray* parserExtensions;

@property(nonatomic, retain) NSMutableArray* parseWarnings;

- (id)initWithPath:(NSString *)aPath document:(SVGDocument *)document;
- (id) initWithURL:(NSURL*)aURL document:(SVGDocument *)document;

- (BOOL)parse:(NSError **)outError;

+(NSDictionary *) NSDictionaryFromCSSAttributes: (NSString *)css;

@end
