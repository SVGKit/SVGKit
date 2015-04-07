#import "SVGUseElement.h"
#import "SVGUseElement_Mutable.h"

@implementation SVGUseElement

@synthesize x;
@synthesize y;
@synthesize width;
@synthesize height;
@synthesize instanceRoot;
@synthesize animatedInstanceRoot;

@synthesize transform; // each SVGElement subclass that conforms to protocol "SVGTransformable" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols

- (void)dealloc {
  [x release];
  [y release];
  [width release];
  [height release];
  [instanceRoot release];
  [animatedInstanceRoot release];
  [super dealloc];
}

-(CALayer *)newLayer
{
	return [[CALayer layer] retain];
}

-(void)layoutLayer:(CALayer *)layer
{
	if( [instanceRoot.correspondingElement respondsToSelector:@selector(layoutLayer:)])
		[((SVGElement<ConverterSVGToCALayer>*)instanceRoot.correspondingElement) layoutLayer:layer];
}

@end
