//
//  DetailViewController.m
//  iOSDemo
//
//  Created by adam on 29/09/2012.
//  Copyright (c) 2012 na. All rights reserved.
//
#import "DetailViewController.h"

#import "MasterViewController.h"

#import "NodeList+Mutable.h"

#import "SVGKFastImageView.h"

@interface DetailViewController ()

@property (nonatomic, retain) UIPopoverController *popoverController;

- (void)loadResource:(NSString *)name;
- (void)shakeHead;

@end


@implementation DetailViewController
@synthesize scrollViewForSVG;

@synthesize toolbar, popoverController, contentView, detailItem;
@synthesize viewActivityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc {
	self.popoverController = nil;
	self.toolbar = nil;
	self.detailItem = nil;
	
	self.name = nil;
	self.exportText = nil;
	self.exportLog = nil;
	self.layerExporter = nil;
	self.scrollViewForSVG = nil;
	self.contentView = nil;
	self.viewActivityIndicator = nil;
	
	[super dealloc];
}

-(void)viewDidLoad
{
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
											   [[[UIBarButtonItem alloc] initWithTitle:@"Debug" style:UIBarButtonItemStyleBordered target:self action:@selector(showHideBorder:)] autorelease],
											   [[[UIBarButtonItem alloc] initWithTitle:@"Animate" style:UIBarButtonItemStyleBordered target:self action:@selector(animate:)] autorelease],
											   nil];
}

#pragma mark - CRITICAL: this method makes Apple render SVGs in sharp focus

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)finalScale
{
	/** NB: very important! The "finalScale" paramter to this method is SLIGHTLY DIFFERENT from the scale that Apple reports in the other delegate methods
	 
	 This is very confusing, clearly it's bit of a hack - the other methods get called
	 at slightly the wrong time, and so their data is slightly wrong (out-by-one animation step).
	 
	 ONLY the values passed as params to this method are correct!
	 */
	
	/**
	 
	 Apple's implementation of zooming is EXTREMELY poorly designed; it's a hack onto a class
	 that was only designed to do panning (hence the name: uiSCROLLview)
	 
	 So ... "zooming" via a UIScrollView is NOT integrated with UIView
	 rendering - in a UIView subclass, you CANNOT KNOW whether you have been "zoomed"
	 (i.e.: had your view contents ruined horribly by Apple's class)
	 
	 The three lines that follow are - allegedly - Apple's preferred way of handling
	 the situation. Note that we DO NOT SET view.frame! According to official docs,
	 view.frame is UNDEFINED (this is very worrying, breaks a huge amount of UIKit-related code,
	 but that's how Apple has documented / implemented it!)
	 */
	view.transform = CGAffineTransformIdentity; // this alters view.frame! But *not* view.bounds
	view.bounds = CGRectApplyAffineTransform( view.bounds, CGAffineTransformMakeScale(finalScale, finalScale));
	[view setNeedsDisplay];
	
	/**
	 Workaround for another bug in Apple's hacks for UIScrollView:
	 
	  - when you reset the transform, as advised by Apple, you "break" Apple's memory of the scroll factor.
	     ... because they "forgot" to store it anywhere (they read your view.transform as if it were a private
			 variable inside UIScrollView! This causes MANY bugs in applications :( )
	 */
	self.scrollViewForSVG.minimumZoomScale /= finalScale;
	self.scrollViewForSVG.maximumZoomScale /= finalScale;
}

#pragma mark - rest of class

- (void)setDetailItem:(id)newDetailItem {
	if (detailItem != newDetailItem) {
		[detailItem release];
		detailItem = [newDetailItem retain];
		
		// FIXME: re-write this class so that this method does NOT require self.view to exist
		[self view]; // Apple's design to trigger the creation of view. Original design of THIS class is that it breaks if view isn't already existing
		[self loadResource:newDetailItem];
	}
	
	if (self.popoverController) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
}

