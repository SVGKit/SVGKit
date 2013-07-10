/**
 Makes the writable properties all package-private, effectively
 */

#import <SVGKit/NodeList.h>

@interface NodeList()

@property(nonatomic,strong) NSMutableArray* internalArray;

@end
