#import <Foundation/Foundation.h>

#import "SVGParser.h"

@interface SVGParserSVG : NSObject <SVGParserExtension> {
    NSMutableDictionary *_graphicsGroups;
	NSMutableArray *_anonymousGraphicsGroups;
    
    @protected
//    NSSet *_supportedTags;
//    NSSet *_supportedNamespaces;
}

@end
