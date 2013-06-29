//
//  AppDelegate.m
//  SVGKitImageRepTest
//
//  Created by C.W. Betts on 12/5/12.
//  Copyright (c) 2012 C.W. Betts. All rights reserved.
//

#define Comment AIFFComment
#include <CoreServices/CoreServices.h>
#undef Comment

#import "AppDelegate.h"
#import "SVGKit.h"

#ifndef DONTUSESVGIMAGEREPDIRECTLY
#define DONTUSESVGIMAGEREPDIRECTLY 0
#endif

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[SVGKit enableLogging];
}

- (IBAction)selectSVG:(id)sender
{
	NSOpenPanel *op = [[NSOpenPanel openPanel] retain];
	[op setTitle: @"Open SVG file"];
	[op setAllowsMultipleSelection: NO];
	[op setAllowedFileTypes:@[@"public.svg-image", @"svg"]];
	[op setCanChooseDirectories: NO];
	[op setCanChooseFiles: YES];
	
	if ([op runModal] != NSOKButton)
	{
		[op release];
		return;
	}
	NSURL *svgUrl = [op URLs][0];
#if DONTUSESVGIMAGEREPDIRECTLY
	NSImage *selectImage = [[NSImage alloc] initWithContentsOfURL:svgUrl];
	[op release];
#else
	NSImage *selectImage = [[NSImage alloc] init];
	SVGKImageRep *imRep = [[SVGKImageRep alloc] initWithContentsOfURL:svgUrl];
	[op release];
	if (!imRep) {
		[selectImage release];
		return;
	}
	[selectImage addRepresentation:imRep];
	[imRep release];
#endif
	[svgSelected setImage:selectImage];
	[selectImage release];
}

- (IBAction)exportAsTIFF:(id)sender
{
	NSImage *theImage = [svgSelected image];
	if (!theImage) {
		NSBeep();
		return;
	} else {
		NSSavePanel *savePanel = [[NSSavePanel savePanel] retain];
		[savePanel setTitle:@"Save TIFF data"];
		[savePanel setAllowedFileTypes:@[(NSString*)kUTTypeTIFF]];
		[savePanel setCanCreateDirectories:YES];
		[savePanel setCanSelectHiddenExtension:YES];
		if ([savePanel runModal] == NSOKButton) {
			NSData *tiffData = nil;
#if DONTUSESVGIMAGEREPDIRECTLY
			tiffData = [theImage TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:1];
#else
			NSArray *imageRepArrays = [theImage representations];
			SVGKImageRep *promising = nil;
			NSSize oldSize = NSZeroSize;
			for (id anObject in imageRepArrays) {
				if ([anObject isKindOfClass:[SVGKImageRep class]]) {
					SVGKImageRep *tmpRef = anObject;
					if (oldSize.height < tmpRef.size.height && oldSize.width < tmpRef.size.width) {
						promising = tmpRef;
						oldSize = tmpRef.size;
					}
				}
			}
#if 0
			if (promising) {
				tiffData = [promising TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:1];
			}
#else
			if (promising) {
				tiffData = [promising.image.NSImage TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:1];
			}
#endif
#endif
			if (tiffData) {
				[tiffData writeToURL:[savePanel URL] atomically:YES];
			} else {
				
			}
		}
		[savePanel release];
	}
}

@end
