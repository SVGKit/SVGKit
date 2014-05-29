//
//  NSCharacterSet+SVGKExtensions.m
//  Avatar
//
//  Created by Devin Chalmers on 3/6/13.
//  Copyright (c) 2013 DJZ. All rights reserved.
//

#import "NSCharacterSet+SVGKExtensions.h"

@implementation NSCharacterSet (SVGKExtensions)

/**
 wsp:
 (#x20 | #x9 | #xD | #xA)
 */
+ (NSCharacterSet *)SVGWhitespaceCharacterSet;
{
	static NSCharacterSet *sWhitespaceCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		DDLogVerbose(@"Allocating static NSCharacterSet containing whitespace characters. Should be small, but Apple seems to take up 5+ megabytes each time?");
		sWhitespaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\x20\x9\xD\xA"];
    });
	
    return sWhitespaceCharacterSet;
}

@end
