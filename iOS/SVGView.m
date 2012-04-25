//
//  SVGView.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGView.h"

#import "SVGDocument.h"
#import "SVGDocument+CA.h"

@implementation SVGView

@synthesize document = _document;

- (id)initWithDocument:(SVGDocument *)document {
	NSParameterAssert(document != nil);
	
	self = [self initWithFrame:CGRectMake(0.0f, 0.0f, document.width, document.height)];
	if (self) {
		self.document = document;
	}
	return self;
}

- (void)dealloc {
	[_document release];
	
	[super dealloc];
}

- (void)setDocument:(SVGDocument *)aDocument {
	if (_document != aDocument) {
		[_document release];
		_document = [aDocument retain];

        for (NSInteger i = [self.layer.sublayers count] - 1; i >= 0; i--) {
            CALayer *sublayer = [self.layer.sublayers objectAtIndex:i];
            [sublayer removeFromSuperlayer];
        }

		[self.layer addSublayer:[_document layerTree]];
	}
}

@end
