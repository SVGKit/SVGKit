/*
 SVGKImage
 
 The main class in SVGKit - this is the one you'll normally interact with
 
 c.f. SVGKit.h for more info on using SVGKit
 
 What is an SVGKImage?
 
 An SVGKImage is as close to "the SVG version of a UIImage" as we could possibly get. We cannot
 subclass UIImage because Apple has defined UIImage as immutable - and SVG images actually change
 (each time you zoom in, we want to re-render the SVG as a higher-resolution set of pixels)
 
 We use the exact same method names as UIImage, and try to be literally as identical as possible.
 
 Creating an SVGKImage:
 
  - PREFERRED: use the "imageNamed:" method
  - CUSTOM SVGKSource class: use the "initWithSource:" method
  - CUSTOM PARSING: Parse using SVGKParser, then send the parse-result to "initWithParsedSVG:"
 
 
 Data:
  - UIImage: not supported yet: will be a cached UIImage that is re-generated on demand. Will enable us to implement an SVGKImageView
 that works as a drop-in replacement for UIImageView
 
  - DOMTree: the SVG DOM spec, the root element of a tree of SVGElement subclasses
  - CALayerTree: the root element of a tree of CALayer subclasses
 
  - size: as per the UIImage.size, returns a size in Apple Points (i.e. 320 == width of iPhone, irrespective of Retina)
  - scale: ??? unknown how we'll define this, but could be useful when doing auto-re-render-on-zoom
  - svgWidth: the internal SVGLength used to generate the correct .size
  - svgHeight: the internal SVGLength used to generate the correct .size
  - rootElement: the SVGSVGElement instance that is the root of the parse SVG tree. Use this to access the full SVG document
 
 */

//Both OS X and iOS have this header
//Include it so the Target OS preprocessor is defined.
//Probably could have included AvailabilityMacros.h, but meh.
#import <Foundation/Foundation.h>

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#import "SVGLength.h"
#import "SVGDocument.h"
#import "SVGElement.h"
#import "SVGSVGElement.h"

#import "SVGKParser.h"
#import "SVGKSource.h"
#import "SVGKParseResult.h"

#define ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED 1 // if ENABLED, then ALL instances created with imageNamed: are shared, and are NEVER RELEASED

@class SVGDefsElement;

@interface SVGKImage : NSObject // doesn't extend UIImage because Apple made UIImage immutable
{
#ifdef ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED
    BOOL cameFromGlobalCache;
#endif
}

/** Generates an image on the fly
 
 NB you can get MUCH BETTER performance using the methods such as exportUIImageAntiAliased and exportNSDataAntiAliased
 */
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
@property (unsafe_unretained, nonatomic, readonly) UIImage* UIImage;
#else
@property (unsafe_unretained, nonatomic, readonly) CIImage *CIImage;
#endif

@property (nonatomic, strong, readonly) SVGKSource* source;
@property (nonatomic, strong, readonly) SVGKParseResult* parseErrorsAndWarnings;

@property (nonatomic, strong, readonly) SVGDocument* DOMDocument;
@property (nonatomic, strong, readonly) SVGSVGElement* DOMTree; // needs renaming + (possibly) replacing by DOMDocument
@property (nonatomic, strong, readonly) CALayer* CALayerTree;
#ifdef ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED
@property (nonatomic, strong, readonly) NSString* nameUsedToInstantiate;
#endif

#pragma mark - methods to quick load an SVG as an image
+ (SVGKImage *)imageNamed:(NSString *)name;      // load from main bundle
+ (SVGKImage *)imageWithContentsOfFile:(NSString *)path;
#if TARGET_OS_IPHONE // doesn't exist on OS X's Image class
+ (SVGKImage *)imageWithData:(NSData *)data;
#endif
+ (SVGKImage*) imageWithSource:(SVGKSource *)newSource; // if you have custom source's you want to use

- (id)initWithContentsOfFile:(NSString *)path;
- (id)initWithData:(NSData *)data;

