//
//  SVGParserLinearGradient.h
//  SVGPad
//
//  Created by Kevin Stich on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGParserSVG.h"


@class SVGGradientElement;

@interface SVGParserGradient : SVGParserSVG {
    SVGGradientElement *currentElement;
}

@end
