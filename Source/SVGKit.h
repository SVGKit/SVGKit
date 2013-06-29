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

//Include this code snippet on OS X to get the source code that includes SVGKit headers to work
//There is a naming conflict with the AIFF header that needs to be worked around.
#if !TARGET_OS_IPHONE
#define Comment AIFFComment
#include <CoreServices/CoreServices.h>
#undef Comment
#endif

#import "DOMHelperUtilities.h"
#import "SVGCircleElement.h"
#import "SVGDefsElement.h"
#import "SVGDescriptionElement.h"
#import "SVGKImage.h"
#import "SVGElement.h"
#import "SVGEllipseElement.h"
#import "SVGGElement.h"
#import "SVGImageElement.h"
#import "SVGLineElement.h"
#import "SVGPathElement.h"
#import "SVGPolygonElement.h"
#import "SVGPolylineElement.h"
#import "SVGRectElement.h"
#import "BaseClassForAllSVGBasicShapes.h"
#import "SVGKSource.h"
#import "SVGTitleElement.h"
#import "SVGUtils.h"
#import "SVGKPattern.h"
#import "SVGKImageView.h"
#import "SVGKFastImageView.h"
#import "SVGKLayeredImageView.h"
#import "SVGKLayer.h"
#if !TARGET_OS_IPHONE
#import "SVGKImageRep.h"
#endif

typedef enum _SVGKLoggingLevel
{
	SVGKLoggingOff = 0,
	SVGKLoggingInfo,
	SVGKLoggingWarning,
	SVGKLoggingError,
	SVGKLoggingVerbose
	
} SVGKLoggingLevel;

@interface SVGKit : NSObject

+ (void) enableLogging;
+ (void) setLogLevel:(SVGKLoggingLevel)newLevel;
+ (void) setRawLogLevel:(int)rawLevel;

@end
