//
//  SVGKit.m
//  SVGKit-iOS
//
//  Created by Devon Blandin on 5/13/13.
//  Copyright (c) 2013 na. All rights reserved.
//

#import "SVGKit.h"
#import "CocoaLumberjack/DDTTYLogger.h"
#import "CocoaLumberjack/DDASLLogger.h"

#define SVGKIT_LOG_CONTEXT 556

#define SVGKitLogError(frmt, ...)     SYNC_LOG_OBJC_MAYBE(httpLogLevel, LOG_FLAG_ERROR,   SVGKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define SVGKitLogWarn(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(httpLogLevel, LOG_FLAG_WARN,    SVGKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define SVGKitLogInfo(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(httpLogLevel, LOG_FLAG_INFO,    SVGKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define SVGKitLogDebug(frmt, ...)    ASYNC_LOG_OBJC_MAYBE(httpLogLevel, LOG_FLAG_DEBUG,   SVGKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define SVGKitLogVerbose(frmt, ...)  ASYNC_LOG_OBJC_MAYBE(httpLogLevel, LOG_FLAG_VERBOSE, SVGKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)

@implementation SVGKit : NSObject

+ (void) enableLogging {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

@end
