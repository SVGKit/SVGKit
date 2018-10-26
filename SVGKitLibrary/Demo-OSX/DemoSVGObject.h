//
//  DemoSVGObject.h
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DemoSVGObject <NSObject>

- (NSURL *)svgURL;
- (NSString *)fileName;
- (NSString *)fullFileName;

@end

@interface DemoSVGObject : NSObject <DemoSVGObject>

- (BOOL)isEqualToURL:(NSURL*)theURL;

@end

@interface DemoSVGBundleObject : DemoSVGObject <DemoSVGObject>

@property (readonly, strong) NSBundle *theBundle;
@property (readonly, copy) NSString* fullFileName;
- (id)initWithName:(NSString *)theName;
- (id)initWithName:(NSString *)theName bundle:(NSBundle*)aBundle;

@end

@interface DemoSVGURLObject : DemoSVGObject <DemoSVGObject>

@property (strong, readonly) NSURL *svgURL;

- (id)initWithURL:(NSURL *)aURL;

@end
