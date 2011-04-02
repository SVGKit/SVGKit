//
//  SVGPadAppDelegate.m
//  SVGPad
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "SVGPadAppDelegate.h"

#import "DetailViewController.h"
#import "RootViewController.h"

@implementation SVGPadAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self.window addSubview:splitViewController.view];
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void)dealloc {
	self.window = nil;
	self.splitViewController = nil;
	self.rootViewController = nil;
	self.detailViewController = nil;
	
	[super dealloc];
}

@end
