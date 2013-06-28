#import "SVGLength.h"

#import "CSSPrimitiveValue.h"
#import "CSSPrimitiveValue_ConfigurablePixelsPerInch.h"

#import "SVGUtils.h"

#include <sys/types.h>
#include <sys/sysctl.h>

@interface SVGLength()
@property(nonatomic,strong) CSSPrimitiveValue* internalCSSPrimitiveValue;
@end

@implementation SVGLength

@synthesize unitType;
@synthesize value;
@synthesize valueInSpecifiedUnits;
@synthesize valueAsString;
@synthesize internalCSSPrimitiveValue;

- (id)init
{
    NSAssert(FALSE, @"This class must not be init'd. Use the static hepler methods to instantiate it instead");
    return nil;
}

- (NSString*)description
{
	NSString *unit = nil;
#define UnitSwitch(name) case SVG_LENGTHTYPE_##name: \
unit = [@( #name ) lowercaseString]; \
break
	
	switch (self.unitType) {
			UnitSwitch(CM);
			UnitSwitch(EMS);
			UnitSwitch(EXS);
			UnitSwitch(IN);
			UnitSwitch(MM);
			UnitSwitch(PC);
			UnitSwitch(PT);
			UnitSwitch(PX);
		case SVG_LENGTHTYPE_NUMBER:
			unit = @" number";
			break;
			
		case SVG_LENGTHTYPE_PERCENTAGE:
			unit = @"%%";
			break;

			
		default:
		case SVG_LENGTHTYPE_UNKNOWN:
			return [NSString stringWithFormat:@"%@: unknown type and length", [self class]];
			break;
	}
	
	return [NSString stringWithFormat:@"%@: %f%@", [self class], self.value, unit];
#undef UnitSwitch
}

- (id)initWithCSSPrimitiveValue:(CSSPrimitiveValue*) pv
{
    self = [super init];
    if (self) {
        self.internalCSSPrimitiveValue = pv;
    }
    return self;
}

-(float)value
{
	return [self.internalCSSPrimitiveValue getFloatValue:self.internalCSSPrimitiveValue.primitiveType];
}

-(SVG_LENGTH_TYPE)unitType
{
	switch( self.internalCSSPrimitiveValue.primitiveType )
	{
		case CSS_CM:
			return SVG_LENGTHTYPE_CM;
		case CSS_EMS:
			return SVG_LENGTHTYPE_EMS;
		case CSS_EXS:
			return SVG_LENGTHTYPE_EXS;
		case CSS_IN:
			return SVG_LENGTHTYPE_IN;
		case CSS_MM:
			return SVG_LENGTHTYPE_MM;
		case CSS_PC:
			return SVG_LENGTHTYPE_PC;
		case CSS_PERCENTAGE:
			return SVG_LENGTHTYPE_PERCENTAGE;
		case CSS_PT:
			return SVG_LENGTHTYPE_PT;
		case CSS_PX:
			return SVG_LENGTHTYPE_PX;
		case CSS_NUMBER:
		case CSS_DIMENSION:
			return SVG_LENGTHTYPE_NUMBER;
		default:
			return SVG_LENGTHTYPE_UNKNOWN;
	}
}

-(void) newValueSpecifiedUnits:(SVG_LENGTH_TYPE) unitType valueInSpecifiedUnits:(float) valueInSpecifiedUnits
{
	NSAssert(FALSE, @"Not supported yet");
}

-(void) convertToSpecifiedUnits:(SVG_LENGTH_TYPE) unitType
{
	NSAssert(FALSE, @"Not supported yet");
}

/** Apple calls this method when the class is loaded; that's as good a time as any to calculate the device / screen's PPI */
+(void)initialize
{
	cachedDevicePixelsPerInch = [self pixelsPerInchForCurrentDevice];
}

+(SVGLength*) svgLengthZero
{
	SVGLength *zeroLength = [[SVGLength alloc] initWithCSSPrimitiveValue:nil];
	return zeroLength;
}

static float cachedDevicePixelsPerInch;
+(SVGLength*) svgLengthFromNSString:(NSString*) s
{
	CSSPrimitiveValue* pv = [[CSSPrimitiveValue alloc] init];
	
	pv.pixelsPerInch = cachedDevicePixelsPerInch;
	pv.cssText = s;
	
	SVGLength* result = [[SVGLength alloc] initWithCSSPrimitiveValue:pv];
	
	return result;
}

-(float) pixelsValue
{
	return [self.internalCSSPrimitiveValue getFloatValue:CSS_PX];
}

-(float) numberValue
{
	return [self.internalCSSPrimitiveValue getFloatValue:CSS_NUMBER];
}

#pragma mark - secret methods needed to provide an implementation on ObjectiveC

+(float) pixelsPerInchForCurrentDevice
{
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
	
	/** Using this as reference: http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density#Apple
	 */
	
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = @(machine);
	free(machine);
	
	if( [platform hasPrefix:@"iPhone1"]
	   || [platform hasPrefix:@"iPhone2"]
	   || [platform hasPrefix:@"iPhone3"])
		return 163.0f;
	
	if( [platform hasPrefix:@"iPhone4"]
	   || [platform hasPrefix:@"iPhone5"])
		return 326.0f;
	
	if( [platform hasPrefix:@"iPhone"]) // catch-all for higher-end devices not yet existing
	{
		NSAssert(FALSE, @"Not supported yet: you are using an iPhone that didn't exist when this code was written, we have no idea what the pixel count per inch is!");
		return 326.0f;
	}
	
	if( [platform hasPrefix:@"iPod1"]
	   || [platform hasPrefix:@"iPod2"]
	   || [platform hasPrefix:@"iPod3"])
		return 163.0f;
	
	if( [platform hasPrefix:@"iPod4"]
	   || [platform hasPrefix:@"iPod5"])
		return 326.0f;
	
	if( [platform hasPrefix:@"iPod"]) // catch-all for higher-end devices not yet existing
	{
		NSAssert(FALSE, @"Not supported yet: you are using an iPod that didn't exist when this code was written, we have no idea what the pixel count per inch is!");
		return 326.0f;
	}
	
	if( [platform hasPrefix:@"iPad1"]
	   || [platform hasPrefix:@"iPad2"])
		return 132.0f;
	if( [platform hasPrefix:@"iPad3"]
	   || [platform hasPrefix:@"iPad4"])
		return 264.0f;
	if( [platform hasPrefix:@"iPad"]) // catch-all for higher-end devices not yet existing
	{
		NSAssert(FALSE, @"Not supported yet: you are using an iPad that didn't exist when this code was written, we have no idea what the pixel count per inch is!");
		return 264.0f;
	}
	
	if( [platform hasPrefix:@"x86_64"])
	{
		DDLogWarn(@"[%@] WARNING: you are running on the simulator; it's impossible for us to calculate centimeter/millimeter/inches units correctly", [self class]);
		return 132.0f; // Simulator, running on desktop machine
	}
	
	NSAssert(FALSE, @"Cannot determine the PPI values for current device; returning 0.0f - hopefully this will crash your code (you CANNOT run SVG's that use CM/IN/MM etc until you fix this)" );
	return 0.0f; // Bet you'll get a divide by zero here...
#else
	//TODO: port to OS X.
	return 72.0;
#endif
}

@end
