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

- (id)initWithLayer:(CALayer *)layer andDocument:(SVGDocument *)doc
{
    self = [self initWithFrame:[layer frame]];
    if( self != nil )
    {
        _document = [doc retain];
        [self.layer addSublayer:layer];
    }
    return self;
}

- (id)initWithDocument:(SVGDocument *)document {
	NSParameterAssert(document != nil);
	
	self = [self initWithFrame:CGRectMake(0.0f, 0.0f, document.width, document.height)];
	if (self) {
		[self setDocument:document];
	}
	return self;
}


- (void)dealloc {
	[_document release];
	
	[super dealloc];
}

- (void)swapLayer:(CALayer *)layer andDocument:(SVGDocument *)doc
{
    for (NSInteger i = [self.layer.sublayers count] - 1; i >= 0; i--) {
        CALayer *sublayer = [self.layer.sublayers objectAtIndex:i];
        [sublayer removeFromSuperlayer];
    }
    if(doc != _document)
    {
        [_document release];
        _document = [doc retain];
    }
    
    [self setTransform:CGAffineTransformIdentity];
    [self.layer setTransform:CATransform3DIdentity];
    [self setFrame:layer.frame];
    
    [self.layer addSublayer:layer];
}


- (void)setDocument:(SVGDocument *)aDocument {
	if (_document != aDocument) {
//        [self swapLayer:[_document layerTree] andDocument:aDocument];
//        [self swapLayer:[_document layerWithElement:_document] andDocument:aDocument];
		[_document release];
		_document = [aDocument retain];

        for (NSInteger i = [self.layer.sublayers count] - 1; i >= 0; i--) {
            CALayer *sublayer = [self.layer.sublayers objectAtIndex:i];
            [sublayer removeFromSuperlayer];
        }

		[self.layer addSublayer:[_document layerTree]];
	}
}

- (void)removeLayers
{
    for (NSInteger i = [self.layer.sublayers count] - 1; i >= 0; i--) {
        CALayer *sublayer = [self.layer.sublayers objectAtIndex:i];
        [sublayer removeFromSuperlayer];
    }
}

- (void)addSublayerFromDocument:(SVGDocument *)document
{
    [self.layer addSublayer:[document layerTree]];
}

@end
