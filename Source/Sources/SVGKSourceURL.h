/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceURL : SVGKSource <NSCopying>

@property (readonly, nonatomic, retain) NSURL* URL;

- (id)initFromURL:(NSURL*)u;
+ (SVGKSource*)sourceFromURL:(NSURL*)u;

@end
