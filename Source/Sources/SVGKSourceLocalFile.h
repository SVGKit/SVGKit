/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceLocalFile : SVGKSource <NSCopying>

@property (nonatomic, copy) NSString* filePath;

- (id)initFromFilename:(NSString*)p;
+ (SVGKSource*)sourceFromFilename:(NSString*)p;

@end
