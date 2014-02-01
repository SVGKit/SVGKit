//
//  RootViewController.h
//  SVGPad
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@class DetailViewController;

@interface MasterViewController : UITableViewController <UIAlertViewDelegate>

@property(nonatomic, STRONG) NSMutableArray *sampleNames;

@property (nonatomic, STRONG) IBOutlet DetailViewController *detailViewController;

@end
