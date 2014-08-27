//
//  SVGTextAreaElement.h
//  SVGKit-iOS
//
//  Created by David Gileadi on 8/26/14.
//  Copyright (c) 2014 na. All rights reserved.
//

#import "SVGTextElement.h"

@interface TinySVGTextAreaElement : SVGTextElement

@property(nonatomic,retain,readonly) SVGLength* /* FIXME: should be SVGAnimatedLengthList */ width;
@property(nonatomic,retain,readonly) SVGLength* /* FIXME: should be SVGAnimatedLengthList */ height;

@end
