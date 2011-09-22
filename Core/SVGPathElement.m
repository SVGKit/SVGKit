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

typedef enum {
	SVGPathSegmentTypeMoveTo = 0,
	SVGPathSegmentTypeLineTo,
	SVGPathSegmentTypeVerticalLineTo,
    SVGPathSegmentTypeHorizontalLineTo,
	SVGPathSegmentTypeCurve
} SVGPathSegmentType;


@interface SVGPathElement ()

- (void) parseData:(NSString *)data;
- (void) parseAttributes:(NSDictionary *)attributes;

- (void) readWhitespace:(NSScanner*)scanner;
- (void) readCommaAndWhitespace:(NSScanner*)scanner;

- (CGFloat) readCoordinate:(NSScanner*)scanner;
- (CGPoint) readCoordinatePair:(NSScanner*)scanner;

- (CGPoint) readMovetoDrawtoCommandGroups:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readMovetoDrawtoCommandGroup:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readMovetoDrawto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readMoveto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readMovetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readVerticalLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readVerticalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readDrawtoCommand:(SVGPathSegmentType)segmentType scanner:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
- (CGPoint) readCloseCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;

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
    BOOL foundCmd;
    
    do {
        NSCharacterSet* knownCommands = [NSCharacterSet characterSetWithCharactersInString:@"MmLlCcVvHhZz"];
        NSString* command = nil;
        foundCmd = [dataScanner scanCharactersFromSet:knownCommands intoString:&command];
        
        if (foundCmd) {
            
            if ([@"z" isEqualToString:command] || [@"Z" isEqualToString:command]) {
                lastCoordinate = [self readCloseCommand:[NSScanner scannerWithString:command]
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
                        lastCoordinate = [self readMovetoDrawtoCommandGroups:commandScanner
                                                                        path:path
                                                                  relativeTo:lastCoordinate];
                    } else if ([@"M" isEqualToString:command]) {
                        lastCoordinate = [self readMovetoDrawtoCommandGroups:commandScanner
                                                                        path:path
                                                                  relativeTo:CGPointZero];
                    } else if ([@"l" isEqualToString:command]) {
                        lastCoordinate = [self readDrawtoCommand:SVGPathSegmentTypeLineTo
                                                         scanner:commandScanner
                                                            path:path
                                                      relativeTo:lastCoordinate];
                    } else if ([@"L" isEqualToString:command]) {
                        lastCoordinate = [self readDrawtoCommand:SVGPathSegmentTypeLineTo
                                                         scanner:commandScanner
                                                            path:path
                                                      relativeTo:CGPointZero];
                    } else if ([@"v" isEqualToString:command]) {
                        lastCoordinate = [self readDrawtoCommand:SVGPathSegmentTypeVerticalLineTo
                                                         scanner:commandScanner
                                                            path:path
                                                      relativeTo:lastCoordinate];
                    } else if ([@"V" isEqualToString:command]) {
                        lastCoordinate = [self readDrawtoCommand:SVGPathSegmentTypeVerticalLineTo
                                                         scanner:commandScanner
                                                            path:path
                                                      relativeTo:CGPointZero];
                    } else if ([@"h" isEqualToString:command]) {
                        lastCoordinate = [self readDrawtoCommand:SVGPathSegmentTypeHorizontalLineTo
                                                         scanner:commandScanner
                                                            path:path
                                                      relativeTo:lastCoordinate];
                    } else if ([@"H" isEqualToString:command]) {
                        lastCoordinate = [self readDrawtoCommand:SVGPathSegmentTypeHorizontalLineTo
                                                         scanner:commandScanner
                                                            path:path
                                                      relativeTo:CGPointZero];
                    } else if ([@"c" isEqualToString:command]) {
                        lastCoordinate = [self readDrawtoCommand:SVGPathSegmentTypeCurve
                                                         scanner:commandScanner
                                                            path:path
                                                      relativeTo:lastCoordinate];
                    } else if ([@"C" isEqualToString:command]) {
                        lastCoordinate = [self readDrawtoCommand:SVGPathSegmentTypeCurve
                                                         scanner:commandScanner
                                                            path:path
                                                      relativeTo:CGPointZero];
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

/* reference
 http://www.w3.org/TR/2011/REC-SVG11-20110816/paths.html#PathDataBNF
 */

/*
svg-path:
    wsp* moveto-drawto-command-groups? wsp*
moveto-drawto-command-groups:
    moveto-drawto-command-group
    | moveto-drawto-command-group wsp* moveto-drawto-command-groups
moveto-drawto-command-group:
    moveto wsp* drawto-commands?
drawto-commands:
    drawto-command
    | drawto-command wsp* drawto-commands
drawto-command:
    closepath
    | lineto
    | horizontal-lineto
    | vertical-lineto
    | curveto
    | smooth-curveto
    | quadratic-bezier-curveto
    | smooth-quadratic-bezier-curveto
    | elliptical-arc
moveto:
    ( "M" | "m" ) wsp* moveto-argument-sequence
moveto-argument-sequence:
    coordinate-pair
    | coordinate-pair comma-wsp? lineto-argument-sequence
closepath:
    ("Z" | "z")
lineto:
    ( "L" | "l" ) wsp* lineto-argument-sequence
lineto-argument-sequence:
    coordinate-pair
    | coordinate-pair comma-wsp? lineto-argument-sequence
horizontal-lineto:
    ( "H" | "h" ) wsp* horizontal-lineto-argument-sequence
horizontal-lineto-argument-sequence:
    coordinate
    | coordinate comma-wsp? horizontal-lineto-argument-sequence
vertical-lineto:
    ( "V" | "v" ) wsp* vertical-lineto-argument-sequence
vertical-lineto-argument-sequence:
    coordinate
    | coordinate comma-wsp? vertical-lineto-argument-sequence
curveto:
    ( "C" | "c" ) wsp* curveto-argument-sequence
curveto-argument-sequence:
    curveto-argument
    | curveto-argument comma-wsp? curveto-argument-sequence
curveto-argument:
    coordinate-pair comma-wsp? coordinate-pair comma-wsp? coordinate-pair
smooth-curveto:
    ( "S" | "s" ) wsp* smooth-curveto-argument-sequence
smooth-curveto-argument-sequence:
    smooth-curveto-argument
    | smooth-curveto-argument comma-wsp? smooth-curveto-argument-sequence
smooth-curveto-argument:
    coordinate-pair comma-wsp? coordinate-pair
quadratic-bezier-curveto:
    ( "Q" | "q" ) wsp* quadratic-bezier-curveto-argument-sequence
quadratic-bezier-curveto-argument-sequence:
    quadratic-bezier-curveto-argument
    | quadratic-bezier-curveto-argument comma-wsp? 
        quadratic-bezier-curveto-argument-sequence
quadratic-bezier-curveto-argument:
    coordinate-pair comma-wsp? coordinate-pair
smooth-quadratic-bezier-curveto:
    ( "T" | "t" ) wsp* smooth-quadratic-bezier-curveto-argument-sequence
smooth-quadratic-bezier-curveto-argument-sequence:
    coordinate-pair
    | coordinate-pair comma-wsp? smooth-quadratic-bezier-curveto-argument-sequence
elliptical-arc:
    ( "A" | "a" ) wsp* elliptical-arc-argument-sequence
elliptical-arc-argument-sequence:
    elliptical-arc-argument
    | elliptical-arc-argument comma-wsp? elliptical-arc-argument-sequence
elliptical-arc-argument:
    nonnegative-number comma-wsp? nonnegative-number comma-wsp? 
        number comma-wsp flag comma-wsp? flag comma-wsp? coordinate-pair
coordinate-pair:
    coordinate comma-wsp? coordinate
coordinate:
    number
nonnegative-number:
    integer-constant
    | floating-point-constant
number:
    sign? integer-constant
    | sign? floating-point-constant
flag:
    "0" | "1"
comma-wsp:
    (wsp+ comma? wsp*) | (comma wsp*)
comma:
    ","
integer-constant:
    digit-sequence
floating-point-constant:
    fractional-constant exponent?
    | digit-sequence exponent
fractional-constant:
    digit-sequence? "." digit-sequence
    | digit-sequence "."
exponent:
    ( "e" | "E" ) sign? digit-sequence
sign:
    "+" | "-"
digit-sequence:
    digit
    | digit digit-sequence
digit:
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
*/

/**
 wsp:
    (#x20 | #x9 | #xD | #xA)
*/
- (void) readWhitespace:(NSScanner*)scanner
{

    NSCharacterSet* whitespace = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%c%c%c%c", 0x20, 0x9, 0xD, 0xA]];
    [scanner scanCharactersFromSet:whitespace
                        intoString:NULL];
}

- (void) readCommaAndWhitespace:(NSScanner*)scanner
{
    [self readWhitespace:scanner];
    static NSString* comma = @",";
    [scanner scanString:comma intoString:NULL];
    [self readWhitespace:scanner];
}

/**
 moveto-drawto-command-groups:
    moveto-drawto-command-group
    | moveto-drawto-command-group wsp* moveto-drawto-command-groups
*/
- (CGPoint) readMovetoDrawtoCommandGroups:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGPoint lastCoord = [self readMovetoDrawtoCommandGroup:scanner path:path relativeTo:origin];
    return lastCoord;
}

/**
 moveto-drawto-command-group:
  moveto wsp* drawto-commands?
 */
- (CGPoint) readMovetoDrawtoCommandGroup:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGPoint lastCoord = [self readMovetoDrawto:scanner path:path relativeTo:origin];
    [self readWhitespace:scanner];
    
    if (![scanner isAtEnd]) {
        [self readWhitespace:scanner];
        lastCoord = [self readMovetoDrawtoCommandGroup:scanner path:path relativeTo:origin];
    }
    
    return lastCoord;
}

/** moveto-drawto-command-group:
  moveto wsp* drawto-commands?
 */
- (CGPoint) readMovetoDrawto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGPoint lastMove = [self readMoveto:scanner path:path relativeTo:origin];
    [self readWhitespace:scanner];
    return lastMove;
}

/**
 moveto:
 ( "M" | "m" ) wsp* moveto-argument-sequence
 */
- (CGPoint) readMoveto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Mm"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan move to command");
    
    [self readWhitespace:scanner];
    
    CGPoint lastCoordinate = origin;
    BOOL relativeCoordinates = [@"m" isEqualToString:cmd];
    if (relativeCoordinates) {
        lastCoordinate = [self readMovetoArgumentSequence:scanner path:path relativeTo:lastCoordinate];
    } else {
        lastCoordinate = [self readMovetoArgumentSequence:scanner path:path relativeTo:CGPointZero];
    }
    
    return lastCoordinate;
}

