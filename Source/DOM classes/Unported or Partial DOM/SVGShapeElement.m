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

@synthesize fillOpacity = _fillOpacity;
@synthesize strokeOpacity = _strokeOpacity;

@synthesize fillPattern = _fillPattern;

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
	_fillOpacity = 1.0f;
}

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult
{
	[super postProcessAttributesAddingErrorsTo:parseResult];
	
	if( [[self getAttribute:@"class"] length] > 0 )
		_styleClass = [self getAttribute:@"class"];
	
	if( [[self getAttribute:@"opacity"] length] > 0 )
		_opacity = [[self getAttribute:@"opacity"] floatValue];
		
	if ([[self getAttribute:@"stroke-opacity"] length] > 0 ) {
		self.strokeOpacity = (uint8_t) ([[self getAttribute:@"stroke-opacity"] floatValue] * 0xFF);
	}
	
	if ([[self getAttribute:@"fill-opacity"] length] > 0 ) {
		self.fillOpacity = (uint8_t) ([[self getAttribute:@"fill-opacity"] floatValue] * 0xFF);
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
	
	NSString* actualStroke = self.cascadedStroke;
	NSString* actualStrokeWidth = self.cascadedStrokeWidth;
	if( actualStroke.length > 0
	&& (! [@"none" isEqualToString:actualStroke]) )
	{
		CGFloat strokeWidth = actualStrokeWidth.length > 0 ? [actualStrokeWidth floatValue] : 1.0f;
		
		/*
		 We have to apply any scale-factor part of the affine transform to the stroke itself (this is bizarre and horrible, yes, but that's the spec for you!)
		 */
		CGSize fakeSize = CGSizeMake( strokeWidth, 0 );
		fakeSize = CGSizeApplyAffineTransform( fakeSize, transformAbsolute );
		_shapeLayer.lineWidth = fakeSize.width;
		
		SVGColor strokeColorAsSVGColor = SVGColorFromString([actualStroke UTF8String]); // have to use the intermediate of an SVGColor so that we can over-ride the ALPHA component in next line
		NSString* actualStrokeOpacity = self.cascadedStrokeOpacity;
		if( actualStrokeOpacity.length > 0 )
			strokeColorAsSVGColor.a = (uint8_t) ([actualStrokeOpacity floatValue] * 0xFF);
		
		_shapeLayer.strokeColor = CGColorWithSVGColor( strokeColorAsSVGColor );
	}
	else
	{
		if( [@"none" isEqualToString:actualStroke] )
		{
			_shapeLayer.strokeColor = nil; // This is how you tell Apple that the stroke is disabled; a strokewidth of 0 will NOT achieve this
			_shapeLayer.lineWidth = 0.0f; // MUST set this explicitly, or Apple assumes 1.0
		}
		else
		{
			_shapeLayer.lineWidth = 1.0f; // default value from SVG spec
		}
	}
	
	
	NSString* actualFill = self.cascadedFill;
	if ( [actualFill hasPrefix:@"none"])
	{
		_shapeLayer.fillColor = nil;
	}
	else if ( [actualFill hasPrefix:@"url"] )
	{
		NSRange idKeyRange = NSMakeRange(5, actualFill.length - 6);
		NSString* _fillId = [actualFill substringWithRange:idKeyRange];
		
		/** Replace the return layer with a special layer using the URL fill */
		/** fetch the fill layer by URL using the DOM */
		NSAssert( self.rootOfCurrentDocumentFragment != nil, @"This SVG shape has a URL fill type; it needs to search for that URL (%@) inside its nearest-ancestor <SVG> node, but the rootOfCurrentDocumentFragment reference was nil (suggests the parser failed, or the SVG file is corrupt)", _fillId );
		
		SVGGradientElement* svgGradient = (SVGGradientElement*) [self.rootOfCurrentDocumentFragment getElementById:_fillId];
		NSAssert( svgGradient != nil, @"This SVG shape has a URL fill (%@), but could not find an XML Node with that ID inside the DOM tree (suggests the parser failed, or the SVG file is corrupt)", _fillId );
		
		//if( _shapeLayer != nil && svgGradient != nil ) //this nil check here is distrubing but blocking
		{
			CAGradientLayer *gradientLayer = [((CAGradientLayer *)svgGradient) newGradientLayerForObjectRect:_shapeLayer.frame viewportRect:self.rootOfCurrentDocumentFragment.viewBoxFrame];
			
			NSLog(@"DOESNT WORK, APPLE's API APPEARS BROKEN???? - About to mask layer frame (%@) with a mask of frame (%@)", NSStringFromCGRect(gradientLayer.frame), NSStringFromCGRect(_shapeLayer.frame));
			gradientLayer.mask =_shapeLayer;
			[_shapeLayer release]; // because it was created with a +1 retain count
			
			return gradientLayer;
		}
	}
	else if( actualFill.length > 0 )
	{
		SVGColor fillColorAsSVGColor = SVGColorFromString([actualFill UTF8String]); // have to use the intermediate of an SVGColor so that we can over-ride the ALPHA component in next line
		NSString* actualFillOpacity = self.cascadedFillOpacity;
		if( actualFillOpacity.length > 0 )
			fillColorAsSVGColor.a = (uint8_t) ([actualFillOpacity floatValue] * 0xFF);
		
		_shapeLayer.fillColor = CGColorWithSVGColor(fillColorAsSVGColor);
	}
	else
	{
		
	}
    
	_shapeLayer.opacity = _opacity;
	
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
