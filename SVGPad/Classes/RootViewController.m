//
//  RootViewController.m
//  SVGPad
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "RootViewController.h"

#import "DetailViewController.h"

@implementation RootViewController

@synthesize detailViewController = _detailViewController;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		_sampleNames = [[NSArray alloc] initWithObjects:@"Monkey", @"Note", @"Lion", @"Map", nil];
	}
	return self;
}

- (void)dealloc {
	[_detailViewController release];
	[_sampleNames release];
	
	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.clearsSelectionOnViewWillAppear = NO;
	self.contentSizeForViewInPopover = CGSizeMake(320.0f, 600.0f);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return [_sampleNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier] autorelease];
	}
	
	cell.textLabel.text = [_sampleNames objectAtIndex:indexPath.row];
	
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	_detailViewController.detailItem = [_sampleNames objectAtIndex:indexPath.row];
}

@end
