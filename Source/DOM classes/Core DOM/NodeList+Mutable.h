/**
 Makes the writable properties all package-private, effectively
 */

#import "NodeList.h"

@interface NodeList()

@property(nonatomic, STRONG) NSMutableArray* internalArray;

@end
