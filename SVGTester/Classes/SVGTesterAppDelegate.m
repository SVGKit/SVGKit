//
//  SVGTesterAppDelegate.m
//  SVGTester
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "SVGTesterAppDelegate.h"

#import "MainWindowController.h"

@implementation SVGTesterAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	if (!_controller) {
		_controller = [[MainWindowController alloc] init];
	}
	
	[_controller showWindow:self];
}

@end
