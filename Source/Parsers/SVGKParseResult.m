#import <SVGKit/SVGKParseResult.h>

@implementation SVGKParseResult

@synthesize libXMLFailed;
@synthesize parsedDocument, rootOfSVGTree, namespacesEncountered;
@synthesize warnings, errorsRecoverable, errorsFatal;

#if ENABLE_PARSER_EXTENSIONS_CUSTOM_DATA
@synthesize extensionsData;
#endif

- (id)init
{
    self = [super init];
    if (self) {
        self.warnings = [[NSMutableArray alloc] init];
		self.errorsRecoverable = [[NSMutableArray alloc] init];
		self.errorsFatal = [[NSMutableArray alloc] init];
		
		self.namespacesEncountered = [[NSMutableDictionary alloc] init];
		
#if ENABLE_PARSER_EXTENSIONS_CUSTOM_DATA
		self.extensionsData = [[NSMutableDictionary alloc] init];
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
	DDLogError(@"[%@] SVG ERROR: %@", [self class], [saxError localizedDescription]);
	[self.errorsFatal addObject:saxError];
}

#if ENABLE_PARSER_EXTENSIONS_CUSTOM_DATA
-(NSMutableDictionary*) dictionaryForParserExtension:(NSObject<SVGKParserExtension>*) extension
{
	NSMutableDictionary* d = [self.extensionsData objectForKey:[extension class]];
	if( d == nil )
	{
		d = [[NSMutableDictionary alloc] init];
		[self.extensionsData setObject:d forKey:[extension class]];
	}
	
	return d;
}
#endif

@end
