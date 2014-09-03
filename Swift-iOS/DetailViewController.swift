//
//  DetailViewController.swift
//  Swift-iOS
//
//  Created by C.W. Betts on 9/2/14.
//  Copyright (c) 2014 na. All rights reserved.
//

import UIKit
import SVGKit
import SVGKit.CALayerExporter
import QuartzCore

struct ImageLoadingOptions {
    var requiresLayeredImageView = false
    var overrideImageSize = CGSizeZero
    var overrideImageRenderScale: CGFloat = 0
    var diskFilenameToLoad: String
    
    init(name: String) {
        diskFilenameToLoad = name
    }
}

let LOAD_SYNCHRONOUSLY = false // Synchronous load is less code, easier to write - but poor for large images

let ALLOW_2X_STYLE_SCALING_OF_SVGS_AS_AN_EXAMPLE = true // demonstrates using the "SVGKImage.scale" property to scale an SVG *before it generates output image data*

let ALLOW_SVGKFASTIMAGEVIEW_TO_DO_HIT_TESTING = true // only exists because people ignore the docs and try to do this when they clearly shouldn't. If you're foolish enough to do this, this code will show you how to do it CORRECTLY. Look how much code this requires! It's insane! Use SVGKLayeredImageView instead if you need hit-testing!

let SHOW_DEBUG_INFO_ON_EACH_TAPPED_LAYER = true // each time you tap and select a layer, that layer's info is displayed on-screen


private var lastTappedLayer: CALayer? = nil
private var lastTappedLayerOriginalBorderWidth: CGFloat = 0
private var lastTappedLayerOriginalBorderColor: CGColor? = UIColor.clearColor().CGColor
private var textLayerForLastTappedLayer: CATextLayer? = nil


class DetailViewController: UIViewController, UIPopoverControllerDelegate, UISplitViewControllerDelegate , CALayerExporterDelegate, UIScrollViewDelegate {
                            
	@IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var exportLog = ""
    var startParseTime = NSDate()
    var endParseTime = NSDate()
    var layerExporter: CALayerExporter? = nil
    var exportText: UITextView? = nil
    var popoverController: UIPopoverController? = nil
    var name = ""
    var tapGestureRecognizer: UITapGestureRecognizer!
    private var tickerLoadingApplesNSTimerSucks: NSTimer!
    
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var scrollViewForSVG: UIScrollView!
    @IBOutlet var contentView: SVGKImageView!
    @IBOutlet var viewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var progressLoading: UIProgressView!
    @IBOutlet var subViewLoadingPopup: UIView!
    
    @IBOutlet var labelParseTime: UILabel!

    func deselectTappedLayer() {
        if( lastTappedLayer != nil ) {
            (lastTappedLayer as SVGKLayer).borderWidth = lastTappedLayerOriginalBorderWidth;
            (lastTappedLayer as SVGKLayer).borderColor = lastTappedLayerOriginalBorderColor;
            
            textLayerForLastTappedLayer?.removeFromSuperlayer()
            textLayerForLastTappedLayer = nil;
            
            lastTappedLayer = nil;
        }
    }
    
