#import "SVGKImage.h"

#import "SVGDefsElement.h"
#import "SVGDescriptionElement.h"
#import "SVGKParser.h"
#import "SVGTitleElement.h"
#import "SVGPathElement.h"
#import "SVGUseElement.h"

#import "SVGSVGElement_Mutable.h" // so that changing .size can change the SVG's .viewport

#import "SVGKParserSVG.h"

#import "SVGKSourceLocalFile.h"
#import "SVGKSourceURL.h"

#import "CALayer+RecursiveClone.h"

#import "SVGKExporterUIImage.h" // needed for .UIImage property

#ifdef ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED
@interface SVGKImageCacheLine : NSObject
@property(nonatomic) int numberOfInstances;
@property(nonatomic,retain) SVGKImage* mainInstance;
@end
@implementation SVGKImageCacheLine
@synthesize numberOfInstances;
@synthesize mainInstance;
@end
#endif

@interface SVGKImage ()

@property(nonatomic) CGSize internalSizeThatWasSetExplicitlyByUser;

@property (nonatomic, retain, readwrite) SVGKParseResult* parseErrorsAndWarnings;

@property (nonatomic, retain, readwrite) SVGKSource* source;

@property (nonatomic, retain, readwrite) SVGDocument* DOMDocument;
@property (nonatomic, retain, readwrite) SVGSVGElement* DOMTree; // needs renaming + (possibly) replacing by DOMDocument
@property (nonatomic, retain, readwrite) CALayer* CALayerTree;
#ifdef ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED
@property (nonatomic, retain, readwrite) NSString* nameUsedToInstantiate;
#endif

#pragma mark - UIImage methods cloned and re-implemented as SVG intelligent methods
//NOT DEFINED: what is the scale for a SVGKImage? @property(nonatomic,readwrite) CGFloat            scale __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

@end

#pragma mark - main class
@implementation SVGKImage

@synthesize DOMDocument, DOMTree, CALayerTree;

@synthesize scale = _scale;
@synthesize source;
@synthesize parseErrorsAndWarnings;
@synthesize nameUsedToInstantiate = _nameUsedToInstantiate;

#ifdef ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED
static NSMutableDictionary* globalSVGKImageCache;

#pragma mark - Respond to low-memory warnings by dumping the global static cache
+(void) initialize
{
	if( self == [SVGKImage class]) // Have to protect against subclasses ADDITIONALLY calling this, as a "[super initialize] line
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarningOrBackgroundNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarningOrBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
}

+(void) didReceiveMemoryWarningOrBackgroundNotification:(NSNotification*) notification
{
	if ([globalSVGKImageCache count] == 0) return;
	
	DDLogCWarn(@"[%@] Low-mem or background; purging cache of %lu SVGKImages...", self, (unsigned long)[globalSVGKImageCache count] );
	
	[globalSVGKImageCache removeAllObjects]; // once they leave the cache, if they are no longer referred to, they should automatically dealloc
}
#endif

