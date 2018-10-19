//
//  SVGLinearGradientElement.m
//  SVGKit-iOS
//
//  Created by lizhuoli on 2018/10/15.
//  Copyright © 2018年 na. All rights reserved.
//

#import "SVGLinearGradientElement.h"
#import "SVGElement_ForParser.h"
#import "SVGGradientLayer.h"

@interface SVGLinearGradientElement ()

@property (nonatomic) BOOL hasSynthesizedProperties;
@property (nonatomic) SVGLength *x1;
@property (nonatomic) SVGLength *y1;
@property (nonatomic) SVGLength *x2;
@property (nonatomic) SVGLength *y2;

@end

@implementation SVGLinearGradientElement

- (CAGradientLayer *)newGradientLayerForObjectRect:(CGRect)objectRect viewportRect:(SVGRect)viewportRect transform:(CGAffineTransform)absoluteTransform {
    SVGGradientLayer *gradientLayer = [[SVGGradientLayer alloc] init];
    BOOL inUserSpace = self.gradientUnits == SVG_UNIT_TYPE_USERSPACEONUSE;
    CGRect rectForRelativeUnits = inUserSpace ? CGRectFromSVGRect( viewportRect ) : objectRect;
    
    gradientLayer.frame = objectRect;
    
    NSString *attrX1 = [self getAttributeInheritedIfNil:@"x1"];
    NSString *attrY1 = [self getAttributeInheritedIfNil:@"y1"];
    SVGLength* svgX1 = [SVGLength svgLengthFromNSString:attrX1.length > 0 ? attrX1 : @"0%"];
    SVGLength* svgY1 = [SVGLength svgLengthFromNSString:attrY1.length > 0 ? attrY1 : @"0%"];
    self.x1 = svgX1;
    self.y1 = svgY1;
    
    // This is a ugly fix. The SVG spec doesn't says, however, most of broswer treat 0.5 as as 50% for point value in <radialGradient> or <linearGradient>, so we keep the same behavior.
    CGFloat x1 = (svgX1.value < 1.f) ? svgX1.value : [svgX1 pixelsValueWithDimension:1.0];
    CGFloat y1 = (svgY1.value < 1.f) ? svgY1.value : [svgY1 pixelsValueWithDimension:1.0];
    
    CGPoint startPoint;
    
    // these should really be two separate code paths (objectBoundingBox and userSpaceOnUse)
    x1 = x1 * CGRectGetWidth(rectForRelativeUnits);
    y1 = y1 * CGRectGetHeight(rectForRelativeUnits);
    startPoint = CGPointMake(x1, y1);
    
    startPoint = CGPointApplyAffineTransform(startPoint, self.transform);
    if (inUserSpace)
    {
        startPoint = CGPointApplyAffineTransform(startPoint, absoluteTransform);
        startPoint.x = startPoint.x - CGRectGetMinX(objectRect);
        startPoint.y = startPoint.y - CGRectGetMinY(objectRect);
    }
    CGPoint gradientStartPoint = startPoint;
    
    // convert to percent
    gradientStartPoint.x = startPoint.x / CGRectGetWidth(objectRect);
    gradientStartPoint.y = startPoint.y / CGRectGetHeight(objectRect);
    
    NSString* attrX2 = [self getAttributeInheritedIfNil:@"x2"];
    NSString* attrY2 = [self getAttributeInheritedIfNil:@"y2"];
    SVGLength* svgX2 = [SVGLength svgLengthFromNSString:attrX2.length > 0 ? attrX2 : @"100%"];
    SVGLength* svgY2 = [SVGLength svgLengthFromNSString:attrY2.length > 0 ? attrY2 : @"0%"];
    self.x2 = svgX2;
    self.y2 = svgY2;
    
    // This is a ugly fix. The SVG spec doesn't says, however, most of broswer treat 0.5 as as 50% for point value in <radialGradient> or <linearGradient>, so we keep the same behavior.
    CGFloat x2 = (svgX2.value < 1.f) ? svgX2.value : [svgX2 pixelsValueWithDimension:1.0];
    CGFloat y2 = (svgY2.value < 1.f) ? svgY2.value : [svgY2 pixelsValueWithDimension:1.0];
    CGPoint endPoint;
    
    // these should really be two separate code paths (objectBoundingBox and userSpaceOnUse)
    x2 = x2 * CGRectGetWidth(rectForRelativeUnits);
    y2 = y2 * CGRectGetHeight(rectForRelativeUnits);
    endPoint = CGPointMake(x2, y2);
    
    endPoint = CGPointApplyAffineTransform(endPoint, self.transform);
    if (inUserSpace)
    {
        endPoint = CGPointApplyAffineTransform(endPoint, absoluteTransform);
        endPoint.x = endPoint.x - CGRectGetMaxX(objectRect) + CGRectGetWidth(objectRect);
        endPoint.y = endPoint.y - CGRectGetMaxY(objectRect) + CGRectGetHeight(objectRect);
    }
    CGPoint gradientEndPoint = endPoint;
    
    // convert to percent
    gradientEndPoint.x = endPoint.x / CGRectGetWidth(objectRect);
    gradientEndPoint.y = endPoint.y / CGRectGetHeight(objectRect);
    
    // Suck on iOS. When using `SVGFastImageView`, the layer software-rendering `drawInContext:` will contains strange boundingRect, while it works fine on macOS. So we need to use custom soft-rendering as well.
    gradientLayer.startPoint = gradientStartPoint;
    gradientLayer.endPoint = gradientEndPoint;
    gradientLayer.type = kCAGradientLayerAxial;
    // custom value (match the SVG spec)
    gradientLayer.gradientElement = self;
    gradientLayer.objectRect = objectRect;
    gradientLayer.viewportRect = viewportRect;
    gradientLayer.absoluteTransform = absoluteTransform;
    
    [gradientLayer setColors:self.colors];
    [gradientLayer setLocations:self.locations];
    
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
        
        SVGLinearGradientElement* baseGradient = (SVGLinearGradientElement*) [self.rootOfCurrentDocumentFragment getElementById:gradientID];
        NSString* svgNamespace = @"http://www.w3.org/2000/svg";
        
        if (baseGradient)
        {
            [baseGradient synthesizeProperties];
            
            if (!self.stops && baseGradient.stops)
            {
                for (SVGGradientStop* stop in baseGradient.stops)
                    [self addStop:stop];
            }
            NSArray *keys = [NSArray arrayWithObjects:@"x1", @"y1", @"x2", @"y2", @"gradientUnits", @"gradientTransform", @"spreadMethod", nil];
            
            for (NSString* key in keys)
            {
                if (![self hasAttribute:key] && [baseGradient hasAttribute:key])
                    [self setAttributeNS:svgNamespace qualifiedName:key value:[baseGradient getAttribute:key]];
            }
            
        }
    }
}

@end
