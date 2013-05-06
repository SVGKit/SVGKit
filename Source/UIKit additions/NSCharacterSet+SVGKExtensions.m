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
        sWhitespaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%c%c%c%c", 0x20, 0x9, 0xD, 0xA]];
		[sWhitespaceCharacterSet retain]; // required, this is a non-ARC project.
    });
    return sWhitespaceCharacterSet;
}

@end
