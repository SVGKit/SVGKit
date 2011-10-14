//
//  SVGDocument+CA.m
//  SVGKit
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "SVGDocument+CA.h"

#import <objc/runtime.h>

@implementation SVGDocument (CA)

static const char *kLayerTreeKey = "svgkit.layertree";

- (CALayer *)layerWithIdentifier:(NSString *)identifier {
	return [self layerWithIdentifier:identifier layer:self.layerTree];
}

- (CALayer *)layerWithIdentifier:(NSString *)identifier layer:(CALayer *)layer {
	if ([layer.name isEqualToString:identifier]) {
		return layer;
	}
	
	for (CALayer *child in layer.sublayers) {
		CALayer *resultingLayer = [self layerWithIdentifier:identifier layer:child];
		
		if (resultingLayer)
			return resultingLayer;
	}
	
	return nil;
}

- (CALayer *)layerTree {
	CALayer *cachedLayerTree = objc_getAssociatedObject(self, (void *) kLayerTreeKey);
	
	if (!cachedLayerTree) {
		cachedLayerTree = [self layerWithElement:self];
		objc_setAssociatedObject(self, (void *) kLayerTreeKey, cachedLayerTree, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return cachedLayerTree;
}

- (CALayer *)layerWithElement:(SVGElement <SVGLayeredElement> *)element {
	CALayer *layer = [element layer];
	
	if (![element.children count]) {
		return layer;
	}
	
	for (SVGElement *child in element.children) {
		if ([child conformsToProtocol:@protocol(SVGLayeredElement)]) {
			CALayer *sublayer = [self layerWithElement:(id<SVGLayeredElement>)child];

			if (!sublayer) {
				continue;
            }

			[layer addSublayer:sublayer];
		}
	}
	
	if (element != self) {
		[element layoutLayer:layer];
	}

    [layer setNeedsDisplay];
	
	return layer;
}

@end
