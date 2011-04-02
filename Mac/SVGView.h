//
//  SVGView.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

@class SVGDocument;

@interface SVGView : NSView { }

@property (nonatomic, retain) SVGDocument *document;

- (id)initWithDocument:(SVGDocument *)document; // set frame to position

@end
