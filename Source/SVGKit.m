//
//  SVGKit.m
//  SVGKit-iOS
//
//  Created by Devon Blandin on 5/13/13.
//  Copyright (c) 2013 na. All rights reserved.
//

#import "SVGKit.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"

int ddLogLevel =
#if DEBUG
LOG_LEVEL_VERBOSE;
#else
LOG_LEVEL_WARN;
#endif

@implementation SVGKit : NSObject

+ (void) setRawLogLevel:(int)rawLevel
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSLog(@"[%@] WARN: Only set the raw level if you know what you're doing!", self);
	});

	ddLogLevel = rawLevel;
}

+ (void) setLogLevel:(SVGKLoggingLevel)newLevel
{
	switch (newLevel) {
		case SVGKLoggingError:
			ddLogLevel = LOG_LEVEL_ERROR;
			break;
			
		case SVGKLoggingInfo:
			ddLogLevel = LOG_LEVEL_INFO;
			break;
			
		case SVGKLoggingVerbose:
			ddLogLevel = LOG_LEVEL_VERBOSE;
			break;
			
		case SVGKLoggingWarning:
			ddLogLevel = LOG_LEVEL_WARN;
			break;
			
		default:
		case SVGKLoggingOff:
			ddLogLevel = LOG_LEVEL_OFF;
			break;
	}
}

+ (void) enableLogging {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

@end
