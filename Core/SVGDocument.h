//
//  SVGDocument.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGElement.h"

@class SVGDefsElement;

@interface SVGDocument : SVGElement < SVGLayeredElement > { }

// only absolute widths and heights are supported (no percentages)
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly, copy) NSString *version;

// convenience accessors to parsed children
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *desc; // 'description' is reserved by NSObject
@property (nonatomic, readonly) SVGDefsElement *defs;

+ (id)documentNamed:(NSString *)name; // 'name' in mainBundle
+ (id)documentWithContentsOfFile:(NSString *)aPath;

- (id)initWithContentsOfFile:(NSString *)aPath;
- (id)initWithFrame:(CGRect)frame;

@end
