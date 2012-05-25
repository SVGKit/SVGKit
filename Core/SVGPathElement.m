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
    //    NSScanner* dataScanner = [[NSScanner alloc] initWithString:data];//[NSScanner scannerWithString:data];
    CGPoint lastCoordinate = CGPointZero;
    SVGCurve lastCurve = SVGCurveZero;
    //    BOOL foundCmd = YES;
    
    PathScanInfo scanInfo;
    const char *rawString = [data UTF8String];
    scanInfo.scanString = rawString;
    int stringLength = scanInfo.stringLength = [data length];
    scanInfo.currentIndex = 0;
    
    char casedCmd;
    char cmdChar;
//    char lastCmd = '\0';
    
    //not a single objective-c message in this entire process now, yay!
    //    @autoreleasepool {
    //        NSCharacterSet* knownCommands = cachedCharacterSetForString(@"MmLlCcVvHhAaSsQqTtZz");// [NSCharacterSet characterSetWithCharactersInString:@"MmLlCcVvHhAaSsQqTtZz"];
    
    bool isRelative = false;
    SkipWhitespace(&scanInfo);
    
    //    if( scanInfo.currentIndex > 0 )
    //        NSLog(@"Whitespace leading path data");
    //        char validationChar;
    //    char lowerOffset = ('A' - 'a');
    do {
        
        //        SkipWhitespace(&scanInfo);
        casedCmd = rawString[scanInfo.currentIndex];//ReadCharacter(&scanInfo);
        
        if( ('9' < casedCmd || casedCmd < '-')) //is non numeric, we have a new message
        {
            isRelative = casedCmd >= 'a';
            cmdChar = (isRelative) ? casedCmd - ('a' - 'A') : casedCmd;
//            if( isRelative )
//                cmdChar = casedCmd - ('a' - 'A');
//            else
//                cmdChar = casedCmd;
            
            scanInfo.currentIndex++; //move past this character
            SkipWhitespace(&scanInfo);
        }
        
        switch ( cmdChar )
        {
            case 'M':
                ReadMovetoCommand(&scanInfo, path, &lastCoordinate, isRelative);
                cmdChar = 'L'; //is relative will not be reset, so we just need to pass along to line-to logic
                break;
                
            case 'C':
                ReadCurvetoArgument(&scanInfo, path, &lastCoordinate, &lastCurve, isRelative);
                break;
                
            case 'S':
                ReadSmoothCurvetoArgument(&scanInfo, path, &lastCoordinate, &lastCurve, isRelative);
                break;
                
            case 'L':
                ReadLinetoArgument(&scanInfo, path, &lastCoordinate, isRelative);
                lastCurve = SVGCurveZero;
                break;
                
            case 'V':
                ReadVerticalLinetoArgument(&scanInfo, path, &lastCoordinate, isRelative);
                lastCurve = SVGCurveZero;
                break;
                
            case 'H':
                ReadHorizontalLinetoArgument(&scanInfo, path, &lastCoordinate, isRelative);
                lastCurve = SVGCurveZero;
                break;
                
                
                
                
                
            case 'Z':
                //                ReadCloseCommand(&scanInfo, path);
                CGPathCloseSubpath(path); //we already read htis char so we don't want to move our pointer again :/
            
            case '\n':
            case '\r':
            case '\t':
            case ' ':
                SkipWhitespace(&scanInfo);
                break;
                
            default:
                //                    foundCmd = false;
//                if( lastCmd == '\0' )
                    NSLog(@"unsupported command %c", cmdChar);
//                else {
//                    scanInfo.currentIndex--;
//                    casedCmd = lastCmd;
//                    goto begin_switch;
//                }
                break;
        }
        
//        lastCmd = casedCmd;
    } while (scanInfo.currentIndex < stringLength);
    
    //    }
    //    [dataScanner release];
    
	[self loadPath:path];
	CGPathRelease(path);
}



@end
