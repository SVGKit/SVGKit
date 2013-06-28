#import "SVGKLayeredImageView.h"

#import <QuartzCore/QuartzCore.h>

#import "SVGKLayer.h"
#import "BlankSVG.h"

@interface SVGKLayeredImageView()
@property(nonatomic,retain) CAShapeLayer* internalBorderLayer;
@end

@implementation SVGKLayeredImageView
@synthesize internalBorderLayer = _internalBorderLayer;

- (id)init
{
	NSAssert(false, @"init not supported, use initWithSVGKImage:");
    
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return [self initWithSVGKImage:nil frame:CGRectZero];
}

- (void)setUpLayer
{
	self.layer = [SVGKLayer layer];
	self.wantsLayer = YES;
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
		DDLogWarn(@"[%@] WARNING: you have initialized an [%@] with a blank image (nil). Possibly because you're using Storyboards or NIBs which Apple won't allow us to decorate. Make sure you assign an SVGKImage to the .image property!", [self class], [self class]);
		
		self = [super initWithFrame:(!NSEqualRects(theFrame, CGRectZero) ? theFrame : NSMakeRect(0, 0, 100, 100))]; // coincides with the inline SVG below!
		if( self )
		{
			[self setUpLayer];
			
			DDLogInfo(@"About to make a blank image using the inlined SVG = %@", SVGKsvgStringDefaultContents);
			
			SVGKImage* defaultBlankImage = [SVGKImage imageWithSource:[SVGKSource sourceFromContentsOfString:SVGKsvgStringDefaultContents]];
			
			((SVGKLayer*) self.layer).SVGImage = defaultBlankImage;
		}
	}
	else
	{
		if (![im hasSize]) {
			im.size = NSMakeSize(100.0, 100.0);
		}
		
		self = [super initWithFrame:(!NSEqualRects(theFrame, CGRectZero) ? theFrame : (NSRect){CGPointZero, im.CALayerTree.frame.size})]; // default: 0,0 to width x height of original image];
		if (self)
		{
			[self setUpLayer];
			
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
