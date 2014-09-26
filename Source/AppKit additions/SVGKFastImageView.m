#import <SVGKit/SVGKFastImageView.h>
#include <tgmath.h>
#import "BlankSVG.h"

#define TEMPORARY_WARNING_FOR_APPLES_BROKEN_RENDERINCONTEXT_METHOD 1 // ONLY needed as temporary workaround for Apple's renderInContext bug breaking various bits of rendering: Gradients, Scaling, etc
#ifndef TEMPORARY_WARNING_FOR_FLIPPED_TEXT
#define TEMPORARY_WARNING_FOR_FLIPPED_TEXT 1 // ONLY needed until we know how to fix the text.
#endif

#if TEMPORARY_WARNING_FOR_APPLES_BROKEN_RENDERINCONTEXT_METHOD
#import <SVGKit/SVGGradientElement.h>
#endif

#if TEMPORARY_WARNING_FOR_FLIPPED_TEXT
#import <SVGKit/SVGTextElement.h>
#endif


@implementation SVGKFastImageView
{
	NSString* internalContextPointerBecauseApplesDemandsIt;
}

@synthesize image = _image;
@synthesize tileRatio = _tileRatio;

+ (BOOL)svgImage:(SVGKImage*)theImage hasNoClass:(Class)theClass
{
	return [self svgElementAndDescendents:theImage.DOMTree haveNoClass:theClass];
}

+ (BOOL)svgElementAndDescendents:(SVGElement*)element haveNoClass:(Class) theClass
{
	if( [element isKindOfClass:theClass])
		return NO;
	else
	{
		for( Node* n in element.childNodes )
		{
			if( [n isKindOfClass:[SVGElement class]])
			{
				if( [self svgElementAndDescendents:(SVGElement*)n haveNoClass:theClass])
					;
				else
					return NO;
			}
		}
	}
	
	return YES;
}

#define CLASSTESTERS_DEPRECATED() DDLogWarn(@"[%@] the function %s is deprecated.", self, sel_getName(_cmd))
#if TEMPORARY_WARNING_FOR_APPLES_BROKEN_RENDERINCONTEXT_METHOD
+(BOOL) svgImageHasNoGradients:(SVGKImage*) image
{
	return [self svgElementAndDescendents:image.DOMTree haveNoClass:[SVGGradientElement class]];
}

+(BOOL) svgElementAndDescendentsHaveNoGradients:(SVGElement*) element
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CLASSTESTERS_DEPRECATED();
	});
	return [self svgElementAndDescendents:element haveNoClass:[SVGGradientElement class]];
}
#else
static dispatch_once_t gradOkayWarnOnce;
#define GRADOKAYSTR @"[%@] %@ no longer has issues with gradients."

+(BOOL) svgImageHasNoGradients:(SVGKImage*) image
{
	CLASSTESTERS_DEPRECATED();
	dispatch_once(&gradOkayWarnOnce, ^{
		DDLogVerbose(GRADOKAYSTR, self, [SVGKFastImageView class]);
	});
	return YES;
}

+(BOOL) svgElementAndDescendentsHaveNoGradients:(SVGElement*) element
{
	CLASSTESTERS_DEPRECATED();
	dispatch_once(&gradOkayWarnOnce, ^{
		DDLogVerbose(GRADOKAYSTR, self, [SVGKFastImageView class]);
	});
	return YES;
}
#endif

#if TEMPORARY_WARNING_FOR_FLIPPED_TEXT
+ (BOOL)svgImageHasNoText:(SVGKImage*)image
{
	return [self svgElementAndDescendents:image.DOMTree haveNoClass:[SVGTextElement class]];
}

+ (BOOL)svgElementAndDescendentsHaveNoText:(SVGElement*) element
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CLASSTESTERS_DEPRECATED();
	});
	return [self svgElementAndDescendents:element haveNoClass:[SVGTextElement class]];
}
#else
static dispatch_once_t textOkayWarnOnce;
#define TEXTOKAYSTR @"[%@] %@ no longer has issues with text."

+ (BOOL)svgImageHasNoText:(SVGKImage*) image
{
	CLASSTESTERS_DEPRECATED();
	dispatch_once(&textOkayWarnOnce, ^{
		NSLog(TEXTOKAYSTR, self, [SVGKFastImageView class]);
	});
	return YES;
}

+ (BOOL)svgElementAndDescendentsHaveNoText:(SVGElement*) element
{
	CLASSTESTERS_DEPRECATED();
	dispatch_once(&textOkayWarnOnce, ^{
		NSLog(TEXTOKAYSTR, self, [SVGKFastImageView class]);
	});
	return YES;
}
#endif

- (id)init
{
	NSAssert(false, @"init not supported, use initWithSVGKImage:");
	
	return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return [self initWithSVGKImage:nil frame:CGRectZero];
}

