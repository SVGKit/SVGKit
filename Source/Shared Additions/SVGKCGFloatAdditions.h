//
//  SVGKCGFloatAdditions.h
//  SVGKit-OSX
//
//  Created by C.W. Betts on 5/12/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SVGKCGFloatAdditions)

- (CGFloat)SVGKCGFloatValue;

@end

@interface NSNumber (SVGKCGFloatAdditions)

- (CGFloat)SVGKCGFloatValue;

@end
