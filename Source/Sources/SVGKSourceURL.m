#import "SVGKSourceURL.h"

@interface SVGKSourceURL ()
@property (readwrite, nonatomic, strong) NSURL* URL;
@end

@implementation SVGKSourceURL

- (id)copyWithZone:(NSZone *)zone
{
	return [[SVGKSourceURL alloc] initFromURL:self.URL];
}

- (id)initFromURL:(NSURL*)u
{
	NSInputStream* stream = [[NSInputStream alloc] initWithURL:u];
	[stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.URL = u;
	}
	return self;
}

+ (SVGKSource*)sourceFromURL:(NSURL*)u {
	SVGKSourceURL* s = [[SVGKSourceURL alloc] initFromURL:u];
	
	return s;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@: Stream: %@, SVG Version: %@, URL: %@", [self class], [self.stream description], [self.svgLanguageVersion description], self.URL];
}

@end
