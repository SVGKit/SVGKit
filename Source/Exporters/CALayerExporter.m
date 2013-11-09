//
//  CALayerExporter.m
//  SVGPad
//
//  Created by Steven Fusco on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CALayerExporter.h"

typedef struct ExportPathCommandsContext {
    NSString* pathName;
    NSMutableString* pathCommands;
} ExportPathCommandsContext;

void exportPathCommands(void *exportPathCommandsConextPtr, const CGPathElement *element)
{
    ExportPathCommandsContext* ctx = (ExportPathCommandsContext*) exportPathCommandsConextPtr;
    NSMutableString* pathCommands = ctx->pathCommands;
    NSString* pathName = ctx-> pathName;
    CGPoint* pathPoints = element->points;
    switch (element->type) {
        case kCGPathElementMoveToPoint:
            [pathCommands appendFormat:@"\nCGPathMoveToPoint(%@, NULL, %f, %f);", pathName, pathPoints[0].x, pathPoints[0].y];
            break;
        case kCGPathElementAddLineToPoint:
            [pathCommands appendFormat:@"\nCGPathAddLineToPoint(%@, NULL, %f, %f);", pathName, pathPoints[0].x, pathPoints[0].y];
            break;
        case kCGPathElementAddQuadCurveToPoint:
        {
            CGFloat cpx = pathPoints[0].x;
            CGFloat cpy = pathPoints[0].y;
            CGFloat x = pathPoints[1].x;
            CGFloat y = pathPoints[1].y;
            [pathCommands appendFormat:@"\nCGPathAddQuadCurveToPoint(%@, NULL, %f, %f, %f, %f);", pathName, cpx, cpy, x, y];
        }
            break;
        case kCGPathElementAddCurveToPoint:
        {
            CGFloat cp1x = pathPoints[0].x;
            CGFloat cp1y = pathPoints[0].y;
            CGFloat cp2x = pathPoints[1].x;
            CGFloat cp2y = pathPoints[1].y;
            CGFloat x = pathPoints[2].x;
            CGFloat y = pathPoints[2].y;
            [pathCommands appendFormat:@"\nCGPathAddCurveToPoint(%@, NULL, %f, %f, %f, %f, %f, %f);", pathName, cp1x, cp1y, cp2x, cp2y, x, y];
        }
            break;
        case kCGPathElementCloseSubpath:
            [pathCommands appendFormat:@"\nCGPathCloseSubpath(%@);", pathName];
            break;
            
        default:
            break;
    }
}

@interface CALayerExporter(Private)

- (void)processLayer:(CALayer *)currentLayer index:(NSInteger)index parent:(NSString*)parentName;

@end


@implementation CALayerExporter

@synthesize delegate;
@synthesize rootView;

- (id)initWithView:(SVGKNativeView*)v
{
    self = [super init];
    if (self) {
        self.rootView = v;
        
        propertyRegistry = [[NSMutableDictionary dictionary] retain];
        
        NSArray* CALayerProperties = [NSArray arrayWithObjects:@"name", @"bounds", @"frame", nil];
        [propertyRegistry setObject:CALayerProperties
                             forKey:NSStringFromClass([CALayer class])];
        
        NSArray* CAShapeLayerProperties = [NSArray arrayWithObjects:@"path", @"fillColor", @"fillRule", @"strokeColor", @"lineWidth", @"miterLimit", @"lineCap", @"lineJoin", @"lineDashPhase", @"lineDashPattern", nil];
        [propertyRegistry setObject:CAShapeLayerProperties
                             forKey:NSStringFromClass([CAShapeLayer class])];
    }
    return self;
}

- (void)dealloc {
    [rootView release];
    [super dealloc];
}

- (void)startExport
{
    if (nil == rootView) {
        return;
    }
    
    [self processLayer:self.rootView.layer index:0 parent:@"root"];
    
    if ([self.delegate respondsToSelector:@selector(layerExporterDidFinish:)]) {
        [self.delegate layerExporterDidFinish:self];
    }
}

