/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceLocalFile : SVGKSource

@property (nonatomic, strong) NSString* filePath;

+ (SVGKSource*)sourceFromFilename:(NSString*)p;

@end
