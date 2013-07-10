#import <SVGKit/SVGKSourceURL.h>
#import "SVGKSource-private.h"

@interface SVGKSourceURL ()
@property (readwrite, nonatomic, strong) NSURL* URL;
@end

@implementation SVGKSourceURL

- (id)copyWithZone:(NSZone *)zone
{
	return [[SVGKSourceURL alloc] initWithURL:self.URL];
}

- (id)initFromURL:(NSURL*)u
{
	return [self initWithURL:u];
}

- (id)initWithURL:(NSURL*)u
{
	NSInputStream* stream = [[NSInputStream alloc] initWithURL:u];
	[stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.URL = u;
	}
	return self;
}

+ (SVGKSource*)sourceFromURL:(NSURL*)u {
	SVGKSourceURL* s = [[SVGKSourceURL alloc] initWithURL:u];
	
	return s;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@, URL: %@", [self baseDescription], self.URL];
}

@end
