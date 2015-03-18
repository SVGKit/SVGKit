#import "SVGKLayeredImageView.h"

#import <QuartzCore/QuartzCore.h>

#import "SVGKSourceString.h"

@interface SVGKLayeredImageView()
@property(nonatomic,retain) CAShapeLayer* internalBorderLayer;
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
		DDLogWarn(@"[%@] WARNING: you have initialized an [%@] with a blank image (nil). Possibly because you're using Storyboards or NIBs which Apple won't allow us to decorate. Make sure you assign an SVGKImage to the .image property!", [self class], [self class]);
		
		self.backgroundColor = [UIColor clearColor];
        
/**
 ************* NB: it is critical that the string we're about to create is NOT INDENTED - the tabs would break the parsing!
 */
		NSString* svgStringDefaultContents = @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
\n\
<svg \
xmlns:svg=\"http://www.w3.org/2000/svg\" \
xmlns=\"http://www.w3.org/2000/svg\" \
width=\"100\" \
height=\"100\" \
id=\"svg2\" \
version=\"1.1\"> \
<defs \
id=\"defs4\" /> \
<metadata \
id=\"metadata7\"> \
</metadata> \
<g \
id=\"layer1\" \
transform=\"translate(0,-952.36218)\"> \
<rect \
style=\"opacity:0.98000003999999996;color:#000000;fill:#bf01ff;fill-opacity:0.99607843;fill-rule:nonzero;stroke:none;stroke-width:3;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate\" \
id=\"rect2985\" \
width=\"100\" \
height=\"100\" \
x=\"0\" \
y=\"952.36218\" /> \
<text \
xml:space=\"preserve\" \
style=\"font-size:40px;font-style:normal;font-weight:normal;line-height:125%;letter-spacing:0px;word-spacing:0px;fill:#f6ff0f;fill-opacity:1;stroke:none;font-family:Sans\" \
x=\"6.3190379\" \
y=\"991.14648\" \
id=\"text3755\" \
><tspan \
x=\"6.3190379\" \
y=\"991.14648\" \
id=\"tspan3759\" \
style=\"font-size:24px;fill:#f6ff0f;fill-opacity:1\">Missing</tspan></text> \
<text \
xml:space=\"preserve\" \
style=\"font-size:40px;font-style:normal;font-weight:normal;line-height:125%;letter-spacing:0px;word-spacing:0px;fill:#fffc45;fill-opacity:1;stroke:none;font-family:Sans\" \
x=\"26.460968\" \
y=\"1030.2456\" \
id=\"text3763\" \
><tspan \
id=\"tspan3765\" \
x=\"26.460968\" \
y=\"1030.2456\" \
style=\"font-size:24px;fill:#fffc45;fill-opacity:1\">SVG</tspan></text> \
</g> \
</svg>";
        
		DDLogInfo(@"About to make a blank image using the inlined SVG = %@", svgStringDefaultContents);
		
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

- (void)dealloc
{
	
    [super dealloc];
}

@end