- (void)processLayer:(CALayer *)currentLayer index:(NSInteger)index parent:(NSString*)parentName
{
    NSString* className = NSStringFromClass([currentLayer class]);
    NSString* layerName = [NSString stringWithFormat:@"%@_layer%ld", parentName, (long)index];
    NSString* createStatement = [NSString stringWithFormat:@"%@* %@ = [[%@ alloc] init];", className, layerName, className];
    
    [self.delegate layerExporter:self
                   didParseLayer:currentLayer
                   withStatement:createStatement];
    
    for (NSString* registeredClassName in [propertyRegistry allKeys]) {
        
        Class registeredClass = NSClassFromString(registeredClassName);
        if ([currentLayer isKindOfClass:registeredClass]) {
            
            for (NSString* propertyName in [propertyRegistry objectForKey:registeredClassName]) {
                
                SEL message = NSSelectorFromString(propertyName);
                
                NSMethodSignature* methodSig = [currentLayer methodSignatureForSelector:message];
                
                NSString* propertyValue = nil;
                const char * methodReturnType = [methodSig methodReturnType];
                
                if (0 == strcmp("@", methodReturnType)) {
                    
                    id v = [currentLayer performSelector:message];
                    
                    if (nil == v) {
                        propertyValue = @"nil";
                    } else if ([v isKindOfClass:[NSString class]]) {
                        propertyValue = [NSString stringWithFormat:@"@\"%@\"", v];
                    } else {
                        propertyValue = NSStringFromClass([v class]);
                    }
                } else {
                    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:methodSig];
                    [inv setSelector:message];
                    [inv setTarget:currentLayer];
                    [inv invoke];
                    
                    if (0 == strcmp("f", methodReturnType)) {
                        float r;
                        [inv getReturnValue:&r];
                        propertyValue = [NSString stringWithFormat:@"%f", r];
                    } else if (0 == strcmp("d", methodReturnType)) {
                        double r;
                        [inv getReturnValue:&r];
                        propertyValue = [NSString stringWithFormat:@"%f", r];
                    } else if (0 == strcmp("{CGRect={CGPoint=ff}{CGSize=ff}}", methodReturnType) || 0 == strcmp("{CGRect={CGPoint=dd}{CGSize=dd}}", methodReturnType)) {
                        CGRect r;
                        [inv getReturnValue:&r];
                        propertyValue = [NSString stringWithFormat:@"CGRectMake(%f, %f, %f, %f)", r.origin.x, r.origin.y, r.size.width, r.size.height];
                    } else if (0 == strcmp("^{CGColor=}", methodReturnType)) {
                        
                        CGColorRef color;
                        [inv getReturnValue:&color];
                        
                        if (0 == color) {
                            propertyValue = @"0";
                        } else {
                            NSString* colorName = [NSString stringWithFormat:@"%@_%@_colorref", layerName, propertyName];
                            NSString* spaceName = [colorName stringByAppendingString:@"_colorSpace"];
                            NSString* componentsName = [colorName stringByAppendingString:@"_colorComponents"];
                            
                            CGColorSpaceRef colorSpace = CGColorGetColorSpace(color);
                            
                            NSMutableString* colorSpaceCreateStatement = [NSMutableString stringWithFormat:@"CGColorSpaceRef %@ = ", spaceName];
                            
                            CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
                            switch (colorSpaceModel) {
                                case kCGColorSpaceModelMonochrome:
                                    [colorSpaceCreateStatement appendString:@"CGColorSpaceCreateDeviceGray();"];
                                    break;
                                case kCGColorSpaceModelRGB:
                                    [colorSpaceCreateStatement appendString:@"CGColorSpaceCreateDeviceRGB();"];
                                    break;
                                case kCGColorSpaceModelCMYK:
                                    [colorSpaceCreateStatement appendString:@"CGColorSpaceCreateDeviceCMYK();"];
                                    break;
                                case kCGColorSpaceModelLab:
                                    // CGColorSpaceCreateLab(<#const CGFloat *whitePoint#>, <#const CGFloat *blackPoint#>, <#const CGFloat *range#>)
                                    break;
                                case kCGColorSpaceModelDeviceN:
                                    // CGColorSpaceCreateWithICCProfile(<#CFDataRef data#>)
                                    break;
                                case kCGColorSpaceModelIndexed:
                                    // CGColorSpaceCreateIndexed(<#CGColorSpaceRef baseSpace#>, <#size_t lastIndex#>, <#const unsigned char *colorTable#>)
                                    break;
                                case kCGColorSpaceModelPattern:
                                    // CGColorSpaceCreatePattern(<#CGColorSpaceRef baseSpace#>)
                                    break;
                                default:
                                    break;
                            }
                            [self.delegate layerExporter:self
                                           didParseLayer:currentLayer
                                           withStatement:colorSpaceCreateStatement];
                            
                            const CGFloat* colorComponents = CGColorGetComponents(color);
                            size_t colorComponentsCount = CGColorGetNumberOfComponents(color);
                            NSMutableString* colorComponentsCreateStatement = [NSMutableString stringWithFormat:@"CGFloat %@[] = ", componentsName];
                            [colorComponentsCreateStatement appendString:@"{"];
                            for (int i=0; i != colorComponentsCount; ++i) {
                                [colorComponentsCreateStatement appendFormat:@"%@%f", ((i != 0) ? @"," : @""), colorComponents[i]];
                            }
                            [colorComponentsCreateStatement appendString:@"};"];
                            [self.delegate layerExporter:self
                                           didParseLayer:currentLayer
                                           withStatement:colorComponentsCreateStatement];
                            
                            NSString* colorCreateStatement = [NSString stringWithFormat:@"CGColorRef %@ = CGColorCreate(%@, %@);", colorName, spaceName, componentsName];
                            [self.delegate layerExporter:self
                                           didParseLayer:currentLayer
                                           withStatement:colorCreateStatement];
                            
                            propertyValue = colorName;
                        }
                        
                    } else if (0 == strcmp("^{CGPath=}", methodReturnType)) {
                        CGPathRef path;
                        [inv getReturnValue:&path];
                        
                        if (0 == path) {
                            propertyValue = @"0";
                        } else {
                        
                            NSString* pathName = [NSString stringWithFormat:@"%@_%@_pathref", layerName, propertyName];
                            NSString* pathCreateStatement = [NSString stringWithFormat:@"CGMutablePathRef %@ = CGPathCreateMutable();", pathName];
                            [self.delegate layerExporter:self
                                           didParseLayer:currentLayer
                                           withStatement:pathCreateStatement];
                            
                            NSMutableString* pathCommands = [NSMutableString string];
                            ExportPathCommandsContext exportPathContext;
                            exportPathContext.pathName = pathName;
                            exportPathContext.pathCommands = pathCommands;
                            
                            CGPathApply(path, &exportPathContext, exportPathCommands);
                            [self.delegate layerExporter:self
                                           didParseLayer:currentLayer
                                           withStatement:pathCommands];
                            
                            propertyValue = pathName;
                        }
                    } else {
                        propertyValue = [NSString stringWithCString:methodReturnType encoding:NSUTF8StringEncoding];
                    }
                }
                
                NSString* propertyAssignmentStatement = [NSString stringWithFormat:@"%@.%@ = %@;", layerName, propertyName, propertyValue];
                [self.delegate layerExporter:self
                               didParseLayer:currentLayer
                               withStatement:propertyAssignmentStatement];
            }
        }
    }
    
    
    NSString* addSublayerStatement = [NSString stringWithFormat:@"[%@ addSublayer:%@];", parentName, layerName];
    [self.delegate layerExporter:self
                   didParseLayer:currentLayer
                   withStatement:addSublayerStatement];
    
    NSString* releaseStatement = [NSString stringWithFormat:@"[%@ release];", layerName];
    [self.delegate layerExporter:self
                   didParseLayer:currentLayer
                   withStatement:releaseStatement];
    
    NSInteger i = index;
    for (CALayer* childLayer in currentLayer.sublayers) {
        [self processLayer:childLayer index:++i parent:layerName];
    }
}





@end

