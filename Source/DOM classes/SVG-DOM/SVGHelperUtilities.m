#import "SVGHelperUtilities.h"

#import "CAShapeLayerWithHitTest.h"
#import "SVGUtils.h"
#import "SVGGradientElement.h"
#import "CGPathAdditions.h"

#import "SVGTransformable.h"
#import "SVGSVGElement.h"

@implementation SVGHelperUtilities

/*! ADAM: SVG Official spec is EXTREMELY BADLY WRITTEN for this aspect (transforms + viewports + viewboxes) - almost all the documentation
 is "missing" and what's there is mumbo-jumbo appallingly bad English. I've had to do lots of "intelligent guessing" and "trial and error"
 to work out what the heck the authors were TRYING to say, but failing badly at actually saying.
 
 Re-calculates the absolute transform on-demand by querying parent's absolute transform and appending self's relative transform
 */
+(CGAffineTransform) transformAbsoluteForTransformableElement:(SVGElement<SVGTransformable>*) transformable
{
	NSAssert([transformable conformsToProtocol:@protocol(SVGTransformable)], @"Illegal argument, sent a non-SVGTransformable object to a method that requires an SVGTransformable (NB: Apple's Xcode is rubbish, it should have thrown a compiler error that you even tried to do this, but it often doesn't bother). Incoming instance = %@", transformable );
	/**
	 
	 Each time you hit a viewPortElement in the DOM Tree, you
	 have to insert an ADDITIONAL transform into the flow of:
	 
	 parent-transform -> child-transform
	 
	 has to become:
	 
	 parent-transform -> VIEWPORT-TRANSFORM -> child-transform
	 */
	
	CGAffineTransform parentAbsoluteTransform;
	CGAffineTransform selfRelativeTransform;
	CGAffineTransform optionalViewportTransform;
	
	NSAssert( transformable.parentNode == nil || [transformable.parentNode isKindOfClass:[SVGElement class]], @"I don't know what to do when parent node is NOT an SVG element of some kind; presumably, this is when SVG root node gets embedded inside something else? The Spec IS VERY BADLY WRITTEN and doesn't clearly define ANYTHING here, and provides very few examples" );
	
	/** PARENT absolute:
	  find the first ancestor that is EITHER transformable (in which case, grab its ABSOLUTE transform)
	  ...OR is nil (in which case: hit the root of the SVG tree, so we can assume the Identity transform)
	 */
	SVGElement* parentSVGElement = (SVGElement*) transformable.parentNode;
	while( ! [parentSVGElement conformsToProtocol:@protocol(SVGTransformable)])
	{
		if( parentSVGElement == nil )
			break;
		parentSVGElement = (SVGElement*) parentSVGElement.parentNode;
	}
	if( parentSVGElement == nil)
		parentAbsoluteTransform = CGAffineTransformIdentity;
	else
	{
		SVGElement<SVGTransformable>* firstTransformableAncestor = (SVGElement<SVGTransformable>*) parentSVGElement;
		parentAbsoluteTransform = [self transformAbsoluteForTransformableElement:firstTransformableAncestor];
	}
	
	/** SELF relative */
	selfRelativeTransform = transformable.transform;
	
	/** VIEWPORT relative */
	if( transformable.viewportElement != nil // if it's nil, it means THE OPPOSITE of what you'd expect - it means that it IS the viewport element - SVG Spec REQUIRES this
	   && transformable.viewportElement != transformable // if it's some-other-object, then: we simply don't need to worry about it
	   )
		optionalViewportTransform = CGAffineTransformIdentity;
	else
	{
		NSAssert( [transformable isKindOfClass:[SVGSVGElement class]], @"I don't know how to handle a VIEWPORT element that is NOT an <svg> tag. The SVG Spec is appallingly badly written, provides zero guidance, and zero examples. Someone will need to investigate as soon as we have an example!");
		
		SVGSVGElement* selfAsSVGTag = (SVGSVGElement*) transformable;
		CGRect frameViewBox = selfAsSVGTag.viewBoxFrame;
		CGRect frameViewport = CGRectFromSVGRect( selfAsSVGTag.viewport );
		
		if( ! CGRectIsEmpty( frameViewBox ) )
		{
			CGAffineTransform translateToViewBox = CGAffineTransformMakeTranslation( -frameViewBox.origin.x, -frameViewBox.origin.y );
			CGAffineTransform scaleToViewBox = CGAffineTransformMakeScale( frameViewport.size.width / frameViewBox.size.width, frameViewport.size.height / frameViewBox.size.height);
			optionalViewportTransform = CGAffineTransformConcat( translateToViewBox, scaleToViewBox );
		}
		else
			optionalViewportTransform = CGAffineTransformIdentity;
	}
	
	
	/** SELF absolute */
	CGAffineTransform result = CGAffineTransformConcat( selfRelativeTransform, CGAffineTransformConcat( optionalViewportTransform, parentAbsoluteTransform));
	
	//DEBUG: NSLog( @"[%@] self.transformAbsolute: returning: affine( (%2.2f %2.2f %2.2f %2.2f), (%2.2f %2.2f)", [self class], result.a, result.b, result.c, result.d, result.tx, result.ty);
	
	return result;
}

