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
#import "SVGParserGradient.h"
#import "SVGParserStyles.h"
#import "SVGTitleElement.h"
#import "SVGPathElement.h"

#import "SVGParserSVG.h"

#import <objc/runtime.h>

#define documentCacheKey "documentCacheKey"

@interface SVGDocument ()

@property (nonatomic, copy) NSString *version;

/*! Only preserved for temporary backwards compatibility */
- (BOOL)parseFileAtPath:(NSString *)aPath;
/*! Only preserved for temporary backwards compatibility */
-(BOOL)parseFileAtURL:(NSURL *)url;

- (BOOL)parseFileAtPath:(NSString *)aPath error:(NSError**) error;
- (BOOL)parseFileAtURL:(NSURL *)url error:(NSError**) error;

- (SVGElement *)findFirstElementOfClass:(Class)class;

//-(void)addElement:(SVGElement *)element forStyle:(NSString *)className;
@end


@implementation SVGDocument

@synthesize catcher = _catcher; //for tracking elements using a particular style, needs to be refactored a bit more but its getting better i promise

@synthesize width = _width;
@synthesize height = _height;
@synthesize version = _version;
@synthesize viewBoxFrame = _viewBoxFrame;

@synthesize graphicsGroups, anonymousGraphicsGroups;

@dynamic title, desc, defs;

+ (NSArray *)generalExtensions
{
    return [NSArray arrayWithObjects:[[[SVGParserSVG alloc] init] autorelease], [[SVGParserGradient new] autorelease], [[SVGParserStyles new] autorelease], nil];
}

