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
	
	self = [self initWithFrame:NSMakeRect(0.0f, 0.0f, document.width, document.height)];
	if (self) {
		self.document = document;
	}
	return self;
}

- (BOOL)isFlipped {
	return YES;
}

- (void)dealloc {
	[_document release];
	
	[super dealloc];
}

- (void)setDocument:(SVGDocument *)aDocument {
	if (_document != aDocument) {
		[_document release];
		_document = [aDocument retain];
		
		for (CALayer *sublayer in [self.layer sublayers]) {
			[sublayer removeFromSuperlayer];
		}
		
		[self.layer addSublayer:[_document layerTree]];
	}
}

@end
