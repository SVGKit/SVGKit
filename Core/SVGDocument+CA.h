//
//  SVGDocument+CA.h
//  SVGKit
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "SVGDocument.h"
#import <QuartzCore/QuartzCore.h>

@interface SVGDocument (CA)

- (CALayer *)layerWithIdentifier:(NSString *)identifier;

- (BOOL)hasLayer;
- (CALayer *)layerTree;

- (CALayer *)layerWithIdentifier:(NSString *)identifier layer:(CALayer *)layer;

- (CATiledLayer *)tiledLayer;
- (CALayer *)layerWithElement:(SVGElement < SVGLayeredElement > *)element;

@end
