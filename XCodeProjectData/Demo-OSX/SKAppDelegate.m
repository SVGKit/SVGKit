//
//  SKAppDelegate.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SKAppDelegate.h"
#import "SKSVGObject.h"

@interface RoseReturnFunc : NSObject

@property (assign) SVGKImageView *theView;
@property (retain) id<SKSVGObject> imagePath;

@end

@implementation RoseReturnFunc

@end

@interface SKAppDelegate ()
@property (readwrite, strong) NSArray *svgArray;
@end

@implementation SKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
	NSString *pname;
	
	_cacheEnabled = NO;
	
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:[[NSBundle mainBundle] resourcePath]];
	
	while (pname = [dirEnum nextObject]) {
		//Only look for SVGs that are in the resources folder and the language subfolders.
		if ([[dirEnum fileAttributes][NSFileType] isEqualToString:NSFileTypeDirectory]) {
			if (!(NSOrderedSame == [[pname pathExtension] caseInsensitiveCompare:@"lproj"])) {
				[dirEnum skipDescendants];
			}
			continue;
		}
		if (NSOrderedSame == [[[pname lastPathComponent] pathExtension] caseInsensitiveCompare:@"svg"]) {
			SKSVGObject *tmpObj = [[SKSVGBundleObject alloc] initWithName:[pname lastPathComponent]];
			if (![tmpArray containsObject:tmpObj]) {
				[tmpArray addObject:tmpObj];
			}
		}
	}
	
	//[tmpArray addObject:[[SKSVGURLObject alloc] initWithURL:[NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/f/f9/BlankMap-Africa.svg"]]];
	
	@autoreleasepool {
		[tmpArray sortUsingComparator:^NSComparisonResult(id rhs, id lhs) {
			NSString *rhsString = [rhs fileName];
			NSString *lhsString = [lhs fileName];
			NSComparisonResult result = [rhsString localizedStandardCompare:lhsString];
			return result;
		}];
	}
	
	self.svgArray = [[NSArray alloc] initWithArray:tmpArray];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSTableView *tmpView = [notification object];
	NSInteger selRow = [tmpView selectedRow];
	if (selRow > -1 && selRow < [self.svgArray count]) {
		NSObject<SKSVGObject> *tmpObj = (self.svgArray)[selRow];
		SVGKImage *theImage = nil;
		SVGKImageView *theImageView = nil;
		NSWindow *imageWindow = nil;
		if (tmpView == self.fastTable) {
			imageWindow = self.quickWindow;
			theImageView = self.fastView;
		} else if (tmpView == self.layeredTable) {
			imageWindow = self.layeredWindow;
			theImageView = self.layeredView;
		} else {
			NSLog(@"This shouldn't happen...");
			return;
		}
		if ([tmpObj.fullFileName hasPrefix:@"Reinel_compass_rose"]) {
			RoseReturnFunc *theFunc = [RoseReturnFunc new];
			theFunc.theView = theImageView;
			theFunc.imagePath = tmpObj;
			NSBeginAlertSheet(@"Complex SVG", @"No", @"Yes", nil, imageWindow, self, @selector(sheetDidEnd:returnCode:contextInfo:), NULL, (void*)CFBridgingRetain(theFunc), @"The image \"%@\" has rendering issues on SVGKit. If you want to load the image, it will probably crash the app or, more likely, cause the view to become unresponsive.\n\nAre you sure you want to load the image?", tmpObj.fileName);
				return;
		}
		
		if ([tmpObj isKindOfClass:[SKSVGBundleObject class]]) {
			//This should also take care of the default use case, which uses the main bundle
			theImage = [SVGKImage imageNamed:tmpObj.fullFileName fromBundle:((SKSVGBundleObject*)tmpObj).theBundle];
		} else {
			theImage = [[SVGKImage alloc] initWithContentsOfURL:[tmpObj svgURL]];
		}
		
		if (![theImage hasSize]) {
			theImage.size = NSMakeSize(32, 32);
		}
		
		theImageView.frameSize = theImage.size;
		theImageView.image = theImage;
	}else
		NSBeep();
}

static inline NSString *exceptionInfo(NSException *e)
{
	NSString *debugStr = nil;
#if 0
	debugStr = [NSString stringWithFormat:@", call stack: { %@ }", [NSDictionary dictionaryWithObjects:e.callStackReturnAddresses forKeys:e.callStackSymbols]];
#else
	debugStr = [NSString stringWithFormat:@", call stack symbols: {%@}",e.callStackSymbols];
#endif
	
	return [NSString stringWithFormat:@"Exception name: \"%@\" reason: %@%@", e.name, e.reason, DEBUG ? debugStr : @""];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	CFTypeRef CFCtx = contextInfo;
	RoseReturnFunc *theFunc = CFBridgingRelease(CFCtx);
	
	if (returnCode != NSAlertDefaultReturn) {
		SVGKImage *tmpImage = nil;
		@try {
			tmpImage = [SVGKImage imageWithContentsOfURL:theFunc.imagePath.svgURL];
		}
		@catch (NSException *e) {
			NSLog(@"EXCEPTION while loading %@: %@", theFunc.imagePath.fileName, exceptionInfo(e));
			return;
		}
		if (![tmpImage hasSize]) {
			tmpImage.size = NSMakeSize(32, 32);
		}
		
		@try {
			theFunc.theView.image = tmpImage;
			theFunc.theView.frameSize = tmpImage.size;
		}
		@catch (NSException *e) {
			theFunc.theView.image = nil;
			theFunc.theView.frameSize = NSMakeSize(100, 100);
			NSLog(@"EXCEPTION while setting image %@ %@: %@", tmpImage, theFunc.imagePath.fileName, exceptionInfo(e));
		}
	}
}

- (IBAction)showLayeredWindow:(id)sender
{
	if (![self.layeredWindow isVisible]) {
		[self.layeredWindow orderFront:nil];
	}
}

- (IBAction)showFastWindow:(id)sender
{
	if (![self.quickWindow isVisible]) {
		[self.quickWindow orderFront:nil];
	}
}

- (IBAction)clearSVGCache:(id)sender
{
	if ([SVGKImage isCacheEnabled]) {
		[SVGKImage clearSVGImageCache];
	} else {
		NSRunAlertPanel(@"Cached Images", @"Cached images are not enabled at the moment.", nil, nil, nil);
	}
}

@synthesize cacheEnabled = _cacheEnabled;
- (void)setCacheEnabled:(BOOL)cacheEnabled
{
	_cacheEnabled = cacheEnabled;
	if (_cacheEnabled) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			NSRunInformationalAlertPanel(@"Image Caching", @"Image caching has been enabled. Note that there might be issues if you load the image to the fast image view, then load it to the layered image view.\n\nThis warning will only show once.", nil, nil, nil);
		});
		[SVGKImage enableCache];
	} else {
		[SVGKImage disableCache];
	}
}

@end
