//
//  SKAppDelegate.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SKAppDelegate.h"
#import "SKSVGObject.h"
#import "SVGKit.h"

@interface SKAppDelegate ()
@property (readwrite, retain) NSArray *svgArray;
@end

@implementation SKAppDelegate

@synthesize svgImage = _svgImage;
- (void)setSvgImage:(SVGKImage *)anImage
{
	if (_svgImage) {
		[_svgImage release];
		_svgImage = nil;
	}
	if (anImage) {
		_svgImage = [anImage retain];
		
		if (![anImage hasSize]) {
			anImage.size = NSMakeSize(32, 32);
		}
		self.layeredView.image = self.fastView.image = anImage;
		
		self.layeredView.frameSize = self.fastView.frameSize = anImage.size;
	} else {
		self.layeredView.image = self.fastView.image = nil;
		
		self.layeredView.frameSize = self.fastView.frameSize = NSMakeSize(32, 32);
	}
}

- (void)dealloc
{
    self.svgArray = nil;
	self.svgImage = nil;
	
	[super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification
{
	NSWindow *theWin = [notification object];
	if (theWin == self.selectorWindow) {
		[[NSApplication sharedApplication] stop:nil];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	//The layered view comes with an SVG image, even when inited without one.
	self.svgImage = self.layeredView.image;
	
	NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
	NSString *pname;
	
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:[[NSBundle mainBundle] resourcePath]];
	
	while (pname = [dirEnum nextObject]) {
		//Only look for SVGs that are in the resources folder, no deeper.
		if ([[[dirEnum fileAttributes] objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]) {
			[dirEnum skipDescendants];
			continue;
		}
		if (NSOrderedSame == [[pname pathExtension] caseInsensitiveCompare:@"svg"]) {
			[tmpArray addObject:[[[SKSVGBundleObject alloc] initWithName:pname] autorelease]];
		}
	}
	
	//[tmpArray addObject:[[[SKSVGURLObject alloc] initWithURL:[NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/f/f9/BlankMap-Africa.svg"]] autorelease]];
	
#if 0
	[tmpArray sortUsingComparator:^NSComparisonResult(id rhs, id lhs) {
		@autoreleasepool {
			NSString *rhsString = [rhs fileName];
			NSString *lhsString = [lhs fileName];
			NSComparisonResult result = [rhsString localizedStandardCompare:lhsString];
			return result;
		}
	}];
#endif
	
	self.svgArray = [NSArray arrayWithArray:tmpArray];
	[tmpArray release];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSTableView *tmpView = [notification object];
	NSInteger selRow = [tmpView selectedRow];
	if (selRow > -1 && selRow < [self.svgArray count]) {
		NSObject<SKSVGObject> *tmpObj = [self.svgArray objectAtIndex:selRow];
		SVGKImage *theImage = nil;
#ifdef USEBUNDLEINIT
		if ([tmpObj isKindOfClass:[SKSVGBundleObject class]]) {
			//This should also take care of the default use case, which uses the main bundle
			theImage = [[SVGKImage imageNamed:tmpObj.fullFileName fromBundle:((SKSVGBundleObject*)tmpObj).theBundle] retain];
		} else {
#endif
			theImage = [[SVGKImage alloc] initWithContentsOfURL:[tmpObj svgURL]];
#ifdef USEBUNDLEINIT
		}
#endif
		self.svgImage = theImage;
		[theImage release];
	}else NSBeep();
	if (![self.layeredWindow isVisible]) {
		[self.layeredWindow orderFront:nil];
	}
	if (![self.quickWindow isVisible]) {
		[self.quickWindow orderFront:nil];
	}
}

- (IBAction)clearSVGCache:(id)sender
{
	if ([[SVGKImage class] respondsToSelector:@selector(clearSVGImageCache)]) {
		[SVGKImage clearSVGImageCache];
	} else {
		NSLog(@"Cached images not implemented in SVGKit.");
	}
}

@end
