#import <SVGKit/CSSValue.h>
#import <SVGKit/CSSValue_ForSubclasses.h>

@implementation CSSValue

@synthesize cssText = _cssText;
@synthesize cssValueType;

- (instancetype)init
{
    NSAssert(FALSE, @"This class cannot be init'd using init. It would break it, badly. Use the correct init call instead (if you don't know what that is, you shouldn't be init'ing this class)");
    
	return nil;
}

- (instancetype)initWithUnitType:(CSSUnitType) t
{
    self = [super init];
    if (self) {
		self.cssValueType = t;
    }
    return self;
}
@end
