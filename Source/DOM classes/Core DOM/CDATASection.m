//
//  CDATASection.m
//  SVGKit
//
//  Created by adam on 22/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SVGKit/CDATASection.h>

@implementation CDATASection

- (instancetype)initWithValue:(NSString*) v
{
    self = [super initType:DOMNodeType_CDATA_SECTION_NODE name:@"#cdata-section" value:v];
    if (self) {
    }
    return self;
}
@end
