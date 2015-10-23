/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceLocalFile : SVGKSource

@property (nonatomic, retain) NSString* filePath;
@property (nonatomic, readonly) BOOL wasRelative;

+ (void)setBundle:(NSBundle *)bundle;

+ (SVGKSourceLocalFile*)sourceFromFilename:(NSString*)p;

+ (SVGKSourceLocalFile*) internalSourceAnywhereInBundleUsingName:(NSString*) name;

@end
