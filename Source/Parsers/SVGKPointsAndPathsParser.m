#import "SVGKPointsAndPathsParser.h"


#import "NSCharacterSet+SVGKExtensions.h"

// TODO: support quadratic-bezier-curveto
// TODO: support smooth-quadratic-bezier-curveto
// TODO: support elliptical-arc

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

@implementation SVGKPointsAndPathsParser


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
	/** This log message can be called literally hundreds of thousands of times in a single parse, which defeats
	 even Cocoa Lumberjack.
	 
	 Even in "verbose" debugging, that's too much!
	 
	 Hence: commented-out
	SVGKitLogVerbose(@"Apple's implementation of scanCharactersFromSet seems to generate large amounts of temporary objects and can cause a crash here by taking literally megabytes of RAM in temporary internal variables. This is surprising, but I can't see anythign we're doing wrong. Adding this autoreleasepool drops memory usage (inside Apple's methods!) massively, so it seems to be the right thing to do");
	 */
	@autoreleasepool
	{
		[scanner scanCharactersFromSet:[NSCharacterSet SVGWhitespaceCharacterSet]
                        intoString:NULL];
	}
}

+ (void) readCommaAndWhitespace:(NSScanner*)scanner
{
    [SVGKPointsAndPathsParser readWhitespace:scanner];
    static NSString* comma = @",";
    [scanner scanString:comma intoString:NULL];
    [SVGKPointsAndPathsParser readWhitespace:scanner];
}

/**
 moveto-drawto-command-groups:
 moveto-drawto-command-group
 | moveto-drawto-command-group wsp* moveto-drawto-command-groups
 */
+ (CGPoint) readMovetoDrawtoCommandGroups:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
#if VERBOSE_PARSE_SVG_COMMAND_STRINGS
	SVGKitLogVerbose(@"Parsing command string: move-to, draw-to command");
#endif
    CGPoint lastCoord = [SVGKPointsAndPathsParser readMovetoDrawto:scanner path:path relativeTo:origin isRelative:isRelative];
    [SVGKPointsAndPathsParser readWhitespace:scanner];
    
    while (![scanner isAtEnd])
	{
        [SVGKPointsAndPathsParser readWhitespace:scanner];
		/** FIXME: wasn't originally, but maybe should be:
		 
		 origin = isRelative ? lastCoord : origin;
		 */
        lastCoord = [SVGKPointsAndPathsParser readMovetoDrawto:scanner path:path relativeTo:origin isRelative:isRelative];
    }
	
	return lastCoord;
}

/** moveto-drawto-command-group:
 moveto wsp* drawto-commands?
 */
+ (CGPoint) readMovetoDrawto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CGPoint lastMove = [SVGKPointsAndPathsParser readMoveto:scanner path:path relativeTo:origin isRelative:isRelative];
    [SVGKPointsAndPathsParser readWhitespace:scanner];
    return lastMove;
}

/**
 moveto:
 ( "M" | "m" ) wsp* moveto-argument-sequence
 */
+ (CGPoint) readMoveto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Mm"];
    if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
	{
		NSAssert(FALSE, @"failed to scan move to command");
		return origin;
	}
    
    [SVGKPointsAndPathsParser readWhitespace:scanner];
    
    CGPoint lastCoordinate = [SVGKPointsAndPathsParser readMovetoArgumentSequence:scanner path:path relativeTo:origin isRelative:isRelative];
    return lastCoordinate;
}

/** moveto-argument-sequence:
 coordinate-pair
 | coordinate-pair comma-wsp? lineto-argument-sequence
 */
+ (CGPoint) readMovetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CGPoint coord = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
    coord.x += origin.x;
	coord.y += origin.y;
	
    CGPathMoveToPoint(path, NULL, coord.x, coord.y);
#if DEBUG_PATH_CREATION
	SVGKitLogWarn(@"[%@] PATH: MOVED to %2.2f, %2.2f", [SVGKPointsAndPathsParser class], coord.x, coord.y );
#endif
    
    [SVGKPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    if (![scanner isAtEnd]) {
        coord = [SVGKPointsAndPathsParser readLinetoArgumentSequence:scanner path:path relativeTo:(isRelative)?coord:origin isRelative:isRelative];
    }
    
    return coord;
}

/**
 coordinate-pair:
 coordinate comma-wsp? coordinate
 */

