//
//  SVGKSourceData.h
//  SVGKit-OSX
//
//  Created by C.W. Betts on 6/24/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SVGKSource.h"

@interface SVGKSourceData : SVGKSource

@property (readwrite, retain, nonatomic) NSData *data;

+ (SVGKSource*)sourceFromData:(NSData*)data;

@end
