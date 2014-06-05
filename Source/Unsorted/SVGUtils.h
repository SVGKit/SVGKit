//
//  SVGUtils.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#define RGB_N(v) (v) / 255.0

typedef struct {
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
} SVGColor;

SVGColor SVGColorMake (uint8_t r, uint8_t g, uint8_t b, uint8_t a);
SVGColor SVGColorFromString (const char *string);

CGFloat SVGPercentageFromString (const char *string);

CGMutablePathRef createPathFromPointsInString (const char *string, boolean_t close);
CGColorRef CGColorWithSVGColor (SVGColor color);
