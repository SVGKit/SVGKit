/**
 
 */
#import <SVGKit/SVGKSource.h>

@interface SVGKSourceURL : SVGKSource <NSCopying>

@property (readonly, nonatomic, strong) NSURL* URL;

- (id)initFromURL:(NSURL*)u DEPRECATED_ATTRIBUTE;
- (instancetype)initWithURL:(NSURL*)u NS_DESIGNATED_INITIALIZER;
+ (SVGKSource*)sourceFromURL:(NSURL*)u;

@end
