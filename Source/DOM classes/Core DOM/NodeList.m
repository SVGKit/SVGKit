#import "NodeList.h"
#import "NodeList+Mutable.h"

@implementation NodeList

@synthesize internalArray;

- (id)init {
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

-(Node*) item:(int) index
{
	return (self.internalArray)[index];
}

-(long)length
{
	return [self.internalArray count];
}

#pragma mark - ADDITIONAL to SVG Spec: Objective-C support for fast-iteration ("for * in ..." syntax)

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id [])buffer count:(NSUInteger)len
{
	return [self.internalArray countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - ADDITIONAL to SVG Spec: useful debug / output / description methods

-(NSString *)description
{
	return [NSString stringWithFormat:@"NodeList: array(%@)", self.internalArray];
}

@end
