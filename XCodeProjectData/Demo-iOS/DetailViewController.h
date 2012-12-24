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

@interface DetailViewController : UIViewController < UIPopoverControllerDelegate, UISplitViewControllerDelegate , CALayerExporterDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UITextView* exportText;
@property (nonatomic, retain) NSMutableString* exportLog;
@property (nonatomic, retain) CALayerExporter* layerExporter;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewForSVG;
@property (nonatomic, retain) IBOutlet SVGKImageView *contentView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *viewActivityIndicator;

@property (nonatomic, retain) id detailItem;

- (IBAction)animate:(id)sender;
- (IBAction)exportLayers:(id)sender;

- (IBAction) showHideBorder:(id)sender;

@end
