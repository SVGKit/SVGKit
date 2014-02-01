/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceLocalFile : SVGKSource

@property (nonatomic, STRONG) NSString* filePath;

+ (SVGKSourceLocalFile*)sourceFromFilename:(NSString*)p;

@end
