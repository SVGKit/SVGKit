//
//  SKSVGObject.h
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SKSVGObject <NSObject>

- (NSURL *)svgURL;
- (NSString *)fileName;

@end


@interface SKSVGBundleObject : NSObject <SKSVGObject>

//@property (readonly) NSURL *svgURL;
//@property (readonly) NSString *fileName;

- (id)initWithName:(NSString *)theName;

@end

@interface SKSVGURLObject : NSObject <SKSVGObject>

@property (retain, nonatomic, readonly) NSURL *svgURL;
//@property (readonly) NSString *fileName;

- (id)initWithURL:(NSURL *)aURL;

@end