static NSMutableArray* _parserExtensions;
+ (void) addSVGParserExtension:(NSObject<SVGParserExtension>*) extension
{
	if( _parserExtensions == nil )
	{
		_parserExtensions = [NSMutableArray new];
	}
	
	[_parserExtensions addObject:extension];
    [SVGParser addSharedParserExtensions:[NSSet setWithObject:extension]];
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

static NSCache *_sharedDocuments;
+ (SVGDocument *)sharedDocumentNamed:(NSString *)name {
	NSParameterAssert(name != nil);
    
    SVGDocument *returnDocument = nil;
//    @synchronized(name) //name is never unique, pointless, need something else to lock on, currently external classes are managing thread safety which is OK but not great
//    {
    returnDocument = [_sharedDocuments objectForKey:name];
//        SEL lookupKey = NSSelectorFromString(name); //this will ensure uniqueness, at the cost of atiny bit of speed
//        returnDocument = objc_getAssociatedObject([self class], lookupKey);
        if( returnDocument != nil ) {
            return returnDocument; //recovered from cache
        }
        
        if( _sharedDocuments == nil )
        {
            _sharedDocuments = [NSCache new];
            
            NSMutableSet *parserSet = [[NSMutableSet alloc] initWithArray:_parserExtensions];
            [parserSet addObjectsFromArray:[self generalExtensions]];
            [SVGParser addSharedParserExtensions:parserSet];
            [parserSet release];
        }
    
        returnDocument = [[SVGDocument alloc] initWithDocumentNamed:name andParser:[SVGParser sharedParser]];
        if( returnDocument != nil ) 
        {
            //NSLog(@"Saving document %@", name);
            //        if( saveParses == nil ) 
            //            saveParses = [NSMutableDictionary new];
            //        [saveParses setObject:returnDocument forKey:name];
//            objc_setAssociatedObject([self class], lookupKey, returnDocument, OBJC_ASSOCIATION_RETAIN);
            [_sharedDocuments setObject:returnDocument forKey:name];
            [returnDocument release];
//            returnDocument->_documentName = lookupKey;
            //        [returnDocument release]; //retained by dictionary
        }
//    }
    
	return returnDocument;
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
             
             
- (id)initWithDocumentNamed:(NSString *)documentName andParser:(SVGParser *)parser
{
	self = [super initWithDocument:self name:@"svg"];
    if( self != nil )
    {
        @autoreleasepool {
            _width = _height = 100;
            
            NSString *aPath = [[NSBundle mainBundle] pathForResource:documentName ofType:@"svg"];
            if( aPath == nil )
            {
                [self release];
                return nil;
            }
            
            SVGParser *sharedParser = [[SVGParser sharedParser] retain];
            [sharedParser parseFileAtPath:aPath toDocument:self];
            [sharedParser release];
        }
        
    }
    return self;
}


//onlyWithPrefix == @"*" for all classes, nil for don't track
- (id)initWithDocumentNamed:(NSString *)documentName 
{
	NSParameterAssert(documentName != nil);
    
	NSString *aPath = [[NSBundle mainBundle] pathForResource:documentName ofType:@"svg"];
    if( aPath == nil )
    {
        [self release];
        return nil;
    }
    
//    _documentName = [documentName retain];
	
	self = [super initWithDocument:self name:@"svg"];
	if (self) {
        //NSLog(@"Creating document with name %@", documentName);
		_width = _height = 100;
		
//        if( onlyWithPrefix != nil ) 
//        {
//            _trackClassPrefix = ([onlyWithPrefix isEqualToString:@"*"]) ? nil : [onlyWithPrefix copy];
//            _elementsByClassName = [NSMutableDictionary new];
//        }
        
		if (![self parseFileAtPath:aPath]) {
			NSLog(@"[%@] - %@ MISSING FILE, COULD NOT CREATE DOCUMENT: path = %@", _cmd, [self class], aPath);
			
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

//- (id)retain
//{
//    NSLog(@"[%@] %@ retained, current count %u", [self class], [self localName], [self retainCount]);
//    return [super retain];
//}
//
//-(oneway void)release
//{
//    NSLog(@"[%@] released %@, current count %u", [self class], [self localName], [self retainCount]);
//    [super release];
//}

- (void)dealloc {
	[_version release];
    self.graphicsGroups = nil;
    self.anonymousGraphicsGroups = nil;
    
//    [_elementsByClassName release];
    [_fillLayersByUrlId release];
    [_styleByClassName release];
//    self.defs = nil;
    
    self.catcher = nil;
    
//    if( _documentName != nil )
//    {
//        objc_setAssociatedObject([SVGDocument class], _documentName, nil, OBJC_ASSOCIATION_ASSIGN);
//    }
    [_layerTree release];
    
	[super dealloc];
}


- (BOOL)parseFileAtPath:(NSString *)aPath error:(NSError **)error
{
    SVGParser *parser = nil;
    BOOL result = NO;
    @autoreleasepool { //stich: hitting really high peak memory when parsing lots of SVGS in dispatch_queue, trying to avoid
        parser = [[SVGParser alloc] initWithPath:aPath document:self];
        
        [parser setParserExtensions:[SVGDocument generalExtensions]];
        
        result = [parser parse:error];
    }
    
	if (!result) 
    {
		NSLog(@"Parser error: %@", error);
	}
    
	[parser release];
    
	return result;
}

- (CGRect)bounds
{
    return CGRectMake(0, 0, self.width, self.height);
}


- (BOOL)parseFileAtPath:(NSString *)aPath {
	return [self parseFileAtPath:aPath error:nil];
}


-(BOOL)parseFileAtURL:(NSURL *)url error:(NSError**) error {
	SVGParser *parser = [[SVGParser alloc] initWithURL:url document:self];
    
    [parser setParserExtensions:[SVGDocument generalExtensions]];
    
    BOOL result = [parser parse:error];
	
	if (!result) 
		NSLog(@"[%@] SVGKit Parse error: %@", [self class], *error);
	
	[parser release];
	
	return result;
}

-(BOOL)parseFileAtURL:(NSURL *)url {
	return [self parseFileAtURL:url error:nil];
}

- (CALayer *)autoreleasedLayer 
{	
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

- (NSString *)currentFillForClassName:(NSString *)className
{
    
    return [[_styleByClassName objectForKey:className] objectForKey:@"fill"];
}


- (void)setStyle:(NSDictionary *)style forClassName:(NSString *)className
{
    if( style != nil )
    {
        //        NSLog(@"Set style for className %@ with properties %@", className, style);
        if( _styleByClassName == nil )
            _styleByClassName = [[NSMutableDictionary alloc] initWithObjectsAndKeys:style, className, nil];
        else
        {
            [_styleByClassName setObject:style forKey:className];
        }
    }
}

-(NSDictionary *)styleForElement:(SVGElement *)element withClassName:(NSString *) className
{
    return [_styleByClassName objectForKey:className];
}


- (void)setFill:(SVGGradientElement *)fillShape forId:(NSString *)idName
{
    if( fillShape != nil && idName != nil )
    {
        if( _fillLayersByUrlId == nil ) _fillLayersByUrlId = [NSMutableDictionary new];
        
        [_fillLayersByUrlId setObject:fillShape forKey:idName];
    }
}


CGPoint relativePosition(CGPoint point, CGRect withRect);
CGPoint relativePosition(CGPoint point, CGRect withRect)
{
    point.x -= withRect.origin.x;
    point.y -= withRect.origin.y;

    point.x /= withRect.size.width;
    point.y /= withRect.size.height;
    
    return point;
}

- (CALayer *)useFillId:(NSString *)idName forLayer:(CAShapeLayer *)filledLayer
{
    if( filledLayer != nil && _fillLayersByUrlId != nil ) //this nil check here is distrubing but blocking
    {
        SVGGradientElement *svgGradient = [_fillLayersByUrlId objectForKey:idName];
        if( svgGradient != nil )
        {
            CAGradientLayer *gradientLayer = (CAGradientLayer *)[svgGradient autoreleasedLayer];
            
//            CGRect filledLayerFrame = filledLayer.frame;
            CGRect docBounds = [self bounds];
            gradientLayer.frame = docBounds;
            
//            docBounds.size.height *= 100.0f;
            gradientLayer.startPoint = relativePosition(gradientLayer.startPoint, docBounds);
            gradientLayer.endPoint = relativePosition(gradientLayer.endPoint, docBounds);
            
            [gradientLayer setMask:filledLayer];
            return gradientLayer;
        }
    }
    return filledLayer;
}


//- (NSUInteger)changableColors
//{
//    return [_elementsByClassName count];
//}

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

+(void)trim
{
    [SVGParserGradient trim];
    [SVGParserSVG trim];
    [SVGParserStyles trim];
    
    [SVGParser trim];
}

+(void)bustCache
{
//    NSArray *keys = [_sharedDocuments allKeys];
//    for( NSString *documentName in keys )
//        if( [[_sharedDocuments objectForKey:documentName] retainCount] == 1 ) //this is the only retain on the document
//            [_sharedDocuments
    [_sharedDocuments release];
    _sharedDocuments = nil;
}

#endif

@end