-(id)initWithFrame:(NSRect)frame
{
	return [self initWithSVGKImage:nil frame:frame];
}

- (id)initWithSVGKImage:(SVGKImage*) im
{
	return [self initWithSVGKImage:im frame:CGRectZero];
}

- (id)initWithSVGKImage:(SVGKImage*)im frame:(NSRect)theFrame
{
	if( im == nil )
	{
		DDLogWarn(@"[%@] WARNING: you have initialized an SVGKImageView with a blank image (nil). Possibly because you're using NIBs which Apple won't allow us to decorate. Make sure you assign an SVGKImage to the .image property!", [self class]);
		DDLogInfo(@"[%@] Using default SVG: %@", [self class], SVGKGetDefaultImageStringContents());
		im = [SVGKImage defaultImage];
	}
	
	if (![im hasSize]) {
		im.size = NSMakeSize(100.0, 100.0);
	}
	
    self = [super initWithFrame:(!NSEqualRects(theFrame, CGRectZero) ? theFrame : (NSRect){CGPointZero, im.size})]; // NB: this may use the default SVG Viewport; an ImageView can theoretically calc a new viewport (but its hard to get right!)
    if (self)
	{
		internalContextPointerBecauseApplesDemandsIt = @"Apple wrote the addObserver / KVO notification API wrong in the first place and now requires developers to pass around pointers to fake objects to make up for the API deficicineces. You have to have one of these pointers per object, and they have to be internal and private. They serve no real value.";
		
		self.image = im;
		//self.frame = CGRectMake( 0,0, im.size.width, im.size.height ); // NB: this uses the default SVG Viewport; an ImageView can theoretically calc a new viewport (but its hard to get right!)
		self.tileRatio = CGSizeZero;
		
		/** other obeservers */
		//[self.layer addObserver:self forKeyPath:@"transform" options:NSKeyValueObservingOptionNew context:internalContextPointerBecauseApplesDemandsIt];
		[self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:(__bridge void *)(internalContextPointerBecauseApplesDemandsIt)];
		[self addObserver:self forKeyPath:@"tileRatio" options:NSKeyValueObservingOptionNew context:(__bridge void *)(internalContextPointerBecauseApplesDemandsIt)];
		[self addObserver:self forKeyPath:@"showBorder" options:NSKeyValueObservingOptionNew context:(__bridge void *)(internalContextPointerBecauseApplesDemandsIt)];
    }
    return self;
}

- (void)setImage:(SVGKImage *)image {
	
#if TEMPORARY_WARNING_FOR_APPLES_BROKEN_RENDERINCONTEXT_METHOD
	{
		BOOL imageIsGradientFree = [SVGKFastImageView svgImageHasNoGradients:image];
		if( !imageIsGradientFree )
			DDLogWarn(@"[%@] WARNING: Apple's rendering DOES NOT ALLOW US to render this image correctly using SVGKFastImageView, because Apple's renderInContext method - according to Apple's docs - ignores Apple's own masking layers. Until Apple fixes this bug, you should use SVGKLayeredImageView for this particular SVG file (or avoid using gradients)", [self class]);
	}
	
	if( image.scale != 0.0 )
		DDLogWarn(@"[%@] WARNING: Apple's rendering DOES NOT ALLOW US to render this image correctly using SVGKFastImageView, because Apple's renderInContext method - according to Apple's docs - ignores Apple's own transforms. Until Apple fixes this bug, you should use SVGKLayeredImageView for this particular SVG file (or avoid using scale: you SHOULD INSTEAD be scaling by setting .size on the image, and ensuring that the incoming SVG has either a viewbox or an explicit svg width or svg height)", [self class]);
#endif
	
#if TEMPORARY_WARNING_FOR_FLIPPED_TEXT
	{
		BOOL imageIsTextFree = [SVGKFastImageView svgImageHasNoText:image];
		if (!imageIsTextFree) {
			DDLogWarn(@"[%@] WARNING: There is currently a bug that makes text generated via newCALayerTree on the drawRect: method to be upside-down.", [self class]);
		}
	}
#endif
	
	if (_image) {
		[_image removeObserver:self forKeyPath:@"size" context:(__bridge void *)(internalContextPointerBecauseApplesDemandsIt)];
	}
	_image = image;
	
	[_image addObserver:self forKeyPath:@"size" options:NSKeyValueObservingOptionNew context:(__bridge void *)(internalContextPointerBecauseApplesDemandsIt)];
}


- (void)dealloc
{
	//[self.layer removeObserver:self forKeyPath:@"transform" context:internalContextPointerBecauseApplesDemandsIt];
	[self removeObserver:self forKeyPath:@"image" context:(__bridge void *)(internalContextPointerBecauseApplesDemandsIt)];
	[self removeObserver:self forKeyPath:@"tileRatio" context:(__bridge void *)(internalContextPointerBecauseApplesDemandsIt)];
	[self removeObserver:self forKeyPath:@"showBorder" context:(__bridge void *)(internalContextPointerBecauseApplesDemandsIt)];
	
	self.image = nil;
}

