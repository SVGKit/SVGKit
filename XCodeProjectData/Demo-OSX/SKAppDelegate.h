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

@property (readonly, strong) NSArray *svgArray;

@property (weak) IBOutlet NSWindow *layeredWindow;
@property (weak) IBOutlet SVGKLayeredImageView *layeredView;
@property (weak) IBOutlet NSTableView *layeredTable;

@property (weak) IBOutlet NSWindow *quickWindow;
@property (weak) IBOutlet SVGKFastImageView *fastView;
@property (weak) IBOutlet NSTableView *fastTable;

- (IBAction)clearSVGCache:(id)sender;
- (IBAction)showLayeredWindow:(id)sender;
- (IBAction)showFastWindow:(id)sender;

@end
