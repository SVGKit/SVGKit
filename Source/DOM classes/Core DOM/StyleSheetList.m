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

-(NSUInteger)length
{
	return self.internalArray.count;
}

-(StyleSheet*) item:(NSUInteger) index
{
	return (self.internalArray)[index];
}

@end
