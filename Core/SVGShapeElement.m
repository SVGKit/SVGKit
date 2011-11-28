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

- (void)finalize {
	CGPathRelease(_path);
	[super finalize];
}

- (void)dealloc {
	CGPathRelease(_path);
    [_fillPattern release];
    
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
			NSLog(@"Gradients are no longer supported");
			_fillType = SVGFillTypeNone;
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
	CAShapeLayer* _shapeLayer = [[CAShapeLayerWithHitTest layer] retain];//[[CAShapeLayer layer] retain];
	_shapeLayer.name = self.identifier;
		[_shapeLayer setValue:self.identifier forKey:kSVGElementIdentifier];
	_shapeLayer.opacity = _opacity;
	
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
