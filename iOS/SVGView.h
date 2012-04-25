//
//  SVGView.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVGDocument;

@interface SVGView : UIView { }

@property (nonatomic, retain) SVGDocument *document;

- (id)initWithDocument:(SVGDocument *)document; // set frame to position

@end
