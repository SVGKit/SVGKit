//
//  AppDelegate.m
//  SVGKitImageRepTest
//
//  Created by C.W. Betts on 12/5/12.
//  Copyright (c) 2012 C.W. Betts. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSBundle *SVGImageRepBundle;
	NSString *bundlesPath = [[NSBundle mainBundle] builtInPlugInsPath];
	SVGImageRepBundle = [[NSBundle alloc] initWithPath:[bundlesPath stringByAppendingPathComponent:@"SVGKImageRep.bundle"]];
	BOOL loaded = [SVGImageRepBundle load];
	if (!loaded) {
		NSLog(@"Bundle Not loaded!");
		[SVGImageRepBundle release];
		return;
	}
	//NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	//NSImage *tempImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"admon-bug.svg"]];
		
	[SVGImageRepBundle release];
}

- (IBAction)selectSVG:(id)sender
{
	NSOpenPanel *op;
	op = [NSOpenPanel openPanel];
	[op setTitle: @"Open svg file"];
	[op setAllowsMultipleSelection: NO];
	[op setAllowedFileTypes:[NSArray arrayWithObjects:@"public.svg-image", @"svg", nil]];
	[op setCanChooseDirectories: NO];
	[op setCanChooseFiles: YES];
	
	if ([op runModal] != NSOKButton)
		return;
	NSURL *svgUrl = [[op URLs] objectAtIndex:0];
	
	NSImage *selectImage = [[NSImage alloc] initWithContentsOfURL:svgUrl];
	[svgSelected setImage:selectImage];
	[selectImage release];
}


@end
