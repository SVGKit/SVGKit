//
//  SVGKit_iOS_Tests.m
//  SVGKit-iOS Tests
//
//  Created by C.W. Betts on 10/13/14.
//  Copyright (c) 2014 na. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SVGKit.h"

#if ! __has_feature(objc_arc)
#error This test file must be compiled with ARC.
#endif

@interface SVGKit_iOS_ARCRetainTests : XCTestCase
@property (strong) NSBundle *pathsToSVGs;
@end

@implementation SVGKit_iOS_ARCRetainTests

- (void)setUp {
    [super setUp];
	
	self.pathsToSVGs = [NSBundle bundleForClass:[self class]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReleasing {
	XCTAssertNoThrow(^{
		@autoreleasepool {
			SVGKImage *image = [SVGKImage imageWithContentsOfFile:[self.pathsToSVGs pathForResource:@"Note" ofType:@"svg"]];
			// Yes, this is ARC, yes we do this to quiet a warning
			[image class];
			image = nil;
		}
	});
}

- (void)testReplacing {
	@try {
		SVGKImage *image = [SVGKImage imageWithContentsOfFile:[self.pathsToSVGs pathForResource:@"CurvedDiamond" ofType:@"svg"]];

		// Yes, this is ARC, yes we do this to quiet a warning
		[image class];

		image = [SVGKImage imageWithContentsOfFile:[self.pathsToSVGs pathForResource:@"Lion" ofType:@"svg"]];
		XCTAssertTrue(YES);
	}
	@catch (NSException *exception) {
		XCTFail(@"Exception Thrown");
	}
}

- (void)testSameFileTwice {
    XCTAssertNoThrow(^{
        @autoreleasepool {
            SVGKImage *image = [SVGKImage imageWithContentsOfFile:[self.pathsToSVGs pathForResource:@"Monkey" ofType:@"svg"]];
            SVGKImage *image2 = [SVGKImage imageWithContentsOfFile:[self.pathsToSVGs pathForResource:@"Monkey" ofType:@"svg"]];
            
            // Yes, this is ARC, yes we do this to quiet a warning
            [image class];
            [image2 class];
        }
    });
}

@end
