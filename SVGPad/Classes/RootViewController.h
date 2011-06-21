//
//  RootViewController.h
//  SVGPad
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@class DetailViewController;

@interface RootViewController : UITableViewController {
  @private
	NSArray *_sampleNames;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
-(NSArray*) getImages;

@end
