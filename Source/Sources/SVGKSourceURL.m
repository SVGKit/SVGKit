#import "SVGKSourceURL.h"

@implementation SVGKSourceURL

- (id)copyWithZone:(NSZone *)zone
{
	return [[SVGKSourceURL alloc] initFromURL:self.URL];
}

- (id)initFromURL:(NSURL*)u
{
	NSInputStream* stream = [NSInputStream inputStreamWithURL:u];
	[stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.URL = u;
	}
	return self;
}

+ (SVGKSource*)sourceFromURL:(NSURL*)u {
	SVGKSourceURL* s = [[[SVGKSourceURL alloc] initFromURL:u] autorelease];
	
	return s;
}

- (void)dealloc {
	self.URL = nil;
	
	[super dealloc];
}

@end
