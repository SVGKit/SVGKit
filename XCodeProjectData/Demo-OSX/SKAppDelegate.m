//
//  SKAppDelegate.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SKAppDelegate.h"

@interface SKAppDelegate ()

@property (readwrite, retain) NSArray *svgArray;


@end

@implementation SKAppDelegate

- (void)dealloc
{
    self.svgArray = nil;
	self.svgImage = nil;
	
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

@end
