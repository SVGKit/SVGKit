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
	NSLog(@"parseData");
	
	CGMutablePathRef path = CGPathCreateMutable();
	
	const char *cstr = [data UTF8String];
	//size_t len = strlen(cstr);
	
	SVGPathSegmentType type = -1;
	bool relative = false;
	
	char accum[MAX_ACCUM];
	bzero(accum, MAX_ACCUM);
	
	int accumIdx = 0, currComponent = 0;
	
	char *ptr = cstr;
	
	while( *ptr != '\0' )
	//for (size_t n = 0; n <= len; n++) 
	{
		char c = *ptr; //cstr[n];
		
		bool newCommand = ( accumIdx != 0 && ( strchr("cClLmMzZ", c ) != NULL ));
		bool newNegativeNumber = ( c == '-' && accumIdx != 0 );
		
		if (c == '\n' || c == '\t' || c == ' ' || c == ',' || c == '\0' || newNegativeNumber || newCommand) {
			if (type != -1) {
				accum[accumIdx] = '\0';
				
				CGPoint currentPoint;
				CGAffineTransform translate;
				
				if(!CGPathIsEmpty(path))
				{
					currentPoint = CGPathGetCurrentPoint(path);
					translate = CGAffineTransformMakeTranslation( currentPoint.x, currentPoint.y );
				}
				
				if (type == SVGPathSegmentTypeMoveTo) {
					static float x, y;
					
					if (currComponent == 0) {
						sscanf( accum, "%g", &x );
						currComponent++;
					}
					else if (currComponent == 1) {
						sscanf( accum, "%g", &y );
						NSLog( @"CGPathMoveToPoint ( %g, %g )", x, y );
						
						CGPathMoveToPoint(path, ( relative ) ? & translate : NULL, x, y);
						type = -1;
					}
				}
				else if (type == SVGPathSegmentTypeLineTo) {
					static float x, y;
					
					if (currComponent == 0) {
						sscanf( accum, "%g", &x );
						currComponent++;
					}
					else if (currComponent == 1) {
						sscanf( accum, "%g", &y );
						
						NSLog( @"CGPathAddLineToPoint ( %g, %g )", x, y );
						
						CGPathAddLineToPoint(path, ( relative ) ? & translate : NULL, x, y);
						type = -1;
					}
				}
				else if (type == SVGPathSegmentTypeCurve) {
					static float x1, y1, x2, y2, x, y;
					
					if (currComponent == 0) {
						sscanf( accum, "%g", &x1 );
						currComponent++;
					}
					else if (currComponent == 1) {
						sscanf( accum, "%g", &y1 );
						currComponent++;
					}
					else if (currComponent == 2) {
						sscanf( accum, "%g", &x2 );
						currComponent++;
					}
					else if (currComponent == 3) {
						sscanf( accum, "%g", &y2 );
						currComponent++;
					}
					else if (currComponent == 4) {
						sscanf( accum, "%g", &x );
						currComponent++;
					}
					else if (currComponent == 5) {
						sscanf( accum, "%g", &y );
						
						NSLog( @"CGPathAddCurveToPoint ( %g, %g, %g, %g, %g, %g )", x1, y1, x2, y2, x, y );
						
						CGPathAddCurveToPoint(path, ( relative ) ? & translate : NULL, x1, y1, x2, y2, x, y);
						type = -1;
					}
				}
				
				bzero(accum, MAX_ACCUM);
				accumIdx = 0;
				
				if( newNegativeNumber )
				{
					accum[accumIdx++] = c;
				}
				else if( newCommand )
				{
					--ptr;
				}
			}
		}
		else if (c == 'M' || c == 'm') {
			currComponent = 0;
			type = SVGPathSegmentTypeMoveTo;
			relative = islower(c);
		}
		else if (c == 'L' || c == 'l') {
			currComponent = 0;
			type = SVGPathSegmentTypeLineTo;
			relative = islower(c);
		}
		else if (c == 'C' || c == 'c') {
			currComponent = 0;
			type = SVGPathSegmentTypeCurve;
			relative = islower(c);
		}
		else if (c == 'Z' || c == 'z') 
		{
			NSLog(@"CGPathCloseSubpath");
			//NSLog( @"CGPathAddLineToPoint ( %g, %g )", x, y );
			
			CGPathCloseSubpath(path);
		}
		else if ((c >= '0' && c <= '9') || c == '-' || c == '.') { // is digit?
			accum[accumIdx++] = c;
		}
		
		++ptr;
	}
	
	//CGPathCloseSubpath(path);
	
	[self loadPath:path];
	
	CGPathRelease(path);
}

@end
