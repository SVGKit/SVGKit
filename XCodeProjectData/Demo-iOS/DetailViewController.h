//
//  DetailViewController.h
//  iOSDemo
//
//  Created by adam on 29/09/2012.
//  Copyright (c) 2012 na. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SVGKit.h"
#import "CALayerExporter.h"
#import "SVGKImage.h"

#define ALLOW_2X_STYLE_SCALING_OF_SVGS_AS_AN_EXAMPLE 1 // demonstrates using the "SVGKImage.scale" property to scale an SVG *before it generates output image data*

#define ALLOW_SVGKFASTIMAGEVIEW_TO_DO_HIT_TESTING 1 // only exists because people ignore the docs and try to do this when they clearly shouldn't. If you're foolish enough to do this, this code will show you how to do it CORRECTLY. Look how much code this requires! It's insane! Use SVGKLayeredImageView instead if you need hit-testing!

#define SHOW_DEBUG_INFO_ON_EACH_TAPPED_LAYER 1 // each time you tap and select a layer, that layer's info is displayed on-screen

@interface DetailViewController : UIViewController < UIPopoverControllerDelegate, UISplitViewControllerDelegate , CALayerExporterDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UITextView* exportText;
@property (nonatomic, retain) NSMutableString* exportLog;
@property (nonatomic, retain) CALayerExporter* layerExporter;
@property (nonatomic, retain) UITapGestureRecognizer* tapGestureRecognizer;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewForSVG;
@property (nonatomic, retain) IBOutlet SVGKImageView *contentView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *viewActivityIndicator;

@property(nonatomic,retain) IBOutlet UILabel* labelParseTime;

@property (nonatomic, retain) id detailItem;


- (IBAction)animate:(id)sender;
- (IBAction)exportLayers:(id)sender;

- (IBAction) showHideBorder:(id)sender;

@end
