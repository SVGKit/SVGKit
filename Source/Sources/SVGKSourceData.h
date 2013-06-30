//
//  SVGKSourceData.h
//  SVGKit-OSX
//
//  Created by C.W. Betts on 6/24/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SVGKSource.h"

@interface SVGKSourceData : SVGKSource <NSCopying>

@property (readonly, strong, nonatomic) NSData *data;

- (id)initFromData:(NSData*)data DEPRECATED_ATTRIBUTE;
- (id)initWithData:(NSData*)data;
+ (SVGKSource*)sourceFromData:(NSData*)data;

@end