    func handleTapGesture(recognizer: UITapGestureRecognizer) {
        var p = recognizer.locationInView(contentView)
        
        var layerForHitTesting = self.contentView.layer;
        
        
        var hitLayer = layerForHitTesting.hitTest(p)
        
        if( hitLayer == lastTappedLayer ) {
            deselectTappedLayer() // do this both ways, but have to do it AFTER the if-test because it nil's one of the if-phrases!
        } else {
            deselectTappedLayer() // do this both ways, but have to do it AFTER the if-test because it nil's one of the if-phrases!
            
            lastTappedLayer = hitLayer;
            
            if( lastTappedLayer != nil ) {
                lastTappedLayerOriginalBorderColor = (lastTappedLayer as SVGKLayer).borderColor;
                lastTappedLayerOriginalBorderWidth = (lastTappedLayer as SVGKLayer).borderWidth;
                
                (lastTappedLayer as SVGKLayer).borderColor = UIColor.greenColor().CGColor
                (lastTappedLayer as SVGKLayer).borderWidth = 3.0;
                
                if SHOW_DEBUG_INFO_ON_EACH_TAPPED_LAYER {
                    /** mtrubnikov's code for adding a text overlay showing exactly what you tapped
                    */
                    var textToDraw: String = NSString(format: "%@ (%@): {%.1f, %.1f} {%.1f, %.1f}", hitLayer.name, NSStringFromClass(hitLayer!.dynamicType), lastTappedLayer!.frame.origin.x, lastTappedLayer!.frame.origin.y, lastTappedLayer!.frame.size.width, lastTappedLayer!.frame.size.height);
                    
                    var fontToDraw = UIFont(name: "Helvetica", size: 14)
                    let sizeOfTextRect = textToDraw.sizeWithAttributes([NSFontAttributeName: fontToDraw])
                    //let sizeOfTextRect = textToDraw.sizeWithFont(fontToDraw)
                    
                    textLayerForLastTappedLayer = CATextLayer()
                    textLayerForLastTappedLayer?.font = "Helvetica"
                    textLayerForLastTappedLayer?.fontSize = 14
                    textLayerForLastTappedLayer?.frame = CGRect(origin: CGPointZero, size: sizeOfTextRect)
                    textLayerForLastTappedLayer?.string = textToDraw
                    textLayerForLastTappedLayer?.alignmentMode = kCAAlignmentLeft
                    textLayerForLastTappedLayer?.foregroundColor = UIColor.redColor().CGColor
                    textLayerForLastTappedLayer?.contentsScale = UIScreen.mainScreen().scale
                    textLayerForLastTappedLayer?.shouldRasterize = false
                    contentView.layer.addSublayer(textLayerForLastTappedLayer!)
                    /*
                    * mtrubnikov's code for adding a text overlay showing exactly what you tapped*/
                }            }
        }
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale finalScale: CGFloat) {
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
        view.setNeedsDisplay()
        
        /**
        Workaround for another bug in Apple's hacks for UIScrollView:
        
        - when you reset the transform, as advised by Apple, you "break" Apple's memory of the scroll factor.
        ... because they "forgot" to store it anywhere (they read your view.transform as if it were a private
        variable inside UIScrollView! This causes MANY bugs in applications :( )
        */
        self.scrollViewForSVG.minimumZoomScale /= finalScale;
        self.scrollViewForSVG.maximumZoomScale /= finalScale;
    }
    
	var detailItem: AnyObject? {
        willSet {
            deselectTappedLayer()
        }
		didSet {
		    // Update the view.
		    self.configureView()
			
            if popoverController != nil {
                popoverController?.dismissPopoverAnimated(true)
            }
			
            loadResource(detailItem as String)
		}
	}

    
    func layerInfo(l: CALayer) -> String {
        return "\(l.dynamicType):\(NSStringFromCGRect(l.frame))"
    }
    