#pragma mark - Convenience initializers
+ (SVGKImage *)imageNamed:(NSString *)name {
	NSParameterAssert(name != nil);
    
#ifdef ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED
    if( globalSVGKImageCache == nil )
    {
        globalSVGKImageCache = [NSMutableDictionary new];
    }
    
    SVGKImageCacheLine* cacheLine = [globalSVGKImageCache valueForKey:name];
    if( cacheLine != nil )
    {
        cacheLine.numberOfInstances ++;
        return cacheLine.mainInstance;
    }
#endif
	
	/** Apple's File APIs are very very bad and require you to strip the extension HALF the time.
	 
	 The other HALF the time, they fail unless you KEEP the extension.
	 
	 It's a mess!
	 */
	NSString *newName = [name stringByDeletingPathExtension];
	NSString *extension = [name pathExtension];
    if ([@"" isEqualToString:extension]) {
        extension = @"svg";
    }
	
	/** First, try to find it in the project BUNDLE (this was HARD CODED at compile time; can never be changed!) */
	NSString *pathToFileInBundle = nil;
	NSBundle *bundle = [NSBundle mainBundle];
	if( bundle != nil )
	{
		pathToFileInBundle = [bundle pathForResource:newName ofType:extension];
	}
	
	/** Second, try to find it in the Documents folder (this is where Apple expects you to store custom files at runtime) */
	NSString* pathToFileInDocumentsFolder = nil;
	NSString* pathToDocumentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	if( pathToDocumentsFolder != nil )
	{
		pathToFileInDocumentsFolder = [[pathToDocumentsFolder stringByAppendingPathComponent:newName] stringByAppendingPathExtension:extension];
		if( [[NSFileManager defaultManager] fileExistsAtPath:pathToFileInDocumentsFolder])
			;
		else
			pathToFileInDocumentsFolder = nil; // couldn't find a file there
	}
	
	if( pathToFileInBundle == nil
	&& pathToFileInDocumentsFolder == nil )
	{
		DDLogCWarn(@"[%@] MISSING FILE (not found in App-bundle, not found in Documents folder), COULD NOT CREATE DOCUMENT: filename = %@, extension = %@", [self class], newName, extension);
		return nil;
	}
	
	/** Prefer the Documents-folder version over the Bundle version (allows you to have a default, and override at runtime) */
	SVGKSourceLocalFile* source = [SVGKSourceLocalFile sourceFromFilename: pathToFileInDocumentsFolder == nil ? pathToFileInBundle : pathToFileInDocumentsFolder];
	
	/**
	 Key moment: init and parse the SVGKImage
	 */
	SVGKImage* result = [self imageWithSource:source];
    
#ifdef ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED
	if( result != nil )
	{
    result->cameFromGlobalCache = TRUE;
    result.nameUsedToInstantiate = name;
    
    SVGKImageCacheLine* newCacheLine = [[[SVGKImageCacheLine alloc] init] autorelease];
    newCacheLine.mainInstance = result;
    
    [globalSVGKImageCache setValue:newCacheLine forKey:name];
	}
	else
	{
		NSLog(@"[%@] WARNING: not caching the output for new SVG image with name = %@, because it failed to load correctly", [self class], name );
	}
#endif
    
    return result;
}

+ (SVGKImage*) imageWithContentsOfURL:(NSURL *)url {
	NSParameterAssert(url != nil);
	@synchronized(self) {
	return [[[[self class] alloc] initWithContentsOfURL:url] autorelease];
    }
}

+ (SVGKImage*) imageWithContentsOfFile:(NSString *)aPath {
    @synchronized(self) {
	return [[[[self class] alloc] initWithContentsOfFile:aPath] autorelease];
    }
}

