//
//  SVGKit.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#include "TargetConditionals.h"

#if TARGET_OS_IPHONE
	#import "SVGCircleElement.h"
	#import "SVGDefsElement.h"
	#import "SVGDescriptionElement.h"
	#import "SVGDocument.h"
	#import "SVGDocument+CA.h"
	#import "SVGElement.h"
	#import "SVGEllipseElement.h"
	#import "SVGGroupElement.h"
    #import "SVGImageElement.h"
	#import "SVGLineElement.h"
	#import "SVGPathElement.h"
	#import "SVGPolygonElement.h"
	#import "SVGPolylineElement.h"
	#import "SVGRectElement.h"
	#import "SVGShapeElement.h"
	#import "SVGTitleElement.h"
	#import "SVGUtils.h"
	#import "SVGView.h"
#else
	#import <SVGKit/SVGCircleElement.h>
	#import <SVGKit/SVGDefsElement.h>
	#import <SVGKit/SVGDescriptionElement.h>
	#import <SVGKit/SVGDocument.h>
	#import <SVGKit/SVGDocument+CA.h>
	#import <SVGKit/SVGElement.h>
	#import <SVGKit/SVGEllipseElement.h>
	#import <SVGKit/SVGGroupElement.h>
    #import <SVGKit/SVGImageElement.h>
	#import <SVGKit/SVGLineElement.h>
	#import <SVGKit/SVGPathElement.h>
	#import <SVGKit/SVGPolygonElement.h>
	#import <SVGKit/SVGPolylineElement.h>
	#import <SVGKit/SVGRectElement.h>
	#import <SVGKit/SVGShapeElement.h>
	#import <SVGKit/SVGTitleElement.h>
	#import <SVGKit/SVGUtils.h>
	#import <SVGKit/SVGView.h>
#endif
