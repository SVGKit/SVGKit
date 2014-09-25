#import "SVGKCSSValue.h"
#import "SVGKCSSValue_ForSubclasses.h"

@implementation SVGKCSSValue

@synthesize cssText = _cssText;
@synthesize cssValueType;

- (void)dealloc {
    [_cssText release];
    [super dealloc];
}

- (id)init
{
    NSAssert(FALSE, @"This class cannot be init'd using init. It would break it, badly. Use the correct init call instead (if you don't know what that is, you shouldn't be init'ing this class)");
    
	return nil;
}

- (id)initWithUnitType:(CSSUnitType) t
{
    self = [super init];
    if (self) {
		self.cssValueType = t;
    }
    return self;
}
@end
