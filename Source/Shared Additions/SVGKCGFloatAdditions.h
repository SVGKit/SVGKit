//
//  SVGKCGFloatAdditions.h
//  SVGKit-OSX
//
//  Created by C.W. Betts on 5/12/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

//The SVGK prefix is to prevent possible clashes when/if Apple implements the functions
@interface NSString (SVGKCGFloatAdditions)

@property (nonatomic, readonly) CGFloat SVGKCGFloatValue;

@end

@interface NSNumber (SVGKCGFloatAdditions)

@property (nonatomic, readonly) CGFloat SVGKCGFloatValue;

@end