#pragma mark - UIImage methods cloned and re-implemented as SVG intelligent methods

/** The natural / preferred size of the SVG (SVG's are infinitely scalable, by definition).
 >  
 >  NOTE: if you change this property, it will invalidate any cached render-data, and all future
 >  renders will be done at this pixel-size/pixel-resolution
 >  
 >  NOTE: when you read the .UIImage property of this class, it generates a bitmap using the
 >  current value of this property (or x2 if retina display)
 >  */
@property(nonatomic) CGSize             size;

/**
 
 TODO: From UIImage. Not needed, I think?
 
 @property(nonatomic,readonly) CIImage           *CIImage __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0); // returns underlying CIImage or nil if CGImageRef based
*/

// the these draw the image 'right side up' in the usual coordinate system with 'point' being the top-left.

- (void)drawAtPoint:(CGPoint)point;                                                        // mode = kCGBlendModeNormal, alpha = 1.0

#pragma mark - unsupported / unimplemented UIImage methods (should add as a feature)

/** This has no meaning for an SVGImage.
 
 TODO: *possibly* we could make this writeable, and say "when you request a CALayerTree, it gets scaled by this"
 */
@property(nonatomic,readonly) CGFloat            scale;

- (void)drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;
- (void)drawInRect:(CGRect)rect;                                                           // mode = kCGBlendModeNormal, alpha = 1.0
- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

- (void)drawAsPatternInRect:(CGRect)rect; // draws the image as a CGPattern

// animated images. When set as UIImageView.image, animation will play in an infinite loop until removed. Drawing will render the first image
#if TARGET_OS_IPHONE
+ (UIImage *)animatedImageNamed:(NSString *)name duration:(NSTimeInterval)duration ;//__OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0); read sequnce of files with suffix starting at 0 or 1
+ (UIImage *)animatedResizableImageNamed:(NSString *)name capInsets:(UIEdgeInsets)capInsets duration:(NSTimeInterval)duration ;//__OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0); // squence of files
+ (UIImage *)animatedImageWithImages:(NSArray *)images duration:(NSTimeInterval)duration ;//__OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0);
#endif
/**
 
 TODO: From UIImage. Not needed, I think?

@property(nonatomic,readonly) NSArray       *images   __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0); // default is nil for non-animated images
@property(nonatomic,readonly) NSTimeInterval duration __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0); // total duration for all frames. default is 0 for non-animated images
 */
#pragma mark ---------end of unsupported items

+ (SVGKImage*)imageWithContentsOfURL:(NSURL *)url;

#pragma mark - core methods for interacting with an SVG image usefully (not from UIImage)

/*! If you want to provide a custom SVGKSource */
- (id)initWithSource:(SVGKSource *)source;

/*! If you already have a parsed SVG, and just want to upgrade it to an SVGKImage
 
 This is the designated initialiser used by all other init methods
 
 NB: this is frequently used if you have to add custom SVGKParserExtensions to parse an
 SVG which contains custom tags
 */
- (id)initWithParsedSVG:(SVGKParseResult *)parseResult;


/*! Creates a new instance each time you call it. This should ONLY be used if you specifically need to duplicate
 the CALayer's (e.g. because you want to render a temporary clone of the CALayers somewhere else on screen,
 and you're going to modify them).
 
 For all other use-cases, you should probably use the .CALayerTree property, which is automatically cached between
 calls - but MUST NOT be altered!
 */
- (CALayer *)newCALayerTree;

/*! uses the current .CALayerTree property to find the layer, recursing down the tree (or creates a new
 CALayerTree on demand, and caches it)
 
 i.e. this takes advantage of the cached CALayerTree instance, and also correctly uses the SVG.viewBox info
 that was used when generating the original CALayerTree
 */
- (CALayer *)layerWithIdentifier:(NSString *)identifier;

/*! uses the current .CALayerTree property to find the layer, recursing down the tree (or creates a new
 CALayerTree on demand, and caches it)
 
 i.e. this takes advantage of the cached CALayerTree instance, and also correctly uses the SVG.viewBox info
 that was used when generating the original CALayerTree
 */
