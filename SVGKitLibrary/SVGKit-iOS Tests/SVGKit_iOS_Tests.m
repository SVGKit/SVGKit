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

#if !__has_feature(objc_arc)
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
	@try {
		@autoreleasepool {
			SVGKImage *image = [[SVGKImage alloc] initWithContentsOfFile:[self.pathsToSVGs pathForResource:@"Note" ofType:@"svg"]];
			// Yes, this is ARC, yes we do this to quiet a warning
			NSLog(@"description: %@", [image description]);
			[image class];
			XCTAssertNoThrow(image = nil);
		}
		XCTAssertTrue(YES);
	}
	@catch (NSException *exception) {
		XCTFail(@"Exception Thrown: %@", exception);
	}
}



- (void)testReplacing {
	@try {
		@autoreleasepool {
			SVGKImage *image = [[SVGKImage alloc] initWithContentsOfFile:[self.pathsToSVGs pathForResource:@"CurvedDiamond" ofType:@"svg"]];
			
			// Yes, this is ARC, yes we do this to quiet a warning
			NSLog(@"description: %@", [image description]);
			[image class];
			
			XCTAssertNoThrow(image = [SVGKImage imageWithContentsOfFile:[self.pathsToSVGs pathForResource:@"Lion" ofType:@"svg"]]);
			NSLog(@"description: %@", [image description]);
			[image class];
		}
		XCTAssertTrue(YES);
	}
	@catch (NSException *exception) {
		XCTFail(@"Exception Thrown: %@", exception);
	}
}

- (void)testSameFileTwice {
    @try {
        @autoreleasepool {
            SVGKImage *image = [SVGKImage imageWithContentsOfFile:[self.pathsToSVGs pathForResource:@"Monkey" ofType:@"svg"]];
            SVGKImage *image2 = [SVGKImage imageWithContentsOfFile:[self.pathsToSVGs pathForResource:@"Monkey" ofType:@"svg"]];
            
            // Yes, this is ARC, yes we do this to quiet a warning
			NSString *image1Desc = [image description];
			NSString *image2Desc = [image2 description];
			NSLog(@"image1: %@, image 2: %@", image1Desc, image2Desc);
        }
		XCTAssertTrue(YES);
    }
	@catch (NSException *exception) {
		XCTFail(@"Exception Thrown: %@", exception);
	}
}

- (void)testSettingImageMultipleTimes {
	@try {
		@autoreleasepool {
			
			SVGKFastImageView *imageView = [[SVGKFastImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
			imageView.image = nil;
			imageView.image = [[SVGKImage alloc] initWithContentsOfFile:[self.pathsToSVGs pathForResource:@"Note" ofType:@"svg"]];
			imageView.image = [[SVGKImage alloc] initWithContentsOfFile:[self.pathsToSVGs pathForResource:@"Note" ofType:@"svg"]];
			// Yes, this is ARC, yes we do this to quiet a warning
			XCTAssertNoThrow(imageView = nil);
		}
		XCTAssertTrue(YES);
	}
	@catch (NSException *exception) {
		XCTFail(@"Exception Thrown: %@", exception);
	}
}

@end
