#import "SVGKLayer.h"

//DW stands for Darwin
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
#define DWBlackColor() [UIColor blackColor].CGColor
#else
#define DWBlackColor() CGColorGetConstantColor(kCGColorBlack)
#endif

@implementation SVGKLayer
{

}

@synthesize SVGImage = _SVGImage;
@synthesize showBorder;

//self.backgroundColor = [UIColor clearColor];

/** Apple requires this to be implemented by CALayer subclasses */
+(id)layer
{
	return [[SVGKLayer alloc] init];
}

- (id)init
{
    self = [super init];
    if (self)
	{
    	self.borderColor = DWBlackColor();
		
		[self addObserver:self forKeyPath:@"showBorder" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}
-(void)setSVGImage:(SVGKImage *) newImage
{
	if( newImage == _SVGImage )
		return;
	
	/** 1: remove old */
	if( _SVGImage != nil )
	{
		[_SVGImage.CALayerTree removeFromSuperlayer];
	}
	
	/** 2: update pointer */
	_SVGImage = newImage;
	
	/** 3: add new */
	if( _SVGImage != nil )
	{
		[self addSublayer:_SVGImage.CALayerTree];
	}
}

- (void)dealloc
{
	//FIXME: Apple crashes on this line, even though BY DEFINITION Apple should not be crashing: [self removeObserver:self forKeyPath:@"showBorder"];
	
	self.SVGImage = nil;
	
}

/** Trigger a call to re-display (at higher or lower draw-resolution) (get Apple to call drawRect: again) */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if( [keyPath isEqualToString:@"showBorder"] )
	{
		if( self.showBorder )
		{
			self.borderWidth = 1.0f;
		}
		else
		{
			self.borderWidth = 0.0f;
		}
		
		[self setNeedsDisplay];
	}
}

@end
