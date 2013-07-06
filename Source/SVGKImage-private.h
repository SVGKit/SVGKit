//
//  SVGKImage-private.h
//  SVGKit-OSX
//
//  Created by C.W. Betts on 7/6/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <SVGKit/SVGKImage.h>
@interface SVGKImage ()
/**
 Lowest-level code used by all the "export" methods and by the ".UIImage", ".CIImage", and ".NSImage" property
 
 @param shouldAntialias = Apple defaults to TRUE, but turn it off for small speed boost
 @param multiplyFlatness = how many pixels a curve can be flattened by (Apple's internal setting) to make it faster to render but less accurate
 @param interpolationQuality = Apple internal setting, c.f. Apple docs for CGInterpolationQuality
 */
-(void) renderToContext:(CGContextRef) context antiAliased:(BOOL) shouldAntialias curveFlatnessFactor:(CGFloat) multiplyFlatness interpolationQuality:(CGInterpolationQuality) interpolationQuality flipYaxis:(BOOL) flipYaxis;
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
-(UIImage *) exportUIImageAntiAliased:(BOOL) shouldAntialias curveFlatnessFactor:(CGFloat) multiplyFlatness interpolationQuality:(CGInterpolationQuality) interpolationQuality showInfo:(BOOL)theWarn;
#else
- (NSBitmapImageRep *)exportBitmapImageRepAntiAliased:(BOOL) shouldAntialias curveFlatnessFactor:(CGFloat) multiplyFlatness interpolationQuality:(CGInterpolationQuality) interpolationQuality showInfo:(BOOL)warn;
#endif
@end
