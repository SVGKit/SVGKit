#import <SVGKit/CSSValueList.h>
#import <SVGKit/CSSValue_ForSubclasses.h>

@interface CSSValueList()

@property(nonatomic,strong) NSArray* internalArray;

@end

@implementation CSSValueList

@synthesize internalArray;

- (instancetype)init
{
    self = [super initWithUnitType:CSS_VALUE_LIST];
    if (self) {
        self.internalArray = @[];
    }
    return self;
}

-(NSUInteger)length
{
	return self.internalArray.count;
}

-(CSSValue*) item:(NSUInteger) index
{
	return (self.internalArray)[index];
}

#pragma mark - non DOM spec methods needed to implement Objective-C code for this class

-(void)setCssText:(NSString *)newCssText
{
	_cssText = newCssText;
	
	/** the css text value has been set, so we need to split the elements up and save them in the internal array */
	DDLogVerbose(@"[%@] received new CSS Text, need to split this and save as CSSValue instances: %@", [self class], _cssText);
	
	self.internalArray = [_cssText componentsSeparatedByString:@" "];
}

@end
