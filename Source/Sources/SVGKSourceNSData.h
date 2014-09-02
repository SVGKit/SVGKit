/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceNSData : SVGKSource

@property (nonatomic, copy) NSData* rawData;
@property (nonatomic, strong) NSURL* effectiveURL;

- (instancetype)initWithData:(NSData*)data;
- (instancetype)initWithData:(NSData*)data URLForRelativeLinks:(NSURL*)url;


+ (SVGKSource*)sourceFromData:(NSData*)data URLForRelativeLinks:(NSURL*) url;

@end
