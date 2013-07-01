//
//  SVGKCGFloatAdditions.m
//  SVGKit-OSX
//
//  Created by C.W. Betts on 5/12/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SVGKCGFloatAdditions.h"

@implementation NSString (SVGKCGFloatAdditions)

- (CGFloat)SVGKCGFloatValue
{
#if CGFLOAT_IS_DOUBLE
	return [self doubleValue];
#else
	return [self floatValue];
#endif
}

@end

@implementation NSNumber (SVGKCGFloatAdditions)

- (CGFloat)SVGKCGFloatValue
{
#if CGFLOAT_IS_DOUBLE
	return [self doubleValue];
#else
	return [self floatValue];
#endif

}

@end
