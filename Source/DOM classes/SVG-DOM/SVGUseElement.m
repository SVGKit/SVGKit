#import "SVGUseElement.h"
#import "SVGUseElement_Mutable.h"

@implementation SVGUseElement

@synthesize x;
@synthesize y;
@synthesize width;
@synthesize height;
@synthesize instanceRoot;
@synthesize animatedInstanceRoot;

-(CALayer *)newLayer
{
	if( [instanceRoot.correspondingElement respondsToSelector:@selector(newLayer)])
	{
		CALayer* initialLayer = [((SVGElement<SVGLayeredElement>*)instanceRoot.correspondingElement) newLayer];
		
		if( CGRectIsEmpty( initialLayer.frame ) ) // Avoid Apple's UIKit getting upset by infinitely large/small areas due to floating point inaccuracy
			return initialLayer;
		
		//For Xcode's broken debugger: CGAffineTransform i = initialLayer.affineTransform;
		//For Xcode's broken debugger: CGAffineTransform mine = self.transformRelative;
		
		initialLayer.affineTransform = CGAffineTransformConcat( self.transformRelative, initialLayer.affineTransform );
		
		return initialLayer;
	}
	else
		return nil;
}

-(void)layoutLayer:(CALayer *)layer
{
	if( [instanceRoot.correspondingElement respondsToSelector:@selector(layoutLayer:)])
		[((SVGElement<SVGLayeredElement>*)instanceRoot.correspondingElement) layoutLayer:layer];
}

@end
