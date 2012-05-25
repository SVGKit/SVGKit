//
//  SVGView.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVGDocument;

@interface SVGView : UIView { 
    SVGDocument *_document;
}

@property (nonatomic, retain) SVGDocument *document;

- (id)initWithLayer:(CALayer *)layer andDocument:(SVGDocument *)doc;
- (id)initWithDocument:(SVGDocument *)document; // set frame to position

- (void)addSublayerFromDocument:(SVGDocument *)document;

- (void)removeLayers;
- (void)swapLayer:(CALayer *)layer andDocument:(SVGDocument *)doc;

@end