+ (SVGKImage*) imageWithSource:(SVGKSource *)newSource
{
	NSParameterAssert(newSource != nil);
	@synchronized(self) {
	return [[[[self class] alloc] initWithSource:newSource] autorelease];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	/** Remove and release (if appropriate) all cached render-output */
	DDLogVerbose(@"[%@] source data changed; de-caching cached data", [self class] );
	self.CALayerTree = nil;
}

/**
 Designated Initializer
 */
- (id)initWithParsedSVG:(SVGKParseResult *)parseResult {
	self = [super init];
	if (self)
	{
		_internalSizeThatWasSetExplicitlyByUser = CGSizeZero; // mark it explicitly as "uninitialized" = this is important for the getSize method!
		_scale = 0.0; // flags it as uninitialized (this is important to know later, when outputting rendered layers)
		
		self.parseErrorsAndWarnings = parseResult;
		
		if( parseErrorsAndWarnings.parsedDocument != nil )
		{
			self.DOMDocument = parseErrorsAndWarnings.parsedDocument;
			self.DOMTree = DOMDocument.rootElement;
		}
		else
		{
			self.DOMDocument = nil;
			self.DOMTree = nil;
		}
		
		if ( self.DOMDocument == nil )
		{
			DDLogError(@"[%@] ERROR: failed to init SVGKImage with source = %@, returning nil from init methods", [self class], source );
			self = nil;
		}
		
		[self addObserver:self forKeyPath:@"DOMTree.viewport" options:NSKeyValueObservingOptionOld context:nil];
		//		[self.DOMTree addObserver:self forKeyPath:@"viewport" options:NSKeyValueObservingOptionOld context:nil];
	}
    return self;
}

- (id)initWithSource:(SVGKSource *)newSource {
	NSAssert( newSource != nil, @"Attempted to init an SVGKImage using a nil SVGKSource");
	
	self = [self initWithParsedSVG:[SVGKParser parseSourceUsingDefaultSVGKParser:newSource]];
	if (self) {
		self.source = newSource;
	}
	return self;
}

- (id)initWithContentsOfFile:(NSString *)aPath {
	NSParameterAssert(aPath != nil);
	
	return [self initWithSource:[SVGKSourceLocalFile sourceFromFilename:aPath]];
}

- (id)initWithContentsOfURL:(NSURL *)url {
	NSParameterAssert(url != nil);
	
	return [self initWithSource:[SVGKSourceURL sourceFromURL:url]];
}

- (void)dealloc
{
#ifdef ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED
    if( self->cameFromGlobalCache )
    {
        SVGKImageCacheLine* cacheLine = [globalSVGKImageCache valueForKey:self.nameUsedToInstantiate];
        cacheLine.numberOfInstances --;
        
        if( cacheLine.numberOfInstances < 1 )
        {
            [globalSVGKImageCache removeObjectForKey:self.nameUsedToInstantiate];
        }
    }
#endif
	
//SOMETIMES CRASHES IN APPLE CODE, CAN'T WORK OUT WHY:	[self removeObserver:self forKeyPath:@"DOMTree.viewport"];
	
    self.source = nil;
    self.parseErrorsAndWarnings = nil;
    
    self.DOMDocument = nil;
	self.DOMTree = nil;
	self.CALayerTree = nil;
#ifdef ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED
    self.nameUsedToInstantiate = nil;
#endif
	
	[super dealloc];
}

//TODO mac alternatives to UIKit functions

#if TARGET_OS_IPHONE
+ (UIImage *)imageWithData:(NSData *)data
{
	NSAssert( FALSE, @"Method unsupported / not yet implemented by SVGKit" );
	return nil;
}
#endif

- (id)initWithData:(NSData *)data
{
	NSAssert( FALSE, @"Method unsupported / not yet implemented by SVGKit" );
	return nil;
}

#pragma mark - UIImage methods we reproduce to make it act like a UIImage

-(BOOL) hasSize
{
	if( ! CGSizeEqualToSize(CGSizeZero, self.internalSizeThatWasSetExplicitlyByUser ) )
		return true;
	
	if( SVGRectIsInitialized( self.DOMTree.viewport ) )
		return true;
	
	if( SVGRectIsInitialized( self.DOMTree.viewBox ) )
		return true;
	
	return false;
}

-(CGSize)size
{
	/**
	 c.f. http://t-machine.org/index.php/2013/04/13/svg-spec-missing-documentation-the-viewport-and-svg-width/
	 
	 1. if we have an explicit size (something the user set), we return that; it overrides EVERYTHING else
	 2. otherwise ... if we have an INTERNAL viewport on the SVG, we return that
	 3. otherwise ... spec is UNDEFINED. If we have a viewbox, we return that (SVG spec defaults to 1 unit of viewbox = 1 pixel on screen)
	 4. otherwise ... spec is UNDEFINED. We have no viewbox, so we assume viewbox is "the bounding box of the entire SVG content, in SVG units", and use 3. above
	 
	 */
	
	/*  1. if we have an explicit size (something the user set), we return that; it overrides EVERYTHING else */
	if( ! CGSizeEqualToSize(CGSizeZero, self.internalSizeThatWasSetExplicitlyByUser ) )
	{
		return self.internalSizeThatWasSetExplicitlyByUser;
	}
	
	/*  2. otherwise ... if we have an INTERNAL viewport on the SVG, we return that */
	if( SVGRectIsInitialized( self.DOMTree.viewport ) )
	{
		return CGSizeFromSVGRect( self.DOMTree.viewport );
	}

	/* Calculate a viewbox, either the explicit one from 3. above, or the implicit one from 4. above
	*/
	SVGRect effectiveViewbox; 
	if( ! SVGRectIsInitialized( self.DOMTree.viewBox ) )
	{
		/**
		 This is painful; the only way to calculate this is to recurse down the entire tree and find out the total extent
		 of every item - taking into account all local and global transforms, etc
		 
		 We CANNOT USE the CALayerTree as a cheat to do this - because the CALayerTree itself uses the output of this method
		 to decide how large to output itself!
		 
		 So, for now, we're going to NSAssert and crash, deliberately, until someone can write a better algorithm (without
		 editing the source of all the SVG* classes, this is quite a lot of work, I think)
		 */
		NSAssert(FALSE, @"Your SVG file has no internal size, and you have failed to specify a desired size. Therefore, we cannot give you a value for the 'image.size' property - you MUST use an SVG file that has a viewbox property, OR use an SVG file that defines an explicit svg width, OR provide a size of your own choosing (by setting image.size to a value) ... before you call this method" );
		effectiveViewbox = SVGRectUninitialized();
	}
	else
		effectiveViewbox = self.DOMTree.viewBox;
		
	/* COMBINED TOGETHER: 
	 
	 3. otherwise ... spec is UNDEFINED. If we have a viewbox, we return that (SVG spec defaults to 1 unit of viewbox = 1 pixel on screen)
	 4. otherwise ... spec is UNDEFINED. We have no viewbox, so we assume viewbox is "the bounding box of the entire SVG content, in SVG units", and use 3. above
	 */
	return CGSizeFromSVGRect( effectiveViewbox );
}

-(void)setSize:(CGSize)newSize
{
	self.internalSizeThatWasSetExplicitlyByUser = newSize;
	
	if( ! SVGRectIsInitialized(self.DOMTree.viewBox) && !SVGRectIsInitialized( self.DOMTree.viewport ) )
	{
		NSLog(@"[%@] WARNING: you have set an explicit image size, but your SVG file has no explicit width or height AND no viewBox. This means the image will NOT BE SCALED - either add a viewBox to your SVG source file, or add an explicit svg width and height -- or: use the .scale method on this class (SVGKImage) instead to scale by desired amount", [self class]);
	}
	
	/** "size" is part of SVGKImage, not the SVG spec; we need to update the SVG spec size too (aka the ViewPort)
	 
	 NB: in SVG world, the DOMTree.viewport is REQUIRED to be deleted if the "rendering agent" (i.e. this library)
	 uses a different value for viewport.
	 
	 You can always re-calculate the "original" viewport by looking at self.DOMTree.width and self.DOMTree.height
	 */
	self.DOMTree.viewport = SVGRectMake(0,0,newSize.width,newSize.height); // implicitly resizes all the internal rendering of the SVG
	
	/** invalidate all cached data that's dependent upon SVG's size */
	self.CALayerTree = nil; // invalidate the cached copy
}

-(void)setScale:(CGFloat)newScale
{
	NSAssert( self.DOMTree != nil, @"Can't set a scale before you've parsed an SVG file; scale is sometimes illegal, depending on the SVG file itself");
	
	NSAssert( ! SVGRectIsInitialized( self.DOMTree.viewBox ), @"image.scale cannot be set because your SVG has an internal viewbox. To resize this SVG, you must instead call image.size = (a new size) to force the svg to scale itself up or down as appropriate");
	
	_scale = newScale;
	
	/** invalidate all cached data that's dependent upon SVG's size */
	self.CALayerTree = nil; // invalidate the cached copy
}

-(UIImage *)UIImage
{
	return [SVGKExporterUIImage exportAsUIImage:self antiAliased:TRUE curveFlatnessFactor:1.0f interpolationQuality:kCGInterpolationDefault]; // Apple defaults
}

// the these draw the image 'right side up' in the usual coordinate system with 'point' being the top-left.

- (void)drawAtPoint:(CGPoint)point                                                        // mode = kCGBlendModeNormal, alpha = 1.0
{
	NSAssert( FALSE, @"Method unsupported / not yet implemented by SVGKit" );
}

#pragma mark - unsupported / unimplemented UIImage methods (should add as a feature)
- (void)drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
	NSAssert( FALSE, @"Method unsupported / not yet implemented by SVGKit" );
}
- (void)drawInRect:(CGRect)rect                                                           // mode = kCGBlendModeNormal, alpha = 1.0
{
	NSAssert( FALSE, @"Method unsupported / not yet implemented by SVGKit" );
}
- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
	NSAssert( FALSE, @"Method unsupported / not yet implemented by SVGKit" );
}

