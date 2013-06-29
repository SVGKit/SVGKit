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

@property (nonatomic, strong) UIPopoverController *popoverController;

- (void)loadResource:(NSString *)name;
- (void)shakeHead;

@end


@implementation DetailViewController
@synthesize scrollViewForSVG;

@synthesize toolbar, popoverController, contentView, detailItem;
@synthesize viewActivityIndicator;
@synthesize name = _name;
@synthesize exportText = _exportText;
@synthesize layerExporter = _layerExporter;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize exportLog = _exportLog;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc {
	self.detailItem = nil;
	
	
}

-(void)viewDidLoad
{
	self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"Debug" style:UIBarButtonItemStyleBordered target:self action:@selector(showHideBorder:)],
											   [[UIBarButtonItem alloc] initWithTitle:@"Animate" style:UIBarButtonItemStyleBordered target:self action:@selector(animate:)]];
}

CALayer* lastTappedLayer;
CGFloat lastTappedLayerOriginalBorderWidth;
CGColorRef lastTappedLayerOriginalBorderColor;
CATextLayer *textLayerForLastTappedLayer;
-(void) deselectTappedLayer
{
	if( lastTappedLayer != nil )
	{
#if ALLOW_SVGKFASTIMAGEVIEW_TO_DO_HIT_TESTING
		if( [self.contentView isKindOfClass:[SVGKFastImageView class]])
		{
			[lastTappedLayer removeFromSuperlayer]; // nothing else needed
		}
		else
#endif
		{
			lastTappedLayer.borderWidth = lastTappedLayerOriginalBorderWidth;
			lastTappedLayer.borderColor = lastTappedLayerOriginalBorderColor;
		}
		
		[textLayerForLastTappedLayer removeFromSuperlayer];
		textLayerForLastTappedLayer = nil;
		
		lastTappedLayer = nil;
	}
}

-(NSString*) layerInfo:(CALayer*) l
{
	return [NSString stringWithFormat:@"%@:%@", [l class], NSStringFromCGRect(l.frame)];
}

/**
 Example of how to handle gaps on an SVG
 */
