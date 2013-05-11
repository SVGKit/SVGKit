/**
 
 */
#import <SVGKit/SVGKSource.h>

@interface SVGKSourceURL : SVGKSource

@property (nonatomic, retain) NSURL* URL;

+ (SVGKSource*)sourceFromURL:(NSURL*)u;

@end
