#import "SVGKStyleSheetList.h"
#import "SVGKStyleSheetList+Mutable.h"

@implementation SVGKStyleSheetList

@synthesize internalArray;

- (id)init
{
    self = [super init];
    if (self) {
        self.internalArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    self.internalArray = nil;
    [super dealloc];
}

-(unsigned long)length
{
	return self.internalArray.count;
}

-(SVGKStyleSheet*) item:(unsigned long) index
{
	return [self.internalArray objectAtIndex:index];
}

@end
