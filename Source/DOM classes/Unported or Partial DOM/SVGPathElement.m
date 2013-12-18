//
//  SVGPathElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGPathElement.h"

#import "SVGUtils.h"
#import "SVGKPointsAndPathsParser.h"

#import "SVGElement_ForParser.h" // to resolve Xcode circular dependencies; in long term, parsing SHOULD NOT HAPPEN inside any class whose name starts "SVG" (because those are reserved classes for the SVG Spec)

@interface SVGPathElement ()

- (void) parseData:(NSString *)data;

@end

@implementation SVGPathElement

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult
{
	[super postProcessAttributesAddingErrorsTo:parseResult];
	
	[self parseData:[self getAttribute:@"d"]];
}

- (void)parseData:(NSString *)data
{
	CGMutablePathRef path = CGPathCreateMutable();
    NSScanner* dataScanner = [NSScanner scannerWithString:data];
    CGPoint lastCoordinate = CGPointZero;
    SVGCurve lastCurve = SVGCurveZero;
    BOOL foundCmd;
    
    NSCharacterSet *knownCommands = [NSCharacterSet characterSetWithCharactersInString:@"MmLlCcVvHhAaSsQqTtZz"];
    NSString* command;
    
    do {
        
        command = nil;
        foundCmd = [dataScanner scanCharactersFromSet:knownCommands intoString:&command];
        
        if (command.length > 1) {
            // Take only one char (it can happen that multiple commands are consecutive, as "ZM" - so we only want to get the "Z")
            const NSInteger tooManyChars = command.length-1;
            command = [command substringToIndex:1];
            [dataScanner setScanLocation:([dataScanner scanLocation] - tooManyChars)];
        }
        
        if (foundCmd) {
            if ([@"z" isEqualToString:command] || [@"Z" isEqualToString:command]) {
                lastCoordinate = [SVGKPointsAndPathsParser readCloseCommand:[NSScanner scannerWithString:command]
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
                        lastCoordinate = [SVGKPointsAndPathsParser readMovetoDrawtoCommandGroups:commandScanner
                                                                        path:path
                                                                  relativeTo:lastCoordinate
										  isRelative:TRUE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"M" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readMovetoDrawtoCommandGroups:commandScanner
                                                                        path:path
                                                                  relativeTo:CGPointZero
										  isRelative:FALSE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"l" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readLinetoCommand:commandScanner
                                                            path:path
                                                      relativeTo:lastCoordinate
										  isRelative:TRUE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"L" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readLinetoCommand:commandScanner
                                                            path:path
                                                      relativeTo:CGPointZero
										  isRelative:FALSE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"v" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readVerticalLinetoCommand:commandScanner
                                                                    path:path
                                                              relativeTo:lastCoordinate];
                        lastCurve = SVGCurveZero;
                    } else if ([@"V" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readVerticalLinetoCommand:commandScanner
                                                                    path:path
                                                      relativeTo:CGPointZero];
                        lastCurve = SVGCurveZero;
                    } else if ([@"h" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readHorizontalLinetoCommand:commandScanner
                                                                      path:path
                                                                relativeTo:lastCoordinate];
                        lastCurve = SVGCurveZero;
                    } else if ([@"H" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readHorizontalLinetoCommand:commandScanner
                                                                      path:path
                                                                relativeTo:CGPointZero];
                        lastCurve = SVGCurveZero;
                    } else if ([@"c" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readCurvetoCommand:commandScanner
                                                        path:path
                                                  relativeTo:lastCoordinate
												  isRelative:TRUE];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"C" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readCurvetoCommand:commandScanner
                                                        path:path
                                                  relativeTo:CGPointZero
									 isRelative:FALSE];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"s" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readSmoothCurvetoCommand:commandScanner
                                                              path:path
                                                        relativeTo:lastCoordinate
                                                     withPrevCurve:lastCurve];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"S" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readSmoothCurvetoCommand:commandScanner
                                                              path:path
                                                        relativeTo:CGPointZero
                                                     withPrevCurve:lastCurve];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"q" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readQuadraticCurvetoCommand:commandScanner
                                                                            path:path
                                                                      relativeTo:lastCoordinate
                                                                      isRelative:TRUE];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"Q" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readQuadraticCurvetoCommand:commandScanner
                                                                            path:path
                                                                      relativeTo:CGPointZero
                                                                      isRelative:FALSE];
                        lastCoordinate = lastCurve.p;
					} else if ([@"t" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readSmoothQuadraticCurvetoCommand:commandScanner
																				  path:path
																			relativeTo:lastCoordinate
																		 withPrevCurve:lastCurve];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"T" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readSmoothQuadraticCurvetoCommand:commandScanner
																				  path:path
																			relativeTo:CGPointZero
																		 withPrevCurve:lastCurve];
                        lastCoordinate = lastCurve.p;
                    } else {
                        DDLogWarn(@"unsupported command %@", command);
                    }
                }
            }
        }
        
    } while (foundCmd);
	
    
	self.pathForShapeInRelativeCoords = path;
	CGPathRelease(path);
}

@end
