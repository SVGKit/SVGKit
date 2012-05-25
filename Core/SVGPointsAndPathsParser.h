//
//  SVGPointsAndPathsParser.h
//  SVGPad
//
//  Created by adam on 18/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <QuartzCore/QuartzCore.h>
#endif


typedef struct {
    const char *scanString;
    int stringLength;
    int currentIndex;
} PathScanInfo;



typedef enum {
    MOVE_TO = 1,
    LINE_TO = 2,
    VERTICAL_LINE_TO = 3,
    HORIZONTAL_LINE_TO = 4,
    CURVE_TO = 5,
    SMOOTH_CURVE_TO = 6,
    CLOSE_PATH = 7,
    
    RELATIVE = 1 << 8
} PathCommandType;

static const int IRRELATIVE_MASK = 0xFF; //bottom 8 bits

typedef struct SVGCurve
{
    CGPoint c1;
    CGPoint c2;
    CGPoint p;
} SVGCurve;

SVGCurve SVGCurveMake(CGFloat cx1, CGFloat cy1, CGFloat cx2, CGFloat cy2, CGFloat px, CGFloat py);
BOOL SVGCurveEqualToCurve(SVGCurve curve1, SVGCurve curve2);
BOOL SVGCurveRefEqualToZero(SVGCurve *curve1);
NSCharacterSet *cachedCharacterSetForString(NSString *characters);

static inline CGPathRef CGPathFromString(NSString *pathString);

PathCommandType DecodeSVGPathCommand(char *commandChar, bool *isRelative);
void ReadCloseCommand(PathScanInfo *scanInfo, CGMutablePathRef path);
void ReadCurvetoArgument(PathScanInfo *scanInfo, CGMutablePathRef path, CGPoint *lastCoordinate, SVGCurve *lastCurve, bool isRelative);
//void ReadCurvetoArgumentSequence(PathScanInfo *scanInfo, CGMutablePathRef path, CGPoint *lastCoordinate, SVGCurve *lastCurve, bool isRelative);
void ReadSmoothCurvetoArgument(PathScanInfo *scanInfo, CGMutablePathRef path, CGPoint *lastCoordinate, SVGCurve *lastCurve, bool isRelative);
void ReadMovetoCommand(PathScanInfo *scanInfo, CGMutablePathRef withPath, CGPoint *lastCoordinate, bool isRelative);
void ReadHorizontalLinetoArgument(PathScanInfo *scanInfo, CGMutablePathRef withPath, CGPoint *lastCoordinate, bool isRelative);
void ReadVerticalLinetoArgument(PathScanInfo *scanInfo, CGMutablePathRef withPath, CGPoint *lastCoordinate, bool isRelative);

void ReadLinetoArgument(PathScanInfo *scanInfo, CGMutablePathRef path, CGPoint *lastCoordinate, bool isRelative);
//#define SVGCurveZero SVGCurveMake(0.,0.,0.,0.,0.,0.)
__unused static SVGCurve SVGCurveZero = { .p = { .x = 0., .y = 0.}, .c1 = { .x = 0., .y = 0.}, .c2 = { .x = 0., .y = 0.} };


char ReadCharacter(PathScanInfo *scanInfo);
void SkipWhitespace(PathScanInfo *scanInfo);

bool UpcaseChar(char *character); //returns true if character was lower case

@interface SVGPointsAndPathsParser : NSObject

+ (void)trim;

static char GetCurrentCharacter(PathScanInfo *scanInfo);

static inline void SkipCommaAndWhitespace(PathScanInfo *scanInfo);
static inline bool SkipCharacter(PathScanInfo *scanInfo, char skipChar);

static inline bool CheckCharacterCaseInsensitive(PathScanInfo *scanInfo, char upperCaseChar);
static inline bool CheckCharactersCaseInsensitive(PathScanInfo *scanInfo, char *upperCaseChars);
static inline char GetUpcaseChar(char character); //returns true if character was lower case

+ (void) readWhitespace:(NSScanner*)scanner;
+ (void) readCommaAndWhitespace:(NSScanner*)scanner;

//static inline void ReadCoordinate(PathScanInfo *pathInfo, CGFloat*readTo);
+ (CGFloat) readCoordinate:(NSScanner*)scanner;
//static inline void ReadCoordinatePair(PathScanInfo *scanInfo, CGPoint *readTo);
+ (CGPoint) readCoordinatePair:(NSScanner*)scanner;


//this is redundant
//+ (CGPoint) readMovetoDrawtoCommandGroups:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CGPoint) readMovetoDrawtoCommandGroup:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CGPoint) readMovetoDrawto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CGPoint) readMoveto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CGPoint) readMovetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;

+ (CGPoint) readLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CGPoint) readLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CGPoint) readVerticalLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
+ (CGPoint) readVerticalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
+ (CGPoint) readHorizontalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
+ (CGPoint) readHorizontalLinetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;

+ (SVGCurve) readCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (SVGCurve) readCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (SVGCurve) readCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
+ (SVGCurve) readSmoothCurvetoCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve;
+ (SVGCurve) readSmoothCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve;
+ (SVGCurve) readSmoothCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(SVGCurve)prevCurve;

+ (CGPoint) readCloseCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;

@end