-(void) handleTapGesture:(UITapGestureRecognizer*) recognizer
{
	CGPoint p = [recognizer locationInView:self.contentView];
	
#if ALLOW_SVGKFASTIMAGEVIEW_TO_DO_HIT_TESTING // look how much code this requires! It's insane! Use SVGKLayeredImageView instead if you need hit-testing!
	SVGKImage* svgImage = nil; // ONLY used for the hacky code below that demonstrates how complex hit-testing is on an SVGKFastImageView
	
	/**
	 WARNING:
	 
	 Whenever you're using SVGKFastImageView, it "hides" the raw CALayers from you, and Apple
	 doesn't provide an easy way around this (we do it this way because there are missing methods
	 and bugs in Apple's UIScrollView, which SVGKFastImageView fixes).
	 
	 So, you cannot do a hittest on "SVGKFastImageView.layer" - that will always return the root,
	 empty, full-size layer.
	 
	 Instead, you have to hit-test the layer INSIDE the fast imageview.
	 
	 --------
	 
	 HOWEVER: YOU SHOULD NOT BE DOING THIS!
	 
	 IF YOU NEED TO DO HIT-TESTING, USE SVGKLayeredImageView (as per the docs!)
	 
	 THE EXAMPLE CODE HERE SHOWS YOU HOW YOU COULD, IN THEORY, DO HIT-TESTING WITH EITHER, BUT IT
	 IS HIGHLY RECOMMENDED NEVER TO USE HIT-TESTING WITH SVGKFastImageView!
	 */
#endif
	CALayer* layerForHitTesting;
	
#if ALLOW_SVGKFASTIMAGEVIEW_TO_DO_HIT_TESTING // look how much code this requires! It's insane! Use SVGKLayeredImageView instead if you need hit-testing!
	if( [self.contentView isKindOfClass:[SVGKFastImageView class]])
	{
		layerForHitTesting = ((SVGKFastImageView*)self.contentView).image.CALayerTree;
		svgImage = ((SVGKFastImageView*)self.contentView).image;
		
		/**
		 ALSO, because SVGKFastImageView DOES NOT ALTER the underlying layers when it zooms
		 (the zoom is handled "fast" and done internally at 100% accuracy),
		 any zoom will be ignored for the hit-test - we have to MANUALLY apply the zoom
		 */
		CGSize scaleConvertImageToViewForHitTest = CGSizeMake( self.contentView.bounds.size.width / svgImage.size.width, self.contentView.bounds.size.height / svgImage.size.height ); // this is a copy/paste of the internal "SCALING" logic used in SVGKFastImageView
		
		p = CGPointApplyAffineTransform( p, CGAffineTransformInvert( CGAffineTransformMakeScale( scaleConvertImageToViewForHitTest.width, scaleConvertImageToViewForHitTest.height)) ); // must do the OPPOSITE of the zoom (to convert the 'seeming' point to the 'actual' point
	}
	else
#endif
		layerForHitTesting = self.contentView.layer;
	
	
	CALayer* hitLayer = [layerForHitTesting hitTest:p];
	
	if( hitLayer == lastTappedLayer )
		[self deselectTappedLayer]; // do this both ways, but have to do it AFTER the if-test because it nil's one of the if-phrases!
	else
	{
		[self deselectTappedLayer]; // do this both ways, but have to do it AFTER the if-test because it nil's one of the if-phrases!
	
#if ALLOW_SVGKFASTIMAGEVIEW_TO_DO_HIT_TESTING // look how much code this requires! It's insane! Use SVGKLayeredImageView instead if you need hit-testing!
		self.title = @""; // reset it so that we can conditionally set it - but also ensuring this code is included in the #if
		if( [self.contentView isKindOfClass:[SVGKFastImageView class]])
		{
			/** NEVER DO THIS - this is a proof-of-concept, but instead you should ALWAYS
			 use SVGKLayeredImageView if you want to do hit-testing!
			 */
			self.title = @"WARNING: don't use SVGKFastImageView for hit-testing";
			
			/**
			 Because SVGKFastImageView "hides" the layers, any visual changes we make
			 will NOT be reflected on-screen.
			 
			 Instead, we have to put a NEW layer over the top
			 */
			CALayer* absolutePositionedCloneLayer = [svgImage newCopyPositionedAbsoluteOfLayer:hitLayer];
			
			lastTappedLayer = [[CALayer alloc] init];
			lastTappedLayer.frame = absolutePositionedCloneLayer.frame;
			
			/**
			 ALSO, because SVGKFastImageView DOES NOT ALTER the underlying layers when it zooms
			 (the zoom is handled "fast" and done internally at 100% accuracy),
			 any zoom will be ignored for the new layer - we have to MANUALLY apply the zoom
			 */
			CGSize scaleConvertImageToView = CGSizeMake( self.contentView.bounds.size.width / svgImage.size.width, self.contentView.bounds.size.height / svgImage.size.height ); // this is a copy/paste of the internal "SCALING" logic used in SVGKFastImageView
			lastTappedLayer.frame = CGRectApplyAffineTransform( lastTappedLayer.frame, CGAffineTransformMakeScale(scaleConvertImageToView.width, scaleConvertImageToView.height));
			
			[self.contentView.layer addSublayer:lastTappedLayer];
		}
		else
#endif
			lastTappedLayer = hitLayer;
		
		if( lastTappedLayer != nil )
		{
			lastTappedLayerOriginalBorderColor = lastTappedLayer.borderColor;
			lastTappedLayerOriginalBorderWidth = lastTappedLayer.borderWidth;
			
			lastTappedLayer.borderColor = [UIColor greenColor].CGColor;
			lastTappedLayer.borderWidth = 3.0;
			
#if SHOW_DEBUG_INFO_ON_EACH_TAPPED_LAYER
			/** mtrubnikov's code for adding a text overlay showing exactly what you tapped
			 */
			NSString* textToDraw = [NSString stringWithFormat:@"%@ (%@): {%.1f, %.1f} {%.1f, %.1f}", hitLayer.name, [hitLayer class], lastTappedLayer.frame.origin.x, lastTappedLayer.frame.origin.y, lastTappedLayer.frame.size.width, lastTappedLayer.frame.size.height];
			
			UIFont* fontToDraw = [UIFont fontWithName:@"Helvetica"
												 size:14.0f];
			CGSize sizeOfTextRect = [textToDraw sizeWithFont:fontToDraw];
			
			textLayerForLastTappedLayer = [[CATextLayer alloc] init];
			[textLayerForLastTappedLayer setFont:@"Helvetica"];
			[textLayerForLastTappedLayer setFontSize:14.0f];
			[textLayerForLastTappedLayer setFrame:CGRectMake(0, 0, sizeOfTextRect.width, sizeOfTextRect.height)];
			[textLayerForLastTappedLayer setString:textToDraw];
			[textLayerForLastTappedLayer setAlignmentMode:kCAAlignmentLeft];
			[textLayerForLastTappedLayer setForegroundColor:[UIColor redColor].CGColor];
			[textLayerForLastTappedLayer setContentsScale:[[UIScreen mainScreen] scale]];
			[textLayerForLastTappedLayer setShouldRasterize:NO];
			[self.contentView.layer addSublayer:textLayerForLastTappedLayer];
			/*
			 * mtrubnikov's code for adding a text overlay showing exactly what you tapped*/
#endif
		}
	}
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
		[self deselectTappedLayer]; // do this first because it DEPENDS UPON the type of self.contentView BEFORE the change in value
		
		detailItem = newDetailItem;
		
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
	
	SVGKImageView* newContentView = nil;
	BOOL thisImageRequiresLayeredImageView = false;
	CGSize customSizeForImage = CGSizeZero;
    
#if ALLOW_2X_STYLE_SCALING_OF_SVGS_AS_AN_EXAMPLE
	BOOL shouldScaleTimesTwo = false;
	if( [name hasSuffix:@"@2x"])
	{
		name = [name substringToIndex:name.length - @"@2x".length];
		shouldScaleTimesTwo = true;
		thisImageRequiresLayeredImageView = true;
	}
#endif
	
	if( [name hasSuffix:@"@160x240"])
	{
		name = [name substringToIndex:name.length - @"@160x240".length];
		customSizeForImage = CGSizeMake( 160, 240 );
	}
	
	if(
	   [name  isEqualToString:@"Monkey"] // Monkey uses layer-animations, so REQUIRES the layered version of SVGKImageView
	   || [name isEqualToString:@"RainbowWing"] // RainbodWing uses gradient-fills, so REQUIRES the layered version of SVGKImageView
	   )
	{
		/**
		 
		 NB: special-case handling here -- this is included AS AN EXAMPLE so you can see the differences.
		 
		 MONKEY.SVG -- CAAnimation of layers
		 -----
		 The problem: Apple's code doesn't allow us to support CoreAnimation *and* make image loading easy.
		 The solution: there are two versions of SVGKImageView - a "normal" one, and a "weaker one that supports CoreAnimation"
		 
		 In this demo, we setup the Monkey.SVG to allow layer-based animation...
		 
		 
		 RAINBOWWING.SVG -- Gradient-fills of shapes
		 -----
		 The problem: Apple's renderInContext has a major bug where it ignores CALayer masks
		 The solution: there are two versions of SVGKImageView - a "normal" one, and a "weaker one that doesnt use renderInContext"
		 
		 */
		thisImageRequiresLayeredImageView = true;
	}
	
	/** Detect the magic name(s) for the nil-demos */
	if( [name isEqualToString:@"nil-demo-layered-imageview"])
	{
		/** This demonstrates / tests what happens if you create an SVGKLayeredImageView with a nil SVGKImage
		 
		 NB: this is what Apple's InterfaceBuilder / Xcode 4 FORCES YOU TO DO because of massive bugs in Xcode 4!
		 */
		newContentView = [[SVGKLayeredImageView alloc] initWithCoder:nil];
	}
	else
	{
		/**
		 FINALLY:
		 
		 the actual loading of the SVG file and making a view to display it!
		 */
		
		SVGKImage *document = nil;
		
		/** Detect URL vs file */
		if( [name hasPrefix:@"http://"])
		{
			document = [SVGKImage imageWithContentsOfURL:[NSURL URLWithString:name]];
		}
		else
			document = [SVGKImage imageNamed:[name stringByAppendingPathExtension:@"svg"]];
		
			if (!thisImageRequiresLayeredImageView && document) {
				thisImageRequiresLayeredImageView = ![SVGKFastImageView svgImageHasNoGradients:document];
			}

#if ALLOW_2X_STYLE_SCALING_OF_SVGS_AS_AN_EXAMPLE
		if( shouldScaleTimesTwo )
			document.scale = 2.0;
#endif
		
		if( document == nil )
		{
			[[[UIAlertView alloc] initWithTitle:@"SVG parse failed" message:@"Total failure. See console log" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
			newContentView = nil; // signals to the rest of this method: the load failed
		}
		else
		{
			if( document.parseErrorsAndWarnings.rootOfSVGTree != nil )
			{
				//NSLog(@"[%@] Freshly loaded document (name = %@) has size = %@", [self class], name, NSStringFromCGSize(document.size) );
				
				/** NB: the SVG Spec says that the "correct" way to upscale or downscale an SVG is by changing the
				 SVG Viewport. SVGKit automagically does this for you if you ever set a value to image.scale */
				if( ! CGSizeEqualToSize( CGSizeZero, customSizeForImage ) )
					document.size = customSizeForImage; // preferred way to scale an SVG! (standards compliant!)
				
				if( thisImageRequiresLayeredImageView )
				{
					newContentView = [[SVGKLayeredImageView alloc] initWithSVGKImage:document];
				}
				else
				{
					newContentView = [[SVGKFastImageView alloc] initWithSVGKImage:document];
					
					NSLog(@"[%@] WARNING: workaround for Apple bugs: UIScrollView spams tiny changes to the transform to the content view; currently, we have NO WAY of efficiently measuring whether or not to re-draw the SVGKImageView. As a temporary solution, we are DISABLING the SVGKImageView's auto-redraw-at-higher-resolution code - in general, you do NOT want to do this", [self class]);
					
					((SVGKFastImageView*)newContentView).disableAutoRedrawAtHighestResolution = TRUE;
				}
			}
			else
			{
				[[[UIAlertView alloc] initWithTitle:@"SVG parse failed" message:[NSString stringWithFormat:@"%i fatal errors, %i warnings. First fatal = %@",[document.parseErrorsAndWarnings.errorsFatal count],[document.parseErrorsAndWarnings.errorsRecoverable count]+[document.parseErrorsAndWarnings.warnings count], ((NSError*)(document.parseErrorsAndWarnings.errorsFatal)[0]).localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
				newContentView = nil; // signals to the rest of this method: the load failed
			}
		}
	}
	
	if( newContentView != nil )
	{
		/**
		 * NB: at this point we're guaranteed to have a "new" replacemtent ready for self.contentView
		 */
		
		/** Move the gesture recognizer off the old view */
		if( self.contentView != nil
		   && self.tapGestureRecognizer != nil )
			[self.contentView removeGestureRecognizer:self.tapGestureRecognizer];
		
		[self.contentView removeFromSuperview];
		
		/******* swap the new contentview in ************/
		self.contentView = newContentView;
		
	
		/** set the border for new item */
		self.contentView.showBorder = FALSE;
	
		/** Move the gesture recognizer onto the new one */	
		if( self.tapGestureRecognizer == nil )
		{
			self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		}
		[self.contentView addGestureRecognizer:self.tapGestureRecognizer];
		
		if (_name) {
			_name = nil;
		}
		
		_name = [name copy];
		
		[self.scrollViewForSVG addSubview:self.contentView];
		[self.scrollViewForSVG setContentSize: self.contentView.frame.size];
		
		float screenToDocumentSizeRatio = self.scrollViewForSVG.frame.size.width / self.contentView.frame.size.width;
		
		self.scrollViewForSVG.minimumZoomScale = MIN( 1, screenToDocumentSizeRatio );
		self.scrollViewForSVG.maximumZoomScale = MAX( 1, screenToDocumentSizeRatio );
		
		/**
		 EXAMPLE:
		 
		 How to find particular nodes in the tree, after parsing.
		 
		 In this case, we search for all SVG <g> tags, which usually mean grouped-objects in Inkscape etc:
		 NodeList* elementsUsingTagG = [document.DOMDocument getElementsByTagName:@"g"];
		 NSLog( @"[%@] checking for SVG standard set of elements with XML tag/node of <g>: %@", [self class], elementsUsingTagG.internalArray );
		 */
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
	animation.fromValue = @0.1f;
	animation.toValue = @-0.1f;
	
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
    UIViewController* textViewController = [[UIViewController alloc] init];
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
    _exportText = nil;
    
    _layerExporter = nil;
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
}



@end
