//
//  AppDelegate.m
//  SVGKitImageRepTest
//
//  Created by C.W. Betts on 12/5/12.
//  Copyright (c) 2012 C.W. Betts. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSBundle *SVGImageRepBundle;
	NSURL *bundlesURL = [[NSBundle mainBundle] builtInPlugInsURL];
	SVGImageRepBundle = [[NSBundle alloc] initWithURL:[bundlesURL URLByAppendingPathComponent:@"SVGKImageRep.bundle"]];
	BOOL loaded = [SVGImageRepBundle load];
	if (!loaded) {
		NSLog(@"Bundle Not loaded!");
		return;
	}
	//NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	//NSImage *tempImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"admon-bug.svg"]];
		
}

- (IBAction)selectSVG:(id)sender
{
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op setTitle: @"Open SVG file"];
	[op setAllowsMultipleSelection: NO];
	[op setAllowedFileTypes:@[@"public.svg-image", @"svg"]];
	[op setCanChooseDirectories: NO];
	[op setCanChooseFiles: YES];
	
	if ([op runModal] != NSOKButton)
		return;
	NSURL *svgUrl = [op URLs][0];
	
	NSImage *selectImage = [[NSImage alloc] initWithContentsOfURL:svgUrl];
	[op release];
	[svgSelected setImage:selectImage];
}


@end