/** moveto-argument-sequence:
 coordinate-pair
 | coordinate-pair comma-wsp? lineto-argument-sequence
*/
- (CGPoint) readMovetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGPoint p = [self readCoordinatePair:scanner];
    CGPoint coord = CGPointMake(p.x+origin.x, p.y+origin.y);
    CGPathMoveToPoint(path, NULL, coord.x, coord.y);
    
    [self readCommaAndWhitespace:scanner];
    
    if (![scanner isAtEnd]) {
        coord = [self readLinetoArgumentSequence:scanner path:path relativeTo:coord];
    }
    
    return coord;
}

/**
 coordinate-pair:
    coordinate comma-wsp? coordinate
*/

- (CGPoint) readCoordinatePair:(NSScanner*)scanner
{
    CGFloat x = [self readCoordinate:scanner];
    [self readCommaAndWhitespace:scanner];
    CGFloat y = [self readCoordinate:scanner];
    
    CGPoint p = CGPointMake(x, y);
    return p;
}

- (CGFloat) readCoordinate:(NSScanner*)scanner
{
    CGFloat f;
    BOOL ok;
    ok = [scanner scanFloat:&f];
    NSAssert(ok, @"invalid coord");
    return f;
}

/** 
 lineto:
    ( "L" | "l" ) wsp* lineto-argument-sequence
*/
- (CGPoint) readLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Ll"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan line to command");
    
    [self readWhitespace:scanner];
    
    CGPoint lastCoordinate = origin;
    BOOL relativeCoordinates = [@"l" isEqualToString:cmd];
    if (relativeCoordinates) {
        lastCoordinate = [self readLinetoArgumentSequence:scanner path:path relativeTo:lastCoordinate];
    } else {
        lastCoordinate = [self readLinetoArgumentSequence:scanner path:path relativeTo:CGPointZero];
    }
    
    return lastCoordinate;
}

