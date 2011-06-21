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
		//_sampleNames = [[NSArray alloc] initWithObjects:@"Monkey", @"Note", nil];
        NSArray* listOfSVGImages = [self getImages];
        _sampleNames = [[NSArray alloc] initWithArray:listOfSVGImages];
	}
	return self;
}

-(NSArray*) getImages
{
    
    NSArray *pngPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"svg" inDirectory:nil];
    return pngPaths;
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
	
    NSString* filePath =  [_sampleNames objectAtIndex:indexPath.row];
    NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
    NSArray* pathComponents = [fileUrl pathComponents];
    NSString* fileName = (NSString*)[pathComponents lastObject];
    cell.textLabel.text = fileName; 	
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* filePath =  [_sampleNames objectAtIndex:indexPath.row];
    NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
    NSArray* pathComponents = [fileUrl pathComponents];
    NSString* fileName = (NSString*)[pathComponents lastObject];
 

	_detailViewController.detailItem = fileName;
}

@end
