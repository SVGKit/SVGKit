//
//  SVGShapeElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGShapeElement.h"

#import "CGPathAdditions.h"
#import "SVGDefsElement.h"
#import "SVGDocument.h"
#import "SVGElement+Private.h"
#import "SVGPattern.h"
#import "CAShapeLayerWithHitTest.h"

@implementation SVGShapeElement

#define IDENTIFIER_LEN 256

@synthesize opacity = _opacity;

@synthesize fillType = _fillType;
@synthesize fillColor = _fillColor;
@synthesize fillPattern = _fillPattern;

@synthesize strokeWidth = _strokeWidth;
@synthesize strokeColor = _strokeColor;

@synthesize path = _path;

@synthesize fillId = _fillId;

- (void)finalize {
	CGPathRelease(_path);
	[super finalize];
}

- (void)dealloc {
	CGPathRelease(_path);
    self.fillPattern = nil;
    
	[super dealloc];
}

- (void)loadDefaults {
	_opacity = 1.0f;
	
	_fillColor = SVGColorMake(0, 0, 0, 255);
	_fillType = SVGFillTypeSolid;
}

- (void)parseAttributes:(NSDictionary *)attributes {
	[super parseAttributes:attributes];
	
	id value = nil;
	
	if ((value = [attributes objectForKey:@"opacity"])) {
		_opacity = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"fill"])) {
		const char *cvalue = [value UTF8String];
		
		if (!strncmp(cvalue, "none", 4)) {
			_fillType = SVGFillTypeNone;
		}
		else if (!strncmp(cvalue, "url", 3)) {
			_fillType = SVGFillTypeURL;
            NSRange idKeyRange = NSMakeRange(5, [value length] - 6);
            _fillId = [value substringWithRange:idKeyRange];
		}
		else {
			_fillColor = SVGColorFromString([value UTF8String]);
			_fillType = SVGFillTypeSolid;
		}
	}
	
	if ((value = [attributes objectForKey:@"stroke-width"])) {
		_strokeWidth = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"stroke"])) {
		const char *cvalue = [value UTF8String];
		
		if (!strncmp(cvalue, "none", 4)) {
			_strokeWidth = 0.0f;
		}
		else {
			_strokeColor = SVGColorFromString(cvalue);
			
			if (!_strokeWidth)
				_strokeWidth = 1.0f;
		}
	}
	
	if ((value = [attributes objectForKey:@"stroke-opacity"])) {
		_strokeColor.a = (uint8_t) ([value floatValue] * 0xFF);
	}
	
	if ((value = [attributes objectForKey:@"fill-opacity"])) {
		_fillColor.a = (uint8_t) ([value floatValue] * 0xFF);
	}
}

- (void)loadPath:(CGPathRef)aPath {
	if (_path) {
		CGPathRelease(_path);
		_path = NULL;
	}
	
	if (aPath) {
		_path = CGPathCreateCopy(aPath);
	}
}

- (CALayer *) newLayer {
	CAShapeLayer* _shapeLayer = [CAShapeLayerWithHitTest layer];
	_shapeLayer.name = self.identifier;
		[_shapeLayer setValue:self.identifier forKey:kSVGElementIdentifier];
	_shapeLayer.opacity = _opacity;
    
    
#ifndef STATIC_COLORS //if STATIC_COLORS is not set, we may want to track shapeLayers for style changes
    if( _createdShapes != nil ) //this might need to happen after gradients are resolved to track the correct element, not sure yet
        [_createdShapes addObject:_shapeLayer];
    
#endif
	
#if OUTLINE_SHAPES
	
#if TARGET_OS_IPHONE
	_shapeLayer.borderColor = [UIColor redColor].CGColor;
#endif
	
	_shapeLayer.borderWidth = 1.0f;
#endif
	
    CGRect rect = CGRectIntegral(CGPathGetPathBoundingBox(_path));
	
	CGPathRef path = CGPathCreateByOffsettingPath(_path, rect.origin.x, rect.origin.y);
	
	_shapeLayer.path = path;
	CGPathRelease(path);
	
	_shapeLayer.frame = rect;
	
	if (_strokeWidth) {
		_shapeLayer.lineWidth = _strokeWidth;
		_shapeLayer.strokeColor = CGColorWithSVGColor(_strokeColor);
	}
	
    CALayer *returnLayer = _shapeLayer;
	if (_fillType == SVGFillTypeNone) {
		_shapeLayer.fillColor = nil;
	}
	else if (_fillType == SVGFillTypeSolid) {
		_shapeLayer.fillColor = CGColorWithSVGColor(_fillColor);
	}
    else if (_fillType == SVGFillTypeURL)
    {
        returnLayer = [[self document] useFillId:_fillId forLayer:_shapeLayer]; //CAGradientLayer does not extend from CAShapeLayer, although this doens't actually work :/
    }
    
    if (nil != _fillPattern) {
        _shapeLayer.fillColor = [_fillPattern CGColor];
    }
	
#if RASTERIZE_SHAPES > 0
    //we need better control over this, rasterization is bad news when scaling/rotation
	if ([_shapeLayer respondsToSelector:@selector(setShouldRasterize:)]) { 
		[_shapeLayer performSelector:@selector(setShouldRasterize:)
					withObject:[NSNumber numberWithBool:YES]];
	}
#endif
	
	return returnLayer;
}

- (void)layoutLayer:(CALayer *)layer { }

@end
