#import <SVGKit/StyleSheetList.h>
#import <SVGKit/StyleSheetList+Mutable.h>

@implementation StyleSheetList

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

-(StyleSheet*) item:(unsigned long) index
{
	return (self.internalArray)[index];
}

@end
