//
//  SVGGradientStop.h
//  SVGPad
//
//  Created by Kevin Stich on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SVGElement.h"

@interface SVGGradientStop : SVGElement

@property (nonatomic, readonly)CGFloat offset;
@property (nonatomic, readonly)CGFloat stopOpacity;
@property (nonatomic, readonly)SVGColor stopColor;

//@property (nonatomic, readonly)NSDictionary *style; //misc unaccounted for properties

-(void)parseAttributes:(NSDictionary *)attributes;

@end
