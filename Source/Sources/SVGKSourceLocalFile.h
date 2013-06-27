/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceLocalFile : SVGKSource <NSCopying>

@property (nonatomic, copy) NSString* filePath;

+ (SVGKSource*)sourceFromFilename:(NSString*)p;

@end
