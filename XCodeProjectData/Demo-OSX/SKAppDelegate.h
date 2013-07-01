//
//  SKAppDelegate.h
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SVGKit/SVGKit.h>

@interface SKAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate>

@property (readonly, strong) NSArray *svgArray;

@property (unsafe_unretained) IBOutlet NSWindow *layeredWindow;
@property (unsafe_unretained) IBOutlet SVGKLayeredImageView *layeredView;
@property (unsafe_unretained) IBOutlet NSTableView *layeredTable;

@property (unsafe_unretained) IBOutlet NSWindow *quickWindow;
@property (unsafe_unretained) IBOutlet SVGKFastImageView *fastView;
@property (unsafe_unretained) IBOutlet NSTableView *fastTable;
@property (nonatomic, getter = isCacheEnabled) BOOL cacheEnabled;

- (IBAction)clearSVGCache:(id)sender;
- (IBAction)showLayeredWindow:(id)sender;
- (IBAction)showFastWindow:(id)sender;

@end
