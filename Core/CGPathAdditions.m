//
//  CGPathAdditions.m
//  SVGPad
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "CGPathAdditions.h"

typedef struct {
	CGMutablePathRef path;
	CGFloat offX;
	CGFloat offY;
} PathInfo;

void applier (void *info, const CGPathElement *element) {
	PathInfo *pathInfo = (PathInfo *) info;
	
	CGMutablePathRef path = pathInfo->path;
	CGFloat x = pathInfo->offX;
	CGFloat y = pathInfo->offY;
	
	const CGPoint *points = element->points;
	
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
	info->offX = x;
	info->offY = y;
	
	CGPathApply(aPath, info, &applier);
	free(info);
	
	return path;
}
