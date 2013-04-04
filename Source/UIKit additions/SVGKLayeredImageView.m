#import "SVGKLayeredImageView.h"

#import <QuartzCore/QuartzCore.h>

@interface SVGKLayeredImageView()
@property(nonatomic,retain) CAShapeLayer* internalBorderLayer;
@end

@implementation SVGKLayeredImageView

/** uses the custom SVGKLayer instead of a default CALayer */
+(Class)layerClass
{
	return NSClassFromString(@"SVGKLayer");
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
#if TARGET_OS_IPHONE
		self.backgroundColor = [UIColor clearColor];
#else
        //clear by default
#endif
	}
	return self;
}

- (id)initWithSVGKImage:(SVGKImage*) im
{
	if( im == nil )
	{
		NSLog(@"[%@] WARNING: you have initialized an [%@] with a blank image (nil). Possibly because you're using Storyboards or NIBs which Apple won't allow us to decorate. Make sure you assign an SVGKImage to the .image property!", [self class], [self class]);
	}
	
    self = [super init];
    if (self)
	{
		self.frame = CGRectMake( 0,0, im.CALayerTree.frame.size.width, im.CALayerTree.frame.size.height ); // default: 0,0 to width x height of original image
#if TARGET_OS_IPHONE
		self.backgroundColor = [UIColor clearColor];
#else
        //clear by default
#endif
		
		((SVGKLayer*) self.layer).SVGImage = im;
		
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

- (void)dealloc
{
	
    [super dealloc];
}

@end