- (void)loadResource:(NSString *)name
{
	[self.viewActivityIndicator startAnimating];
	[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]]; // makes the animation appear
	
    [self.contentView removeFromSuperview];
    
	SVGKImage *document = nil;
	/** Detect URL vs file */
	if( [name hasPrefix:@"http://"])
	{
		document = [SVGKImage imageWithContentsOfURL:[NSURL URLWithString:name]];
	}
	else
		document = [SVGKImage imageNamed:[name stringByAppendingPathExtension:@"svg"]];
	
	
	
	if( document == nil )
	{
				[[[[UIAlertView alloc] initWithTitle:@"SVG parse failed" message:@"Total failure. See console log" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
	}
	else
	{
		if( document.parseErrorsAndWarnings.rootOfSVGTree != nil )
		{
			NSLog(@"[%@] Freshly loaded document (name = %@) has size = %@", [self class], name, NSStringFromCGSize(document.size) );
			
			if( [name  isEqualToString:@"Monkey"])
			{
				/**
				 
				 NB: very special-case handling here -- this is included AS AN EXAMPLE so you can see the differences.
				 
				 The problem: Apple's code doesn't allow us to support CoreAnimation *and* make image loading easy.
				 The solution: there are two versions of SVGKImageView - a "normal" one, and a "weaker one that supports CoreAnimation"
				 
				 In this demo, we setup the Monkey.SVG to allow layer-based animation...
				 */
				
				self.contentView = [[[SVGKLayeredImageView alloc] initWithSVGKImage:document] autorelease];
			}
			else
			{
				self.contentView = [[[SVGKFastImageView alloc] initWithSVGKImage:document] autorelease];
				
				NSLog(@"[%@] WARNING: workaround for Apple bugs: UIScrollView spams tiny changes to the transform to the content view; currently, we have NO WAY of efficiently measuring whether or not to re-draw the SVGKImageView. As a temporary solution, we are DISABLING the SVGKImageView's auto-redraw-at-higher-resolution code - in general, you do NOT want to do this", [self class]);
				
				((SVGKFastImageView*)self.contentView).disableAutoRedrawAtHighestResolution = TRUE;
			}
			self.contentView.showBorder = FALSE;
			
			if (_name) {
				[_name release];
				_name = nil;
			}
			
			_name = [name copy];
			
			[self.scrollViewForSVG addSubview:self.contentView];
			[self.scrollViewForSVG setContentSize: self.contentView.frame.size];
			
			float screenToDocumentSizeRatio = self.scrollViewForSVG.frame.size.width / self.contentView.frame.size.width;
			
			self.scrollViewForSVG.minimumZoomScale = MIN( 1, screenToDocumentSizeRatio );
			self.scrollViewForSVG.maximumZoomScale = MAX( 1, screenToDocumentSizeRatio );
			
			NodeList* elementsUsingTagG = [document.DOMDocument getElementsByTagName:@"g"];
			NSLog( @"[%@] checking for SVG standard set of elements with XML tag/node of <g>: %@", [self class], elementsUsingTagG.internalArray );
		}
		else
		{
			[[[[UIAlertView alloc] initWithTitle:@"SVG parse failed" message:[NSString stringWithFormat:@"%i fatal errors, %i warnings. First fatal = %@",[document.parseErrorsAndWarnings.errorsFatal count],[document.parseErrorsAndWarnings.errorsRecoverable count]+[document.parseErrorsAndWarnings.warnings count], ((NSError*)[document.parseErrorsAndWarnings.errorsFatal objectAtIndex:0]).localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
		}
	}
	
	[self.viewActivityIndicator stopAnimating];
}

- (IBAction)animate:(id)sender {
	if ([_name isEqualToString:@"Monkey"]) {
		[self shakeHead];
	}
}


- (void)shakeHead {
	CALayer *layer = [self.contentView.image layerWithIdentifier:@"head"];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.duration = 0.25f;
	animation.autoreverses = YES;
	animation.repeatCount = 100000;
	animation.fromValue = [NSNumber numberWithFloat:0.1f];
	animation.toValue = [NSNumber numberWithFloat:-0.1f];
	
	[layer addAnimation:animation forKey:@"shakingHead"];
}

- (IBAction) showHideBorder:(id)sender
{
	self.contentView.showBorder = ! self.contentView.showBorder;
	
	/**
	 NB: normally, the following would NOT be needed - the SVGKImageView would automatically
	 detect it needs to be re-drawn.
	 
	 But ... because we're doing zooming in this class, and Apple's zooming causes huge performance problems,
	 we disabled the auto-redraw in the loadResource: method above.
	 
	 So, now, we have to manually tell the SVGKImageView to redraw
	 */
	[self.contentView setNeedsDisplay];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)argumentPopoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.popoverController = argumentPopoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.popoverController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
}

#pragma mark Export


- (IBAction)exportLayers:(id)sender {
    if (_layerExporter) {
        return;
    }
    _layerExporter = [[CALayerExporter alloc] initWithView:contentView];
    _layerExporter.delegate = self;
    
    UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
    UIViewController* textViewController = [[[UIViewController alloc] init] autorelease];
    [textViewController setView:textView];
    UIPopoverController* exportPopover = [[UIPopoverController alloc] initWithContentViewController:textViewController];
    [exportPopover setDelegate:self];
    [exportPopover presentPopoverFromBarButtonItem:sender
						  permittedArrowDirections:UIPopoverArrowDirectionAny
										  animated:YES];
    
    _exportText = textView;
    _exportText.text = @"exporting...";
    
    _exportLog = [[NSMutableString alloc] init];
    [_layerExporter startExport];
}

- (void) layerExporter:(CALayerExporter*)exporter didParseLayer:(CALayer*)layer withStatement:(NSString*)statement
{
    //NSLog(@"%@", statement);
    [_exportLog appendString:statement];
    [_exportLog appendString:@"\n"];
}

- (void)layerExporterDidFinish:(CALayerExporter *)exporter
{
    _exportText.text = _exportLog;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)pc
{
    [_exportText release];
    _exportText = nil;
    
    [_layerExporter release];
    _layerExporter = nil;
    
    [pc release];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}



@end
