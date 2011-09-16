//
//  SVGPathView.m
//  ElectionMeterDemo
//
//  Created by Steven Fusco on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVGPathView.h"

#import "SVGDocument.h"
#import "SVGPathElement.h"

@implementation SVGPathView

@synthesize delegate;

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
                              
@end
