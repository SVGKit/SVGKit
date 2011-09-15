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

@interface SVGPathElement ()

- (void)parseData:(NSString *)data;

@end


@implementation SVGPathElement

typedef enum {
	SVGPathSegmentTypeMoveTo = 0,
	SVGPathSegmentTypeLineTo,
	SVGPathSegmentTypeCurve
} SVGPathSegmentType;

#define MAX_ACCUM 16

- (void)parseAttributes:(NSDictionary *)attributes {
	[super parseAttributes:attributes];
	
	id value = nil;
	
	if ((value = [attributes objectForKey:@"d"])) {
		[self parseData:value];
	}
}

- (void)parseData:(NSString *)data {
	CGMutablePathRef path = CGPathCreateMutable();
	
    /*
	const char *cstr = [data UTF8String];
	size_t len = strlen(cstr);
	
	SVGPathSegmentType type = -1;
	
	char accum[MAX_ACCUM];
	bzero(accum, MAX_ACCUM);
	
	int accumIdx = 0, currComponent = 0;
	
	for (size_t n = 0; n <= len; n++) {
		char c = cstr[n];
		
		if (c == '\n' || c == '\t' || c == ' ' || c == ',' || c == '\0') {
			if (type != -1) {
				accum[accumIdx] = '\0';
				
				if (type == SVGPathSegmentTypeMoveTo) {
					static int x;
					
					if (currComponent == 0) {
						x = atoi(accum);
						currComponent++;
					}
					else if (currComponent == 1) {
						CGPathMoveToPoint(path, NULL, x, atoi(accum));
						type = -1;
					}
				}
				else if (type == SVGPathSegmentTypeLineTo) {
					static int x;
					
					if (currComponent == 0) {
						x = atoi(accum);
						currComponent++;
					}
					else if (currComponent == 1) {
						CGPathAddLineToPoint(path, NULL, x, atoi(accum));
						type = -1;
					}
				}
				else if (type == SVGPathSegmentTypeCurve) {
					static int x1, y1, x2, y2, x;
					
					if (currComponent == 0) {
						x1 = atoi(accum);
						currComponent++;
					}
					else if (currComponent == 1) {
						y1 = atoi(accum);
						currComponent++;
					}
					else if (currComponent == 2) {
						x2 = atoi(accum);
						currComponent++;
					}
					else if (currComponent == 3) {
						y2 = atoi(accum);
						currComponent++;
					}
					else if (currComponent == 4) {
						x = atoi(accum);
						currComponent++;
					}
					else if (currComponent == 5) {
						CGPathAddCurveToPoint(path, NULL, x1, y1, x2, y2, x, atoi(accum));
						type = -1;
					}
				}
				
				bzero(accum, MAX_ACCUM);
				accumIdx = 0;
			}
		}
		else if (c == 'M' || c == 'm') {
			currComponent = 0;
			type = SVGPathSegmentTypeMoveTo;
		}
		else if (c == 'L' || c == 'l') {
			currComponent = 0;
			type = SVGPathSegmentTypeLineTo;
		}
		else if (c == 'C' || c == 'c') {
			currComponent = 0;
			type = SVGPathSegmentTypeCurve;
		}
		else if (c == 'Z' || c == 'z') {
			CGPathCloseSubpath(path);
		}
		else if ((c >= '0' && c <= '9') || c == '-') { // is digit?
			accum[accumIdx++] = c;
		}
	}
     */
    
    NSScanner* pathScanner = [NSScanner scannerWithString:data];
	SVGPathSegmentType type = -1;
    static NSString* comma = @",";
    
    while (![pathScanner isAtEnd]) {
        NSString* command = nil;
        [pathScanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"MmLlCcZz"]
                                intoString:&command];
        
        if ([@"z" isEqualToString:command] || [@"Z" isEqualToString:command]) {
            CGPathCloseSubpath(path);
            break;
        }
        
        if ([@"l" isEqualToString:command] || [@"L" isEqualToString:command]) {
            type = SVGPathSegmentTypeLineTo;
        } else if ([@"c" isEqualToString:command] || [@"C" isEqualToString:command]) {
            type = SVGPathSegmentTypeCurve;
        } else if ([@"m" isEqualToString:command] || [@"M" isEqualToString:command]) {
            type = SVGPathSegmentTypeMoveTo;
        } else {
            NSLog(@"unknown command type: %@", command);
            break;
        }
        
        float x1;
        float y1;
        float x2;
        float y2;
        float x3;
        float y3;
        [pathScanner scanFloat:&x1];
        [pathScanner scanString:comma intoString:NULL];
        [pathScanner scanFloat:&y1];
        
        switch (type) {
            case SVGPathSegmentTypeCurve:
                [pathScanner scanFloat:&x2];
                [pathScanner scanString:comma intoString:NULL];
                [pathScanner scanFloat:&y2];
                
                [pathScanner scanFloat:&x3];
                [pathScanner scanString:comma intoString:NULL];
                [pathScanner scanFloat:&y3];

                CGPathAddCurveToPoint(path, NULL, x1, y1, x2, y2, x3, y3);
                break;
            case SVGPathSegmentTypeLineTo:
                
                CGPathAddLineToPoint(path, NULL, x1, y1);
                break;
                
            case SVGPathSegmentTypeMoveTo:
                
                CGPathMoveToPoint(path, NULL, x1, y1);
                break;
                
            default:
                break;
        }
    }
	
	[self loadPath:path];
	
	CGPathRelease(path);
}

@end
