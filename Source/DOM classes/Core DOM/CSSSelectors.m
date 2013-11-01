//
//  CSSSelectors.m
//  SVGKit-iOS
//
//  Created by David Gileadi on 10/15/13.
//  Copyright (c) 2013 na. All rights reserved.
//

#import "CSSSelectors.h"

@implementation CSSSelectorBase

@synthesize selector;

- (id)initWithSelector:(NSString *) sel
{
    if( self = [super init] )
    {
        self.selector = sel;
    }
    return self;
}

@end

@implementation CSSClassSelector

- (id)initWithSelector:(NSString *) sel
{
    return [super initWithSelector:[sel substringFromIndex:1]];
}

- (BOOL)appliesTo:(SVGElement *) element
{
    return element.className != nil && [element.className isEqualToString:self.selector];
}

@end

@implementation CSSElementSelector

- (BOOL)appliesTo:(SVGElement *) element
{
    return element.nodeName != nil && [element.nodeName isEqualToString:self.selector];
}

@end

@implementation CSSIdSelector

- (id)initWithSelector:(NSString *) sel
{
    return [super initWithSelector:[sel substringFromIndex:1]];
}

- (BOOL)appliesTo:(SVGElement *) element
{
    return element.identifier != nil && [element.identifier isEqualToString:self.selector];
}

@end