/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceLocalFile : SVGKSource

@property (nonatomic, retain) NSString* filePath;
@property (nonatomic, readonly) BOOL wasRelative;

+ (SVGKSourceLocalFile*)sourceFromFilename:(NSString*)p;

+ (SVGKSourceLocalFile*) internalSourceAnywhereInBundleUsingName:(NSString*) name;

@end
