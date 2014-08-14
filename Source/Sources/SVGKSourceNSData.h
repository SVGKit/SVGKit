/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceNSData : SVGKSource

@property (nonatomic, retain) NSData* rawData;
@property (nonatomic, retain) NSURL* effectiveURL;

+ (SVGKSource*)sourceFromData:(NSData*)data URLForRelativeLinks:(NSURL*) url;

@end
