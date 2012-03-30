//
//  SVGGroupElement.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGElement.h"

@interface SVGGroupElement : SVGElement < SVGLayeredElement > { 
//    NSDictionary *_attributes;
}

@property (nonatomic, readonly) NSDictionary *attributes;
@property (nonatomic, readonly) CGFloat opacity;


-(NSDictionary *)fillBlanksInDictionary:(NSDictionary *)highPriority;
-(NSDictionary *)dictionaryByMergingDictionary:(NSDictionary *)lowPriority overridenByDictionary:(NSDictionary *)highPriority;
@end
