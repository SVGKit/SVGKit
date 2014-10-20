//
//  CGPathAdditions.m
//  SVGPad
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "CGPathAdditions.h"

void applier (void *info, const CGPathElement *element);

typedef struct {
	CGMutablePathRef path;
	CGFloat offX;
	CGFloat offY;
} PathInfo;

CGFloat fixInfinity(CGFloat inputFloat){
    if(inputFloat>CGFLOAT_MAX) inputFloat=CGFLOAT_MAX;
    if(inputFloat<(-1)*CGFLOAT_MAX) inputFloat=(-1)*CGFLOAT_MAX;
    return inputFloat;
}

CGPoint *fixPointInfinity(CGPoint *inputFloat){
    int i;
    for (i = 0; i < sizeof(inputFloat); ++i)
    {
        inputFloat[0].x=fixInfinity(inputFloat[0].x);
        inputFloat[0].y=fixInfinity(inputFloat[0].y);

    }
    return inputFloat;
}

void applier (void *info, const CGPathElement *element) {
	PathInfo *pathInfo = (PathInfo *) info;
	
	CGMutablePathRef path = pathInfo->path;
	CGFloat x = fixInfinity(pathInfo->offX);
	CGFloat y = fixInfinity(pathInfo->offY);
    
	const CGPoint *points = fixPointInfinity(element->points);
	
	switch (element->type) {
		case kCGPathElementMoveToPoint:
			CGPathMoveToPoint(path, NULL, points[0].x - x, points[0].y - y);
			break;
		case kCGPathElementAddLineToPoint:
			CGPathAddLineToPoint(path, NULL, points[0].x - x, points[0].y - y);
			break;
		case kCGPathElementAddQuadCurveToPoint:
			CGPathAddQuadCurveToPoint(path, NULL, points[0].x - x, points[0].y - y,
									  points[1].x - x, points[1].y - y);
			break;
		case kCGPathElementAddCurveToPoint:
			CGPathAddCurveToPoint(path, NULL, points[0].x - x, points[0].y - y,
								  points[1].x - x, points[1].y - y,
								  points[2].x - x, points[2].y - y);
			break;
		case kCGPathElementCloseSubpath:
			CGPathCloseSubpath(path);
			break;
	}
}

CGPathRef CGPathCreateByOffsettingPath (CGPathRef aPath, CGFloat x, CGFloat y) {
	CGMutablePathRef path = CGPathCreateMutable();
	
	PathInfo *info = (PathInfo *) malloc(sizeof(PathInfo));
	info->path = path;
	info->offX = fixInfinity(x);
	info->offY = fixInfinity(y);
	
	CGPathApply(aPath, info, &applier);
	free(info);
	
	return path;
}

void applyPathTranslation (void *info, const CGPathElement *element) {
	PathInfo *pathInfo = (PathInfo *) info;
	
	CGMutablePathRef path = pathInfo->path;
	CGFloat x = fixInfinity(pathInfo->offX);
	CGFloat y = fixInfinity(pathInfo->offY);
	
	const CGPoint *points = fixPointInfinity(element->points);
	
	switch (element->type) {
		case kCGPathElementMoveToPoint:
			CGPathMoveToPoint(path, NULL, points[0].x + x, points[0].y + y);
			break;
		case kCGPathElementAddLineToPoint:
			CGPathAddLineToPoint(path, NULL, points[0].x + x, points[0].y + y);
			break;
		case kCGPathElementAddQuadCurveToPoint:
			CGPathAddQuadCurveToPoint(path, NULL, points[0].x + x, points[0].y + y,
									  points[1].x + x, points[1].y + y);
			break;
		case kCGPathElementAddCurveToPoint:
			CGPathAddCurveToPoint(path, NULL, points[0].x + x, points[0].y + y,
								  points[1].x + x, points[1].y + y,
								  points[2].x + x, points[2].y + y);
			break;
		case kCGPathElementCloseSubpath:
			CGPathCloseSubpath(path);
			break;
	}
}

CGPathRef CGPathCreateByTranslatingPath (CGPathRef aPath, CGFloat x, CGFloat y) {
	CGMutablePathRef path = CGPathCreateMutable();
	
	PathInfo *info = (PathInfo *) malloc(sizeof(PathInfo));
	info->path = path;
	info->offX = fixInfinity(x);
	info->offY = fixInfinity(y);
	
	CGPathApply(aPath, info, &applyPathTranslation);
	free(info);
	
	return path;
}
