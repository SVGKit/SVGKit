//
//  SVGPointsAndPathsParser.m
//  SVGPad
//
//  Created by adam on 18/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SVGPointsAndPathsParser.h"

// TODO: support quadratic-bezier-curveto
// TODO: support smooth-quadratic-bezier-curveto
// TODO: support elliptical-arc

/*! Very useful for debugging the parser - this will output one line of logging
 * for every CGPath command that's actually done; you can then compare these lines
 * to the input source file, and manually check what's being sent to the renderer
 * versus what was expected
 */
#define DEBUG_PATH_CREATION 0
void readWhitespace(NSScanner *scanner);

NSCharacterSet *cachedCharacterSetForString(NSString *characters);

static NSMutableDictionary *characterSetBuffer = nil;
NSCharacterSet *cachedCharacterSetForString(NSString *characters) //getting HUGE amounts of charactersets during parsing
{
    NSCharacterSet *returnSet = [characterSetBuffer objectForKey:characters];
    if( returnSet == nil )
    {
        if( characterSetBuffer == nil )
            characterSetBuffer = [NSMutableDictionary new];
        returnSet = (NSCharacterSet *)CFCharacterSetCreateWithCharactersInString(kCFAllocatorDefault, (CFStringRef)characters);
        [characterSetBuffer setObject:(NSCharacterSet *)returnSet forKey:characters];
        CFRelease(returnSet);
    }
    return returnSet;
}


inline SVGCurve SVGCurveMake(CGFloat cx1, CGFloat cy1, CGFloat cx2, CGFloat cy2, CGFloat px, CGFloat py)
{
    SVGCurve curve;
    curve.c1 = CGPointMake(cx1, cy1);
    curve.c2 = CGPointMake(cx2, cy2);
    curve.p = CGPointMake(px, py);
    return curve;
}
inline BOOL SVGCurveEqualToCurve(SVGCurve curve1, SVGCurve curve2)
{
    return (
            CGPointEqualToPoint(curve1.c1, curve2.c1)
            &&
            CGPointEqualToPoint(curve1.c2, curve2.c2)
            &&
            CGPointEqualToPoint(curve1.p, curve2.p)
            );
}

@implementation SVGPointsAndPathsParser


/* references
 http://www.w3.org/TR/2011/REC-SVG11-20110816/paths.html#PathDataBNF
 http://www.w3.org/TR/2011/REC-SVG11-20110816/shapes.html#PointsBNF
 
 */

/*
 http://www.w3.org/TR/2011/REC-SVG11-20110816/paths.html#PathDataBNF
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

/*
 http://www.w3.org/TR/2011/REC-SVG11-20110816/shapes.html#PointsBNF
 
 list-of-points:
 wsp* coordinate-pairs? wsp*
 coordinate-pairs:
 coordinate-pair
 | coordinate-pair comma-wsp coordinate-pairs
 coordinate-pair:
 coordinate comma-wsp coordinate
 | coordinate negative-coordinate
 coordinate:
 number
 number:
 sign? integer-constant
 | sign? floating-point-constant
 negative-coordinate:
 "-" integer-constant
 | "-" floating-point-constant
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
+ (void) readWhitespace:(NSScanner*)scanner
{
	
    NSCharacterSet* whitespace = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%c%c%c%c", 0x20, 0x9, 0xD, 0xA]];
    [scanner scanCharactersFromSet:whitespace
                        intoString:NULL];
}

static NSCharacterSet *whitespaceChars = nil;
void readWhitespace(NSScanner *scanner)
{
    if( whitespaceChars == nil )
        whitespaceChars = (NSCharacterSet *)CFCharacterSetCreateWithCharactersInString(kCFAllocatorDefault, (CFStringRef)[NSString stringWithFormat:@"%c%c%c%c", 0x20, 0x9, 0xD, 0xA]);
    [scanner scanCharactersFromSet:whitespaceChars intoString:NULL];
}

+ (void) readCommaAndWhitespace:(NSScanner*)scanner
{
    readWhitespace(scanner);
//    [SVGPointsAndPathsParser readWhitespace:scanner];
    static NSString* comma = @",";
    [scanner scanString:comma intoString:NULL];
    readWhitespace(scanner);
}

/**
 moveto-drawto-command-groups:
 moveto-drawto-command-group
 | moveto-drawto-command-group wsp* moveto-drawto-command-groups
 */
+ (CGPoint) readMovetoDrawtoCommandGroups:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CGPoint lastCoord = [SVGPointsAndPathsParser readMovetoDrawtoCommandGroup:scanner path:path relativeTo:origin isRelative:isRelative];
    return lastCoord;
}

