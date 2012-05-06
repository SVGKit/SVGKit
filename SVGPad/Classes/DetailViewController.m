//
//  DetailViewController.m
//  SVGPad
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "DetailViewController.h"

#import "RootViewController.h"

@interface DetailViewController ()

@property (nonatomic, retain) UIPopoverController *popoverController;

- (void)loadResource:(NSString *)name;

- (void)shakeHead;

@end


@implementation DetailViewController

@synthesize toolbar, popoverController, contentView, detailItem;

- (void)dealloc {
	self.popoverController = nil;
	self.toolbar = nil;
	self.detailItem = nil;
	
	[super dealloc];
}

- (void)setDetailItem:(id)newDetailItem {
	if (detailItem != newDetailItem) {
		[detailItem release];
		detailItem = [newDetailItem retain];
		
		[self loadResource:newDetailItem];
	}
	
	if (self.popoverController) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
}

- (void)loadResource:(NSString *)name {
	SVGDocument *document = [SVGDocument documentNamed:[name stringByAppendingPathExtension:@"svg"]];
	
	self.contentView.bounds = CGRectMake(0.0f, 0.0f, document.width, document.height);
	self.contentView.document = document;
	
	if (_name) {
		[_name release];
		_name = nil;
	}
	
	_name = [name copy];
}

- (IBAction)animate:(id)sender {
	if ([_name isEqualToString:@"Monkey"] || [_name isEqualToString:@"Rayflower"]) {
		[self shakeHead];
	}
}

- (void)shakeHead {
	CALayer *layer = [self.contentView.document layerWithIdentifier:@"head"];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.duration = 0.25f;
	animation.autoreverses = YES;
	animation.repeatCount = 100000;
	animation.fromValue = [NSNumber numberWithFloat:0.1f];
	animation.toValue = [NSNumber numberWithFloat:-0.1f];
	
	[layer addAnimation:animation forKey:@"shakingHead"];
}

- (void)splitViewController:(UISplitViewController *)svc
	 willHideViewController:(UIViewController *)aViewController
		  withBarButtonItem:(UIBarButtonItem *)barButtonItem
	   forPopoverController:(UIPopoverController *)pc {
	
	barButtonItem.title = @"Samples";
	
	NSMutableArray *items = [[toolbar items] mutableCopy];
	[items insertObject:barButtonItem atIndex:0];
	
	[toolbar setItems:items animated:YES];
	[items release];
	
	self.popoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
	 willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	
	NSMutableArray *items = [[toolbar items] mutableCopy];
	[items removeObjectAtIndex:0];
	
	[toolbar setItems:items animated:YES];
	[items release];
	
	self.popoverController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
