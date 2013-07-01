/**
 Reports detailed information from an attempted run of the SVG Parser
 */
#import <Foundation/Foundation.h>

@class SVGSVGElement, SVGDocument;
#import <SVGKit/SVGSVGElement.h>
#import <SVGKit/SVGDocument.h>

@protocol SVGKParserExtension;
#import <SVGKit/SVGKParserExtension.h>

@interface SVGKParseResult : NSObject

@property(nonatomic, retain) NSMutableArray* warnings, * errorsRecoverable, * errorsFatal;
@property(nonatomic) BOOL libXMLFailed;

@property(nonatomic,retain) SVGSVGElement* rootOfSVGTree; /*< both are needed, see spec */
@property(nonatomic,retain) SVGDocument* parsedDocument; /*< both are needed, see spec */

@property(nonatomic,retain) NSMutableDictionary* namespacesEncountered; /**< maps "prefix" to "uri" */

-(void) addSourceError:(NSError*) fatalError;
-(void) addParseWarning:(NSError*) warning;
-(void) addParseErrorRecoverable:(NSError*) recoverableError;
-(void) addParseErrorFatal:(NSError*) fatalError;
-(void) addSAXError:(NSError*) saxError;

#if ENABLE_PARSER_EXTENSIONS_CUSTOM_DATA
/*! Each SVGKParserExtension can optionally save extra data here */
@property(nonatomic,retain) NSMutableDictionary* extensionsData;

-(NSMutableDictionary*) dictionaryForParserExtension:(NSObject<SVGKParserExtension>*) extension;
#endif

@end
