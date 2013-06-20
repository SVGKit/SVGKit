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
@property (readwrite, strong) NSArray *svgArray;

@end

@implementation SKAppDelegate

@synthesize svgImage = _svgImage;
- (void)setSvgImage:(SVGKImage *)anImage
{
	_svgImage = anImage;
	if (anImage) {
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
	
	@autoreleasepool {
		NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
		NSString *pname;
		
		NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:[[NSBundle mainBundle] resourcePath]];

		while (pname = [dirEnum nextObject]) {
			//Only look for SVGs that are in the resources folder, no deeper.
			if ([[dirEnum fileAttributes][NSFileType] isEqualToString:NSFileTypeDirectory]) {
				[dirEnum skipDescendants];
				continue;
			}
			if (NSOrderedSame == [[pname pathExtension] caseInsensitiveCompare:@"svg"]) {
				[tmpArray addObject:[[SKSVGBundleObject alloc] initWithName:pname]];
			}
		}
		
		//[tmpArray addObject:[[SKSVGURLObject alloc] initWithURL:[NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/f/f9/BlankMap-Africa.svg"]]];
		
#if 0
		[tmpArray sortUsingComparator:^NSComparisonResult(id rhs, id lhs) {
			NSString *rhsString = [rhs fileName];
			NSString *lhsString = [lhs fileName];
			NSComparisonResult result = [rhsString localizedStandardCompare:lhsString];
			return result;
		}];
#endif
		
		self.svgArray = [[NSArray alloc] initWithArray:tmpArray];
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSTableView *tmpView = [notification object];
	NSInteger selRow = [tmpView selectedRow];
	if (selRow > -1 && selRow < [self.svgArray count]) {
		NSObject <SKSVGObject> *tmpObj = (self.svgArray)[selRow];
		SVGKImage *theImage = nil;
		if ([tmpObj isKindOfClass:[SKSVGBundleObject class]]) {
			//This should also take care of the default use case, which uses the main bundle
			theImage = [SVGKImage imageNamed:tmpObj.fullFileName fromBundle:((SKSVGBundleObject*)tmpObj).theBundle];
		} else {
			theImage = [[SVGKImage alloc] initWithContentsOfURL:[tmpObj svgURL]];
		}
		self.svgImage = theImage;
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