/** Trigger a call to re-display (at higher or lower draw-resolution) (get Apple to call drawRect: again) */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if( [keyPath isEqualToString:@"transform"] &&  CGSizeEqualToSize( CGSizeZero, self.tileRatio ) )
	{
		/*NSLog(@"transform changed. Setting layer scale: %2.2f --> %2.2f", self.layer.contentsScale, self.transform.a);
		 self.layer.contentsScale = self.transform.a;*/
		[self.image.CALayerTree removeFromSuperlayer]; // force apple to redraw?
		[self setNeedsDisplay:YES];
	}
	else
	{
		[self setNeedsDisplay:YES];
	}
}

/**
 NB: this implementation is a bit tricky, because we're extending Apple's concept of a UIView to add "tiling"
 and "automatic rescaling"
 
 */
-(void)drawRect:(NSRect)rect
{
	/**
	 view.bounds == width and height of the view
	 imageBounds == natural width and height of the SVGKImage
	 */
	CGRect imageBounds = CGRectMake( 0,0, self.image.size.width, self.image.size.height );
	
	
	/** Check if tiling is enabled in either direction
	 
	 We have to do this FIRST, because we cannot extend Apple's enum they use for UIViewContentMode
	 (objective-C is a weak language).
	 
	 If we find ANY tiling, we will be forced to skip the UIViewContentMode handling
	 
	 TODO: it would be nice to combine the two - e.g. if contentMode=BottomRight, then do the tiling with
	 the bottom right corners aligned. If = TopLeft, then tile with the top left corners aligned,
	 etc.
	 */
	int cols = ceil(self.tileRatio.width);
	int rows = ceil(self.tileRatio.height);
	
	if( cols < 1 ) // It's meaningless to have "fewer than 1" tiles; this lets us ALSO handle special case of "CGSizeZero == disable tiling"
		cols = 1;
	if( rows < 1 ) // It's meaningless to have "fewer than 1" tiles; this lets us ALSO handle special case of "CGSizeZero == disable tiling"
		rows = 1;
	
	
	CGSize scaleConvertImageToView;
	CGSize tileSize;
	if( cols == 1 && rows == 1 ) // if we are NOT tiling, then obey the UIViewContentMode as best we can!
	{
#ifdef USE_SUBLAYERS_INSTEAD_OF_BLIT
		if( self.image.CALayerTree.superlayer == self.layer )
		{
			[super drawRect:rect];
			return; // TODO: Apple's bugs - they ignore all attempts to force a redraw
		}
		else
		{
			[self.layer addSublayer:self.image.CALayerTree];
			return; // we've added the layer - let Apple take care of the rest!
		}
#else
		scaleConvertImageToView = CGSizeMake( self.bounds.size.width / imageBounds.size.width, self.bounds.size.height / imageBounds.size.height );
		tileSize = self.bounds.size;
#endif
	}
	else
	{
		scaleConvertImageToView = CGSizeMake( self.bounds.size.width / (self.tileRatio.width * imageBounds.size.width), self.bounds.size.height / ( self.tileRatio.height * imageBounds.size.height) );
		tileSize = CGSizeMake( self.bounds.size.width / self.tileRatio.width, self.bounds.size.height / self.tileRatio.height );
	}
	
	//DEBUG: NSLog(@"cols, rows: %i, %i ... scaleConvert: %@ ... tilesize: %@", cols, rows, NSStringFromSize(scaleConvertImageToView), NSStringFromSize(tileSize) );
	/** To support tiling, and to allow internal shrinking, we use renderInContext */
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	for( int k=0; k<rows; k++ )
		for( int i=0; i<cols; i++ )
		{
			CGContextSaveGState(context);
			
			CGContextTranslateCTM(context, i * tileSize.width, k * tileSize.height );
			CGContextScaleCTM( context, scaleConvertImageToView.width, scaleConvertImageToView.height );
			
			CGAffineTransform textTrans = CGContextGetTextMatrix(context);
			//textTrans = CGAffineTransformTranslate(textTrans, 0, tileSize.height);
			textTrans = CGAffineTransformScale(textTrans, 1.0, -1.0);
			CGContextSetTextMatrix(context, textTrans);
			
			[self.image.CALayerTree renderInContext:context];
			
			CGContextRestoreGState(context);
		}
	
	/** The border is VERY helpful when debugging rendering and touch / hit detection problems! */
	if( self.showBorder )
	{
		[[NSColor blackColor] set];
		[NSBezierPath strokeRect:rect];
	}
}

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	self.image.size = frame.size;
}

@end
