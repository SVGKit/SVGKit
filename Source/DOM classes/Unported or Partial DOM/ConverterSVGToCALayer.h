#import <Foundation/Foundation.h>
#import <QuartzCore/Quartzcore.h>

@protocol ConverterSVGToCALayer < NSObject >

/*!
 NB: the returned layer has - as its "name" property - the "identifier" property of the SVGElement that created it;
 but that can be overwritten by applications (for valid reasons), so we ADDITIONALLY store the identifier into a
 custom key - kSVGElementIdentifier - on the CALayer. Because it's a custom key, it's (almost) guaranteed not to be
 overwritten / altered by other application code
 */
- (CALayer *) newLayer;
- (void)layoutLayer:(CALayer *)layer;

// TODO: maybe another method filterLayer to implement CIFilters on the layer. On OSX this can be done with layer.filters;
// on iOS this would need to be done via something like http://stackoverflow.com/questions/9701358/applying-a-cifilter-to-a-calayer
// see also https://developer.apple.com/library/ios/documentation/graphicsimaging/Conceptual/CoreImaging/ci_tasks/ci_tasks.html#//apple_ref/doc/uid/TP30001185-CH3-SW3

@end
