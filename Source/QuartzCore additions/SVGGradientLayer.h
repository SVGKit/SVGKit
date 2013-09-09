//
//  SVGGradientLayer.h
//  SVGKit-iOS
//
//  Created by zhen ling tsai on 19/7/13.
//  Copyright (c) 2013 na. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import "SVGTransformable.h"

static NSString * const kExt_CAGradientLayerRadial = @"radialGradient";

@interface SVGGradientLayer : CAGradientLayer <SVGTransformable>

@property (nonatomic, readwrite) CGPathRef maskPath;
@property (nonatomic, readwrite, retain) NSArray *stopIdentifiers;

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
- (void)setStopColor:(UIColor *)color forIdentifier:(NSString *)identifier;
#else
- (void)setStopColor:(NSColor *)color forIdentifier:(NSString *)identifier;
#endif
@end
