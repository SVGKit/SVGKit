/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceURL : SVGKSource <NSCopying>

@property (readonly, nonatomic, strong) NSURL* URL;

- (id)initFromURL:(NSURL*)u;
+ (SVGKSource*)sourceFromURL:(NSURL*)u;

@end
