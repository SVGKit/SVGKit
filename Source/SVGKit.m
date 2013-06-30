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

+ (SVGKLoggingLevel) logLevel
{
	SVGKLoggingLevel retVal;
	switch (ddLogLevel) {
		case LOG_LEVEL_ERROR:
			retVal = SVGKLoggingError;
			break;
			
		case LOG_LEVEL_INFO:
			retVal = SVGKLoggingInfo;
			break;
			
		case LOG_LEVEL_OFF:
			retVal = SVGKLoggingOff;
			break;
			
		case LOG_LEVEL_VERBOSE:
			retVal = SVGKLoggingVerbose;
			break;
			
		case LOG_LEVEL_WARN:
			retVal = SVGKLoggingWarning;
			break;
			
		default:
			retVal = SVGKLoggingInvalid;
			break;
	}
	return retVal;
}

static dispatch_once_t rawLogLevelToken;

#define RAWLEVELWARNSTR @"[%@] WARN: Only set/get the raw log level if you know what you're doing!"

+ (int) rawLogLevel
{
	dispatch_once(&rawLogLevelToken, ^{
		NSLog(RAWLEVELWARNSTR, self);
	});
	
	return ddLogLevel;
}

+ (void) setRawLogLevel:(int)rawLevel
{
	dispatch_once(&rawLogLevelToken, ^{
		NSLog(RAWLEVELWARNSTR, self);
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