/**
 moveto-drawto-command-group:
 moveto wsp* drawto-commands?
 */
+ (CGPoint) readMovetoDrawtoCommandGroup:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CGPoint lastCoord = [SVGPointsAndPathsParser readMovetoDrawto:scanner path:path relativeTo:origin isRelative:isRelative];
    readWhitespace(scanner);
    
    if (![scanner isAtEnd]) {
        readWhitespace(scanner);
        lastCoord = [SVGPointsAndPathsParser readMovetoDrawtoCommandGroup:scanner path:path relativeTo:origin isRelative:isRelative];
    }
    
    return lastCoord;
}

/** moveto-drawto-command-group:
 moveto wsp* drawto-commands?
 */
+ (CGPoint) readMovetoDrawto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CGPoint lastMove = [SVGPointsAndPathsParser readMoveto:scanner path:path relativeTo:origin isRelative:isRelative];
    readWhitespace(scanner);
    return lastMove;
}

/**
 moveto:
 ( "M" | "m" ) wsp* moveto-argument-sequence
 */
+ (CGPoint) readMoveto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = cachedCharacterSetForString(@"Mm");//[NSCharacterSet characterSetWithCharactersInString:@"Mm"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan move to command");
    if (!ok) return origin;
    
    readWhitespace(scanner);
    
    CGPoint lastCoordinate = [SVGPointsAndPathsParser readMovetoArgumentSequence:scanner path:path relativeTo:origin isRelative:isRelative];
    return lastCoordinate;
}

/** moveto-argument-sequence:
 coordinate-pair
 | coordinate-pair comma-wsp? lineto-argument-sequence
 */
+ (CGPoint) readMovetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CGPoint p = [SVGPointsAndPathsParser readCoordinatePair:scanner];
    CGPoint coord = CGPointMake(p.x+origin.x, p.y+origin.y);
    CGPathMoveToPoint(path, NULL, coord.x, coord.y);
#if DEBUG_PATH_CREATION
	NSLog(@"[%@] PATH: MOVED to %2.2f, %2.2f", [SVGPointsAndPathsParser class], coord.x, coord.y );
#endif
    
    [SVGPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    if (![scanner isAtEnd]) {
        coord = [SVGPointsAndPathsParser readLinetoArgumentSequence:scanner path:path relativeTo:(isRelative)?coord:origin isRelative:isRelative];
    }
    
    return coord;
}

/**
 coordinate-pair:
 coordinate comma-wsp? coordinate
 */

+ (CGPoint) readCoordinatePair:(NSScanner*)scanner
{
    CGFloat x = [SVGPointsAndPathsParser readCoordinate:scanner];
    [SVGPointsAndPathsParser readCommaAndWhitespace:scanner];
    CGFloat y = [SVGPointsAndPathsParser readCoordinate:scanner];
    
    CGPoint p = CGPointMake(x, y);
    return p;
}

+ (CGFloat) readCoordinate:(NSScanner*)scanner
{
    float f;
    BOOL ok;
    ok = [scanner scanFloat:&f];
    NSAssert(ok, @"invalid coord");
    return f;
}

/** 
 lineto:
 ( "L" | "l" ) wsp* lineto-argument-sequence
 */
+ (CGPoint) readLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = cachedCharacterSetForString(@"Ll");//[NSCharacterSet characterSetWithCharactersInString:@"Ll"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan line to command");
    if (!ok) return origin;
	
    readWhitespace(scanner);
    
    CGPoint lastCoordinate = [SVGPointsAndPathsParser readLinetoArgumentSequence:scanner path:path relativeTo:origin isRelative:isRelative];
    return lastCoordinate;
}

/** 
 lineto-argument-sequence:
 coordinate-pair
 | coordinate-pair comma-wsp? lineto-argument-sequence
 */
+ (CGPoint) readLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CGPoint coord = [SVGPointsAndPathsParser readCoordinatePair:scanner];
//    CGPoint coord = CGPointMake(p.x+origin.x, p.y+origin.y);
    coord.x += origin.x;
    coord.y += origin.y;
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
#if DEBUG_PATH_CREATION
	NSLog(@"[%@] PATH: LINE to %2.2f, %2.2f", [SVGPointsAndPathsParser class], coord.x, coord.y );
#endif
	
    readWhitespace(scanner);
    if ([scanner isAtEnd]) {
        return coord;
    }
    else {
        return [SVGPointsAndPathsParser readLinetoArgumentSequence:scanner path:path relativeTo:(isRelative)?coord:origin isRelative:isRelative]; //i think GCC will perform better if tail recursive :/
    }
    
