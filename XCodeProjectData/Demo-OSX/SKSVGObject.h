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
- (NSString *)fullFileName;

@end

@interface SKSVGObject : NSObject <SKSVGObject>

- (BOOL)isEqualToURL:(NSURL*)theURL;

@end

@interface SKSVGBundleObject : SKSVGObject <SKSVGObject>

@property (retain, readonly) NSBundle *theBundle;
@property (readonly, copy) NSString* fullFileName;
- (id)initWithName:(NSString *)theName;
- (id)initWithName:(NSString *)theName bundle:(NSBundle*)aBundle;

@end

@interface SKSVGURLObject : SKSVGObject <SKSVGObject>

@property (retain, readonly) NSURL *svgURL;

- (id)initWithURL:(NSURL *)aURL;

@end
