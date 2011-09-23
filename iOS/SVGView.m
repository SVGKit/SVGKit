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
		
        NSArray* sublayerArray = [[self.layer sublayers] copy];
		for (CALayer *sublayer in sublayerArray) {
			[sublayer removeFromSuperlayer];
		}
        [sublayerArray release];
		
		[self.layer addSublayer:[_document layerTree]];
	}
}

@end