/** 
 lineto-argument-sequence:
 coordinate-pair
 | coordinate-pair comma-wsp? lineto-argument-sequence
 */
- (CGPoint) readLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGPoint p = [self readCoordinatePair:scanner];
    CGPoint coord = CGPointMake(p.x+origin.x, p.y+origin.y);
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
    
    [self readWhitespace:scanner];
    if (![scanner isAtEnd]) {
        coord = [self readLinetoArgumentSequence:scanner path:path relativeTo:coord];
    }
    
    return coord;
}

/**
 curveto:
 ( "C" | "c" ) wsp* curveto-argument-sequence
 */
- (CGPoint) readCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Cc"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan curve to command");
    
    [self readWhitespace:scanner];
    
    CGPoint lastCoordinate = origin;
    BOOL relativeCoordinates = [@"c" isEqualToString:cmd];
    if (relativeCoordinates) {
        lastCoordinate = [self readCurvetoArgumentSequence:scanner path:path relativeTo:lastCoordinate];
    } else {
        lastCoordinate = [self readCurvetoArgumentSequence:scanner path:path relativeTo:CGPointZero];
    }
    
    return lastCoordinate;
}

/**
 curveto-argument-sequence:
    curveto-argument
    | curveto-argument comma-wsp? curveto-argument-sequence
 */
