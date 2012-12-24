//
//  SVGRectElement.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGShapeElement.h"

@interface SVGRectElement : SVGShapeElement { }

@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;

@property (nonatomic, readonly) CGFloat rx;
@property (nonatomic, readonly) CGFloat ry;

@end
