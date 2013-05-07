//
//  AppDelegate.h
//  SVGKitImageRepTest
//
//  Created by C.W. Betts on 12/5/12.
//  Copyright (c) 2012 C.W. Betts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	IBOutlet NSImageCell *svgSelected;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)selectSVG:(id)sender;


@end