+ (CGPoint) readCoordinatePair:(NSScanner*)scanner
{
	CGPoint p;
	[SVGKPointsAndPathsParser readCoordinate:scanner intoFloat:&p.x];
    [SVGKPointsAndPathsParser readCommaAndWhitespace:scanner];
    [SVGKPointsAndPathsParser readCoordinate:scanner intoFloat:&p.y];
    
    return p;
}

+ (void) readCoordinate:(NSScanner*)scanner intoFloat:(CGFloat*) floatPointer
{
#if CGFLOAT_IS_DOUBLE
	if( ! [scanner scanDouble:floatPointer] )
		NSAssert(FALSE, @"invalid coord");
#else
	if( ! [scanner scanFloat:floatPointer] )
		NSAssert(FALSE, @"invalid coord");
#endif
}

/** 
 lineto:
 ( "L" | "l" ) wsp* lineto-argument-sequence
 */
+ (CGPoint) readLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
#if VERBOSE_PARSE_SVG_COMMAND_STRINGS
	SVGKitLogVerbose(@"Parsing command string: line-to command");
#endif
	
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Ll"];
    
	if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
	{
		NSAssert( FALSE, @"failed to scan line to command");
		return origin;
	}
	
    [SVGKPointsAndPathsParser readWhitespace:scanner];
    
    CGPoint lastCoordinate = [SVGKPointsAndPathsParser readLinetoArgumentSequence:scanner path:path relativeTo:origin isRelative:isRelative];
    return lastCoordinate;
}

/** 
 lineto-argument-sequence:
 coordinate-pair
 | coordinate-pair comma-wsp? lineto-argument-sequence
 */
+ (CGPoint) readLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CGPoint p = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
    CGPoint coord = CGPointMake(p.x+origin.x, p.y+origin.y);
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
#if DEBUG_PATH_CREATION
	SVGKitLogWarn(@"[%@] PATH: LINE to %2.2f, %2.2f", [SVGKPointsAndPathsParser class], coord.x, coord.y );
#endif
	
    [SVGKPointsAndPathsParser readCommaAndWhitespace:scanner];
	
	while( ![scanner isAtEnd])
	{
		origin = (isRelative)?coord:origin;
		p = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
		coord = CGPointMake(p.x+origin.x, p.y+origin.y);
		CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
#if DEBUG_PATH_CREATION
		SVGKitLogWarn(@"[%@] PATH: LINE to %2.2f, %2.2f", [SVGKPointsAndPathsParser class], coord.x, coord.y );
#endif
		
		[SVGKPointsAndPathsParser readCommaAndWhitespace:scanner];
	}
    
    return coord;
}

/**
 quadratic-bezier-curveto:
 ( "Q" | "q" ) wsp* quadratic-bezier-curveto-argument-sequence
 */
+ (SVGCurve) readQuadraticCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
#if VERBOSE_PARSE_SVG_COMMAND_STRINGS
	SVGKitLogVerbose(@"Parsing command string: quadratic-bezier-curve-to command");
#endif
	
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Qq"];
    
	if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
	{
		NSAssert( FALSE, @"failed to scan quadratic curve to command");
		return SVGCurveZero;
	}
	
    [SVGKPointsAndPathsParser readWhitespace:scanner];
    
    SVGCurve lastCurve = [SVGKPointsAndPathsParser readQuadraticCurvetoArgumentSequence:scanner path:path relativeTo:origin isRelative:isRelative];
    return lastCurve;
}
/**
 quadratic-bezier-curveto-argument-sequence:
 quadratic-bezier-curveto-argument
 | quadratic-bezier-curveto-argument comma-wsp? quadratic-bezier-curveto-argument-sequence
 */
+ (SVGCurve) readQuadraticCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    SVGCurve curve = [SVGKPointsAndPathsParser readQuadraticCurvetoArgument:scanner path:path relativeTo:origin];
    
	while(![scanner isAtEnd])
	{
		curve = [SVGKPointsAndPathsParser readQuadraticCurvetoArgument:scanner path:path relativeTo:(isRelative ? curve.p : origin)];
    }
    
    return curve;
}

/**
 quadratic-bezier-curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair
 */
