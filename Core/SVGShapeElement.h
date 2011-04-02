//
//  SVGShapeElement.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGElement.h"
#import "SVGUtils.h"

@class SVGGradientElement;

typedef enum {
	SVGFillTypeNone = 0,
	SVGFillTypeSolid,
} SVGFillType;

@interface SVGShapeElement : SVGElement < SVGLayeredElement > { }

@property (nonatomic, readonly) CGFloat opacity;

@property (nonatomic, readonly) SVGFillType fillType;
@property (nonatomic, readonly) SVGColor fillColor;

@property (nonatomic, readonly) CGFloat strokeWidth;
@property (nonatomic, readonly) SVGColor strokeColor;

@property (nonatomic, readonly) CGPathRef path;

@end
