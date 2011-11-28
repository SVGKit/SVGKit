//
//  SVGParser.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

@class SVGDocument;

@protocol SVGParserExtension <NSObject>
-(BOOL) createdItemShouldStoreContent:(NSObject*) item;
- (NSObject*)handleStartElement:(NSString *)name document:(SVGDocument*) document xmlns:(NSString*) prefix attributes:(NSMutableDictionary *)attributes;
-(void) addChildObject:(NSObject*)child toObject:(NSObject*)parent;
-(void) parseContent:(NSMutableString*) content forItem:(NSObject*) item;

-(NSArray*) supportedNamespaces;
-(NSArray*) supportedTags;
@end

@interface SVGParser : NSObject {
  @private
	NSString *_path;
	BOOL _failed;
	BOOL _storingChars;
	NSMutableString *_storedChars;
	NSMutableArray *_elementStack;
	__weak SVGDocument *_document;
}

@property(nonatomic,retain) NSMutableArray* parserExtensions;

- (id)initWithPath:(NSString *)aPath document:(SVGDocument *)document;

- (BOOL)parse:(NSError **)outError;

+(NSDictionary *) NSDictionaryFromCSSAttributes: (NSString *)css;

@end