+ (SVGCurve) readQuadraticCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
	SVGCurve curveResult;
	
    curveResult.c1 = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
    curveResult.c1.x += origin.x;
	curveResult.c1.y += origin.y;
    [SVGKPointsAndPathsParser readCommaAndWhitespace:scanner];
    
	curveResult.c2 = CGPointZero;
	
    curveResult.p = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
    curveResult.p.x += origin.x;
	curveResult.p.y += origin.y;
    [SVGKPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    CGPathAddQuadCurveToPoint(path, NULL, curveResult.c1.x, curveResult.c1.y, curveResult.p.x, curveResult.p.y);
#if DEBUG_PATH_CREATION
	SVGKitLogWarn(@"[%@] PATH: QUADRATIC CURVE to (%2.2f, %2.2f)..(%2.2f, %2.2f)", [SVGKPointsAndPathsParser class], curveResult.c1.x, curveResult.c1.y, curveResult.p.x, curveResult.p.y);
#endif
    
    return curveResult;
}

/**
 smooth-quadratic-bezier-curveto:
 ( "T" | "t" ) wsp* smooth-quadratic-bezier-curveto-argument-sequence
 */
+ (SVGCurve) readSmoothQuadraticCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve
{
#if VERBOSE_PARSE_SVG_COMMAND_STRINGS
	SVGKitLogVerbose(@"Parsing command string: smooth-quadratic-bezier-curve-to command");
#endif
	NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Tt"];
    
	if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
	{
		NSAssert( FALSE, @"failed to scan smooth quadratic curve to command");
		return SVGCurveZero;
	}
	
    [SVGKPointsAndPathsParser readWhitespace:scanner];
    
    SVGCurve lastCurve = [SVGKPointsAndPathsParser readSmoothQuadraticCurvetoArgumentSequence:scanner path:path relativeTo:origin withPrevCurve:prevCurve];
    return lastCurve;
}


/**
 smooth-quadratic-bezier-curveto-argument-sequence:
 smooth-quadratic-bezier-curveto-argument
 | smooth-quadratic-bezier-curveto-argument comma-wsp? smooth-quadratic-bezier-curveto-argument-sequence
 */
+ (SVGCurve) readSmoothQuadraticCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve
{
    SVGCurve curve = [SVGKPointsAndPathsParser readSmoothQuadraticCurvetoArgument:scanner path:path relativeTo:origin withPrevCurve:prevCurve];
    
    if (![scanner isAtEnd]) {
        curve = [SVGKPointsAndPathsParser readSmoothQuadraticCurvetoArgumentSequence:scanner path:path relativeTo:curve.p withPrevCurve:curve];
    }
    
    return curve;
}

/**
 smooth-quadratic-bezier-curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair
 */
+ (SVGCurve) readSmoothQuadraticCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve
{
    CGPoint p1 = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
    CGPoint coord1 = CGPointMake(p1.x+origin.x, p1.y+origin.y);
    [SVGKPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    SVGCurve thisCurve = SVGCurveZero;
    if (SVGCurveEqualToCurve(SVGCurveZero, prevCurve)) {
        // assume control point is coincident with the current point
        thisCurve = SVGCurveMake(coord1.x, coord1.y, 0.0f, 0.0f, thisCurve.p.x, thisCurve.p.y);
    } else {
        // calculate the mirror of the previous control point
        CGPoint currentPoint = prevCurve.p;
        CGPoint controlPoint = prevCurve.c1;
        CGPoint mirrorCoord = CGPointMake(currentPoint.x+(currentPoint.x-controlPoint.x), currentPoint.y+(currentPoint.y-controlPoint.y));
        thisCurve = SVGCurveMake(mirrorCoord.x, mirrorCoord.y, 0.0f, 0.0f, coord1.x, coord1.y);
    }
    
    CGPathAddQuadCurveToPoint(path, NULL, thisCurve.c1.x, thisCurve.c1.y, thisCurve.p.x, thisCurve.p.y );
#if DEBUG_PATH_CREATION
	SVGKitLogWarn(@"[%@] PATH: SMOOTH QUADRATIC CURVE to (%2.2f, %2.2f)..(%2.2f, %2.2f)", [SVGKPointsAndPathsParser class], thisCurve.c1.x, thisCurve.c1.y, thisCurve.p.x, thisCurve.p.y );
#endif
	
    return thisCurve;
}

/**
 curveto:
 ( "C" | "c" ) wsp* curveto-argument-sequence
 */
+ (SVGCurve) readCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
#if VERBOSE_PARSE_SVG_COMMAND_STRINGS
	SVGKitLogVerbose(@"Parsing command string: curve-to command");
#endif
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Cc"];
    
	if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd])
	{
		NSAssert( FALSE, @"failed to scan curve to command");
		return SVGCurveZero;
	}
	
    [SVGKPointsAndPathsParser readWhitespace:scanner];
    
    SVGCurve lastCurve = [SVGKPointsAndPathsParser readCurvetoArgumentSequence:scanner path:path relativeTo:origin isRelative:isRelative];
    return lastCurve;
}

