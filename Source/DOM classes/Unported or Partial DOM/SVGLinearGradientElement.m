//
//  SVGLinearGradientElement.m
//  SVGKit-iOS
//
//  Created by lizhuoli on 2018/10/15.
//  Copyright © 2018年 na. All rights reserved.
//

#import "SVGLinearGradientElement.h"
#import "SVGElement_ForParser.h"

@interface SVGLinearGradientElement ()

@property (nonatomic) BOOL hasSynthesizedProperties;
@property (nonatomic) SVGLength *x1;
@property (nonatomic) SVGLength *y1;
@property (nonatomic) SVGLength *x2;
@property (nonatomic) SVGLength *y2;

@end

@implementation SVGLinearGradientElement

- (CAGradientLayer *)newGradientLayerForObjectRect:(CGRect)objectRect viewportRect:(SVGRect)viewportRect transform:(CGAffineTransform)transformAbsolute {
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    BOOL inUserSpace = self.gradientUnits == SVG_UNIT_TYPE_USERSPACEONUSE;
    CGRect rectForRelativeUnits = inUserSpace ? CGRectFromSVGRect( viewportRect ) : objectRect;
    
    gradientLayer.frame = objectRect;
    
    NSString *attrX1 = [self getAttributeInheritedIfNil:@"x1"];
    NSString *attrY1 = [self getAttributeInheritedIfNil:@"y1"];
    SVGLength* svgX1 = [SVGLength svgLengthFromNSString:attrX1.length > 0 ? attrX1 : @"0%"];
    SVGLength* svgY1 = [SVGLength svgLengthFromNSString:attrY1.length > 0 ? attrY1 : @"0%"];
    self.x1 = svgX1;
    self.y1 = svgY1;
    CGFloat x1;
    CGFloat y1;
    
    // these should really be two separate code paths (objectBoundingBox and userSpaceOnUse)
    if (!inUserSpace)
    {
        x1 = [svgX1 pixelsValueWithDimension:1.0];
        y1 = [svgY1 pixelsValueWithDimension:1.0];
    }
    else
    {
        x1 = [svgX1 pixelsValueWithDimension:CGRectGetWidth(rectForRelativeUnits)];
        y1 = [svgY1 pixelsValueWithDimension:CGRectGetHeight(rectForRelativeUnits)];
    }
    
    CGPoint startPoint = CGPointMake(x1, y1);
    
    startPoint = CGPointApplyAffineTransform(startPoint, self.transform);
    if (inUserSpace)
    {
        startPoint = CGPointApplyAffineTransform(startPoint, transformAbsolute);
    }
    CGPoint gradientStartPoint = startPoint;
    
    if (inUserSpace)
    {
        gradientStartPoint.x = (startPoint.x - CGRectGetMinX(objectRect))/CGRectGetWidth(objectRect);
        gradientStartPoint.y = (startPoint.y - CGRectGetMinY(objectRect))/CGRectGetHeight(objectRect);
    }
    
    NSString* attrX2 = [self getAttributeInheritedIfNil:@"x2"];
    NSString *attrY2 = [self getAttributeInheritedIfNil:@"y2"];
    SVGLength* svgX2 = [SVGLength svgLengthFromNSString:attrX2.length > 0 ? attrX2 : @"100%"];
    SVGLength* svgY2 = [SVGLength svgLengthFromNSString:attrY2.length > 0 ? attrY2 : @"0%"];
    self.x2 = svgX2;
    self.y2 = svgY2;
    CGFloat x2;
    CGFloat y2;
    
    if (!inUserSpace)
    {
        x2 = [svgX2 pixelsValueWithDimension:1.0];
        y2 = [svgY2 pixelsValueWithDimension:1.0];
    }
    else
    {
        x2 = [svgX2 pixelsValueWithDimension:CGRectGetWidth(rectForRelativeUnits)];
        y2 = [svgY2 pixelsValueWithDimension:CGRectGetHeight(rectForRelativeUnits)];
    }
    
    
    CGPoint endPoint = CGPointMake(x2, y2);
    endPoint = CGPointApplyAffineTransform(endPoint, self.transform);
    if (inUserSpace)
    {
        endPoint = CGPointApplyAffineTransform(endPoint, transformAbsolute);
    }
    CGPoint gradientEndPoint = endPoint;
    
    if (inUserSpace)
    {
        gradientEndPoint.x = ((endPoint.x - CGRectGetMaxX(objectRect))/CGRectGetWidth(objectRect))+1;
        gradientEndPoint.y = ((endPoint.y - CGRectGetMaxY(objectRect))/CGRectGetHeight(objectRect))+1;
    }
    
    //    return gradientLayer;
    CGFloat rotation = atan2(transformAbsolute.b, transformAbsolute.d);
    if (fabs(rotation)>.01) {
        CGAffineTransform tr = CGAffineTransformMakeTranslation(.5, .5);
        tr = CGAffineTransformRotate(tr, rotation);
        tr = CGAffineTransformTranslate(tr, -.5, -.5);
        gradientStartPoint = CGPointApplyAffineTransform(gradientStartPoint, tr);
        gradientEndPoint = CGPointApplyAffineTransform(gradientEndPoint, tr);
    }
    gradientLayer.startPoint = gradientStartPoint;
    gradientLayer.endPoint = gradientEndPoint;
    gradientLayer.type = kCAGradientLayerAxial;
    
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
