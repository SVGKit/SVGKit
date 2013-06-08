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

@property (weak) IBOutlet NSWindow *selectorWindow;
@property (readwrite, strong) SVGKImage *svgImage;
@property (readonly, strong) NSArray *svgArray;

@property (weak) IBOutlet NSWindow *layeredWindow;
@property (weak) IBOutlet SVGKLayeredImageView *layeredView;

@property (weak) IBOutlet NSWindow *quickWindow;
@property (weak) IBOutlet SVGKFastImageView *fastView;


@end
