#import "SVGDocumentView.h"


#import "SVGElement.h"

@interface SVGDocumentView()
- (CALayer *)layerWithElement:(SVGElement <SVGLayeredElement> *)element;

@property(nonatomic, retain, readwrite) SVGDocument* svg;
@property(nonatomic, retain, readwrite) CALayer* rootLayer;
@property(nonatomic, retain, readwrite) NSMutableDictionary* layersByElementId;

@end

@implementation SVGDocumentView

@synthesize svg;
@synthesize rootLayer;
@synthesize layersByElementId;

+(SVGDocumentView*) documentViewWithDocument:(SVGDocument*) d
{
	SVGDocumentView* result = [[[SVGDocumentView alloc] initWithDocument:d] autorelease];
	return result;
}

-(id) initWithDocument:(SVGDocument*) d
{
    self = [super init];
    if (self) {
        self.svg = d;
		self.rootLayer = [svg autoreleasedLayer];
		
		self.layersByElementId = [NSMutableDictionary dictionary];
		
		self.rootLayer = [self layerWithElement:self.svg];
		
		[layersByElementId setObject:self.rootLayer forKey:svg.identifier];
		NSLog(@"[%@] ROOT element id: %@ => layer: %@", [self class], svg.identifier, self.rootLayer);
    }
    return self;
}

- (void) dealloc
{
    self.svg = nil;
    self.rootLayer = nil;
    self.layersByElementId = nil;
    
    [super dealloc];
}

- (CALayer *)layerWithElement:(SVGElement <SVGLayeredElement> *)element {
	CALayer *layer = [element autoreleasedLayer];
	
	if (![element.children count]) {
		return layer;
	}
	
	for (SVGElement *child in element.children) {
		if ([child conformsToProtocol:@protocol(SVGLayeredElement)]) {
			CALayer *sublayer = [self layerWithElement:(id<SVGLayeredElement>)child];
			
			if (!sublayer) {
				continue;
            }
			
			[layer addSublayer:sublayer];
			[layersByElementId setObject:sublayer forKey:child.identifier];
			NSLog(@"[%@] element id: %@ => layer: %@", [self class], child.identifier, sublayer);
		}
	}
	
	if (element != self.svg) {
		[element layoutLayer:layer];
	}
	
    [layer setNeedsDisplay];
	
	return layer;
}


@end
