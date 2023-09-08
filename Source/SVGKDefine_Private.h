/**
SVGKDefine_Private.h

SVGKDefine define some common macro used for private header.
*/

#ifndef SVGKDefine_Private_h
#define SVGKDefine_Private_h

#import "SVGKDefine.h"
@import OSLog;

// These macro is only used inside framework project, does not expose to public header and effect user's define

#define SVGKIT_LOG_CONTEXT 556

#define SVGKitLogger os_log_create("com.github.svgkit", "SVGKit")

#define SVGKitLogError(frmt, ...)     os_log_with_type(SVGKitLogger, OS_LOG_TYPE_FAULT, frmt, ##__VA_ARGS__);
#define SVGKitLogWarn(frmt, ...)      os_log_with_type(SVGKitLogger, OS_LOG_TYPE_ERROR, frmt, ##__VA_ARGS__);
#define SVGKitLogInfo(frmt, ...)      os_log_with_type(SVGKitLogger, OS_LOG_TYPE_INFO, frmt, ##__VA_ARGS__);
#define SVGKitLogVerbose(frmt, ...)   os_log_with_type(SVGKitLogger, OS_LOG_TYPE_DEBUG, frmt, ##__VA_ARGS__);

#if SVGKIT_MAC
#define NSStringFromCGRect(rect) NSStringFromRect(rect)
#define NSStringFromCGSize(size) NSStringFromSize(size)
#define NSStringFromCGPoint(point) NSStringFromPoint(point)
#endif

#endif /* SVGKDefine_Private_h */