- (void)drawAsPatternInRect:(CGRect)rect // draws the image as a CGPattern
// animated images. When set as UIImageView.image, animation will play in an infinite loop until removed. Drawing will render the first image
{
	NSAssert( FALSE, @"Method unsupported / not yet implemented by SVGKit" );
}

#if TARGET_OS_IPHONE
+ (UIImage *)animatedImageNamed:(NSString *)name duration:(NSTimeInterval)duration  // read sequnce of files with suffix starting at 0 or 1
{
	NSAssert( FALSE, @"Method unsupported / not yet implemented by SVGKit" );
	return nil;
}
+ (UIImage *)animatedResizableImageNamed:(NSString *)name capInsets:(UIEdgeInsets)capInsets duration:(NSTimeInterval)duration // squence of files
{
	NSAssert( FALSE, @"Method unsupported / not yet implemented by SVGKit" );
	return nil;
}
+ (UIImage *)animatedImageWithImages:(NSArray *)images duration:(NSTimeInterval)duration
{
	NSAssert( FALSE, @"Method unsupported / not yet implemented by SVGKit" );
	return nil;
}
#endif

#pragma mark - CALayer methods: generate the CALayerTree

- (CALayer *)layerWithIdentifier:(NSString *)identifier
{
	return [self layerWithIdentifier:identifier layer:self.CALayerTree];
}

