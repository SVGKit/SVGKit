//
//  AppDelegate.m
//  SVGKitImageRepTest
//
//  Created by C.W. Betts on 12/5/12.
//  Copyright (c) 2012 C.W. Betts. All rights reserved.
//

#import "AppDelegate.h"

#ifndef DONTUSESVGIMAGEREPDIRECTLY
#define DONTUSESVGIMAGEREPDIRECTLY 0
#endif

#if defined(DONTUSESVGIMAGEREPDIRECTLY) && DONTUSESVGIMAGEREPDIRECTLY
#else
@interface SVGKitImageRep : NSImageRep

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
		storedRep = [NSClassFromString(@"SVGKitImageRep") retain];
	}
	return storedRep;
}

#endif

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
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
#if defined(DONTUSESVGIMAGEREPDIRECTLY) && DONTUSESVGIMAGEREPDIRECTLY
	NSImage *selectImage = [[NSImage alloc] initWithContentsOfURL:svgUrl];
#else
	NSImage *selectImage = [[NSImage alloc] init];
	SVGKitImageRep *imRep = [[[[self class] imageRepClass] alloc] initWithURL:svgUrl];
	if (!imRep) {
		return;
	}
	[selectImage addRepresentation:imRep];
#endif
	[svgSelected setImage:selectImage];
}


@end
