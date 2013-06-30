/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceLocalFile : SVGKSource <NSCopying>

@property (readonly, nonatomic, copy) NSString* filePath;

- (id)initFromFilename:(NSString*)p DEPRECATED_ATTRIBUTE;
- (id)initWithFilename:(NSString*)p;
+ (SVGKSource*)sourceFromFilename:(NSString*)p;

@end