- (CALayer *)layerWithIdentifier:(NSString *)identifier layer:(CALayer *)layer {
	
	if ([[layer valueForKey:kSVGElementIdentifier] isEqualToString:identifier]) {
		return layer;
	}
	
	for (CALayer *child in layer.sublayers) {
		CALayer *resultingLayer = [self layerWithIdentifier:identifier layer:child];
		
		if (resultingLayer)
			return resultingLayer;
	}
	
	return nil;
}

-(CALayer*) newCopyPositionedAbsoluteLayerWithIdentifier:(NSString *)identifier
{
	NSAssert( identifier != nil, @"Requested the layer with NIL identifier - your calling method is broken and should check its arguments more carefully");
	
	CALayer* originalLayer = [self layerWithIdentifier:identifier];
	
	if( originalLayer == nil )
	{
		DDLogError(@"[%@] ERROR: requested a clone of CALayer with id = %@, but there is no layer with that identifier in the parsed SVG layer stack", [self class], identifier );
		return nil;
	}
	else
		return [self newCopyPositionedAbsoluteOfLayer:originalLayer];
}

-(CALayer*) newCopyPositionedAbsoluteOfLayer:(CALayer *)originalLayer
{
	return [self newCopyPositionedAbsoluteOfLayer:originalLayer withSubLayers:FALSE];
}

