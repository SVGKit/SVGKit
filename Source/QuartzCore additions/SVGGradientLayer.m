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

- (id)init
{
	if ((self = [super init]))
	{
		_radialTransform = CGAffineTransformIdentity;
	}
	return self;
}

- (void)dealloc {
    CGPathRelease(maskPath);
    [stopIdentifiers release];
    [super dealloc];
}

- (void)setMaskPath:(CGPathRef)maskP {
    if (maskP != maskPath) {
        CGPathRelease(maskPath);
        maskPath = CGPathRetain(maskP);
    }
}

- (void)renderInContext:(CGContextRef)ctx {
	
    CGContextSaveGState(ctx);

	if (self.maskPath)
	{
		CGContextAddPath(ctx, self.maskPath);
		CGContextClip(ctx);
	}
    if ([self.type isEqualToString:kExt_CAGradientLayerRadial]) {
        
        size_t num_locations = self.locations.count;
        
        //NOT USED: size_t numbOfComponents = 0;
        CGColorSpaceRef colorSpace = NULL;
		
        if (self.colors.count) {
            CGColorRef colorRef = (CGColorRef)[self.colors objectAtIndex:0];
            //NOT USED: numbOfComponents = CGColorGetNumberOfComponents(colorRef);
            colorSpace = CGColorGetColorSpace(colorRef);
            
            CGFloat *locations = calloc(num_locations, sizeof(CGFloat));
            
            for (int x = 0; x < num_locations; x++) {
                locations[x] = [[self.locations objectAtIndex:x] floatValue];
			}
			
			CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) self.colors, locations);
            CGPoint position = self.centerPoint;
			
			CGContextConcatCTM(ctx, self.radialTransform);
			
			CGContextSetAlpha(ctx, self.opacity);
			CGContextDrawRadialGradient(ctx, gradient, position, 0, position, self.radius, kCGGradientDrawsAfterEndLocation);
            
            free(locations);
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
