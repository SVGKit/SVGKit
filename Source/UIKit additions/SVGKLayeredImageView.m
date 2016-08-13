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
#ifndef SVGK_DONT_USE_EMPTY_IMAGE_PLACEHOLDER
        SVGKitLogWarn(@"[%@] WARNING: you have initialized an [%@] with a blank image (nil). Possibly because you're using Storyboards or NIBs which Apple won't allow us to decorate. Make sure you assign an SVGKImage to the .image property!", [self class], [self class]);
		
		self.backgroundColor = [UIColor clearColor];
        
        NSString* svgStringDefaultContents = @"\
        <svg width=\"100\" height=\"100\" viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"> \
            <rect width=\"100\" height=\"100\" fill=\"#BF01FF\"/> \
            <path d=\"M11.77 18.42L15.11 18.42 20.05 32.98 24.96 18.42 28.27 18.42 28.27 35.64 26.05 35.64 26.05 25.48C26.05 25.13 26.06 24.54 26.08 23.73 26.09 22.92 26.1 22.05 26.1 21.12L21.19 35.64 18.88 35.64 13.94 21.12 13.94 21.65C13.94 22.07 13.95 22.71 13.97 23.57 13.99 24.44 14 25.07 14 25.48L14 35.64 11.77 35.64 11.77 18.42ZM31.54 23.15L33.68 23.15 33.68 35.64 31.54 35.64 31.54 23.15ZM31.54 18.42L33.68 18.42 33.68 20.81 31.54 20.81 31.54 18.42ZM38.13 31.7C38.19 32.4 38.36 32.94 38.65 33.32 39.18 34 40.11 34.34 41.42 34.34 42.2 34.34 42.89 34.17 43.48 33.83 44.07 33.49 44.37 32.96 44.37 32.25 44.37 31.71 44.13 31.3 43.66 31.02 43.35 30.85 42.75 30.65 41.85 30.42L40.18 30C39.11 29.74 38.32 29.44 37.81 29.11 36.9 28.54 36.45 27.75 36.45 26.74 36.45 25.56 36.88 24.59 37.73 23.86 38.59 23.13 39.74 22.76 41.18 22.76 43.07 22.76 44.44 23.31 45.27 24.42 45.8 25.13 46.05 25.88 46.04 26.7L44.04 26.7C44 26.22 43.84 25.79 43.54 25.4 43.05 24.84 42.21 24.56 41.02 24.56 40.22 24.56 39.62 24.72 39.21 25.02 38.8 25.33 38.59 25.73 38.59 26.23 38.59 26.77 38.86 27.21 39.4 27.54 39.71 27.74 40.18 27.91 40.79 28.06L42.18 28.4C43.7 28.76 44.71 29.12 45.23 29.46 46.05 30 46.46 30.85 46.46 32.01 46.46 33.12 46.03 34.09 45.19 34.9 44.34 35.71 43.05 36.12 41.31 36.12 39.45 36.12 38.12 35.69 37.35 34.85 36.57 34 36.15 32.95 36.1 31.7L38.13 31.7ZM50.13 31.7C50.19 32.4 50.36 32.94 50.65 33.32 51.18 34 52.11 34.34 53.42 34.34 54.2 34.34 54.89 34.17 55.48 33.83 56.07 33.49 56.37 32.96 56.37 32.25 56.37 31.71 56.13 31.3 55.66 31.02 55.35 30.85 54.75 30.65 53.85 30.42L52.18 30C51.11 29.74 50.32 29.44 49.81 29.11 48.9 28.54 48.45 27.75 48.45 26.74 48.45 25.56 48.88 24.59 49.73 23.86 50.59 23.13 51.74 22.76 53.18 22.76 55.07 22.76 56.44 23.31 57.27 24.42 57.8 25.13 58.05 25.88 58.04 26.7L56.04 26.7C56 26.22 55.84 25.79 55.54 25.4 55.05 24.84 54.21 24.56 53.02 24.56 52.22 24.56 51.62 24.72 51.21 25.02 50.8 25.33 50.59 25.73 50.59 26.23 50.59 26.77 50.86 27.21 51.4 27.54 51.71 27.74 52.18 27.91 52.79 28.06L54.18 28.4C55.7 28.76 56.71 29.12 57.23 29.46 58.05 30 58.46 30.85 58.46 32.01 58.46 33.12 58.03 34.09 57.19 34.9 56.34 35.71 55.05 36.12 53.31 36.12 51.45 36.12 50.12 35.69 49.35 34.85 48.57 34 48.15 32.95 48.1 31.7L50.13 31.7ZM60.87 23.15L63.02 23.15 63.02 35.64 60.87 35.64 60.87 23.15ZM60.87 18.42L63.02 18.42 63.02 20.81 60.87 20.81 60.87 18.42ZM66.2 23.09L68.21 23.09 68.21 24.87C68.8 24.13 69.43 23.61 70.09 23.29 70.76 22.97 71.5 22.81 72.31 22.81 74.09 22.81 75.29 23.43 75.92 24.67 76.26 25.35 76.43 26.32 76.43 27.59L76.43 35.64 74.29 35.64 74.29 27.73C74.29 26.96 74.18 26.34 73.95 25.88 73.57 25.09 72.89 24.7 71.91 24.7 71.41 24.7 71 24.76 70.68 24.86 70.1 25.03 69.59 25.37 69.16 25.89 68.8 26.3 68.58 26.73 68.47 27.17 68.37 27.61 68.31 28.24 68.31 29.06L68.31 35.64 66.2 35.64 66.2 23.09ZM86.56 23.59C86.96 23.86 87.36 24.26 87.78 24.79L87.78 23.2 89.72 23.2 89.72 34.62C89.72 36.21 89.49 37.47 89.02 38.39 88.14 40.09 86.49 40.95 84.06 40.95 82.71 40.95 81.57 40.64 80.65 40.04 79.73 39.43 79.21 38.49 79.11 37.2L81.25 37.2C81.35 37.76 81.55 38.19 81.86 38.5 82.34 38.97 83.09 39.2 84.11 39.2 85.73 39.2 86.79 38.63 87.29 37.49 87.58 36.82 87.72 35.62 87.7 33.89 87.27 34.53 86.77 35.01 86.17 35.32 85.58 35.63 84.79 35.79 83.82 35.79 82.46 35.79 81.27 35.31 80.25 34.34 79.23 33.38 78.72 31.78 78.72 29.56 78.72 27.45 79.23 25.81 80.26 24.63 81.29 23.45 82.53 22.86 83.98 22.86 84.96 22.86 85.82 23.11 86.56 23.59L86.56 23.59ZM86.82 25.85C86.18 25.1 85.36 24.73 84.37 24.73 82.88 24.73 81.87 25.42 81.32 26.81 81.03 27.56 80.89 28.53 80.89 29.73 80.89 31.15 81.17 32.22 81.75 32.96 82.32 33.7 83.09 34.07 84.06 34.07 85.58 34.07 86.64 33.38 87.26 32.02 87.61 31.24 87.78 30.34 87.78 29.31 87.78 27.75 87.46 26.6 86.82 25.85L86.82 25.85Z\" fill=\"#F8E81C\"/> \
            <path d=\"M28.35 64.08C28.41 65.06 28.64 65.85 29.04 66.46 29.82 67.6 31.18 68.17 33.13 68.17 34.01 68.17 34.8 68.05 35.52 67.8 36.91 67.31 37.61 66.45 37.61 65.2 37.61 64.26 37.32 63.59 36.73 63.19 36.14 62.8 35.21 62.46 33.94 62.17L31.61 61.65C30.09 61.3 29.01 60.92 28.38 60.51 27.28 59.79 26.73 58.72 26.73 57.29 26.73 55.74 27.27 54.47 28.34 53.48 29.41 52.49 30.93 51.99 32.89 51.99 34.69 51.99 36.22 52.42 37.49 53.3 38.75 54.17 39.38 55.56 39.38 57.47L37.19 57.47C37.07 56.55 36.82 55.84 36.44 55.35 35.73 54.45 34.52 54.01 32.82 54.01 31.44 54.01 30.45 54.29 29.85 54.87 29.25 55.45 28.95 56.12 28.95 56.89 28.95 57.73 29.3 58.35 30 58.74 30.46 58.99 31.51 59.3 33.13 59.68L35.55 60.23C36.71 60.49 37.61 60.86 38.24 61.32 39.34 62.12 39.88 63.29 39.88 64.82 39.88 66.73 39.19 68.09 37.8 68.91 36.42 69.73 34.8 70.14 32.97 70.14 30.83 70.14 29.15 69.59 27.94 68.5 26.73 67.42 26.14 65.94 26.16 64.08L28.35 64.08ZM44.2 52.42L49.14 67.08 54.03 52.42 56.64 52.42 50.36 69.64 47.89 69.64 41.62 52.42 44.2 52.42ZM70.48 52.92C72.19 53.81 73.24 55.39 73.62 57.64L71.31 57.64C71.03 56.38 70.45 55.46 69.57 54.89 68.68 54.32 67.57 54.03 66.23 54.03 64.63 54.03 63.29 54.63 62.2 55.82 61.11 57.02 60.57 58.8 60.57 61.17 60.57 63.21 61.02 64.88 61.91 66.16 62.81 67.45 64.28 68.09 66.31 68.09 67.86 68.09 69.15 67.64 70.17 66.74 71.19 65.84 71.71 64.38 71.73 62.36L66.34 62.36 66.34 60.43 73.9 60.43 73.9 69.64 72.4 69.64 71.84 67.42C71.05 68.29 70.35 68.89 69.74 69.23 68.72 69.81 67.42 70.09 65.84 70.09 63.8 70.09 62.05 69.43 60.58 68.11 58.98 66.46 58.18 64.18 58.18 61.29 58.18 58.41 58.96 56.12 60.52 54.42 62 52.79 63.93 51.98 66.29 51.98 67.9 51.98 69.3 52.29 70.48 52.92L70.48 52.92Z\" fill=\"#F8E81C\"/> \
        </svg>";
        
		SVGKitLogInfo(@"About to make a blank image using the inlined SVG = %@", svgStringDefaultContents);
		
		SVGKImage* defaultBlankImage = [SVGKImage imageWithSource:[SVGKSourceString sourceFromContentsOfString:svgStringDefaultContents]];
		
		self.backgroundColor = [UIColor cyanColor];
		
		((SVGKLayer*) self.layer).SVGImage = defaultBlankImage;
#endif
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
