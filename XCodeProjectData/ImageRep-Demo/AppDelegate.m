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

#if defined(DONTUSESVGIMAGEREPDIRECTLY) && DONTUSESVGIMAGEREPDIRECTLY
#else
@interface SVGKitImageRep : NSImageRep
- (NSData *)TIFFRepresentation;
- (NSData *)TIFFRepresentationUsingCompression:(NSTIFFCompression)comp factor:(float)factor;

+ (NSImageRep *)imageRepWithData:(NSData *)d;

- (id)initWithData:(NSData *)theData;
- (id)initWithURL:(NSURL *)theURL;
- (id)initWithPath:(NSString *)thePath;
- (id)initWithSVGString:(NSString *)theString;

@end

@interface AppDelegate ()
+ (Class)imageRepClass;
@end

#endif

@implementation AppDelegate

#if defined(DONTUSESVGIMAGEREPDIRECTLY) && DONTUSESVGIMAGEREPDIRECTLY
#else

+ (Class)imageRepClass
{
	static Class storedRep = nil;
	if (storedRep == nil) {
		storedRep = NSClassFromString(@"SVGKitImageRep");
	}
	return storedRep;
}

#endif


- (void)dealloc
{
    [super dealloc];
}

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
	NSOpenPanel *op = [[NSOpenPanel openPanel] retain];
	[op setTitle: @"Open SVG file"];
	[op setAllowsMultipleSelection: NO];
	[op setAllowedFileTypes:[NSArray arrayWithObjects:@"public.svg-image", @"svg", nil]];
	[op setCanChooseDirectories: NO];
	[op setCanChooseFiles: YES];
	
	if ([op runModal] != NSOKButton)
	{
		[op release];
		return;
	}
	NSURL *svgUrl = [[op URLs] objectAtIndex:0];
#if defined(DONTUSESVGIMAGEREPDIRECTLY) && DONTUSESVGIMAGEREPDIRECTLY
	NSImage *selectImage = [[NSImage alloc] initWithContentsOfURL:svgUrl];
	[op release];
#else
	NSImage *selectImage = [[NSImage alloc] init];
	SVGKitImageRep *imRep = [(SVGKitImageRep*)[[[self class] imageRepClass] alloc] initWithURL:svgUrl];
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
		[savePanel setAllowedFileTypes:[NSArray arrayWithObject:(NSString*)kUTTypeTIFF]];
		[savePanel setCanCreateDirectories:YES];
		[savePanel setCanSelectHiddenExtension:YES];
		if ([savePanel runModal] == NSOKButton) {
			NSData *tiffData = nil;
#if defined(DONTUSESVGIMAGEREPDIRECTLY) && DONTUSESVGIMAGEREPDIRECTLY
			tiffData = [theImage TIFFRepresentation];
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
				tiffData = [promising TIFFRepresentation];
			}
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