	func configureView() {
		// Update the user interface for the detail item.
		if let detail: AnyObject = self.detailItem {
		    if let label = self.detailDescriptionLabel {
		        label.text = detail.description
		    }
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    func willLoadNewResource() {
        // update the view
        self.subViewLoadingPopup.hidden = false;
        self.progressLoading.progress = 0;
        self.viewActivityIndicator.startAnimating()
        /** Move the gesture recognizer off the old view */
        if( contentView != nil
            && tapGestureRecognizer != nil ) {
                contentView.removeGestureRecognizer(tapGestureRecognizer)
        }
        
        labelParseTime.removeFromSuperview() // we'll re-add to the new one
        contentView.removeFromSuperview()
    }
    
    /**
    If you want to emulate Apple's @2x naming system for UIImage, you can...
    */
    func preProcessImageFor2X(inout options: ImageLoadingOptions) {
        if ALLOW_2X_STYLE_SCALING_OF_SVGS_AS_AN_EXAMPLE {
            if options.diskFilenameToLoad.hasSuffix("@2x") {
                options.diskFilenameToLoad = (options.diskFilenameToLoad as NSString).substringToIndex((options.diskFilenameToLoad as NSString).length - ("@2x" as NSString).length);
                options.overrideImageRenderScale = 2.0;
                options.requiresLayeredImageView = true;
            }
        }
    }

    func preProcessImageForAt160x240(inout options: ImageLoadingOptions) {
        if options.diskFilenameToLoad.hasSuffix("@160x240") // could be any 999x999 you want, up to you to implement!
        {
            options.diskFilenameToLoad = (options.diskFilenameToLoad as NSString).substringToIndex((options.diskFilenameToLoad as NSString).length - ("@160x240" as NSString).length)
            options.overrideImageSize = CGSize(width: 160, height: 240)
        }
    }
    
    func preProcessImageCheckWorkaroundAppleBugInGradientImages(inout options: ImageLoadingOptions) {
        if(
        options.diskFilenameToLoad == "Monkey" // Monkey uses layer-animations, so REQUIRES the layered version of SVGKImageView
        || options.diskFilenameToLoad == "RainbowWing" // RainbowWing uses gradient-fills, so REQUIRES the layered version of SVGKImageView
        || options.diskFilenameToLoad == "imagetag-layered" // uses gradients for prettiness
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
            options.requiresLayeredImageView = true;
        }
    }

    func loadResource(name: String) {
        willLoadNewResource()
        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.01))// makes the animation appear
        
        let currentTime = NSDate()
        
        startParseTime = currentTime // reset them
        endParseTime = currentTime
        
        /** This demo shows different images being used in different ways.
        Here we setup special conditions based on the filename etc:
        */
        var loadingOptions = ImageLoadingOptions(name: name)
        preProcessImageFor2X(&loadingOptions)
        preProcessImageForAt160x240(&loadingOptions)
        preProcessImageCheckWorkaroundAppleBugInGradientImages(&loadingOptions)
        
        /** Detect the magic name(s) for the nil-demos */
        if name == "nil-demo-layered-imageview" {
            /** This demonstrates / tests what happens if you create an SVGKLayeredImageView with a nil SVGKImage
            
            NB: this is what Apple's InterfaceBuilder / Xcode 4 FORCES YOU TO DO because of massive bugs in Xcode 4!
            */
            didLoadNewResourceCreatingImageView(SVGKLayeredImageView(coder: nil))
        }
        else
        {
            /**
            the actual loading of the SVG file
            */
            
            var document: SVGKImage! = nil
            
            /** Detect URL vs file */
            startParseTime = NSDate()
            if name.hasPrefix("http://")
            {
                document = SVGKImage(contentsOfURL: NSURL(string: name))
                internalLoadedResource(name, withOptions: loadingOptions, createImageViewFromDocument: document)
            }
            else
            {
                if LOAD_SYNCHRONOUSLY {
                    document = SVGKImage(named: name.stringByAppendingPathExtension("svg"))
                    internalLoadedResource(name, withOptions: loadingOptions, createImageViewFromDocument: document)
                } else {
                    var parser = SVGKImage.imageAsynchronouslyNamed(name.stringByAppendingPathExtension("svg"), onCompletion: { (loadedImage) -> Void in
                        self.tickerLoadingApplesNSTimerSucks.invalidate()
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.internalLoadedResource(name, withOptions: loadingOptions, createImageViewFromDocument: loadedImage)
                        })
                    })
                    self.tickerLoadingApplesNSTimerSucks = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "tickLoadingSVG:", userInfo: parser, repeats: true)
                }
            }
        }
    }
    
    @objc func tickLoadingSVG(parser: SVGKParser!) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // must be on main queue since this affects the UIKit GUI!
            self.progressLoading!.progress = Float(parser!.currentParseRun.parseProgressFractionApproximate)
        })
    }
    
    private func internalLoadedResource(name:String, withOptions loadingOptions: ImageLoadingOptions, createImageViewFromDocument document: SVGKImage!) {
        endParseTime = NSDate()
        
        var newContentView: SVGKImageView? = nil;
        if( loadingOptions.overrideImageRenderScale != 1.0 ) {
            document.scale = loadingOptions.overrideImageRenderScale;
        }
        if document == nil {
            UIAlertView(title: "SVG parse failed", message: "Total failure. See console log", delegate: nil, cancelButtonTitle: "OK").show()
            newContentView = nil; // signals to the rest of this method: the load failed
        } else {
            if document.parseErrorsAndWarnings.rootOfSVGTree != nil {
                //NSLog(@"[%@] Freshly loaded document (name = %@) has size = %@", [self class], name, NSStringFromCGSize(document.size) );
                
                /** NB: the SVG Spec says that the "correct" way to upscale or downscale an SVG is by changing the
                SVG Viewport. SVGKit automagically does this for you if you ever set a value to image.scale */
                if( !CGSizeEqualToSize( CGSizeZero, loadingOptions.overrideImageSize ) ) {
                document.size = loadingOptions.overrideImageSize; // preferred way to scale an SVG! (standards compliant!)
                }
                
                if loadingOptions.requiresLayeredImageView {
                    newContentView = SVGKLayeredImageView(SVGKImage: document)
                } else {
                    newContentView = SVGKFastImageView(SVGKImage: document)
                    
                    NSLog("[\(self.dynamicType)] WARNING: workaround for Apple bugs: UIScrollView spams tiny changes to the transform to the content view; currently, we have NO WAY of efficiently measuring whether or not to re-draw the SVGKImageView. As a temporary solution, we are DISABLING the SVGKImageView's auto-redraw-at-higher-resolution code - in general, you do NOT want to do this");
                    
                    (newContentView as SVGKFastImageView).disableAutoRedrawAtHighestResolution = true
                }
            } else {
                UIAlertView(title: "SVG parse failed", message: "\(document.parseErrorsAndWarnings.errorsFatal.count) fatal errors, \(document.parseErrorsAndWarnings.errorsRecoverable.count + document.parseErrorsAndWarnings.warnings.count) warnings. First fatal = \((document.parseErrorsAndWarnings.errorsFatal[0] as NSError).localizedDescription)", delegate: nil, cancelButtonTitle: "OK")
                
                newContentView = nil; // signals to the rest of this method: the load failed
                
            }
        }
        
        self.name = name
        
        didLoadNewResourceCreatingImageView(newContentView)
    }
	
    func didLoadNewResourceCreatingImageView(newContentView: SVGKImageView!) {
        if newContentView != nil  {
            /**
            * NB: at this point we're guaranteed to have a "new" replacemtent ready for self.contentView
            */
            
            /******* swap the new contentview in ************/
            self.contentView = newContentView;
            
            if( self.labelParseTime == nil ){
                self.labelParseTime = UILabel();
                self.labelParseTime.autoresizingMask = .FlexibleWidth;
                self.labelParseTime.backgroundColor = UIColor(white: 1, alpha: 0.5)
                self.labelParseTime.textColor = UIColor.blackColor();
                self.labelParseTime.text = "(parsing)";
            }
            /** Workaround for Apple 10 years old bug in OS X that they ported to iOS :( */
            self.labelParseTime.frame = CGRectMake( 0, 0, self.contentView.bounds.size.width, 20.0 );
            
            contentView.addSubview(labelParseTime)
            
            /** set the border for new item */
            self.contentView.showBorder = false;
            
            /** Move the gesture recognizer onto the new one */
            if( tapGestureRecognizer == nil ) {
                self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:") ;
            }
            contentView.addGestureRecognizer(tapGestureRecognizer)
            
            scrollViewForSVG.addSubview(contentView)
            scrollViewForSVG.contentSize = contentView.frame.size
            
            var screenToDocumentSizeRatio = self.scrollViewForSVG.frame.size.width / self.contentView.frame.size.width;
            
            self.scrollViewForSVG.minimumZoomScale = min( 1, screenToDocumentSizeRatio );
            self.scrollViewForSVG.maximumZoomScale = max( 1, screenToDocumentSizeRatio );
            
            title = self.name;
            self.labelParseTime.text = NSString(format:"%@ (parsed: %.2f secs, rendered: %.2f secs)", name, endParseTime.timeIntervalSinceDate(startParseTime), self.contentView.timeIntervalForLastReRenderOfSVGFromMemory)
            
            /** Fast image view renders asynchronously, so we have to wait for a callback that its finished a render... */
            contentView.addObserver(self, forKeyPath: "timeIntervalForLastReRenderOfSVGFromMemory", options: NSKeyValueObservingOptions(0), context: nil)
            
            /**
            EXAMPLE:
            
            How to find particular nodes in the tree, after parsing.
            
            In this case, we search for all SVG <g> tags, which usually mean grouped-objects in Inkscape etc:
            NodeList* elementsUsingTagG = [document.DOMDocument getElementsByTagName:@"g"];
            NSLog( @"[%@] checking for SVG standard set of elements with XML tag/node of <g>: %@", [self class], elementsUsingTagG.internalArray );
            */
        }
        
        self.viewActivityIndicator.stopAnimating()
        self.subViewLoadingPopup.hidden = true;
    }

    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if keyPath == "timeIntervalForLastReRenderOfSVGFromMemory" {
            labelParseTime.text = NSString(format:"%@ (parsed: %.2f secs, rendered: %.2f secs)", name as NSString, endParseTime.timeIntervalSinceDate(startParseTime), contentView.timeIntervalForLastReRenderOfSVGFromMemory );

        }
    }
    
    @IBAction func animate(sender: AnyObject!) {
        if name == "Monkey" {
            shakeHead()
        }
    }
    
    func shakeHead() {
        var layer = contentView.image.layerWithIdentifier("head")
        
        var animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.25
        animation.autoreverses = true
        animation.repeatCount = 100000;
        animation.fromValue = 0.1
        animation.toValue = -0.1
        
        layer.addAnimation(animation, forKey: "shakingHead")

    }
    
    @IBAction func showHideBorder(sender: AnyObject!) {
    contentView.showBorder = !contentView.showBorder;
    
    /**
    NB: normally, the following would NOT be needed - the SVGKImageView would automatically
    detect it needs to be re-drawn.
    
    But ... because we're doing zooming in this class, and Apple's zooming causes huge performance problems,
    we disabled the auto-redraw in the loadResource: method above.
    
    So, now, we have to manually tell the SVGKImageView to redraw
    */
    contentView.setNeedsDisplay()
    }

    
    // MARK: - Split View
    
    func splitViewController(svc: UISplitViewController, willHideViewController aViewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController pc: UIPopoverController) {
        barButtonItem.title = NSLocalizedString("Master", comment: "Master")
        navigationItem.setLeftBarButtonItem(barButtonItem, animated: true)
        popoverController = pc;

    }
    
    func splitViewController(svc: UISplitViewController, willShowViewController aViewController: UIViewController, invalidatingBarButtonItem barButtonItem: UIBarButtonItem) {
        navigationItem.setLeftBarButtonItem(nil, animated: true)
        popoverController = nil;
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    // MARK: export
    
    @IBAction func exportLayers(sender: AnyObject!) {
        if layerExporter != nil {
            return
        }
        layerExporter = CALayerExporter(view: contentView)
        layerExporter?.delegate = self;
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        var textViewController = UIViewController()
        textViewController.view = textView
        var exportPopover = UIPopoverController(contentViewController: textViewController)
        exportPopover.delegate = self
        exportPopover.presentPopoverFromBarButtonItem(sender as UIBarButtonItem, permittedArrowDirections: .Any, animated: true)
        
        exportText = textView;
        exportText?.text = "exporting..."
        
        exportLog = ""
        layerExporter!.startExport()
    }
    
    func layerExporter(exporter: CALayerExporter!, didParseLayer layer: CALayer!, withStatement statement: String!) {
        exportLog += statement + "\n"
    }
    
    func layerExporterDidFinish(exporter: CALayerExporter!) {
        exportText?.text = exportLog
    }
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        exportText = nil
        
        layerExporter = nil
    }

}

