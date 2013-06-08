//
//  SKAppDelegate.h
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SVGKit.h"

@interface SKAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSWindowDelegate>

@property (assign) IBOutlet NSWindow *selectorWindow;
@property (readwrite, retain, nonatomic) SVGKImage *svgImage;
@property (readonly, retain) NSArray *svgArray;

@property (assign) IBOutlet NSWindow *layeredWindow;
@property (assign) IBOutlet SVGKLayeredImageView *layeredView;

@property (assign) IBOutlet NSWindow *quickWindow;
@property (assign) IBOutlet SVGKFastImageView *fastView;


@end
