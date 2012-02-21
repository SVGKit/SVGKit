//
//  SVGPathElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGPathElement.h"

#import "SVGElement+Private.h"
#import "SVGShapeElement+Private.h"
#import "SVGUtils.h"
#import "SVGPointsAndPathsParser.h"

@interface SVGPathElement ()

- (void) parseData:(NSString *)data;
- (void) parseAttributes:(NSDictionary *)attributes;

@end

@implementation SVGPathElement

- (void)parseAttributes:(NSDictionary *)attributes
{
	[super parseAttributes:attributes];
	
	id value = nil;
	
	if ((value = [attributes objectForKey:@"d"])) {
		[self parseData:value];
	}
}

- (void)parseData:(NSString *)data
{
	CGMutablePathRef path = CGPathCreateMutable();
    NSScanner* dataScanner = [NSScanner scannerWithString:data];
    CGPoint lastCoordinate = CGPointZero;
    SVGCurve lastCurve = SVGCurveZero;
    BOOL foundCmd;
    
    do {
        NSCharacterSet* knownCommands = [NSCharacterSet characterSetWithCharactersInString:@"MmLlCcVvHhAaSsQqTtZz"];
        NSString* command = nil;
        foundCmd = [dataScanner scanCharactersFromSet:knownCommands intoString:&command];
        
        if (foundCmd) {
            if ([@"z" isEqualToString:command] || [@"Z" isEqualToString:command]) {
                lastCoordinate = [SVGPointsAndPathsParser readCloseCommand:[NSScanner scannerWithString:command]
                                                   path:path
                                             relativeTo:lastCoordinate];
            } else {
                NSString* cmdArgs = nil;
                BOOL foundParameters = [dataScanner scanUpToCharactersFromSet:knownCommands
                                                                   intoString:&cmdArgs];
                
                if (foundParameters) {
                    NSString* commandWithParameters = [command stringByAppendingString:cmdArgs];
                    NSScanner* commandScanner = [NSScanner scannerWithString:commandWithParameters];
                    
                    if ([@"m" isEqualToString:command]) {
                        lastCoordinate = [SVGPointsAndPathsParser readMovetoDrawtoCommandGroups:commandScanner
                                                                        path:path
                                                                  relativeTo:lastCoordinate
										  isRelative:TRUE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"M" isEqualToString:command]) {
                        lastCoordinate = [SVGPointsAndPathsParser readMovetoDrawtoCommandGroups:commandScanner
                                                                        path:path
                                                                  relativeTo:CGPointZero
										  isRelative:FALSE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"l" isEqualToString:command]) {
                        lastCoordinate = [SVGPointsAndPathsParser readLinetoCommand:commandScanner
                                                            path:path
                                                      relativeTo:lastCoordinate
										  isRelative:TRUE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"L" isEqualToString:command]) {
                        lastCoordinate = [SVGPointsAndPathsParser readLinetoCommand:commandScanner
                                                            path:path
                                                      relativeTo:CGPointZero
										  isRelative:FALSE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"v" isEqualToString:command]) {
                        lastCoordinate = [SVGPointsAndPathsParser readVerticalLinetoCommand:commandScanner
                                                                    path:path
                                                              relativeTo:lastCoordinate];
                        lastCurve = SVGCurveZero;
                    } else if ([@"V" isEqualToString:command]) {
                        lastCoordinate = [SVGPointsAndPathsParser readVerticalLinetoCommand:commandScanner
                                                                    path:path
                                                      relativeTo:CGPointZero];
                        lastCurve = SVGCurveZero;
                    } else if ([@"h" isEqualToString:command]) {
                        lastCoordinate = [SVGPointsAndPathsParser readHorizontalLinetoCommand:commandScanner
                                                                      path:path
                                                                relativeTo:lastCoordinate];
                        lastCurve = SVGCurveZero;
                    } else if ([@"H" isEqualToString:command]) {
                        lastCoordinate = [SVGPointsAndPathsParser readHorizontalLinetoCommand:commandScanner
                                                                      path:path
                                                                relativeTo:CGPointZero];
                        lastCurve = SVGCurveZero;
                    } else if ([@"c" isEqualToString:command]) {
                        lastCurve = [SVGPointsAndPathsParser readCurvetoCommand:commandScanner
                                                        path:path
                                                  relativeTo:lastCoordinate
												  isRelative:TRUE];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"C" isEqualToString:command]) {
                        lastCurve = [SVGPointsAndPathsParser readCurvetoCommand:commandScanner
                                                        path:path
                                                  relativeTo:CGPointZero
									 isRelative:FALSE];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"s" isEqualToString:command]) {
                        lastCurve = [SVGPointsAndPathsParser readSmoothCurvetoCommand:commandScanner
                                                              path:path
                                                        relativeTo:lastCoordinate
                                                     withPrevCurve:lastCurve];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"S" isEqualToString:command]) {
                        lastCurve = [SVGPointsAndPathsParser readSmoothCurvetoCommand:commandScanner
                                                              path:path
                                                        relativeTo:CGPointZero
                                                     withPrevCurve:lastCurve];
                        lastCoordinate = lastCurve.p;
                    } else {
                        NSLog(@"unsupported command %@", command);
                    }
                }
            }
        }
        
    } while (foundCmd);
	
    
	[self loadPath:path];
	CGPathRelease(path);
}

@end
