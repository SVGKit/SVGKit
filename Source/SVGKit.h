/*!
 
 SVGKit - https://github.com/SVGKit/SVGKit
 
 THE MOST IMPORTANT ELEMENTS YOU'LL INTERACT WITH:
 
 1. SVGKImage = contains most of the convenience methods for loading / reading / displaying SVG files
 2. SVGKImageView = the easiest / fastest way to display an SVGKImage on screen
 3. SVGKLayer = the low-level way of getting an SVG as a bunch of layers
 
 SVGKImage makes heavy use of the following classes - you'll often use these classes (most of them given to you by an SVGKImage):
 
 4. SVGKSource = the "file" or "URL" for loading the SVG data
 5. SVGKParseResult = contains the parsed SVG file AND/OR the list of errors during parsing
 
 */

#include <TargetConditionals.h>

#import <SVGKit/DOMHelperUtilities.h>
	#import <SVGKit/SVGCircleElement.h>
	#import <SVGKit/SVGDefsElement.h>
	#import <SVGKit/SVGDescriptionElement.h>
	#import <SVGKit/SVGKImage.h>
	#import <SVGKit/SVGElement.h>
	#import <SVGKit/SVGEllipseElement.h>
	#import <SVGKit/SVGGElement.h>
    #import <SVGKit/SVGImageElement.h>
	#import <SVGKit/SVGLineElement.h>
	#import <SVGKit/SVGPathElement.h>
	#import <SVGKit/SVGPolygonElement.h>
	#import <SVGKit/SVGPolylineElement.h>
	#import <SVGKit/SVGRectElement.h>
	#import <SVGKit/BaseClassForAllSVGBasicShapes.h>
	#import <SVGKit/SVGKSource.h>
	#import <SVGKit/SVGTitleElement.h>
	#import <SVGKit/SVGUtils.h>
    #import <SVGKit/SVGKPattern.h>
	#import <SVGKit/SVGKImageView.h>
	#import <SVGKit/SVGKLayeredImageView.h>
	#import <SVGKit/SVGKLayer.h>
