//
//  SVGDocument+CA.m
//  SVGKit
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "SVGDocument+CA.h"

#import <objc/runtime.h>

@implementation SVGDocument (CA)

//added as private prop to SVGDocument to help debug cleanup, feel free to readd
//static const char *kLayerTreeKey = "svgkit.layertree";
- (BOOL)hasLayer
{
    return _layerTree != nil;
}

- (CALayer *)layerWithIdentifier:(NSString *)identifier 
{
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
//	CALayer *cachedLayerTree = objc_getAssociatedObject(self, (void *) kLayerTreeKey);
	
	if (_layerTree == nil) {
		_layerTree = [[self layerWithElement:self] retain];
//		objc_setAssociatedObject(self, (void *) kLayerTreeKey, cachedLayerTree, OBJC_ASSOCIATION_ASSIGN);
	}
	
	return _layerTree;
}

- (CATiledLayer *)tiledLayer
{
	CATiledLayer *layer = [CATiledLayer layer];
	
	if (![self.children count]) {
		return layer;
	}
	
    IMP layerWithElement = [self methodForSelector:@selector(layerWithElement:)];
    
	for (SVGElement *child in self.children) {
		if ([child conformsToProtocol:@protocol(SVGLayeredElement)]) {
			CALayer *sublayer = layerWithElement(self, _cmd, child);//[self layerWithElement:(id<SVGLayeredElement>)child];
            
			if (!sublayer) {
				continue;
            }
            
			[layer addSublayer:sublayer];
		}
	}
	
//	if (element != self) {
//		[element layoutLayer:layer];
//	}
    
    [layer setNeedsDisplay];
	
	return layer;
}

- (CALayer *)layerWithElement:(SVGElement <SVGLayeredElement> *)element {
	CALayer *layer = [element autoreleasedLayer];
	
	if (![element.children count]) {
		return layer;
	}
	
    IMP layerWithElement = [self methodForSelector:_cmd];
    
	for (SVGElement *child in element.children) {
		if ([child conformsToProtocol:@protocol(SVGLayeredElement)]) {
			CALayer *sublayer = layerWithElement(self, _cmd, child);//[self layerWithElement:(id<SVGLayeredElement>)child];

			if (!sublayer) {
				continue;
            }

			[layer addSublayer:sublayer];
		}
	}
	
	if (element != self) {
		[element layoutLayer:layer];
	}
    else
        [layer setBounds:CGRectMake(0, 0, self.width, self.height)];
    
    [layer setNeedsDisplay];
	return layer;
}

@end
