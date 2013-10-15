//
//  CSSSelectors.h
//  SVGKit-iOS
//
//  Created by David Gileadi on 10/15/13.
//  Copyright (c) 2013 na. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGElement.h"

@protocol CSSSelector <NSObject>

- (BOOL)appliesTo:(SVGElement *) element;

@end


@interface CSSSelectorBase : NSObject

@property(nonatomic,retain) NSString *selector;

- (id)initWithSelector:(NSString *) sel;

@end


@interface CSSClassSelector : CSSSelectorBase <CSSSelector>
@end

@interface CSSElementSelector : CSSSelectorBase <CSSSelector>
@end

@interface CSSIdSelector : CSSSelectorBase <CSSSelector>
@end