//
//  SVGGroupElement.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGElement.h"

@interface SVGGroupElement : SVGElement < SVGLayeredElement > { 
    BOOL _hasFill;
}

@property (nonatomic, readonly) CGFloat opacity;
@property (nonatomic, readonly) SVGColor fill;

@end
