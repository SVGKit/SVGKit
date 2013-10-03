//
//  SVGGroupElement.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import <SVGKit/SVGElement.h>
#import <SVGKit/ConverterSVGToCALayer.h>

@interface SVGGroupElement : SVGElement < ConverterSVGToCALayer > { }

@property (nonatomic, readonly) CGFloat opacity;

@end
