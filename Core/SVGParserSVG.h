#import <Foundation/Foundation.h>

#import "SVGParser.h"

@interface SVGParserSVG : NSObject <SVGParserExtension> {
    NSMutableDictionary *_graphicsGroups;
}

@end