- (CALayer *)layerWithIdentifier:(NSString *)identifier layer:(CALayer *)layer;

/*! As for layerWithIdentifier: but works out the absolute position of the layer,
 effectively pulling it out of the layer-tree (the newly created layer has NO SUPERLAYER,
 because it no longer needs one)
 
 Useful for extracting individual features from an SVG
 
 WARNING: will assert if you supply a nil identifier string
 WARNING: some SVG editors (e.g. Adobe Illustrator) don't bother creating an 'id' attribute for every node (the spec allows this,
 but strongly discourages it). Inkscape does the right thing and generates an automatic 'id' for every node. If you are loading
 docs that have many 'anonymous' nodes, you'll need to get actual pointer refs to the layers you need to work with, and use the
 alternate version of this method.
 */
- (CALayer*) newCopyPositionedAbsoluteLayerWithIdentifier:(NSString *)identifier;

/*! As for layerWithIdentifier: but works out the absolute position of the layer,
 effectively pulling it out of the layer-tree (the newly created layer has NO SUPERLAYER,
 because it no longer needs one)
 
 Useful for extracting individual features from an SVG
 */
- (CALayer*) newCopyPositionedAbsoluteOfLayer:(CALayer *)originalLayer;

/*! returns all the individual CALayer's in the full layer tree, indexed by the SVG identifier of the SVG node that created that layer */
- (NSDictionary*) dictionaryOfLayers;

/**
 Higher-performance version of .UIImage property (the property uses this method, but you can tweak the parameters for better performance / worse accuracy)
 
 NB: you can get BETTER performance using the exportNSDataAntiAliased: version of this method, becuase you bypass Apple's slow code for making UIImage objects
 
 @param shouldAntialias = Apple defaults to TRUE, but turn it off for small speed boost
 @param multiplyFlatness = how many pixels a curve can be flattened by (Apple's internal setting) to make it faster to render but less accurate
 @param interpolationQuality = Apple internal setting, c.f. Apple docs for CGInterpolationQuality
 */
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
- (UIImage *) exportUIImageAntiAliased:(BOOL) shouldAntialias curveFlatnessFactor:(CGFloat) multiplyFlatness interpolationQuality:(CGInterpolationQuality) interpolationQuality;
#else
- (CIImage *)exportCIImageAntiAliased:(BOOL) shouldAntialias curveFlatnessFactor:(CGFloat) multiplyFlatness interpolationQuality:(CGInterpolationQuality) interpolationQuality;
- (NSImage*)exportNSImageAntiAliased:(BOOL) shouldAntialias curveFlatnessFactor:(CGFloat) multiplyFlatness interpolationQuality:(CGInterpolationQuality) interpolationQuality;
#endif
/**
 Highest-performance version of .UIImage property (this minimizes memory usage and can lead to large speed-ups e.g. when using SVG images as textures with OpenGLES)
 
 NB: we could probably achieve get even higher performance in OpenGL by sidestepping NSData entirely and using raw byte arrays (should result in zero-copy).
 
 @param shouldAntialias = Apple defaults to TRUE, but turn it off for small speed boost
 @param multiplyFlatness = how many pixels a curve can be flattened by (Apple's internal setting) to make it faster to render but less accurate
 @param interpolationQuality = Apple internal setting, c.f. Apple docs for CGInterpolationQuality
 */
-(NSData*) exportNSDataAntiAliased:(BOOL) shouldAntialias curveFlatnessFactor:(CGFloat) multiplyFlatness interpolationQuality:(CGInterpolationQuality) interpolationQuality flipYaxis:(BOOL) flipYaxis;

#pragma mark - Useful bonus methods, will probably move to a different class at some point

/** alters the SVG image's size directly (by changing the viewport) so that it will fit inside the specifed area without stretching or deforming */
-(void) scaleToFitInside:(CGSize) maxSize;

@end
