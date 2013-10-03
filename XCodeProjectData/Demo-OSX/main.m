//
//  main.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SVGKit/SVGKit.h>

#ifndef TESTSVGKPARSERASYNCHRONOUS
#define TESTSVGKPARSERASYNCHRONOUS 0
#endif

#if TESTSVGKPARSERASYNCHRONOUS
@interface TestDelegate : NSObject <SVGKParserDelegate>

@end

@implementation TestDelegate

- (void)parser:(SVGKParser *)parserPassed DidFinishParsingWithResult:(SVGKParseResult *)result
{
	[parserPassed release];
	NSLog(@"Parse Complete");
}

@end
#endif

int main(int argc, char *argv[])
{
	@autoreleasepool {
		[SVGKit enableLogging];
	}
	
#if TESTSVGKPARSERASYNCHRONOUS
	//SVGKParser parseAsynchronously tester
	@autoreleasepool {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"CurvedDiamond" ofType:@"svg"];
		SVGKSource *theSource = [SVGKSource sourceFromFilename:path];
		SVGKParser *theParser = [[[SVGKParser alloc] initWithSource:theSource] retain];
		[theParser addDefaultSVGParserExtensions];
		[theParser parseAsynchronously];
		TestDelegate *theTest = [TestDelegate new];
		[theParser parseAsynchronouslyWithDelegate:theTest];
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			sleep(20);
			dispatch_sync(dispatch_get_main_queue(), ^{
				[theParser parseAsynchronouslyWithDelegate:theTest];

			});
		});
	}
#endif
	
	return NSApplicationMain(argc, (const char **)argv);
	
}
