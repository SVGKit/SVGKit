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
#define SVGKNativeView UIView
#else
#import <Cocoa/Cocoa.h>
#define SVGKNativeView NSView
#endif
#import <QuartzCore/QuartzCore.h>

@protocol CALayerExporterDelegate;

@interface CALayerExporter : NSObject
{
    @private
    NSMutableDictionary* propertyRegistry;
}

@property (readwrite,nonatomic,retain) SVGKNativeView* rootView;
@property (readwrite,nonatomic,assign) id<CALayerExporterDelegate> delegate;

- (CALayerExporter*) initWithView:(SVGKNativeView*)v;
- (void) startExport;

@end


@protocol CALayerExporterDelegate <NSObject>

- (void) layerExporter:(CALayerExporter*)exporter didParseLayer:(CALayer*)layer withStatement:(NSString*)statement;

@optional

- (void) layerExporterDidFinish:(CALayerExporter*)exporter;

@end
