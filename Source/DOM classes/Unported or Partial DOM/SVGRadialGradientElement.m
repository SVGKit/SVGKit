//
//  SVGRadialGradientElement.m
//  SVGKit-iOS
//
//  Created by lizhuoli on 2018/10/15.
//  Copyright © 2018年 na. All rights reserved.
//

#import "SVGRadialGradientElement.h"
#import "SVGElement_ForParser.h"
#import "SVGUtils.h"
#import "SVGGradientLayer.h"

@interface SVGRadialGradientElement ()

@property (nonatomic) BOOL hasSynthesizedProperties;
@property (nonatomic) SVGLength *cx;
@property (nonatomic) SVGLength *cy;
@property (nonatomic) SVGLength *r;
@property (nonatomic) SVGLength *fx;
@property (nonatomic) SVGLength *fy;
@property (nonatomic) SVGLength *fr;

@end

@implementation SVGRadialGradientElement

- (CAGradientLayer *)newGradientLayerForObjectRect:(CGRect)objectRect viewportRect:(SVGRect)viewportRect transform:(CGAffineTransform)absoluteTransform {
    SVGGradientLayer *gradientLayer = [[SVGGradientLayer alloc] init];
    BOOL inUserSpace = self.gradientUnits == SVG_UNIT_TYPE_USERSPACEONUSE;
//    CGRect rectForRelativeUnits = inUserSpace ? CGRectFromSVGRect( viewportRect ) : objectRect;
    
    gradientLayer.frame = objectRect;
    
    NSString *cxAttr = [self getAttributeInheritedIfNil:@"cx"];
    NSString *cyAttr = [self getAttributeInheritedIfNil:@"cy"];
    NSString *rAttr = [self getAttributeInheritedIfNil:@"r"];
    NSString *fxAttr = [self getAttributeInheritedIfNil:@"fx"];
    NSString *fyAttr = [self getAttributeInheritedIfNil:@"fy"];
    NSString *frAttr = [self getAttributeInheritedIfNil:@"fr"];
    SVGLength* svgCX = [SVGLength svgLengthFromNSString:cxAttr.length > 0 ? cxAttr : @"50%"];
    SVGLength* svgCY = [SVGLength svgLengthFromNSString:cyAttr.length > 0 ? cyAttr : @"50%"];
    SVGLength* svgR = [SVGLength svgLengthFromNSString:rAttr.length > 0 ? rAttr : @"50%"];
    // focal value
    SVGLength* svgFX = fxAttr.length > 0 ? [SVGLength svgLengthFromNSString:fxAttr] : svgCX;
    SVGLength* svgFY = fyAttr.length > 0 ? [SVGLength svgLengthFromNSString:fyAttr] : svgCY;
    SVGLength* svgFR = [SVGLength svgLengthFromNSString:frAttr.length > 0 ? frAttr : @"0%"];
    // This is a tempory workaround. Apple's `CAGradientLayer` does not support focal point for radial gradient. We have to use the low-level API `CGContextDrawRadialGradient` and using custom software-render for focal point. So it does not works for `SVGLayredView` which is hardware-render by CA render server.
    if (fxAttr.length > 0 || fyAttr.length > 0 || frAttr.length > 0) {
        SVGKitLogVerbose(@"The radialGradient element #%@ contains focal value: (fx:%@, fy: %@, fr:%@). The focul value is only supported on `SVGFastimageView` and it will be ignored when rendering in SVGLayredView.", [self getAttribute:@"id"], fxAttr, fyAttr, frAttr);
    }
    self.cx = svgCX;
    self.cy = svgCY;
    self.r = svgR;
    self.fx = svgFX;
    self.fy = svgFY;
    self.fr = svgFR;
    
    // This is a ugly fix. The SVG spec doesn't says, however, most of broswer treat 0.5 as as 50% for point value in <radialGradient> or <linearGradient>, so we keep the same behavior.
    CGFloat cx = (svgCX.value < 1.f) ? svgCX.value : [svgCX pixelsValueWithDimension:1.0];
    CGFloat cy = (svgCY.value < 1.f) ? svgCY.value : [svgCY pixelsValueWithDimension:1.0];
    CGFloat r = (svgR.value < 1.f) ? svgR.value : [svgR pixelsValueWithDimension:1.0];
    CGFloat fx = (svgFX.value < 1.f) ? svgFX.value : [svgFX pixelsValueWithDimension:1.0];
    CGFloat fy = (svgFY.value < 1.f) ? svgFY.value : [svgFY pixelsValueWithDimension:1.0];
    
    CGFloat radius;
    CGPoint gradientStartPoint = CGPointZero;
    CGPoint gradientEndPoint = CGPointZero;
    
    if (!inUserSpace)
    {
        // compute size based on percentages
        CGFloat x = cx * CGRectGetWidth(objectRect);
        CGFloat y = cy * CGRectGetHeight(objectRect);
        CGPoint startPoint = CGPointMake(x, y);
        CGFloat val = MIN(CGRectGetWidth(objectRect), CGRectGetHeight(objectRect));
        radius = r * val;
        
        CGFloat ex = fx * CGRectGetWidth(objectRect);
        CGFloat ey = fy * CGRectGetHeight(objectRect);
        
        gradientStartPoint = startPoint;
        gradientEndPoint = CGPointMake(ex, ey);
    }
    else
    {
        radius = r;
        CGPoint startPoint = CGPointMake(cx, cy);
        
        // work out the new radius
        CGFloat rad = radius * 2.f;
        CGRect rect = CGRectMake(startPoint.x, startPoint.y, rad, rad);
        rect = CGRectApplyAffineTransform(rect, self.transform);
        rect = CGRectApplyAffineTransform(rect, absoluteTransform);
        radius = CGRectGetHeight(rect) / 2.f;
        
        gradientStartPoint = startPoint;
        gradientEndPoint = CGPointMake(fx, fy);
    }
    
    if (inUserSpace)
    {
        // apply the absolute position
        gradientStartPoint = CGPointApplyAffineTransform(gradientStartPoint, absoluteTransform);
        gradientEndPoint = CGPointApplyAffineTransform(gradientEndPoint, absoluteTransform);
    }
    
    // convert to percent
    CGPoint startPoint = gradientStartPoint;
    gradientStartPoint = CGPointMake((startPoint.x) / CGRectGetWidth(objectRect), startPoint.y / CGRectGetHeight(objectRect));
    gradientEndPoint = CGPointMake((startPoint.x + radius) / CGRectGetWidth(objectRect), (startPoint.y + radius) / CGRectGetHeight(objectRect));

    // Suck. When using `SVGLayredImageView`, the layer rendering is submitted to CA render server, and your custom `renderInContex:` code will not work. So we just set both built-in value (CAGradientLayer property) && custom value (SVGGradientLayer property)
    // FIX-ME: built-in value (not match the SVG spec, all the focal value will be ignored)
    gradientLayer.startPoint = gradientStartPoint;
    gradientLayer.endPoint = gradientEndPoint;
    gradientLayer.type = kCAGradientLayerRadial;
    // custom value (match the SVG spec)
    gradientLayer.gradientElement = self;
    gradientLayer.objectRect = objectRect;
    gradientLayer.viewportRect = viewportRect;
    gradientLayer.absoluteTransform = absoluteTransform;
    
    if (svgR.value <= 0) {
        //  Spec: <r> A value of lower or equal to zero will cause the area to be painted as a single color using the color and opacity of the last gradient <stop>.
        SVGGradientStop *lastStop = self.stops.lastObject;
        gradientLayer.backgroundColor = CGColorWithSVGColor(lastStop.stopColor);
        gradientLayer.opacity = lastStop.stopOpacity;
    } else {
        [gradientLayer setColors:self.colors];
        [gradientLayer setLocations:self.locations];
    }
    
    SVGKitLogVerbose(@"[%@] set gradient layer start = %@", [self class], NSStringFromCGPoint(gradientLayer.startPoint));
    SVGKitLogVerbose(@"[%@] set gradient layer end = %@", [self class], NSStringFromCGPoint(gradientLayer.endPoint));
    SVGKitLogVerbose(@"[%@] set gradient layer colors = %@", [self class], self.colors);
    SVGKitLogVerbose(@"[%@] set gradient layer locations = %@", [self class], self.locations);
    
    return gradientLayer;
}