-(CALayer*) newCopyPositionedAbsoluteOfLayer:(CALayer *)originalLayer withSubLayers:(BOOL) recursive
{
	
	/*CALayer* clonedLayer = [[[originalLayer class] alloc] init];
	
	clonedLayer.frame = originalLayer.frame;
	if( [originalLayer isKindOfClass:[CAShapeLayer class]] )
	{
		((CAShapeLayer*)clonedLayer).path = ((CAShapeLayer*)originalLayer).path;
		((CAShapeLayer*)clonedLayer).lineCap = ((CAShapeLayer*)originalLayer).lineCap;
		((CAShapeLayer*)clonedLayer).lineWidth = ((CAShapeLayer*)originalLayer).lineWidth;
		((CAShapeLayer*)clonedLayer).strokeColor = ((CAShapeLayer*)originalLayer).strokeColor;
		((CAShapeLayer*)clonedLayer).fillColor = ((CAShapeLayer*)originalLayer).fillColor;
	}*/
	
	CALayer* clonedLayer = recursive ? [originalLayer cloneRecursively] : [originalLayer cloneShallow];
	
	if( clonedLayer == nil )
		return nil;
	else
	{		
		CGRect lFrame = clonedLayer.frame;
		CGFloat xOffset = 0.0;
		CGFloat yOffset = 0.0;
		CALayer* currentLayer = originalLayer;
		
		if( currentLayer.superlayer == nil )
		{
			DDLogWarn(@"AWOOGA: layer %@ has no superlayer!", originalLayer );
		}
		
		while( currentLayer.superlayer != nil )
		{
			//DEBUG: DDLogVerbose(@"shifting (%2.2f, %2.2f) to accomodate offset of layer = %@ inside superlayer = %@", currentLayer.superlayer.frame.origin.x, currentLayer.superlayer.frame.origin.y, currentLayer, currentLayer.superlayer );
			
			currentLayer = currentLayer.superlayer;
			//DEBUG: DDLogVerbose(@"...next superlayer in positioning absolute = %@, %@", currentLayer, NSStringFromCGRect(currentLayer.frame));
			xOffset += currentLayer.frame.origin.x;
			yOffset += currentLayer.frame.origin.y;
		}
		
		lFrame.origin = CGPointMake( lFrame.origin.x + xOffset, lFrame.origin.y + yOffset );
		clonedLayer.frame = lFrame;
		
		
		return clonedLayer;
	}
}

- (CALayer *)newLayerWithElement:(SVGElement <ConverterSVGToCALayer> *)element
{
	CALayer *layer = [element newLayer];
	
	//DEBUG: DDLogVerbose(@"[%@] DEBUG: converted SVG element (class:%@) to CALayer (class:%@ frame:%@ pointer:%@) for id = %@", [self class], NSStringFromClass([element class]), NSStringFromClass([layer class]), NSStringFromCGRect( layer.frame ), layer, element.identifier);
	
	NodeList* childNodes = element.childNodes;
	
	/**
	 Special handling for <use> tags - they have to masquerade invisibly as the node they are referring to
	 */
	if( [element isKindOfClass:[SVGUseElement class]] )
	{
		SVGUseElement* useElement = (SVGUseElement*) element;
		childNodes = useElement.instanceRoot.correspondingElement.childNodes;
	}
	
	if ( childNodes.length < 1 ) {
		return layer;
	}
	
	/**
	 Generate child nodes and then re-layout
	 
	 (parent may have to change its size to fit children)
	 */
	for (SVGElement *child in childNodes )
	{
		if ([child conformsToProtocol:@protocol(ConverterSVGToCALayer)]) {
			
			CALayer *sublayer = [[self newLayerWithElement:(SVGElement<ConverterSVGToCALayer> *)child] autorelease];
			
			if (!sublayer) {
				continue;
            }
			
			[layer addSublayer:sublayer];
		}
	}
	
	/** ...relayout */
	/**
	 NOTE:
	 
	 This call (layoutLayer:), and the fact that we call it directly on the "ConverterSVGToCALayer" instance,
	 is critical to ensuring that SVG <g> tags generate correctly sized/shaped/positioned CALayer's.
	 
	 It is not used for any other class / SVG Element.
	 
	 It's only needed by G elements because they have no explicit size, and their extent is defined by
	 
	    "all the space occupied by my children"
	 
	 If you refactor this method, or CALayer exporting, please make sure you keep the current behaviour. You can
	 test it by:
	 
	 1. Make an SVG file with a G element wrapping some shape in the middle of screen
	 2. Load the file
	 3. Select the CALayer for the shape, and clone it (using the category for CAShape in this project)
	 4. add the clone to the screen, with its CALayer.position set to 0,0
	 5. If the code is correct, it will be positioned in top left corner.
	 6. If the code is broken, it will be positioned somewhere in the middle of the screen (probably directly on top of the one you cloned)
	    --- i.e. you've accidentally embedded the "relative position" into the "absolute position" of the CALayer
	 */
	[element layoutLayer:layer];
    [layer setNeedsDisplay];
	
	return layer;
}

