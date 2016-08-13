#import "SVGKLayeredImageView.h"

#import <QuartzCore/QuartzCore.h>

#import "SVGKSourceString.h"

@interface SVGKLayeredImageView()
@property(nonatomic,strong) CAShapeLayer* internalBorderLayer;
@end

@implementation SVGKLayeredImageView
@synthesize internalBorderLayer = _internalBorderLayer;

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
    if( aDecoder == nil )
	{
		self = [super initWithFrame:CGRectMake(0,0,100,100)]; // coincides with the inline SVG in populateFromImage!
	}
	else
	{
		self = [super initWithCoder:aDecoder];
	}
    if( self )
    {
        [self populateFromImage:nil];
    }
	return self;
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
		self = [super initWithFrame:CGRectMake(0,0,100,100)]; // coincides with the inline SVG in populateFromImage!
	}
	else
	{
		self = [super initWithFrame:CGRectMake( 0,0, im.CALayerTree.frame.size.width, im.CALayerTree.frame.size.height )]; // default: 0,0 to width x height of original image];
	}
    
    if (self)
    {
        [self populateFromImage:im];
    }
    return self;
}

- (void)populateFromImage:(SVGKImage*) im
{
	if( im == nil )
	{
		SVGKitLogWarn(@"[%@] WARNING: you have initialized an [%@] with a blank image (nil). Possibly because you're using Storyboards or NIBs which Apple won't allow us to decorate. Make sure you assign an SVGKImage to the .image property!", [self class], [self class]);
		
		self.backgroundColor = [UIColor clearColor];
        
        NSString* svgStringDefaultContents = @"\
        <svg width=\"100\" height=\"100\" viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"> \
            <rect width=\"100\" height=\"100\" fill=\"#BF01FF\"/> \
        </svg>";
        
		SVGKitLogInfo(@"About to make a blank image using the inlined SVG = %@", svgStringDefaultContents);
		
		SVGKImage* defaultBlankImage = [SVGKImage imageWithSource:[SVGKSourceString sourceFromContentsOfString:svgStringDefaultContents]];
		
		self.backgroundColor = [UIColor cyanColor];
		
		((SVGKLayer*) self.layer).SVGImage = defaultBlankImage;
	}
	else
	{
		self.backgroundColor = [UIColor clearColor];
		
		((SVGKLayer*) self.layer).SVGImage = im;
	}
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

-(NSTimeInterval)timeIntervalForLastReRenderOfSVGFromMemory
{
	return[((SVGKLayer*)self.layer).endRenderTime timeIntervalSinceDate:((SVGKLayer*)self.layer).startRenderTime];
}


@end
