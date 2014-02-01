/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceURL : SVGKSource

@property (nonatomic, STRONG) NSURL* URL;

+ (SVGKSource*)sourceFromURL:(NSURL*)u;

@end
