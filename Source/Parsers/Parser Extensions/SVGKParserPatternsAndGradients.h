//
//  SVGKParserPatternsAndGradients.h
//  SVGKit
//
//  Created by adam applecansuckmybigtodger on 28/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#import <SVGKit/SVGKParser.h>

@interface SVGKParserPatternsAndGradients : NSObject <SVGKParserExtension>

@end
