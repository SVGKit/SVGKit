#import "SVGKLayer.h"

@implementation SVGKLayer
{

}

@synthesize SVGImage = _SVGImage;
@synthesize showBorder = _showBorder;

//self.backgroundColor = [UIColor clearColor];

/** Apple requires this to be implemented by CALayer subclasses */
+(id)layer
{
	SVGKLayer* layer = [[[SVGKLayer alloc] init] autorelease];
	return layer;
}

- (id)init
{
    self = [super init];
    if (self)
	{
    	self.borderColor = [UIColor blackColor].CGColor;
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
		[_SVGImage release];
	}
	
	/** 2: update pointer */
	_SVGImage = newImage;
	
	/** 3: add new */
	if( _SVGImage != nil )
	{
		[_SVGImage retain];
		self.startRenderTime = [NSDate date];
		[self addSublayer:_SVGImage.CALayerTree];
		self.endRenderTime = [NSDate date];
	}
}

- (void)setShowBorder:(BOOL)value {
    _showBorder = value;
    [self removeObserver:self forKeyPath:@"showBorder"];
    if (value) {
        [self addObserver:self forKeyPath:@"showBorder" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)dealloc
{
    if (_showBorder) {
        [self removeObserver:self forKeyPath:@"showBorder"];
    }
	self.SVGImage = nil;
	
    [super dealloc];
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