+(CALayer *) newCALayerForPathBasedSVGElement:(SVGElement<SVGTransformable>*) svgElement withPath:(CGPathRef) pathRelative
{
	CAShapeLayer* _shapeLayer = [[CAShapeLayerWithHitTest layer] retain];
	_shapeLayer.name = svgElement.identifier;
	[_shapeLayer setValue:svgElement.identifier forKey:kSVGElementIdentifier];
	
	/** transform our LOCAL path into ABSOLUTE space */
	CGAffineTransform transformAbsolute = [self transformAbsoluteForTransformableElement:svgElement];
	CGMutablePathRef pathToPlaceInLayer = CGPathCreateMutable();
	CGPathAddPath( pathToPlaceInLayer, &transformAbsolute, pathRelative);
	
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
	
	NSString* actualStroke = [svgElement cascadedValueForStylableProperty:@"stroke"];
	NSString* actualStrokeWidth = [svgElement cascadedValueForStylableProperty:@"stroke-width"];
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
		NSString* actualStrokeOpacity = [svgElement cascadedValueForStylableProperty:@"stroke-opacity"];
		if( actualStrokeOpacity.length > 0 )
			strokeColorAsSVGColor.a = (uint8_t) ([actualStrokeOpacity floatValue] * 0xFF);
		
		_shapeLayer.strokeColor = CGColorWithSVGColor( strokeColorAsSVGColor );
		
		/**
		 Line joins + caps: butt / square / miter
		 */
		NSString* actualLineCap = [svgElement cascadedValueForStylableProperty:@"stroke-linecap"];
		NSString* actualLineJoin = [svgElement cascadedValueForStylableProperty:@"stroke-linejoin"];
		NSString* actualMiterLimit = [svgElement cascadedValueForStylableProperty:@"stroke-miterlimit"];
		if( actualLineCap.length > 0 )
		{
			if( [actualLineCap isEqualToString:@"butt"] )
				_shapeLayer.lineCap = kCALineCapButt;
			else if( [actualLineCap isEqualToString:@"round"] )
				_shapeLayer.lineCap = kCALineCapRound;
			else if( [actualLineCap isEqualToString:@"square"] )
				_shapeLayer.lineCap = kCALineCapSquare;
		}
		if( actualLineJoin.length > 0 )
		{
			if( [actualLineJoin isEqualToString:@"miter"] )
				_shapeLayer.lineJoin = kCALineJoinMiter;
			else if( [actualLineJoin isEqualToString:@"round"] )
				_shapeLayer.lineJoin = kCALineJoinRound;
			else if( [actualLineJoin isEqualToString:@"bevel"] )
				_shapeLayer.lineJoin = kCALineJoinBevel;
		}
		if( actualMiterLimit.length > 0 )
		{
			_shapeLayer.miterLimit = [actualMiterLimit floatValue];
		}
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
	
	
	NSString* actualFill = [svgElement cascadedValueForStylableProperty:@"fill"];
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
		NSAssert( svgElement.rootOfCurrentDocumentFragment != nil, @"This SVG shape has a URL fill type; it needs to search for that URL (%@) inside its nearest-ancestor <SVG> node, but the rootOfCurrentDocumentFragment reference was nil (suggests the parser failed, or the SVG file is corrupt)", _fillId );
		
		SVGGradientElement* svgGradient = (SVGGradientElement*) [svgElement.rootOfCurrentDocumentFragment getElementById:_fillId];
		NSAssert( svgGradient != nil, @"This SVG shape has a URL fill (%@), but could not find an XML Node with that ID inside the DOM tree (suggests the parser failed, or the SVG file is corrupt)", _fillId );
		
		//if( _shapeLayer != nil && svgGradient != nil ) //this nil check here is distrubing but blocking
		{
			CAGradientLayer *gradientLayer = [((CAGradientLayer *)svgGradient) newGradientLayerForObjectRect:_shapeLayer.frame viewportRect:svgElement.rootOfCurrentDocumentFragment.viewBoxFrame];
			
			NSLog(@"DOESNT WORK, APPLE's API APPEARS BROKEN???? - About to mask layer frame (%@) with a mask of frame (%@)", NSStringFromCGRect(gradientLayer.frame), NSStringFromCGRect(_shapeLayer.frame));
			gradientLayer.mask =_shapeLayer;
			[_shapeLayer release]; // because it was created with a +1 retain count
			
			return gradientLayer;
		}
	}
	else if( actualFill.length > 0 )
	{
		SVGColor fillColorAsSVGColor = SVGColorFromString([actualFill UTF8String]); // have to use the intermediate of an SVGColor so that we can over-ride the ALPHA component in next line
		NSString* actualFillOpacity = [svgElement cascadedValueForStylableProperty:@"fill-opacity"];
		if( actualFillOpacity.length > 0 )
			fillColorAsSVGColor.a = (uint8_t) ([actualFillOpacity floatValue] * 0xFF);
		
		_shapeLayer.fillColor = CGColorWithSVGColor(fillColorAsSVGColor);
	}
	else
	{
		
	}
    
	NSString* actualOpacity = [svgElement cascadedValueForStylableProperty:@"opacity"];
	_shapeLayer.opacity = actualOpacity.length > 0 ? [actualOpacity floatValue] : 1; // unusually, the "opacity" attribute defaults to 1, not 0
	
	if ([_shapeLayer respondsToSelector:@selector(setShouldRasterize:)]) {
		[_shapeLayer performSelector:@selector(setShouldRasterize:)
						  withObject:[NSNumber numberWithBool:YES]];
	}
	
	return _shapeLayer;
}

@end