-(CALayer *)newCALayerTree
{
	if( self.DOMTree == nil )
		return nil;
	else
	{
		CALayer* newLayerTree = [self newLayerWithElement:self.DOMTree];
		
		if( 0.0f != self.scale )
		{
			NSLog(@"[%@] WARNING: because you specified an image.scale (you SHOULD be using SVG viewbox or <svg width> instead!), we are changing the .anchorPoint and the .affineTransform of the returned CALayerTree. Apple's own libraries are EXTREMELY BUGGY if you hand them layers that have these variables changed (some of Apple's libraries completely ignore them, this is a major Known Bug that Apple hasn't fixed in many years). Proceed at your own risk, and warned!", [self class] );
			
			/** Apple's bugs in CALayer are legion, and some have been around for almost 10 years...
			 
			 When you set the affineTransform on a Layer, if you do not ALSO MANUALLY change the anchorpoint, Apple
			 renders the layer at the wrong co-ords.
			 */
			newLayerTree.anchorPoint = CGPointApplyAffineTransform( newLayerTree.anchorPoint, CGAffineTransformMakeScale(1.0f/self.scale, 1.0f/self.scale));
			newLayerTree.affineTransform = CGAffineTransformMakeScale( self.scale, self.scale );
		}
		
		return newLayerTree;
	}
}

-(CALayer *)CALayerTree
{
	if( CALayerTree == nil )
	{
		DDLogInfo(@"[%@] WARNING: no CALayer tree found, creating a new one (will cache it once generated)", [self class] );

		NSDate* startTime = [NSDate date];
		self.CALayerTree = [[self newCALayerTree] autorelease];
		
		DDLogInfo(@"[%@] ...time taken to convert from DOM to fresh CALayers: %2.3f seconds)", [self class], -1.0f * [startTime timeIntervalSinceNow] );		
	}
	else
		DDLogVerbose(@"[%@] rendering to CGContext: re-using cached CALayers (FREE))", [self class] );
	
	return CALayerTree;
}


- (void) addSVGLayerTree:(CALayer*) layer withIdentifier:(NSString*) layerID toDictionary:(NSMutableDictionary*) layersByID
{
	// TODO: consider removing this method: it caches the lookup of individual items in the CALayerTree. It's a performance boost, but is it enough to be worthwhile?
	[layersByID setValue:layer forKey:layerID];
	
	if ( [layer.sublayers count] < 1 )
	{
		return;
	}
	
	for (CALayer *subLayer in layer.sublayers)
	{
		NSString* subLayerID = [subLayer valueForKey:kSVGElementIdentifier];
		
		if( subLayerID != nil )
		{
			DDLogVerbose(@"[%@] element id: %@ => layer: %@", [self class], subLayerID, subLayer);
			
			[self addSVGLayerTree:subLayer withIdentifier:subLayerID toDictionary:layersByID];
			
		}
	}
}

- (NSDictionary*) dictionaryOfLayers
{
	// TODO: consider removing this method: it caches the lookup of individual items in the CALayerTree. It's a performance boost, but is it enough to be worthwhile?
	NSMutableDictionary* layersByElementId = [NSMutableDictionary dictionary];
	
	CALayer* rootLayer = self.CALayerTree;
	
	[self addSVGLayerTree:rootLayer withIdentifier:self.DOMTree.identifier toDictionary:layersByElementId];
	
	DDLogVerbose(@"[%@] ROOT element id: %@ => layer: %@", [self class], self.DOMTree.identifier, rootLayer);
	
    return layersByElementId;
}

#pragma mark - Useful bonus methods, will probably move to a different class at some point

-(void) scaleToFitInside:(CGSize) maxSize
{
	NSAssert( [self hasSize], @"Cannot scale this image because the SVG file has infinite size. Either fix the SVG file, or set an explicit size you want it to be exported at (by calling .size = something on this SVGKImage instance");
	
	float wScale = maxSize.width / self.size.width;
	float hScale = maxSize.height / self.size.height;
	
	float smallestScaleUp = MIN( wScale, hScale );
	
	if( smallestScaleUp < 1.0f )
		smallestScaleUp = MAX( wScale, hScale ); // instead of scaling-up the smallest, scale-down the largest
	
	self.size = CGSizeApplyAffineTransform( self.size, CGAffineTransformMakeScale( smallestScaleUp, smallestScaleUp));
}

@end

