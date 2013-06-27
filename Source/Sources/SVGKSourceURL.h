/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceURL : SVGKSource <NSCopying>

@property (nonatomic, retain) NSURL* URL;

+ (SVGKSource*)sourceFromURL:(NSURL*)u;

@end
