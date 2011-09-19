//
//  SVGPathView.m
//  ElectionMeterDemo
//
//  Created by Steven Fusco on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVGPathView.h"

#import "SVGDocument.h"
#import "SVGElement+Private.h"
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
            CFRelease(translatedPath);
        }
        
        [newPathElement setIdentifier:pathElement.identifier];
        [newPathElement setOpacity:pathElement.opacity];
        [newPathElement setStrokeColor:pathElement.strokeColor];
        [newPathElement setStrokeWidth:pathElement.strokeWidth];
        [newPathElement setFillType:pathElement.fillType];
        [newPathElement setFillColor:pathElement.fillColor];

        _pathElement = newPathElement;
        
        SVGDocument* doc = [[SVGDocument alloc] initWithFrame:viewRect];
        [doc addChild:newPathElement];
        
        [self setDocument:doc];
        
        [newPathElement release]; // retained by doc
        [doc release]; // retained by super
    }
    return self;
}

- (void) handleElementTouched:(SVGPathElement*)pathElem atPoint:(CGPoint)touchPoint
{
    if ([self.delegate respondsToSelector:@selector(pathView:pathTouched:atPoint:)]) {
        [self.delegate pathView:self
                    pathTouched:pathElem
                        atPoint:touchPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* t = [touches anyObject];
    CGPoint touchPoint = [t locationInView:self];
    
    for (SVGElement* e in self.document.children) {
        if ([e isKindOfClass:[SVGPathElement class]]) {
            SVGPathElement* pathElem = (SVGPathElement*)e;
            CGPathRef path = pathElem.path;
            if (CGPathContainsPoint(path, NULL, touchPoint, NO)) {
                [self handleElementTouched:pathElem atPoint:touchPoint];
            }
        }
    }
}

- (CAShapeLayer*) pathElementLayer
{
    return (CAShapeLayer*) [[self document] layerWithIdentifier:self.pathElement.identifier];
}
                              
@end
