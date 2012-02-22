//
//  SVGDocument.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGElement.h"

#import "SVGGroupElement.h"

#import "SVGParser.h"

#if NS_BLOCKS_AVAILABLE
typedef void (^SVGElementAggregationBlock)(SVGElement < SVGLayeredElement > * layeredElement);
#endif

@class SVGDefsElement;

@interface SVGDocument : SVGElement < SVGLayeredElement > {
@private 
    NSMutableDictionary *_styleByClassName; //styles by class name
    NSMutableDictionary *_fillLayersByUrlId; //styles by class name
    NSMutableDictionary *_elementsByClassName; //[className] => (NSSet *)elementsUsingThatStyle
    NSString *_trackClassPrefix; //only elements using classes with this prefix will be tracked
}

// only absolute widths and heights are supported (no percentages)
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly, copy) NSString *version;

// convenience accessors to parsed children
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *desc; // 'description' is reserved by NSObject
@property (nonatomic, readonly) SVGDefsElement *defs;

/*! from the SVG spec, each "g" tag in the XML is a separate "group of graphics things",
 * this dictionary contains a mapping from "value of id attribute" to "SVGGroupElement"
 *
 * see also: anonymousGraphicsGroups (for groups that have no "id=" attribute)
 */
@property (nonatomic, retain) NSDictionary *graphicsGroups;
/*! from the SVG spec, each "g" tag in the XML is a separate "group of graphics things",
 * this array contains all the groups that had no "id=" attribute
 *
 * see also: graphicsGroups (for groups that have an "id=" attribute)
 */
@property (nonatomic, retain) NSArray *anonymousGraphicsGroups;

+ (void) addSVGParserExtension:(NSObject<SVGParserExtension>*) extension;
+ (id)documentNamed:(NSString *)name; // 'name' in mainBundle
+ (id)documentWithContentsOfFile:(NSString *)aPath;
+ (SVGDocument *)sharedDocumentNamed:(NSString *)name trackingPrefix:(NSString *)trackPrefix;

- (id)initWithContentsOfFile:(NSString *)aPath;
- (id)initWithContentsOfFile:(NSString *)aPath trackElementsByClassName:(NSString *)onlyWithPrefix;
- (id)initWithFrame:(CGRect)frame;

- (NSString *)currentFillForClassName:(NSString *)className;
- (NSUInteger)changableColors;

- (BOOL)changeFillForStyle:(NSString *)className toNewFill:(NSString *)fillString;
- (BOOL)changeFillForStyle:(NSString *)className toNewCGColor:(CGColorRef)newColor;


-(NSDictionary *)styleForElement:(SVGElement *)element withClassName:(NSString *) className;
- (void)setStyle:(NSDictionary *)style forClassName:(NSString *)className;

- (void)setFill:(SVGGradientElement *)fillShape forId:(NSString *)idName;
- (CALayer *)useFillId:(NSString *)idName forLayer:(CAShapeLayer *)filledLayer;

#if NS_BLOCKS_AVAILABLE

- (void) applyAggregator:(SVGElementAggregationBlock)aggregator;

#endif

@end
