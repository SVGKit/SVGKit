/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceLocalFile : SVGKSource

@property (nonatomic, copy) NSString* filePath;

+ (SVGKSource*)sourceFromFilename:(NSString*)p;

@end