/**
 curveto-argument-sequence:
 curveto-argument
 | curveto-argument comma-wsp? curveto-argument-sequence
 */
+ (SVGCurve) readCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
	SVGCurve curve = [SVGKPointsAndPathsParser readCurvetoArgument:scanner path:path relativeTo:origin];
    
	while( ![scanner isAtEnd])
	{
		CGPoint newOrigin = isRelative ? curve.p : origin;
		
        curve = [SVGKPointsAndPathsParser readCurvetoArgument:scanner path:path relativeTo:newOrigin];
    }
	
    return curve;
}

/**
 curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair comma-wsp? coordinate-pair
 */
+ (SVGCurve) readCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
	SVGCurve curveResult;
    curveResult.c1 = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
	curveResult.c1.x += origin.x; // avoid allocating a new struct, an allocation here could happen MILLIONS of times in a large parse!
	curveResult.c1.y += origin.y;
    [SVGKPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    curveResult.c2 = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
    curveResult.c2.x += origin.x; // avoid allocating a new struct, an allocation here could happen MILLIONS of times in a large parse!
	curveResult.c2.y += origin.y;
    [SVGKPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    curveResult.p = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
    curveResult.p.x += origin.x; // avoid allocating a new struct, an allocation here could happen MILLIONS of times in a large parse!
	curveResult.p.y += origin.y;
    [SVGKPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    CGPathAddCurveToPoint(path, NULL, curveResult.c1.x, curveResult.c1.y, curveResult.c2.x, curveResult.c2.y, curveResult.p.x, curveResult.p.y);
#if DEBUG_PATH_CREATION
	SVGKitLogWarn(@"[%@] PATH: CURVE to (%2.2f, %2.2f)..(%2.2f, %2.2f)..(%2.2f, %2.2f)", [SVGKPointsAndPathsParser class], curveResult.c1.x, curveResult.c1.y, curveResult.c2.x, curveResult.c2.y, curveResult.p.x, curveResult.p.y);
#endif
    
    return curveResult;
}

/**
 smooth-curveto:
 ( "S" | "s" ) wsp* smooth-curveto-argument-sequence
 */
+ (SVGCurve) readSmoothCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Ss"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan smooth curve to command");
    if (!ok) return SVGCurveZero;
	
    [SVGKPointsAndPathsParser readWhitespace:scanner];
    
    SVGCurve lastCurve = [SVGKPointsAndPathsParser readSmoothCurvetoArgumentSequence:scanner path:path relativeTo:origin withPrevCurve:prevCurve];
    return lastCurve;
}

/**
 smooth-curveto-argument-sequence:
 smooth-curveto-argument
 | smooth-curveto-argument comma-wsp? smooth-curveto-argument-sequence
 */
+ (SVGCurve) readSmoothCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve
{
    SVGCurve curve = [SVGKPointsAndPathsParser readSmoothCurvetoArgument:scanner path:path relativeTo:origin withPrevCurve:prevCurve];
    
    if (![scanner isAtEnd]) {
        curve = [SVGKPointsAndPathsParser readSmoothCurvetoArgumentSequence:scanner path:path relativeTo:curve.p withPrevCurve:curve];
    }
    
    return curve;
}

/**
 smooth-curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair
 */