//    return coord;
}

/**
 curveto:
 ( "C" | "c" ) wsp* curveto-argument-sequence
 */
+ (SVGCurve) readCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = cachedCharacterSetForString(@"Cc");//[NSCharacterSet characterSetWithCharactersInString:@"Cc"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan curve to command");
    if (!ok) return SVGCurveZero;
	
    readWhitespace(scanner);
    
    SVGCurve lastCurve = [SVGPointsAndPathsParser readCurvetoArgumentSequence:scanner path:path relativeTo:origin isRelative:isRelative];
    return lastCurve;
}

/**
 curveto-argument-sequence:
 curveto-argument
 | curveto-argument comma-wsp? curveto-argument-sequence
 */
+ (SVGCurve) readCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    SVGCurve curve = [SVGPointsAndPathsParser readCurvetoArgument:scanner path:path relativeTo:origin];
    
    if (![scanner isAtEnd]) {
        curve = [SVGPointsAndPathsParser readCurvetoArgumentSequence:scanner path:path relativeTo:(isRelative ? curve.p : origin) isRelative:isRelative];
    }
    
    return curve;
}
/**
 curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair comma-wsp? coordinate-pair
 */
+ (SVGCurve) readCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGPoint p1 = [SVGPointsAndPathsParser readCoordinatePair:scanner];
    CGPoint coord1 = CGPointMake(p1.x+origin.x, p1.y+origin.y);
    [SVGPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    CGPoint p2 = [SVGPointsAndPathsParser readCoordinatePair:scanner];
    CGPoint coord2 = CGPointMake(p2.x+origin.x, p2.y+origin.y);
    [SVGPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    CGPoint p3 = [SVGPointsAndPathsParser readCoordinatePair:scanner];
    CGPoint coord3 = CGPointMake(p3.x+origin.x, p3.y+origin.y);
    [SVGPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    CGPathAddCurveToPoint(path, NULL, coord1.x, coord1.y, coord2.x, coord2.y, coord3.x, coord3.y);
#if DEBUG_PATH_CREATION
	NSLog(@"[%@] PATH: CURVE to (%2.2f, %2.2f)..(%2.2f, %2.2f)..(%2.2f, %2.2f)", [SVGPointsAndPathsParser class], coord1.x, coord1.y, coord2.x, coord2.y, coord3.x, coord3.y );
#endif
    
    return SVGCurveMake(coord1.x, coord1.y, coord2.x, coord2.y, coord3.x, coord3.y);
}

/**
 smooth-curveto:
 ( "S" | "s" ) wsp* smooth-curveto-argument-sequence
 */
+ (SVGCurve) readSmoothCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = cachedCharacterSetForString(@"Ss");//[NSCharacterSet characterSetWithCharactersInString:@"Ss"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan smooth curve to command");
    if (!ok) return SVGCurveZero;
	
    readWhitespace(scanner);
    
    SVGCurve lastCurve = [SVGPointsAndPathsParser readSmoothCurvetoArgumentSequence:scanner path:path relativeTo:origin withPrevCurve:prevCurve];
    return lastCurve;
}

/**
 smooth-curveto-argument-sequence:
 smooth-curveto-argument
 | smooth-curveto-argument comma-wsp? smooth-curveto-argument-sequence
 */
+ (SVGCurve) readSmoothCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve
{
    SVGCurve curve = [SVGPointsAndPathsParser readSmoothCurvetoArgument:scanner path:path relativeTo:origin withPrevCurve:prevCurve];
    
    if (![scanner isAtEnd]) {
        curve = [SVGPointsAndPathsParser readSmoothCurvetoArgumentSequence:scanner path:path relativeTo:origin withPrevCurve:prevCurve];
    }
    
    return curve;
}

/**
 smooth-curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair
 */
+ (SVGCurve) readSmoothCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve
{
    CGPoint p1 = [SVGPointsAndPathsParser readCoordinatePair:scanner];
    CGPoint coord1 = CGPointMake(p1.x+origin.x, p1.y+origin.y);
    [SVGPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    CGPoint p2 = [SVGPointsAndPathsParser readCoordinatePair:scanner];
    CGPoint coord2 = CGPointMake(p2.x+origin.x, p2.y+origin.y);
    
    SVGCurve thisCurve;
    if (SVGCurveEqualToCurve(SVGCurveZero, prevCurve)) {
        // assume control point is coincident with the current point
        thisCurve = SVGCurveMake(coord1.x, coord1.y, coord2.x, coord2.y, coord1.x, coord1.y);
    } else {
        // calculate the mirror of the previous control point
        CGPoint currentPoint = prevCurve.p;
        CGPoint controlPoint = prevCurve.c2;
        CGPoint mirrorCoord = CGPointMake(currentPoint.x+(currentPoint.x-controlPoint.x), currentPoint.y+(currentPoint.y-controlPoint.y));
        thisCurve = SVGCurveMake(mirrorCoord.x, mirrorCoord.y, coord1.x, coord1.y, coord2.x, coord2.y);
    }
    
    CGPathAddCurveToPoint(path, NULL, thisCurve.c1.x, thisCurve.c1.y, thisCurve.c2.x, thisCurve.c2.y, thisCurve.p.x, thisCurve.p.y);
#if DEBUG_PATH_CREATION
	NSLog(@"[%@] PATH: SMOOTH CURVE to (%2.2f, %2.2f)..(%2.2f, %2.2f)..(%2.2f, %2.2f)", [SVGPointsAndPathsParser class], thisCurve.c1.x, thisCurve.c1.y, thisCurve.c2.x, thisCurve.c2.y, thisCurve.p.x, thisCurve.p.y );
#endif
	
    return thisCurve;
}

/**
 vertical-lineto-argument-sequence:
 coordinate
 | coordinate comma-wsp? vertical-lineto-argument-sequence
 */
+ (CGPoint) readVerticalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGFloat yValue = [SVGPointsAndPathsParser readCoordinate:scanner];
    CGPoint vertCoord = CGPointMake(origin.x, origin.y+yValue);
    CGPoint currentPoint = CGPathGetCurrentPoint(path);
    CGPoint coord = CGPointMake(currentPoint.x, currentPoint.y+(vertCoord.y-currentPoint.y));
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
#if DEBUG_PATH_CREATION
	NSLog(@"[%@] PATH: VERTICAL LINE to (%2.2f, %2.2f)", [SVGPointsAndPathsParser class], coord.x, coord.y );
#endif
    return coord;
}

/**
 vertical-lineto:
 ( "V" | "v" ) wsp* vertical-lineto-argument-sequence
 */
+ (CGPoint) readVerticalLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = cachedCharacterSetForString(@"Vv");//[NSCharacterSet characterSetWithCharactersInString:@"Vv"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan vertical line to command");
    if (!ok) return origin;
	
    readWhitespace(scanner);
    
    CGPoint lastCoordinate = [SVGPointsAndPathsParser readVerticalLinetoArgumentSequence:scanner path:path relativeTo:origin];
    return lastCoordinate;
}

