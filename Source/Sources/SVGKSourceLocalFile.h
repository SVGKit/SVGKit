/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceLocalFile : SVGKSource

@property (nonatomic, retain) NSString* filePath;

+ (SVGKSourceLocalFile*)sourceFromFilename:(NSString*)p;

@end
