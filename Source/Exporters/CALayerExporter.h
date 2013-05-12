//
//  CALayerExporter.h
//  SVGPad
//
//  Created by Steven Fusco on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//DW stands for Darwin
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#define DWView UIView
#else
#import <AppKit/AppKit.h>
#define DWView NSView
#endif
#import <QuartzCore/QuartzCore.h>

@protocol CALayerExporterDelegate;

@interface CALayerExporter : NSObject
{
    @private
    NSMutableDictionary* propertyRegistry;
}

@property (readwrite,nonatomic,retain) DWView* rootView;
@property (readwrite,nonatomic,assign) id<CALayerExporterDelegate> delegate;

- (id) initWithView:(DWView*)v;
- (void) startExport;

@end


@protocol CALayerExporterDelegate <NSObject>

- (void) layerExporter:(CALayerExporter*)exporter didParseLayer:(CALayer*)layer withStatement:(NSString*)statement;

@optional

- (void) layerExporterDidFinish:(CALayerExporter*)exporter;

@end
