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

- (NSString *)docPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [[documentsDirectory stringByAppendingString:@"/"] retain];
}

@synthesize scrollView;

@synthesize toolbar, popoverController, contentView, detailItem;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc {
	self.popoverController = nil;
	self.toolbar = nil;
	self.detailItem = nil;
	
    [_layerCamera release];
/*    [_layerExporter release];*/
    [scrollView release];
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



- (void)loadResource:(NSString *)name
{
    [self.contentView removeFromSuperview];
    
	SVGDocument *document = [SVGDocument documentNamed:[name stringByAppendingPathExtension:@"svg"]];
	NSLog(@"[%@] Freshly loaded document (name = %@) has width,height = (%.2f, %.2f)", [self class], name, document.width, document.height );
	self.contentView = [[[SVGView alloc] initWithDocument:document] autorelease];
	
	if (_name) {
		[_name release];
		_name = nil;
	}
	
	_name = [name copy];
    
    [self.scrollView addSubview:self.contentView];
    [self.scrollView setContentSize:CGSizeMake(document.width, document.height)];
    [self.scrollView zoomToRect:CGRectMake(0, 0, document.width, document.height) animated:YES];
    
    
    if( _layerCamera == nil )
        _layerCamera = [[CALayerCamera alloc] initWithPriority:DISPATCH_QUEUE_PRIORITY_BACKGROUND];
    
    [_layerCamera saveImageOf:[document layerTree] forSize:CGSizeMake(1024, 1024) toPath:[[self docPath] stringByAppendingPathComponent:@"testCameraOutput.png"] withPathCallback:^(NSString *savePath) {
        if( savePath != nil )
            NSLog(@"Image successfully saved to %@", savePath);
        else {
            NSLog(@"Image failed to save");
        }
    }];
}

- (IBAction)animate:(id)sender {
	if ([_name isEqualToString:@"Monkey"]) {
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
}

#pragma mark Export


- (IBAction)exportLayers:(id)sender {
/*    if (_layerExporter) {
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
    [_layerExporter startExport];*/
}
/*
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
*/
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)pc
{
    [_exportText release];
    _exportText = nil;
    /*
    [_layerExporter release];
    _layerExporter = nil;
    */
    [pc release];
}


- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}



@end
