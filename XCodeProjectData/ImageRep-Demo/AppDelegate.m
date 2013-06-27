//
//  AppDelegate.m
//  SVGKitImageRepTest
//
//  Created by C.W. Betts on 12/5/12.
//  Copyright (c) 2012 C.W. Betts. All rights reserved.
//

#import "AppDelegate.h"

//This is done so we don't have to include the entire SVGKit Headers.
@interface SVGKit : NSObject

+ (void) enableLogging;

@end

#ifndef DONTUSESVGIMAGEREPDIRECTLY
#define DONTUSESVGIMAGEREPDIRECTLY 0
#endif

#if !DONTUSESVGIMAGEREPDIRECTLY
#import "SVGKitImageRep.h"
#endif

@implementation AppDelegate

#if !DONTUSESVGIMAGEREPDIRECTLY

+ (Class)imageRepClass
{
	static Class storedRep = nil;
	if (storedRep == nil) {
		storedRep = NSClassFromString(@"SVGKitImageRep");
	}
	return storedRep;
}

#endif

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[SVGKit enableLogging];
	NSBundle *SVGImageRepBundle;
	NSURL *bundlesURL = [[NSBundle mainBundle] builtInPlugInsURL];
	SVGImageRepBundle = [NSBundle bundleWithURL:[bundlesURL URLByAppendingPathComponent:@"SVGKImageRep.bundle"]];
	BOOL loaded = [SVGImageRepBundle load];
	if (!loaded) {
		NSLog(@"Bundle Not loaded!");
		return;
	}
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
#if DONTUSESVGIMAGEREPDIRECTLY
	NSImage *selectImage = [[NSImage alloc] initWithContentsOfURL:svgUrl];
#else
	NSImage *selectImage = [[NSImage alloc] init];
	SVGKitImageRep *imRep = [(SVGKitImageRep*)[[[self class] imageRepClass] alloc] initWithContentsOfURL:svgUrl];
	if (!imRep) {
		return;
	}
	[selectImage addRepresentation:imRep];
#endif
	[svgSelected setImage:selectImage];
}

- (IBAction)exportAsTIFF:(id)sender
{
	NSImage *theImage = [svgSelected image];
	if (!theImage) {
		NSBeep();
		return;
	} else {
		NSSavePanel *savePanel = [NSSavePanel savePanel];
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
			SVGKitImageRep *promising = nil;
			NSSize oldSize = NSZeroSize;
			for (id anObject in imageRepArrays) {
				if ([anObject isKindOfClass:[[self class] imageRepClass]]) {
					SVGKitImageRep *tmpRef = anObject;
					if (oldSize.height < tmpRef.size.height && oldSize.width < tmpRef.size.width) {
						promising = tmpRef;
						oldSize = tmpRef.size;
					}
				}
			}
			if (promising) {
				tiffData = [promising TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:1];
			}
#endif
			if (tiffData) {
				[tiffData writeToURL:[savePanel URL] atomically:YES];
			} else {
				
			}
		}
	}
}

@end
