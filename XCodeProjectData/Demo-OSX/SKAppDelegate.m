//
//  SKAppDelegate.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SKAppDelegate.h"
#import "SKSVGObject.h"

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
	}
}

- (void)dealloc
{
    self.svgArray = nil;
	self.svgImage = nil;
	
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[SVGKit enableLogging];
	
	NSMutableArray *tmpArray = [NSMutableArray array];
	NSString *pname;
		
	//NSDirectoryEnumerationOptions
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:[[NSBundle mainBundle] resourcePath]];

	self.svgImage = self.layeredView.image;
	
	@autoreleasepool {
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
		
		[tmpArray addObject:[[[SKSVGURLObject alloc] initWithURL:[NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/f/f9/BlankMap-Africa.svg"]] autorelease]];
		
		[tmpArray sortUsingComparator:^NSComparisonResult(id rhs, id lhs) {
			NSString *rhsString = [rhs fileName];
			NSString *lhsString = [lhs fileName];
			NSComparisonResult result = [rhsString localizedStandardCompare:lhsString];
			return result;
		}];
		
		self.svgArray = [NSArray arrayWithArray:tmpArray];
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSTableView *tmpView = [notification object];
	NSInteger selRow = [tmpView selectedRow];
	if (selRow > -1 && selRow < [self.svgArray count]) {
		SVGKImage *theImage = [[SVGKImage alloc] initWithContentsOfURL:[[self.svgArray objectAtIndex:selRow] svgURL]];
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

@end
