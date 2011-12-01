//
//  DetailViewController.h
//  SVGPad
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGKit.h"
#import "CALayerExporter.h"

@interface DetailViewController : UIViewController < UIPopoverControllerDelegate, UISplitViewControllerDelegate , CALayerExporterDelegate> {
  @private
	NSString *_name;
    UITextView* _exportText;
    NSMutableString* _exportLog;
    CALayerExporter* _layerExporter;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet SVGView *contentView;

@property (nonatomic, retain) id detailItem;

- (IBAction)animate:(id)sender;
- (IBAction)exportLayers:(id)sender;

@end
