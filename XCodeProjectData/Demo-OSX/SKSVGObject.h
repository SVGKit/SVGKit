//
//  SKSVGObject.h
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKSVGObject : NSObject

@property (retain, nonatomic, readonly) NSURL *svgURL;
@property (readonly) NSString *fileName;

- (id)initWithURL:(NSURL *)aURL;

@end
