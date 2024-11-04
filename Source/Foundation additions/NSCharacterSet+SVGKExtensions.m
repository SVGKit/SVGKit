//
//  NSCharacterSet+SVGKExtensions.m
//  Avatar
//
//  Created by Devin Chalmers on 3/6/13.
//  Copyright (c) 2013 DJZ. All rights reserved.
//

#import "NSCharacterSet+SVGKExtensions.h"
#import "SVGKDefine_Private.h"

@implementation NSCharacterSet (SVGKExtensions)

/**
 wsp:
 (#x20 | #x9 | #xD | #xA)
 */
+ (NSCharacterSet *)SVGWhitespaceCharacterSet {
	static NSCharacterSet *sWhitespaceCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		SVGKitLogVerbose(@"Allocating static NSCharacterSet containing whitespace characters. Should be small, but Apple seems to take up 5+ megabytes each time?");
		sWhitespaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%c%c%c%c", 0x20, 0x9, 0xD, 0xA]];
		 // required, this is a non-ARC project.
    });
	
    return sWhitespaceCharacterSet;
}

/**
 Returns Apple's whitespace character set with an added comma.
 It's expensive to both create and modify NSCharacterSet, so we ensure it is only done once since this set is used frequently.
 */
+ (NSCharacterSet *)SVGWhitespaceAndCommaCharacterSet {
    static NSCharacterSet *sWhitespaceAndCommaCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *whitespaceSet = [NSMutableCharacterSet whitespaceCharacterSet];
        [whitespaceSet addCharactersInString:@","];
        sWhitespaceAndCommaCharacterSet = whitespaceSet;
    });
    return sWhitespaceAndCommaCharacterSet;
}
/**
 Returns Apple's alphanumeric character set with an added dash and underscore.
 It's expensive to both create and modify NSCharacterSet, so we ensure it is only done once since this set is used frequently.
 */
+ (NSCharacterSet *)SVGAlphanumericAndDashesCharacterSet {
    static NSCharacterSet *sAlphanumericAndDashesCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *alphanumerics = [NSMutableCharacterSet alphanumericCharacterSet];
        [alphanumerics addCharactersInString:@"-_"];
        sAlphanumericAndDashesCharacterSet = alphanumerics;
    });
    return sAlphanumericAndDashesCharacterSet;
}
@end