- (void)synthesizeProperties {
    if (self.hasSynthesizedProperties)
        return;
    self.hasSynthesizedProperties = YES;
    
    NSString* gradientID = [self getAttributeNS:@"http://www.w3.org/1999/xlink" localName:@"href"];
    
    if ([gradientID length])
    {
        if ([gradientID hasPrefix:@"#"])
            gradientID = [gradientID substringFromIndex:1];
        
        SVGRadialGradientElement* baseGradient = (SVGRadialGradientElement*) [self.rootOfCurrentDocumentFragment getElementById:gradientID];
        NSString* svgNamespace = @"http://www.w3.org/2000/svg";
        
        if (baseGradient)
        {
            [baseGradient synthesizeProperties];
            
            if (!self.stops && baseGradient.stops)
            {
                for (SVGGradientStop* stop in baseGradient.stops)
                    [self addStop:stop];
            }
            NSArray *keys = [NSArray arrayWithObjects:@"cx", @"cy", @"r", @"fx", @"fy", @"fr", @"gradientUnits", @"gradientTransform", @"spreadMethod", nil];
            
            for (NSString* key in keys)
            {
                if (![self hasAttribute:key] && [baseGradient hasAttribute:key])
                    [self setAttributeNS:svgNamespace qualifiedName:key value:[baseGradient getAttribute:key]];
            }
            
        }
    }
}

@end
