//
//  ComparisonView.h
//  SVGTester
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@interface ComparisonView : NSView {
  @private
	NSBitmapImageRep *_original;
	NSBitmapImageRep *_output;
    
    BOOL _shouldDrawRedGreenOverlay;
}

- (void)compareImage:(NSBitmapImageRep *)image withOriginal:(NSBitmapImageRep *)original;

- (void) showOverlay;
- (void) hideOverlay;

@end
