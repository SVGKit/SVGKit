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

#include "TargetConditionals.h"

#import "DOMHelperUtilities.h"
#import "SVGCircleElement.h"
#import "SVGClipPathElement.h"
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
#import "TinySVGTextAreaElement.h"

#import <CocoaLumberjack/CocoaLumberjack.h>

#define SVGKIT_LOG_CONTEXT 556

#define SVGKitLogError(frmt, ...)     SYNC_LOG_OBJC_MAYBE(ddLogLevel, DDLogFlagError,   SVGKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define SVGKitLogWarn(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(ddLogLevel, DDLogFlagWarning,    SVGKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define SVGKitLogInfo(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(ddLogLevel, DDLogFlagInfo,    SVGKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define SVGKitLogDebug(frmt, ...)    ASYNC_LOG_OBJC_MAYBE(ddLogLevel, DDLogFlagDebug,   SVGKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define SVGKitLogVerbose(frmt, ...)  ASYNC_LOG_OBJC_MAYBE(ddLogLevel, DDLogFlagVerbose, SVGKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)


@interface SVGKit : NSObject

+ (void) enableLogging;

@end
