//
//  SVGPadAppDelegate.h
//  SVGPad
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

@class RootViewController, DetailViewController;

@interface SVGPadAppDelegate : NSObject < UIApplicationDelegate > { }

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
