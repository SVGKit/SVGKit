//
//  SVGEllipseElement.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import <SVGKit/BaseClassForAllSVGBasicShapes.h>

@interface SVGEllipseElement : BaseClassForAllSVGBasicShapes { }

@property (nonatomic, readonly) CGFloat cx;
@property (nonatomic, readonly) CGFloat cy;
@property (nonatomic, readonly) CGFloat rx;
@property (nonatomic, readonly) CGFloat ry;

@end
