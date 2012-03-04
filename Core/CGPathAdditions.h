//
//  CGPathAdditions.h
//  SVGPad
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#endif

/*! ADAM: I have no idea what this is supposed to mean, but it seems to be "the opposite of translation" */
CGPathRef CGPathCreateByOffsettingPath (CGPathRef aPath, CGFloat x, CGFloat y);

/*! ADAM: created this coherent method that does what it claims to: it translates a path by the specified amount */
CGPathRef CGPathCreateByTranslatingPath (CGPathRef aPath, CGFloat x, CGFloat y);