//
//  NSObject+NSString_CGStrings.h
//  SVGKit-iOS
//
//  Created by CJ Hanson on 4/3/13.
//  Copyright (c) 2013 na. All rights reserved.
//
#if TARGET_OS_IPHONE
#else

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#ifdef __cplusplus
extern "C" {
#endif

static inline NSString * NSStringFromCGRect(CGRect rect)
{
    return NSStringFromRect(NSRectFromCGRect(rect));
}
    
static inline NSString * NSStringFromCGPoint(CGPoint point)
{
    return NSStringFromPoint(NSPointFromCGPoint(point));
}

static inline NSString * NSStringFromCGSize(CGSize size)
{
    return NSStringFromSize(NSSizeFromCGSize(size));
}
    
#ifdef __cplusplus
}
#endif

#endif //mac only