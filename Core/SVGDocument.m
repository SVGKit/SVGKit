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

@interface SVGDocument ()

@property (nonatomic, copy) NSString *version;

- (BOOL)parseFileAtPath:(NSString *)aPath;

- (SVGElement *)findFirstElementOfClass:(Class)class;

-(void)addElement:(SVGElement *)element forStyle:(NSString *)className;
@end


@implementation SVGDocument

@synthesize width = _width;
@synthesize height = _height;
@synthesize version = _version;

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

static NSMutableDictionary *saveParses;
+ (SVGDocument *)sharedDocumentNamed:(NSString *)name trackingPrefix:(NSString *)trackPrefix {
	NSParameterAssert(name != nil);
	
	SVGDocument *returnDocument = nil;
    
    returnDocument = [saveParses objectForKey:name];
    if( returnDocument != nil )
        return returnDocument; //recovered from cache
    
    //    else
    //        NSLog(@"Yay saved one");
    
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
    
    returnDocument = [[SVGDocument alloc] initWithContentsOfFile:path trackElementsByClassName:trackPrefix];
    if( returnDocument != nil ) 
    {
        if( saveParses == nil ) 
            saveParses = [NSMutableDictionary new];
        [saveParses setObject:returnDocument forKey:name];
        [returnDocument release]; //retained by dictionary
    }
    
	return returnDocument;
}

+ (id)documentWithContentsOfFile:(NSString *)aPath {
	return [[[[self class] alloc] initWithContentsOfFile:aPath] autorelease];
}

- (id)initWithContentsOfFile:(NSString *)aPath {
	NSParameterAssert(aPath != nil);
	
	self = [super initWithDocument:self name:@"svg"];
	if (self) {
		_width = _height = 100;
		
		if (![self parseFileAtPath:aPath]) {
			NSLog(@"[%@] MISSING FILE, COULD NOT CREATE DOCUMENT: path = %@", [self class], aPath);
			
			[self release];
			return nil;
		}
	}
	return self;
}


//onlyWithPrefix == @"*" for all classes, nil for don't track
- (id)initWithContentsOfFile:(NSString *)aPath trackElementsByClassName:(NSString *)onlyWithPrefix 
{
	NSParameterAssert(aPath != nil);
	
	self = [super initWithDocument:self name:@"svg"];
	if (self) {
		_width = _height = 100;
		
        if( onlyWithPrefix != nil ) 
        {
            _trackClassPrefix = ([onlyWithPrefix isEqualToString:@"*"]) ? nil : [onlyWithPrefix copy];
            _elementsByClassName = [NSMutableDictionary new];
        }
        
		if (![self parseFileAtPath:aPath]) {
			NSLog(@"[%@] MISSING FILE, COULD NOT CREATE DOCUMENT: path = %@", [self class], aPath);
			
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
    
    [_elementsByClassName release];
    [_fillLayersByUrlId release];
    [_styleByClassName release];
    
	[super dealloc];
}

- (BOOL)parseFileAtPath:(NSString *)aPath {
	NSError *error = nil;
	
	SVGParser *parser = [[SVGParser alloc] initWithPath:aPath document:self];
	SVGParserSVG *subParserSVG = [[[SVGParserSVG alloc] init] autorelease];
	[parser.parserExtensions addObject:subParserSVG];

    NSObject<SVGParserExtension>*extension = [SVGParserGradient new];
    [parser.parserExtensions addObject:extension];
    [extension release]; //retained by parserExtensions
    
    extension = [SVGParserStyles new];
    [parser.parserExtensions addObject:extension];
    [extension release];
    
	for( NSObject<SVGParserExtension>* extension in _parserExtensions )
	{
		[parser.parserExtensions addObject:extension];
	}
	
	if (![parser parse:&error]) 
    {
		NSLog(@"Parser error: %@", error);
		[parser release];
		
		return NO;
	}
	
	[parser release];
	
	return YES;
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
}

- (NSString *)currentFillForClassName:(NSString *)className
{
    
    return [[_styleByClassName objectForKey:className] objectForKey:@"fill"];
}

- (BOOL)changeFillForStyle:(NSString *)className toNewFill:(NSString *)fillString
{
    NSMutableDictionary *style = [_styleByClassName objectForKey:className];
    if( style != nil )
    {
        //        SVGColor newColor = SVGColorFromString([fillString UTF8String]);
        [style setObject:fillString forKey:@"fill"];
        NSArray *elements = [_elementsByClassName objectForKey:className];
        CGColorRef newColor = CGColorWithSVGColor(SVGColorFromString([fillString UTF8String])) ;
        for (SVGElement *element in elements) 
        {
            [element updateFill:newColor];        }
        return true;
    }
    return false;
}

- (BOOL)changeFillForStyle:(NSString *)className toNewCGColor:(CGColorRef)newColor
{
    NSMutableDictionary *style = [_styleByClassName objectForKey:className];
    if( style != nil )
    {
        NSArray *elements = [_elementsByClassName objectForKey:className];
        
        //        [style setObject:[newColor de forKey:@"fill"];
        for (SVGElement *element in elements) 
        {
            [element updateFill:newColor];
        }
        return true;
    }
    return false;
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
    NSDictionary *returnStyle = [_styleByClassName objectForKey:className];
    
    if( returnStyle != nil && _elementsByClassName != nil )
    {
        
        NSString * subString = [className substringToIndex:[_trackClassPrefix length]];
        
        if( (_trackClassPrefix == nil || [subString isEqualToString:_trackClassPrefix] ) )
            [self addElement:element forStyle:className];
    }
    
    return returnStyle;
}

-(void)addElement:(SVGElement *)element forStyle:(NSString *)className
{
    NSMutableArray * elementsWithStyle = [_elementsByClassName objectForKey:className];
    if( elementsWithStyle == nil )
        [_elementsByClassName setObject:(elementsWithStyle = [NSMutableArray new]) forKey:className];
    
    [element setTrackShapeLayers:true];
    [elementsWithStyle addObject:element];
}

- (void)setFill:(SVGGradientElement *)fillShape forId:(NSString *)idName
{
    if( fillShape != nil && idName != nil )
    {
        if( _fillLayersByUrlId == nil ) _fillLayersByUrlId = [NSMutableDictionary new];
        
        [_fillLayersByUrlId setObject:fillShape forKey:idName];
    }
}

- (CALayer *)useFillId:(NSString *)idName forLayer:(CAShapeLayer *)filledLayer
{
    if( filledLayer != nil )
    {
        SVGGradientElement *svgGradient = [_fillLayersByUrlId objectForKey:idName];
        if( svgGradient != nil )
        {
            CAGradientLayer *gradientLayer = (CAGradientLayer *)[svgGradient newLayer];
            [gradientLayer setMask:filledLayer];
            return gradientLayer;
        }
    }
    return filledLayer;
}


- (NSUInteger)changableColors
{
    return [_elementsByClassName count];
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
