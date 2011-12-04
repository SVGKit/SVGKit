//
//  MainWindowController.m
//  SVGTester
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "MainWindowController.h"

@implementation MainWindowController

@synthesize view = _view;

- (id)init {
	self = [super initWithWindowNibName:@"MainWindow"];
	if (self) {
		_names = [NSArray arrayWithObjects:@"Monkey.svg", @"Note.svg", nil];
		_currentIndex = 0;
	}
	return self;
}

- (IBAction)next:(id)sender {
	NSString *name = [_names objectAtIndex:_currentIndex];
	
	SVGDocument *document = [SVGDocument documentNamed:name];
	
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																	pixelsWide:document.width
																	pixelsHigh:document.height
																 bitsPerSample:8
															   samplesPerPixel:3
																	  hasAlpha:NO
																	  isPlanar:NO
																colorSpaceName:NSCalibratedRGBColorSpace
																   bytesPerRow:4 * document.width
																  bitsPerPixel:32];
	
	CGContextRef context = [[NSGraphicsContext graphicsContextWithBitmapImageRep:rep] graphicsPort];
	
	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // white background
	CGContextFillRect(context, CGRectMake(0.0f, 0.0f, document.width, document.height));
	
	CGContextScaleCTM(context, 1.0f, -1.0f); // flip
	CGContextTranslateCTM(context, 0.0f, -document.height);
	
	[[document layerTree] renderInContext:context];
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	
	NSBitmapImageRep *rendering = [[NSBitmapImageRep alloc] initWithCGImage:image];
	CGImageRelease(image);
	
	NSString *imageName = [name stringByReplacingOccurrencesOfString:@"svg" withString:@"png"];
	NSString *file = [[NSBundle mainBundle] pathForImageResource:imageName];
	
	NSData *data = [NSData dataWithContentsOfFile:file];
	NSBitmapImageRep *original = [[NSBitmapImageRep alloc] initWithData:data];
	
	[_view compareImage:rendering withOriginal:original];
	
	if (_currentIndex == [_names count] - 1) {
		[sender setEnabled:NO];
	}
	
	_currentIndex++;
}

- (void)windowDidLoad {
	[super windowDidLoad];
	[self next:nil];
}

@end
