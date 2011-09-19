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

@property (nonatomic, readwrite) CGFloat opacity;

@property (nonatomic, readwrite) SVGFillType fillType;
@property (nonatomic, readwrite) SVGColor fillColor;

@property (nonatomic, readwrite) CGFloat strokeWidth;
@property (nonatomic, readwrite) SVGColor strokeColor;

@property (nonatomic, readonly) CGPathRef path;

@end
