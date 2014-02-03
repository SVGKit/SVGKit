#import "SVGKParseResult.h"

@implementation SVGKParseResult

@synthesize libXMLFailed;
@synthesize parsedDocument, rootOfSVGTree, namespacesEncountered;
@synthesize warnings, errorsRecoverable, errorsFatal;

#if ENABLE_PARSER_EXTENSIONS_CUSTOM_DATA
@synthesize extensionsData;
#endif

-(void)dealloc {
    self.warnings = nil;
    self.errorsRecoverable = nil;
    self.errorsFatal = nil;
    self.namespacesEncountered = nil;
    self.parsedDocument = nil;
    self.rootOfSVGTree = nil;
    
    [super DEALLOC];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.warnings = [NSMutableArray array];
		self.errorsRecoverable = [NSMutableArray array];
		self.errorsFatal = [NSMutableArray array];
		
		self.namespacesEncountered = [NSMutableDictionary dictionary];
		
		#if ENABLE_PARSER_EXTENSIONS_CUSTOM_DATA
		self.extensionsData = [NSMutableDictionary dictionary];
#endif
    }
    return self;
}
-(void) addSourceError:(NSError*) fatalError
{
	DDLogError(@"[%@] SVG ERROR: %@", [self class], fatalError);
	[self.errorsRecoverable addObject:fatalError];
}

-(void) addParseWarning:(NSError*) warning
{
	DDLogWarn(@"[%@] SVG WARNING: %@", [self class], warning);
	[self.warnings addObject:warning];
}

-(void) addParseErrorRecoverable:(NSError*) recoverableError
{
	DDLogWarn(@"[%@] SVG WARNING (recoverable): %@", [self class], recoverableError);
	[self.errorsRecoverable addObject:recoverableError];
}

-(void) addParseErrorFatal:(NSError*) fatalError
{
	DDLogError(@"[%@] SVG ERROR: %@", [self class], fatalError);
	[self.errorsFatal addObject:fatalError];
}

-(void) addSAXError:(NSError*) saxError
{
	DDLogWarn(@"[%@] SVG ERROR: %@", [self class], [saxError localizedDescription]);
	[self.errorsFatal addObject:saxError];
}

#if ENABLE_PARSER_EXTENSIONS_CUSTOM_DATA
-(NSMutableDictionary*) dictionaryForParserExtension:(NSObject<SVGKParserExtension>*) extension
{
	NSMutableDictionary* d = [self.extensionsData objectForKey:[extension class]];
	if( d == nil )
	{
		d = [NSMutableDictionary dictionary];
		[self.extensionsData setObject:d forKey:[extension class]];
	}
	
	return d;
}
#endif

@end
