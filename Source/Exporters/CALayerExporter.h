//
//  CALayerExporter.h
//  SVGPad
//
//  Created by Steven Fusco on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import <QuartzCore/QuartzCore.h>

@protocol CALayerExporterDelegate;

@interface CALayerExporter : NSObject
{
    @private
    NSMutableDictionary* propertyRegistry;
}

#if TARGET_OS_IPHONE
@property (readwrite,nonatomic,retain) UIView* rootView;
#else
@property (readwrite,nonatomic,retain) NSView* rootView;
#endif
@property (readwrite,nonatomic,assign) id<CALayerExporterDelegate> delegate;

#if TARGET_OS_IPHONE
- (CALayerExporter*) initWithView:(UIView*)v;
#else
- (CALayerExporter*) initWithView:(NSView*)v;
#endif

- (void) startExport;

@end


@protocol CALayerExporterDelegate <NSObject>

- (void) layerExporter:(CALayerExporter*)exporter didParseLayer:(CALayer*)layer withStatement:(NSString*)statement;

@optional

- (void) layerExporterDidFinish:(CALayerExporter*)exporter;

@end
