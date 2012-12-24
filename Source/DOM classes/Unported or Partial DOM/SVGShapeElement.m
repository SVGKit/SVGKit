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
@synthesize fillId = _fillId;

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
	
	if( [[self getAttribute:@"class"] length] > 0 )
		_styleClass = [self getAttribute:@"class"];
	
	if( [[self getAttribute:@"opacity"] length] > 0 )
		_opacity = [[self getAttribute:@"opacity"] floatValue];
	
	if ([[self getAttribute:@"fill"] length] > 0 ) {
		NSString* fill = [self getAttribute:@"fill"];
		
		if ( [fill hasPrefix:@"none"]) {
			_fillType = SVGFillTypeNone;
		}
		else if ( [fill hasPrefix:@"url"] ) {
			_fillType = SVGFillTypeURL;
			NSRange idKeyRange = NSMakeRange(5, fill.length - 6);
			_fillId = [[fill substringWithRange:idKeyRange] retain];
		}
		else {
			_fillColor = SVGColorFromString(fill.cString);
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

-(void)setFillColor:(SVGColor)fillColor
{
	_fillColor = fillColor;
	_fillType = SVGFillTypeSolid;
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
	
	switch( _fillType )
	{
		case SVGFillTypeNone:
		{
		_shapeLayer.fillColor = nil;
		} break;
			
		case SVGFillTypeSolid:
		{
		_shapeLayer.fillColor = CGColorWithSVGColor(_fillColor);
		} break;
			
		case SVGFillTypeURL:
		{
			/** Replace the return layer with a special layer using the URL fill */
			/** fetch the fill layer by URL using the DOM */
			NSAssert( self.rootOfCurrentDocumentFragment != nil, @"This SVG shape has a URL fill type; it needs to search for that URL (%@) inside its nearest-ancestor <SVG> node, but the rootOfCurrentDocumentFragment reference was nil (suggests the parser failed, or the SVG file is corrupt)", _fillId );
			
			SVGGradientElement* svgGradient = (SVGGradientElement*) [self.rootOfCurrentDocumentFragment getElementById:_fillId];
			NSAssert( svgGradient != nil, @"This SVG shape has a URL fill (%@), but could not find an XML Node with that ID inside the DOM tree (suggests the parser failed, or the SVG file is corrupt)", _fillId );
			
			if( _shapeLayer != nil && svgGradient != nil ) //this nil check here is distrubing but blocking
			{
				CAGradientLayer *gradientLayer = (CAGradientLayer *)[svgGradient newLayer];
				
				//            CGRect filledLayerFrame = filledLayer.frame;
				gradientLayer.bounds = self.rootOfCurrentDocumentFragment.viewBoxFrame;
				
				//            docBounds.size.height *= 100.0f;
				/** these are completely wrong, reading the Apple Docs, I don't know
				 how they worked before?
				 
				 gradientLayer.startPoint = relativePosition(gradientLayer.startPoint, gradientLayer.bounds);
				gradientLayer.endPoint = relativePosition(gradientLayer.endPoint, gradientLayer.bounds);
				 */
				
				//[gradientLayer setMask:_shapeLayer];
				return gradientLayer;
			}
		} break;
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

CGPoint relativePosition(CGPoint point, CGRect withRect);
CGPoint relativePosition(CGPoint point, CGRect withRect)
{
	    point.x -= withRect.origin.x;
	    point.y -= withRect.origin.y;
	
	    point.x /= withRect.size.width;
	    point.y /= withRect.size.height;
	    return point;
}

- (void)layoutLayer:(CALayer *)layer { }

@end
