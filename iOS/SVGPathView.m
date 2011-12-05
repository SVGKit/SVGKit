//
//  SVGPathView.m
//  SVGKit
//

#import "SVGPathView.h"

#import "SVGElement+Private.h"
#import "SVGDocument.h"
#import "SVGPathElement.h"
#import "SVGShapeElement+Private.h"
#import "CGPathAdditions.h"
#import "SVGDocument+CA.h"

@implementation SVGPathView

@synthesize delegate;
@synthesize pathElement=_pathElement;

- (id)initWithPathElement:(SVGPathElement*)pathElement translateTowardOrigin:(BOOL)shouldTranslate
{
    CGPathRef originalPath = [pathElement path];
    CGRect pathRect = CGRectIntegral(CGPathGetBoundingBox(originalPath));
    CGRect viewRect = CGRectMake(0, 0, CGRectGetWidth(pathRect), CGRectGetHeight(pathRect));
    
    self = [super initWithFrame:viewRect];
    if (self) {
        SVGPathElement* newPathElement = [[SVGPathElement alloc] init];
        
        if (!shouldTranslate) {
            [newPathElement loadPath:originalPath];
        } else {
            CGPathRef translatedPath = CGPathCreateByOffsettingPath(originalPath, pathRect.origin.x, pathRect.origin.y);
            [newPathElement loadPath:translatedPath];
            CGPathRelease(translatedPath);
        }
        
        [newPathElement setIdentifier:pathElement.identifier];
        [newPathElement setOpacity:pathElement.opacity];
        [newPathElement setStrokeColor:pathElement.strokeColor];
        [newPathElement setStrokeWidth:pathElement.strokeWidth];
        [newPathElement setFillType:pathElement.fillType];
        [newPathElement setFillColor:pathElement.fillColor];
        [newPathElement setFillPattern:pathElement.fillPattern];

        _pathElement = newPathElement;
        
        SVGDocument* doc = [[SVGDocument alloc] initWithFrame:viewRect];
        [doc addChild:newPathElement];
        
        [self setDocument:doc];
        
        [newPathElement release]; // retained by doc
        [doc release]; // retained by super
    }
    return self;
}

- (void) handleElement:(SVGPathElement*)pathElem touched:(UITouch*)touch
{
    if ([self.delegate respondsToSelector:@selector(pathView:path:touch:)]) {
        [self.delegate pathView:self path:pathElem touch:touch];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* t = [touches anyObject];
    CGPoint touchPoint = [t locationInView:self];
    
    [self.document applyAggregator:^(SVGElement<SVGLayeredElement> *e) {
        if ([e isKindOfClass:[SVGPathElement class]]) {
            SVGPathElement* pathElem = (SVGPathElement*)e;
            CGPathRef path = pathElem.path;
            if (CGPathContainsPoint(path, NULL, touchPoint, NO)) {
                [self handleElement:pathElem touched:t];
            }
        }
    }];
}

- (CAShapeLayer*) pathElementLayer
{
    return (CAShapeLayer*) [[self document] layerWithIdentifier:self.pathElement.identifier];
}


#if NS_BLOCKS_AVAILABLE

- (void) enumerateChildLayersUsingBlock:(layerTreeEnumerator)callback givenParent:(CALayer*)parentLayer
{
    callback(parentLayer);
    
    for (CALayer* sublayer in [parentLayer sublayers]) {
        [self enumerateChildLayersUsingBlock:callback
                                 givenParent:sublayer];
    }
}

- (void)enumerateChildLayersUsingBlock:(layerTreeEnumerator)callback
{
    [self enumerateChildLayersUsingBlock:callback
                             givenParent:self.layer];
}

#endif

@end
