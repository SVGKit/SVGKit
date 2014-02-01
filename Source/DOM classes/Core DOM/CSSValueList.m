#import "CSSValueList.h"
#import "CSSValue_ForSubclasses.h"

@interface CSSValueList()

@property(nonatomic, STRONG) NSArray* internalArray;

@end

@implementation CSSValueList

@synthesize internalArray;

- (void)dealloc {
  self.internalArray = nil;
  [super DEALLOC];
}

- (id)init
{
    self = [super initWithUnitType:CSS_VALUE_LIST];
    if (self) {
        self.internalArray = [NSArray array];
    }
    return self;
}

-(unsigned long)length
{
	return self.internalArray.count;
}

-(CSSValue*) item:(unsigned long) index
{
	return [self.internalArray objectAtIndex:index];
}

#pragma mark - non DOM spec methods needed to implement Objective-C code for this class

-(void)setCssText:(NSString *)newCssText
{
	[_cssText RELEASE];
	_cssText = newCssText;
	[_cssText RETAIN];
	
	/** the css text value has been set, so we need to split the elements up and save them in the internal array */
	DDLogVerbose(@"[%@] received new CSS Text, need to split this and save as CSSValue instances: %@", [self class], _cssText);
	
	self.internalArray = [_cssText componentsSeparatedByString:@" "];
}

@end