+ (SVGCurve) readSmoothCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve
{
	// FIXME: reduce the allocations here; make one SVGCurve and update it, not multiple CGPoint's
	
    CGPoint p1 = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
    CGPoint coord1 = CGPointMake(p1.x+origin.x, p1.y+origin.y);
    [SVGKPointsAndPathsParser readCommaAndWhitespace:scanner];
    
    CGPoint p2 = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
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
	SVGKitLogWarn(@"[%@] PATH: SMOOTH CURVE to (%2.2f, %2.2f)..(%2.2f, %2.2f)..(%2.2f, %2.2f)", [SVGKPointsAndPathsParser class], thisCurve.c1.x, thisCurve.c1.y, thisCurve.c2.x, thisCurve.c2.y, thisCurve.p.x, thisCurve.p.y );
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
	// FIXME: reduce the allocations here; make one CGPoint and update it, not multiple
    CGFloat yValue;
	[SVGKPointsAndPathsParser readCoordinate:scanner intoFloat:&yValue];
    CGPoint vertCoord = CGPointMake(origin.x, origin.y+yValue);
    CGPoint currentPoint = CGPathGetCurrentPoint(path);
    CGPoint coord = CGPointMake(currentPoint.x, currentPoint.y+(vertCoord.y-currentPoint.y));
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
#if DEBUG_PATH_CREATION
	SVGKitLogWarn(@"[%@] PATH: VERTICAL LINE to (%2.2f, %2.2f)", [SVGKPointsAndPathsParser class], coord.x, coord.y );
#endif
    return coord;
}

/**
 vertical-lineto:
 ( "V" | "v" ) wsp* vertical-lineto-argument-sequence
 */
+ (CGPoint) readVerticalLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
#if VERBOSE_PARSE_SVG_COMMAND_STRINGS
	SVGKitLogVerbose(@"Parsing command string: vertical-line-to command");
#endif
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Vv"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan vertical line to command");
    if (!ok) return origin;
	
    [SVGKPointsAndPathsParser readWhitespace:scanner];
    
    CGPoint lastCoordinate = [SVGKPointsAndPathsParser readVerticalLinetoArgumentSequence:scanner path:path relativeTo:origin];
    return lastCoordinate;
}

/**
 horizontal-lineto-argument-sequence:
 coordinate
 | coordinate comma-wsp? horizontal-lineto-argument-sequence
 */
+ (CGPoint) readHorizontalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
	// FIXME: reduce the allocations here; make one CGPoint and update it, not multiple
	
    CGFloat xValue;
	[SVGKPointsAndPathsParser readCoordinate:scanner intoFloat:&xValue];
    CGPoint horizCoord = CGPointMake(origin.x+xValue, origin.y);
    CGPoint currentPoint = CGPathGetCurrentPoint(path);
    CGPoint coord = CGPointMake(currentPoint.x+(horizCoord.x-currentPoint.x), currentPoint.y);
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
#if DEBUG_PATH_CREATION
	SVGKitLogWarn(@"[%@] PATH: HORIZONTAL LINE to (%2.2f, %2.2f)", [SVGKPointsAndPathsParser class], coord.x, coord.y );
#endif
    return coord;
}

/**
 horizontal-lineto:
 ( "H" | "h" ) wsp* horizontal-lineto-argument-sequence
 */
+ (CGPoint) readHorizontalLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
#if VERBOSE_PARSE_SVG_COMMAND_STRINGS
	SVGKitLogVerbose(@"Parsing command string: horizontal-line-to command");
#endif
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Hh"];
    
	if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
	{
		NSAssert( FALSE, @"failed to scan horizontal line to command");
		return origin;
	}
	
    [SVGKPointsAndPathsParser readWhitespace:scanner];
    
    CGPoint lastCoordinate = [SVGKPointsAndPathsParser readHorizontalLinetoArgumentSequence:scanner path:path relativeTo:origin];
    return lastCoordinate;
}

+ (CGPoint) readCloseCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
#if VERBOSE_PARSE_SVG_COMMAND_STRINGS
	SVGKitLogVerbose(@"Parsing command string: close command");
#endif
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Zz"];
	
	if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
	{
		NSAssert( FALSE, @"failed to scan close command");
		return origin;
	}
	
    CGPathCloseSubpath(path);
#if DEBUG_PATH_CREATION
	SVGKitLogWarn(@"[%@] PATH: finished path", [SVGKPointsAndPathsParser class] );
#endif

	return CGPathGetCurrentPoint(path);
}

