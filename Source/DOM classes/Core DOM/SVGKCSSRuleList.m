#import "SVGKCSSRuleList.h"
#import "SVGKCSSRuleList+Mutable.h"

@implementation SVGKCSSRuleList

@synthesize internalArray;

- (void)dealloc {
    self.internalArray = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.internalArray = [NSMutableArray array];
    }
    return self;
}

-(unsigned long)length
{
	return self.internalArray.count;
}

-(SVGKCSSRule *)item:(unsigned long)index
{
	return [self.internalArray objectAtIndex:index];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"CSSRuleList: array(%@)", self.internalArray];
}

@end
