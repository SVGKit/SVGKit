#if V_1_COMPATIBILITY_COMPILE_CALAYEREXPORTER_CLASS
//
//  CALayerExporter.h
//  SVGPad
//
//  Created by Steven Fusco on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol CALayerExporterDelegate;

@interface CALayerExporter : NSObject
{
    @private
    NSMutableDictionary* propertyRegistry;
}

@property (readwrite,nonatomic,strong) UIView* rootView;
@property (readwrite,nonatomic,weak) id<CALayerExporterDelegate> delegate;

- (CALayerExporter*) initWithView:(UIView*)v;
- (void) startExport;

@end


@protocol CALayerExporterDelegate <NSObject>

- (void) layerExporter:(CALayerExporter*)exporter didParseLayer:(CALayer*)layer withStatement:(NSString*)statement;

@optional

- (void) layerExporterDidFinish:(CALayerExporter*)exporter;

@end
#endif