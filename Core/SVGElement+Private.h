//
//  SVGElement+Private.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGElement.h"

@interface SVGElement (Private)

- (void)parseAttributes:(NSDictionary *)attributes;
- (void)addChild:(SVGElement *)element;
- (void)parseContent:(NSString *)content;

@end