+ (SVGCurve)readEllipticalArcArguments:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
	NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Aa"];
	
	[scanner scanCharactersFromSet:cmdFormat intoString:nil];

	// need to find the center point of the ellipse from the two points and an angle
	// see http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes for these calculations
	
	CGPoint currentPt = CGPathGetCurrentPoint(path);
	
	CGFloat x1 = currentPt.x;
	CGFloat y1 = currentPt.y;
	
	CGPoint radii = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
	CGFloat rx = fabs(radii.x);
	CGFloat ry = fabs(radii.y);
	
	CGFloat phi;
	
	[SVGKPointsAndPathsParser readCoordinate:scanner intoFloat:&phi];
	
	phi *= M_PI/180.;
	
	phi = fmod(phi, 2 * M_PI);
	
	CGPoint flags = [SVGKPointsAndPathsParser readCoordinatePair:scanner];
	
	BOOL largeArcFlag = flags.x != 0.;
	BOOL sweepFlag = flags.y != 0.;

	CGPoint endPoint = [SVGKPointsAndPathsParser readCoordinatePair:scanner];

	// end parsing

	CGFloat x2 = origin.x + endPoint.x;
	CGFloat y2 = origin.y + endPoint.y;

	SVGCurve curve;
	
	curve.p = CGPointMake(x2, y2);
	
	if (rx == 0 || ry == 0)
	{
		CGPathAddLineToPoint(path, NULL, curve.p.x, curve.p.y);
		return curve;
	}
	CGFloat cosPhi = cos(phi);
	CGFloat sinPhi = sin(phi);
	
	CGFloat	x1p = cosPhi * (x1-x2)/2. + sinPhi * (y1-y2)/2.;
	CGFloat	y1p = -sinPhi * (x1-x2)/2. + cosPhi * (y1-y2)/2.;
	
	CGFloat lhs;
	{
		CGFloat rx_2 = rx * rx;
		CGFloat ry_2 = ry * ry;
		CGFloat xp_2 = x1p * x1p;
		CGFloat yp_2 = y1p * y1p;

		CGFloat delta = xp_2/rx_2 + yp_2/ry_2;
		
		if (delta > 1.0)
		{
			rx *= sqrt(delta);
			ry *= sqrt(delta);
			rx_2 = rx * rx;
			ry_2 = ry * ry;
		}
		CGFloat sign = (largeArcFlag == sweepFlag) ? -1 : 1;
		CGFloat numerator = rx_2 * ry_2 - rx_2 * yp_2 - ry_2 * xp_2;
		CGFloat denom = rx_2 * yp_2 + ry_2 * xp_2;
		
		numerator = MAX(0, numerator);
		
		lhs = sign * sqrt(numerator/denom);
	}
	
	CGFloat cxp = lhs * (rx*y1p)/ry;
	CGFloat cyp = lhs * -((ry * x1p)/rx);
	
	CGFloat cx = cosPhi * cxp + -sinPhi * cyp + (x1+x2)/2.;
	CGFloat cy = cxp * sinPhi + cyp * cosPhi + (y1+y2)/2.;
	
	// transform our ellipse into the unit circle

	CGAffineTransform tr = CGAffineTransformMakeScale(1./rx, 1./ry);

	tr = CGAffineTransformRotate(tr, -phi);
	tr = CGAffineTransformTranslate(tr, -cx, -cy);
	
	CGPoint arcPt1 = CGPointApplyAffineTransform(CGPointMake(x1, y1), tr);
	CGPoint arcPt2 = CGPointApplyAffineTransform(CGPointMake(x2, y2), tr);
		
	CGFloat startAngle = atan2(arcPt1.y, arcPt1.x);
	CGFloat endAngle = atan2(arcPt2.y, arcPt2.x);
	
	CGFloat angleDelta = endAngle - startAngle;;
	
	if (sweepFlag)
	{
		if (angleDelta < 0)
			angleDelta += 2. * M_PI;
	}
	else
	{
		if (angleDelta > 0)
			angleDelta = angleDelta - 2 * M_PI;
	}
	// construct the inverse transform
	CGAffineTransform trInv = CGAffineTransformMakeTranslation( cx, cy);
	
	trInv = CGAffineTransformRotate(trInv, phi);
	trInv = CGAffineTransformScale(trInv, rx, ry);

	// add a inversely transformed circular arc to the current path
	CGPathAddRelativeArc( path, &trInv, 0, 0, 1., startAngle, angleDelta);
	
	return curve;
}

@end
