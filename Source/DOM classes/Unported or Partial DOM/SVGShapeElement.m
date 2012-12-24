//
//  SVGShapeElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGShapeElement.h"

#import "CGPathAdditions.h"
#import "SVGDefsElement.h"
#import "SVGKPattern.h"
#import "CAShapeLayerWithHitTest.h"

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

@implementation SVGShapeElement

#define IDENTIFIER_LEN 256

@synthesize opacity = _opacity;

@synthesize fillType = _fillType;
@synthesize fillColor = _fillColor;
@synthesize fillPattern = _fillPattern;

@synthesize strokeWidth = _strokeWidth;
@synthesize strokeColor = _strokeColor;

@synthesize pathRelative = _pathRelative;

- (void)finalize {
	CGPathRelease(_pathRelative);
	[super finalize];
}

- (void)dealloc {
	CGPathRelease(_pathRelative);
    self.fillPattern = nil;
    
	[super dealloc];
}

- (void)loadDefaults {
	_opacity = 1.0f;
	
	_fillColor = SVGColorMake(0, 0, 0, 255);
	_fillType = SVGFillTypeSolid;
}

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult
{
	[super postProcessAttributesAddingErrorsTo:parseResult];
	
	if( [[self getAttribute:@"opacity"] length] > 0 )
	_opacity = [[self getAttribute:@"opacity"] floatValue];
	
	if ([[self getAttribute:@"fill"] length] > 0 ) {
		const char *cvalue = [[self getAttribute:@"fill"] UTF8String];
		
		if (!strncmp(cvalue, "none", 4)) {
			_fillType = SVGFillTypeNone;
		}
		else if (!strncmp(cvalue, "url", 3)) {
			NSLog(@"Gradients are no longer supported");
			_fillType = SVGFillTypeNone;
		}
		else {
			_fillColor = SVGColorFromString(cvalue);
			_fillType = SVGFillTypeSolid;
		}
	}
	
	if( [[self getAttribute:@"stroke-width"] length] > 0 )
		_strokeWidth = [[self getAttribute:@"stroke-width"] floatValue];
	
	if ( [[self getAttribute:@"stroke"] length] > 0 ) {
		const char *cvalue = [[self getAttribute:@"stroke"] UTF8String];
		
		if (!strncmp(cvalue, "none", 4)) {
			_strokeWidth = 0.0f;
		}
		else {
			_strokeColor = SVGColorFromString(cvalue);
			
			if (!_strokeWidth)
				_strokeWidth = 1.0f;
		}
	}
	
	if ([[self getAttribute:@"stroke-opacity"] length] > 0 ) {
		_strokeColor.a = (uint8_t) ([[self getAttribute:@"stroke-opacity"] floatValue] * 0xFF);
	}
	
	if ([[self getAttribute:@"fill-opacity"] length] > 0 ) {
		_fillColor.a = (uint8_t) ([[self getAttribute:@"fill-opacity"] floatValue] * 0xFF);
	}
}

- (void)setPathByCopyingPathFromLocalSpace:(CGPathRef)aPath {
	if (_pathRelative) {
		CGPathRelease(_pathRelative);
		_pathRelative = NULL;
	}
	
	if (aPath) {
		_pathRelative = CGPathCreateCopy(aPath);
	}
}

- (CALayer *) newLayer
{
	CAShapeLayer* _shapeLayer = [[CAShapeLayerWithHitTest layer] retain];
	_shapeLayer.name = self.identifier;
		[_shapeLayer setValue:self.identifier forKey:kSVGElementIdentifier];
	_shapeLayer.opacity = _opacity;
	
	/** transform our LOCAL path into ABSOLUTE space */
	CGAffineTransform transformAbsolute = [self transformAbsolute];
	CGMutablePathRef pathToPlaceInLayer = CGPathCreateMutable();
	CGPathAddPath( pathToPlaceInLayer, &transformAbsolute, _pathRelative);
	
	/** find out the ABSOLUTE BOUNDING BOX of our transformed path */
    //BIZARRE: Apple sometimes gives a different value for this even when transformAbsolute == identity! : CGRect localPathBB = CGPathGetPathBoundingBox( _pathRelative );
	//DEBUG ONLY: CGRect unTransformedPathBB = CGPathGetBoundingBox( _pathRelative );
	CGRect transformedPathBB = CGPathGetBoundingBox( pathToPlaceInLayer );
	
	/** NB: when we set the _shapeLayer.frame, it has a *side effect* of moving the path itself - so, in order to prevent that,
	 because Apple didn't provide a BOOL to disable that "feature", we have to pre-shift the path forwards by the amount it
	 will be shifted backwards */
	CGPathRef finalPath = CGPathCreateByOffsettingPath( pathToPlaceInLayer, transformedPathBB.origin.x, transformedPathBB.origin.y );
	
	/** Can't use this - iOS 5 only! path = CGPathCreateCopyByTransformingPath(path, transformFromSVGUnitsToScreenUnits ); */
	
	_shapeLayer.path = finalPath;
	CGPathRelease(finalPath);
	CGPathRelease(pathToPlaceInLayer);

	/**
	 NB: this line, by changing the FRAME of the layer, has the side effect of also changing the CGPATH's position in absolute
	 space! This is why we needed the "CGPathRef finalPath =" line a few lines above...
	 */
	_shapeLayer.frame = transformedPathBB;
		
	//DEBUG ONLY: CGRect shapeLayerFrame = _shapeLayer.frame;
	
	if (_strokeWidth) {
		/*
		 We have to apply any scale-factor part of the affine transform to the stroke itself (this is bizarre and horrible, yes, but that's the spec for you!)
		 */
		CGSize fakeSize = CGSizeMake( _strokeWidth, 0 );
		fakeSize = CGSizeApplyAffineTransform( fakeSize, transformAbsolute );
		_shapeLayer.lineWidth = fakeSize.width;
		_shapeLayer.strokeColor = CGColorWithSVGColor(_strokeColor);
	}
	else
	{
		_shapeLayer.strokeColor = nil; // This is how you tell Apple that the stroke is disabled; a strokewidth of 0 will NOT achieve this
		_shapeLayer.lineWidth = 0.0f; // MUST set this explicitly, or Apple assumes 1.0
	}
	
	if (_fillType == SVGFillTypeNone) {
		_shapeLayer.fillColor = nil;
	}
	else if (_fillType == SVGFillTypeSolid) {
		_shapeLayer.fillColor = CGColorWithSVGColor(_fillColor);
	}
    
    if (nil != _fillPattern) {
        _shapeLayer.fillColor = [_fillPattern CGColor];
    }
	
	if ([_shapeLayer respondsToSelector:@selector(setShouldRasterize:)]) {
		[_shapeLayer performSelector:@selector(setShouldRasterize:)
					withObject:[NSNumber numberWithBool:YES]];
	}
	
	return _shapeLayer;
}

- (void)layoutLayer:(CALayer *)layer { }

@end
