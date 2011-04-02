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

- (CALayer *)layerTree;

@end
