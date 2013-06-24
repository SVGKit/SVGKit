#import "CSSRuleList.h"
#import "CSSRuleList+Mutable.h"

@implementation CSSRuleList

@synthesize internalArray;


- (id)init
{
    self = [super init];
    if (self) {
        self.internalArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(unsigned long)length
{
	return self.internalArray.count;
}

-(CSSRule *)item:(unsigned long)index
{
	return (self.internalArray)[index];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"CSSRuleList: array(%@)", self.internalArray];
}

@end
