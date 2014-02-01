//
//  SVGGradientLayer.m
//  SVGKit-iOS
//
//  Created by zhen ling tsai on 19/7/13.
//  Copyright (c) 2013 na. All rights reserved.
//

#import "SVGGradientLayer.h"

@implementation SVGGradientLayer

@synthesize maskPath;
@synthesize stopIdentifiers;
@synthesize transform;

- (void)dealloc {
    CGPathRelease(maskPath);
    [stopIdentifiers RELEASE];
    [super DEALLOC];
}

- (void)setMaskPath:(CGPathRef)maskP {
    if (maskP != maskPath) {
        CGPathRelease(maskPath);
        maskPath = CGPathRetain(maskP);
    }
}

- (void)renderInContext:(CGContextRef)ctx {
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, maskPath);
    CGContextClip(ctx);
    if ([self.type isEqualToString:kExt_CAGradientLayerRadial]) {
        
        size_t num_locations = self.locations.count;
        
        size_t numbOfComponents = 0;
        CGColorSpaceRef colorSpace = NULL;
        CGContextConcatCTM(ctx, CGAffineTransformMake(1, 0, 0, 1, self.startPoint.x, self.startPoint.y));
        CGContextConcatCTM(ctx, self.transform);
        CGContextConcatCTM(ctx, CGAffineTransformMake(1, 0, 0, 1, -self.startPoint.x, -self.startPoint.y));
        
        if (self.colors.count) {
            CGColorRef colorRef = (__bridge CGColorRef)[self.colors objectAtIndex:0];
            numbOfComponents = CGColorGetNumberOfComponents(colorRef);
            colorSpace = CGColorGetColorSpace(colorRef);
            
            CGFloat *locations = calloc(num_locations, sizeof(CGFloat));
            CGFloat *components = calloc(num_locations, numbOfComponents * sizeof(CGFloat));
            
            for (int x = 0; x < num_locations; x++) {
                locations[x] = [[self.locations objectAtIndex:x] floatValue];
                const CGFloat *comps = CGColorGetComponents((CGColorRef)[self.colors objectAtIndex:x]);
                for (int y = 0; y < numbOfComponents; y++) {
                    size_t shift = numbOfComponents * x;
                    components[shift + y] = comps[y];
                }
            }
            
            CGPoint position = self.startPoint;
            CGFloat radius = floorf(self.endPoint.x * self.bounds.size.width);
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
            
            CGContextDrawRadialGradient(ctx, gradient, position, 0, position, radius, kCGGradientDrawsAfterEndLocation);
            
            free(locations);
            free(components);
            CGGradientRelease(gradient);
        }
    } else {
        [super renderInContext:ctx];
    }
    CGContextRestoreGState(ctx);
}

- (void)setStopColor:(UIColor *)color forIdentifier:(NSString *)identifier {
    int i = 0;
    for (NSString *key in stopIdentifiers) {
        if ([key isEqualToString:identifier]) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.colors];
            const CGFloat *colors = CGColorGetComponents((CGColorRef)[arr objectAtIndex:i]);
            float a = colors[3];
            const CGFloat *colors2 = CGColorGetComponents(color.CGColor);
            float r = colors2[0];
            float g = colors2[1];
            float b = colors2[2];
            [arr removeObjectAtIndex:i];
            [arr insertObject:(id)[UIColor colorWithRed:r green:g blue:b alpha:a].CGColor atIndex:i];
            [self setColors:[NSArray arrayWithArray:arr]];
            return;
        }
        i++;
    }
}

- (BOOL)containsPoint:(CGPoint)p {
    BOOL boundsContains = CGRectContainsPoint(self.bounds, p);
	if( boundsContains )
	{
		BOOL pathContains = CGPathContainsPoint(self.maskPath, NULL, p, false);
		
		if( pathContains )
		{
			return TRUE;
		}
	}
	return FALSE;
}

@end
