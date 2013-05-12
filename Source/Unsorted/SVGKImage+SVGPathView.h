#import <SVGKit/SVGKImage.h>

/*!
 This extension is used by SVGPathView to make a call recurse down the whole document stack
 
 It is *probably* better to re-factor this somehow, to somewhere - but for backwards compatibility,
 I'm leaving it in, and enabled by default. All the code is encapsulated in this one category, so
 it's pretty clean at the moment
 */

#import <SVGKit/SVGLayeredElement.h>

#if NS_BLOCKS_AVAILABLE
typedef void (^SVGElementAggregationBlock)(SVGElement < SVGLayeredElement > * layeredElement);
#endif

@interface SVGKImage (SVGPathView)

#if NS_BLOCKS_AVAILABLE

- (void) applyAggregator:(SVGElementAggregationBlock)aggregator;

#endif

@end
