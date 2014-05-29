//
//  AppDelegate.m
//  SVGKitImageRepTest
//
//  Created by C.W. Betts on 12/5/12.
//  Copyright (c) 2012 C.W. Betts. All rights reserved.
//

#import "AppDelegate.h"
#import <SVGKit/SVGKImageRep.h>

@interface SVGKit : NSObject
+ (void) enableLogging;
@end

@implementation AppDelegate
@synthesize useRepDirectly;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.useRepDirectly = NO;
	[SVGKit enableLogging];
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
	NSImage *selectImage;
	if (!self.useRepDirectly) {
		selectImage = [[NSImage alloc] initWithContentsOfURL:svgUrl];
	} else {
		selectImage = [[NSImage alloc] init];
		SVGKImageRep *imRep = [[SVGKImageRep alloc] initWithContentsOfURL:svgUrl];
		if (!imRep) {
			return;
		}
		[selectImage addRepresentation:imRep];
	}
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
			NSData *tiffData;
			if (!self.useRepDirectly)
				tiffData = [theImage TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:1];
			else {
				NSArray *imageRepArrays = [theImage representations];
				SVGKImageRep *promising;
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
				if (promising) {
					tiffData = [promising TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:1];
				}
			}
			if (tiffData) {
				[tiffData writeToURL:[savePanel URL] atomically:YES];
			} else {
				
			}
		}
	}
}

@end