/**
 horizontal-lineto-argument-sequence:
 coordinate
 | coordinate comma-wsp? horizontal-lineto-argument-sequence
 */
+ (CGPoint) readHorizontalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CGFloat xValue = [SVGPointsAndPathsParser readCoordinate:scanner];
    CGPoint horizCoord = CGPointMake(origin.x+xValue, origin.y);
    CGPoint currentPoint = CGPathGetCurrentPoint(path);
    CGPoint coord = CGPointMake(currentPoint.x+(horizCoord.x-currentPoint.x), currentPoint.y);
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
#if DEBUG_PATH_CREATION
	NSLog(@"[%@] PATH: HORIZONTAL LINE to (%2.2f, %2.2f)", [SVGPointsAndPathsParser class], coord.x, coord.y );
#endif
    return coord;
}

/**
 horizontal-lineto:
 ( "H" | "h" ) wsp* horizontal-lineto-argument-sequence
 */
+ (CGPoint) readHorizontalLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = cachedCharacterSetForString(@"Hh");//[NSCharacterSet characterSetWithCharactersInString:@"Hh"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan horizontal line to command");
    if (!ok) return origin;
	
    readWhitespace(scanner);
    
    CGPoint lastCoordinate = [SVGPointsAndPathsParser readHorizontalLinetoArgumentSequence:scanner path:path relativeTo:origin];
    return lastCoordinate;
}

+ (CGPoint) readCloseCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = cachedCharacterSetForString(@"Zz");//[NSCharacterSet characterSetWithCharactersInString:@"Zz"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan close command");
    if (!ok) return origin;
	
    CGPathCloseSubpath(path);
#if DEBUG_PATH_CREATION
	NSLog(@"[%@] PATH: finished path", [SVGPointsAndPathsParser class] );
#endif
    
    return origin;
}

+ (void)trim
{
    [characterSetBuffer release];
    characterSetBuffer = nil;
}

@end
