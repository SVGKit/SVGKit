#import "SVGLength.h"

@implementation SVGLength

@synthesize unitType;
@synthesize value;
@synthesize valueInSpecifiedUnits;
@synthesize valueAsString;

-(void) newValueSpecifiedUnits:(SVG_LENGTH_TYPE) unitType valueInSpecifiedUnits:(float) valueInSpecifiedUnits
{
	
}

-(void) convertToSpecifiedUnits:(SVG_LENGTH_TYPE) unitType
{
	
}

+(SVGLength*) svgLengthZero
{
	SVGLength* result = [[SVGLength new] autorelease];
	result.value = 0.0f;
	
	return result;
}

+(SVGLength*) svgLengthFromNSString:(NSString*) s
{
	SVGLength* result = [[SVGLength new] autorelease];
	
	result.value = [s floatValue];
	
	return result;
}

-(float) pixelsValue
{
	return value;
}

@end
