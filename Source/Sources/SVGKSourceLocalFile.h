/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceLocalFile : SVGKSource

@property (nonatomic, retain) NSString* filePath;

+ (SVGKSource*)sourceFromFilename:(NSString*)p;

@end
