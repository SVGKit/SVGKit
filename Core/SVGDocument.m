//
//  SVGDocument.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGDocument.h"

#import "SVGDefsElement.h"
#import "SVGDescriptionElement.h"
#import "SVGElement+Private.h"
#import "SVGParser.h"
#import "SVGTitleElement.h"
#import "SVGPathElement.h"

#import "SVGParserSVG.h"

@interface SVGDocument ()

@property (nonatomic, copy) NSString *version;

/*! Only preserved for temporary backwards compatibility */
- (BOOL)parseFileAtPath:(NSString *)aPath;
/*! Only preserved for temporary backwards compatibility */
-(BOOL)parseFileAtURL:(NSURL *)url;

- (BOOL)parseFileAtPath:(NSString *)aPath error:(NSError**) error;
- (BOOL)parseFileAtURL:(NSURL *)url error:(NSError**) error;

- (SVGElement *)findFirstElementOfClass:(Class)class;

@end


@implementation SVGDocument

@synthesize width = _width;
@synthesize height = _height;
@synthesize version = _version;
@synthesize viewBoxFrame = _viewBoxFrame;

@synthesize graphicsGroups, anonymousGraphicsGroups;

@dynamic title, desc, defs;

static NSMutableArray* _parserExtensions;
+ (void) addSVGParserExtension:(NSObject<SVGParserExtension>*) extension
{
	if( _parserExtensions == nil )
	{
		_parserExtensions = [NSMutableArray new];
	}
	
	[_parserExtensions addObject:extension];
}

/* TODO: parse 'viewBox' */

+ (id)documentNamed:(NSString *)name {
	NSParameterAssert(name != nil);
	
	NSBundle *bundle = [NSBundle mainBundle];
	
	if (!bundle)
		return nil;
	
	NSString *newName = [name stringByDeletingPathExtension];
	NSString *extension = [name pathExtension];
    if ([@"" isEqualToString:extension]) {
        extension = @"svg";
    }
	
	NSString *path = [bundle pathForResource:newName ofType:extension];
	
	if (!path)
	{
		NSLog(@"[%@] MISSING FILE, COULD NOT CREATE DOCUMENT: filename = %@, extension = %@", [self class], newName, extension);
		return nil;
	}
	
	return [self documentWithContentsOfFile:path];
}

+ (id)documentFromURL:(NSURL *)url {
	NSParameterAssert(url != nil);
	
	return [[[[self class] alloc] initWithContentsOfURL:url] autorelease];
}

+ (id)documentWithContentsOfFile:(NSString *)aPath {
	return [[[[self class] alloc] initWithContentsOfFile:aPath] autorelease];
}

- (id)initWithContentsOfFile:(NSString *)aPath {
	NSParameterAssert(aPath != nil);
	
	self = [super initWithDocument:self name:@"svg"];
	if (self) {
		_width = _height = 100;
		
		NSError* parseError = nil;
		if (![self parseFileAtPath:aPath error:&parseError]) {
			NSLog(@"[%@] MISSING OR CORRUPT FILE, OR FILE USES FEATURES THAT SVGKit DOES NOT YET SUPPORT, COULD NOT CREATE DOCUMENT: path = %@, error = %@", [self class], aPath, parseError);
			
			[self release];
			return nil;
		}
	}
	return self;
}

- (id)initWithContentsOfURL:(NSURL *)url {
	NSParameterAssert(url != nil);
	
	self = [super initWithDocument:self name:@"svg"];
	if (self) {
		_width = _height = 100;
		
		if (![self parseFileAtURL:url]) {
			NSLog(@"[%@] ERROR: COULD NOT FIND SVG AT URL = %@", [self class], url);
			
			[self release];
			return nil;
		}
	}
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithDocument:self name:@"svg"];
	if (self) {
        _width = CGRectGetWidth(frame);
        _height = CGRectGetHeight(frame);
    }
	return self;
}

- (void)dealloc {
	[_version release];
    self.graphicsGroups = nil;
    self.anonymousGraphicsGroups = nil;
	[super dealloc];
}

