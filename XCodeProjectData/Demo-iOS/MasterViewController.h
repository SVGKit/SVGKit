//
//  RootViewController.h
//  SVGPad
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@class DetailViewController;

@interface MasterViewController : UITableViewController <UIAlertViewDelegate>

@property(nonatomic,retain) NSMutableArray *sampleNames;

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