- (CGPoint) readCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGPoint coord = [self readCurvetoArgument:scanner path:path relativeTo:origin];
    
    if (![scanner isAtEnd]) {
        coord = [self readCurvetoArgumentSequence:scanner path:path relativeTo:coord];
    }
    
    return coord;
}
/**
 curveto-argument:
    coordinate-pair comma-wsp? coordinate-pair comma-wsp? coordinate-pair
 */

- (CGPoint) readCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGPoint p1 = [self readCoordinatePair:scanner];
    CGPoint coord1 = CGPointMake(p1.x+origin.x, p1.y+origin.y);
    [self readCommaAndWhitespace:scanner];
    
    CGPoint p2 = [self readCoordinatePair:scanner];
    CGPoint coord2 = CGPointMake(p2.x+origin.x, p2.y+origin.y);
    [self readCommaAndWhitespace:scanner];
    
    CGPoint p3 = [self readCoordinatePair:scanner];
    CGPoint coord3 = CGPointMake(p3.x+origin.x, p3.y+origin.y);
    [self readCommaAndWhitespace:scanner];
    
    CGPathAddCurveToPoint(path, NULL, coord1.x, coord1.y, coord2.x, coord2.y, coord3.x, coord3.y);
    
    return coord3;
}

/**
 vertical-lineto-argument-sequence:
    coordinate
    | coordinate comma-wsp? vertical-lineto-argument-sequence
*/
- (CGPoint) readVerticalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGFloat yValue = [self readCoordinate:scanner];
    CGPoint coord = CGPointMake(origin.x, origin.y+yValue);
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
    return coord;
}

/**
 vertical-lineto:
 ( "V" | "v" ) wsp* vertical-lineto-argument-sequence
*/
- (CGPoint) readVerticalLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Vv"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan vertical line to command");
    
    [self readWhitespace:scanner];
    
    CGPoint lastCoordinate = origin;
    BOOL relativeCoordinates = [@"v" isEqualToString:cmd];
    if (relativeCoordinates) {
        lastCoordinate = [self readVerticalLinetoArgumentSequence:scanner path:path relativeTo:lastCoordinate];
    } else {
        lastCoordinate = [self readVerticalLinetoArgumentSequence:scanner path:path relativeTo:CGPointZero];
    }
    
    return lastCoordinate;
}

/**
 horizontal-lineto-argument-sequence:
    coordinate
    | coordinate comma-wsp? horizontal-lineto-argument-sequence
 */
- (CGPoint) readHorizontalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGFloat xValue = [self readCoordinate:scanner];
    CGPoint coord = CGPointMake(origin.x+xValue, origin.y);
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
    return coord;
}

/**
 horizontal-lineto:
    ( "H" | "h" ) wsp* horizontal-lineto-argument-sequence
 */
- (CGPoint) readHorizontalLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Hh"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan horizontal line to command");
    
    [self readWhitespace:scanner];
    
    CGPoint lastCoordinate = origin;
    BOOL relativeCoordinates = [@"h" isEqualToString:cmd];
    if (relativeCoordinates) {
        lastCoordinate = [self readHorizontalLinetoArgumentSequence:scanner path:path relativeTo:lastCoordinate];
    } else {
        lastCoordinate = [self readHorizontalLinetoArgumentSequence:scanner path:path relativeTo:CGPointZero];
    }
    
    return lastCoordinate;
}

/**
 drawto-command:
 closepath
 | lineto
 | horizontal-lineto
 | vertical-lineto
 | curveto
 | smooth-curveto
 | quadratic-bezier-curveto
 | smooth-quadratic-bezier-curveto
 | elliptical-arc
 */
- (CGPoint) readDrawtoCommand:(SVGPathSegmentType)segmentType scanner:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
#warning TODO: support smooth-curveto
#warning TODO: support smooth-quadratic-bezier-curveto
#warning TODO: support elliptical-arc
    
    switch (segmentType) {
        case SVGPathSegmentTypeLineTo:
            return [self readLinetoCommand:scanner path:path relativeTo:origin];
            
        case SVGPathSegmentTypeCurve:
            return [self readCurvetoCommand:scanner path:path relativeTo:origin];
        
        case SVGPathSegmentTypeVerticalLineTo:
            return [self readVerticalLinetoCommand:scanner path:path relativeTo:origin];
        
        case SVGPathSegmentTypeHorizontalLineTo:
            return [self readHorizontalLinetoCommand:scanner path:path relativeTo:origin];
            
        default:
            return origin;
    }
}

- (CGPoint) readCloseCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Zz"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan close command");

    CGPathCloseSubpath(path);
    
    return origin;
}

@end