- (BOOL)parseFileAtPath:(NSString *)aPath error:(NSError**) error {
	SVGParser *parser = [[SVGParser alloc] initWithPath:aPath document:self];
	SVGParserSVG *subParserSVG = [[[SVGParserSVG alloc] init] autorelease];
	[parser.parserExtensions addObject:subParserSVG];
	for( NSObject<SVGParserExtension>* extension in _parserExtensions )
	{
		[parser.parserExtensions addObject:extension];
	}
	
	if (![parser parse:error]) {
		NSLog(@"[%@] SVGKit Parse error: %@", [self class], *error);
		[parser release];
		
		return NO;
	}
	
	[parser release];
	
	return YES;
}

- (BOOL)parseFileAtPath:(NSString *)aPath {
	return [self parseFileAtPath:aPath error:nil];
}


-(BOOL)parseFileAtURL:(NSURL *)url error:(NSError**) error {
	SVGParser *parser = [[SVGParser alloc] initWithURL:url document:self];
	SVGParserSVG *subParserSVG = [[[SVGParserSVG alloc] init] autorelease];
	[parser.parserExtensions addObject:subParserSVG];
	for( NSObject<SVGParserExtension>* extension in _parserExtensions )
	{
		[parser.parserExtensions addObject:extension];
	}
	
	if (![parser parse:error]) {
		NSLog(@"[%@] SVGKit Parse error: %@", [self class], *error);
		[parser release];
		
		return NO;
	}
	
	[parser release];
	
	return YES;
}

-(BOOL)parseFileAtURL:(NSURL *)url {
	return [self parseFileAtURL:url error:nil];
}

- (CALayer *)newLayer {
	
	CALayer* _layer = [CALayer layer];
		_layer.frame = CGRectMake(0.0f, 0.0f, _width, _height);
	
	return _layer;
}

- (void)layoutLayer:(CALayer *)layer { }

- (SVGElement *)findFirstElementOfClass:(Class)class {
	for (SVGElement *element in self.children) {
		if ([element isKindOfClass:class])
			return element;
	}
	
	return nil;
}

- (NSString *)title {
	return [self findFirstElementOfClass:[SVGTitleElement class]].stringValue;
}

- (NSString *)desc {
	return [self findFirstElementOfClass:[SVGDescriptionElement class]].stringValue;
}

- (SVGDefsElement *)defs {
	return (SVGDefsElement *) [self findFirstElementOfClass:[SVGDefsElement class]];
}

- (void)parseAttributes:(NSDictionary *)attributes {
	[super parseAttributes:attributes];
	
	id value = nil;
	
	if ((value = [attributes objectForKey:@"width"])) {
		_width = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"height"])) {
		_height = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"version"])) {
		self.version = value;
	}
	
	if( (value = [attributes objectForKey:@"viewBox"])) {
		NSArray* boxElements = [(NSString*) value componentsSeparatedByString:@" "];
		
		_viewBoxFrame = CGRectMake([[boxElements objectAtIndex:0] floatValue], [[boxElements objectAtIndex:1] floatValue], [[boxElements objectAtIndex:2] floatValue], [[boxElements objectAtIndex:3] floatValue]);
		NSLog(@"[%@] DEBUG INFO: set document viewBox = %@", [self class], NSStringFromCGRect(self.viewBoxFrame));
	}
}

#if NS_BLOCKS_AVAILABLE

- (void) applyAggregator:(SVGElementAggregationBlock)aggregator toElement:(SVGElement < SVGLayeredElement > *)element
{
	if (![element.children count]) {
		return;
	}
	
	for (SVGElement *child in element.children) {
		if ([child conformsToProtocol:@protocol(SVGLayeredElement)]) {
			SVGElement<SVGLayeredElement>* layeredElement = (SVGElement<SVGLayeredElement>*)child;
            if (layeredElement) {
                aggregator(layeredElement);
                
                [self applyAggregator:aggregator
                            toElement:layeredElement];
            }
		}
	}
}

- (void) applyAggregator:(SVGElementAggregationBlock)aggregator
{
    [self applyAggregator:aggregator toElement:self];
}

#endif

@end
