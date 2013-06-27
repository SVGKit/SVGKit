//
//  SKAppDelegate.h
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SVGKit.h"

@interface SKAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate>

@property (readonly, retain) NSArray *svgArray;

@property (assign) IBOutlet NSWindow *layeredWindow;
@property (assign) IBOutlet SVGKLayeredImageView *layeredView;
@property (assign) IBOutlet NSTableView *layeredTable;

@property (assign) IBOutlet NSWindow *quickWindow;
@property (assign) IBOutlet SVGKFastImageView *fastView;
@property (assign) IBOutlet NSTableView *fastTable;
@property (nonatomic, getter = isCacheEnabled) BOOL cacheEnabled;

- (IBAction)clearSVGCache:(id)sender;
- (IBAction)showLayeredWindow:(id)sender;
- (IBAction)showFastWindow:(id)sender;

@end
