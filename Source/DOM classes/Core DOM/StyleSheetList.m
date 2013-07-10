#import <SVGKit/StyleSheetList.h>
#import <SVGKit/StyleSheetList+Mutable.h>

@implementation StyleSheetList

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

-(StyleSheet*) item:(unsigned long) index
{
	return (self.internalArray)[index];
}

@end
