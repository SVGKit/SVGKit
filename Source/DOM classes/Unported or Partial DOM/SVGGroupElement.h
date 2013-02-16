//
//  SVGGroupElement.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGElement.h"
#import "SVGLayeredElement.h"

@interface SVGGroupElement : SVGElement < SVGLayeredElement > { }

@property (nonatomic, readonly) CGFloat opacity;

@end
