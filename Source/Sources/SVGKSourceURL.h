/**
 
 */
#import <SVGKit/SVGKSource.h>

@interface SVGKSourceURL : SVGKSource <NSCopying>

@property (readonly, nonatomic, strong) NSURL* URL;

- (id)initFromURL:(NSURL*)u DEPRECATED_ATTRIBUTE;
- (id)initWithURL:(NSURL*)u;
+ (SVGKSource*)sourceFromURL:(NSURL*)u;

@end
