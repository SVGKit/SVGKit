//
//  RootViewController.m
//  SVGPad
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController()
@property(nonatomic,retain) NSString* nameOfBrokenSVGToLoad;
@end

@implementation MasterViewController

@synthesize sampleNames = _sampleNames;
@synthesize detailViewController = _detailViewController;
@synthesize nameOfBrokenSVGToLoad = _nameOfBrokenSVGToLoad;

- (void)setupSampleNames
{
    self.sampleNames = [NSMutableArray arrayWithObjects: @"map-alaska-onlysimple", @"g-element-applies-rotation", @"groups-and-layers-test", @"http://upload.wikimedia.org/wikipedia/commons/f/f9/BlankMap-Africa.svg", @"shapes", @"strokes", @"transformations", @"rounded-rects", @"gradients",@"radialGradientTest", @"PreserveAspectRatio", @"australia_states_blank", @"Reinel_compass_rose", @"Monkey", @"Blank_Map-Africa", @"opacity01", @"Note", @"Note@2x", @"imageWithASinglePointPath", @"Lion", @"lingrad01", @"Map", @"CurvedDiamond", @"Text", @"text01", @"tspan01", @"Location_European_nation_states", @"uk-only", @"Europe_states_reduced", @"Compass_rose_pale", @"quad01", @"cubic01", @"rotated-and-skewed-text", @"RainbowWing", @"sakamura-default-fill-opacity-test", @"StyleAttribute", @"voies", @"nil-demo-layered-imageview", @"svg-with-explicit-width", @"svg-with-explicit-width-large", @"svg-with-explicit-width-large@160x240", @"BlankMap-World6-Equirectangular", @"Coins", @"imagetag-layered", @"ImageAspectRatio", @"test-stroke-dash-array", @"radial-gradient-opacity",
                        
        // This file is still not fully supported, arc to is missing, but it has the evenodd in it
        @"fillrule-evenodd",
                        nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[self setupSampleNames];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setupSampleNames];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( [[_sampleNames objectAtIndex:indexPath.row] isEqualToString:@"Reinel_compass_rose"])
	{
		NSLog(@"*****************\n*   WARNING\n*\n* The sample 'Reinel_compass_rose' is currently unsupported;\n* it is included in this build so that people working on it can test it and see if it works yet\n*\n*\n*****************");
		
		[[[[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Reinel_compass_rose breaks SVGKit, it uses unsupported SVG commands; until we have added support for those commands, it's here as a test - but it WILL CRASH if you try to view it" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK, crash",nil] autorelease] show];
		
		self.nameOfBrokenSVGToLoad = [_sampleNames objectAtIndex:indexPath.row];
		
		return;
	}
	
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"iPhoneDetailViewController" bundle:nil] autorelease];
	    }
	    [self.navigationController pushViewController:self.detailViewController animated:YES];
		self.detailViewController.detailItem = [_sampleNames objectAtIndex:indexPath.row];
    } else {
        self.detailViewController.detailItem = [_sampleNames objectAtIndex:indexPath.row];
    }
}

#pragma mark - alertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( buttonIndex == [alertView cancelButtonIndex] )
	{
		return;
	}
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"iPhoneDetailViewController" bundle:nil] autorelease];
	    }
	    [self.navigationController pushViewController:self.detailViewController animated:YES];
		self.detailViewController.detailItem = self.nameOfBrokenSVGToLoad;
    } else {
        self.detailViewController.detailItem = self.nameOfBrokenSVGToLoad;
    }
	
	self.nameOfBrokenSVGToLoad = nil;
}

@end
