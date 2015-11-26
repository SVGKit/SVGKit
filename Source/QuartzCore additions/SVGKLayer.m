#import "SVGKLayer.h"

@implementation SVGKLayer
{

}

@synthesize SVGImage = _SVGImage;
@synthesize showBorder;

//self.backgroundColor = [UIColor clearColor];

/** Apple requires this to be implemented by CALayer subclasses */
+(id)layer
{
	SVGKLayer* layer = [[SVGKLayer alloc] init];
	return layer;
}

- (id)init
{
    self = [super init];
    if (self)
	{
    	self.borderColor = [UIColor blackColor].CGColor;
		
		[self addObserver:self forKeyPath:@"showBorder" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}
-(void)setSVGImage:(SVGKImage *) newImage
{
	if( newImage == _SVGImage )
		return;
	
	self.startRenderTime = self.endRenderTime = nil; // set to nil, so that watchers know it hasn't loaded yet
	
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
		self.startRenderTime = [NSDate date];
		[self addSublayer:_SVGImage.CALayerTree];
		self.endRenderTime = [NSDate date];
	}
}

- (void)dealloc
{
	//FIXME: Apple crashes on this line, even though BY DEFINITION Apple should not be crashing: [self removeObserver:self forKeyPath:@"showBorder"];
	@try {
		[self removeObserver:self forKeyPath:@"showBorder"];
	}
	@catch (NSException *exception) {
		SVGKitLogError(@"Exception removing showBorder observer");
	}
	
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
