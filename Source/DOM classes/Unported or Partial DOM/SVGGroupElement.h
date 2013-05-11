//
//  SVGGroupElement.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import <SVGKit/SVGElement.h>
#import <SVGKit/SVGLayeredElement.h>

@interface SVGGroupElement : SVGElement < SVGLayeredElement > { }

@property (nonatomic, readonly) CGFloat opacity;

@end
