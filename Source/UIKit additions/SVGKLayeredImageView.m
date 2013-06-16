#import "SVGKLayeredImageView.h"

#import <QuartzCore/QuartzCore.h>

#import "SVGKLayer.h"
#import "BlankSVG.h"

@interface SVGKLayeredImageView()
@property(nonatomic,retain) CAShapeLayer* internalBorderLayer;
@end

@implementation SVGKLayeredImageView
@synthesize internalBorderLayer = _internalBorderLayer;

/** uses the custom SVGKLayer instead of a default CALayer */
+(Class)layerClass
{
	return [SVGKLayer class];
}

- (id)init
{
	NSAssert(false, @"init not supported, use initWithSVGKImage:");
    
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return [self initWithSVGKImage:nil];
}

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if( self )
	{
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (id)initWithSVGKImage:(SVGKImage*) im
{
	if( im == nil )
	{
		DDLogWarn(@"[%@] WARNING: you have initialized an [%@] with a blank image (nil). Possibly because you're using Storyboards or NIBs which Apple won't allow us to decorate. Make sure you assign an SVGKImage to the .image property!", [self class], [self class]);
		
		self = [super initWithFrame:CGRectMake(0,0,100,100)]; // coincides with the inline SVG below!
		if( self )
		{
			self.backgroundColor = [UIColor clearColor];
			
			NSString* svgStringDefaultContents = SVGKsvgStringDefaultContents;
			
			NSLog(@"About to make a blank image using the inlined SVG = %@", svgStringDefaultContents);
			
			SVGKImage* defaultBlankImage = [SVGKImage imageWithSource:[SVGKSource sourceFromContentsOfString:svgStringDefaultContents]];
			
			self.backgroundColor = [UIColor cyanColor];
			
			((SVGKLayer*) self.layer).SVGImage = defaultBlankImage;
		}
	}
	else
	{
		self = [super initWithFrame:CGRectMake( 0,0, im.CALayerTree.frame.size.width, im.CALayerTree.frame.size.height )]; // default: 0,0 to width x height of original image];
		if (self)
		{
			self.backgroundColor = [UIColor clearColor];
			
			((SVGKLayer*) self.layer).SVGImage = im;
			
		}
	}
	
    return self;
}

/** Delegate the call to the internal layer that's coded to handle this stuff automatically */
-(SVGKImage *)image
{
	return ((SVGKLayer*)self.layer).SVGImage;
}
/** Delegate the call to the internal layer that's coded to handle this stuff automatically */
-(void)setImage:(SVGKImage *)image
{
	((SVGKLayer*)self.layer).SVGImage = image;
}

/** Delegate the call to the internal layer that's coded to handle this stuff automatically */
-(BOOL)showBorder
{
	return ((SVGKLayer*)self.layer).showBorder;
}
/** Delegate the call to the internal layer that's coded to handle this stuff automatically */
-(void)setShowBorder:(BOOL)showBorder
{
	((SVGKLayer*)self.layer).showBorder = showBorder;
}

@end
