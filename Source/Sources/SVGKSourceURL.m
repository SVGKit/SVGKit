#import "SVGKSourceURL.h"

@implementation SVGKSourceURL

+ (SVGKSource*)sourceFromURL:(NSURL*)u {
	NSInputStream* stream = [NSInputStream inputStreamWithURL:u];
	[stream open];
	
	SVGKSourceURL* s = [[[SVGKSourceURL alloc] initWithInputSteam:stream] autorelease];
	s.URL = u;
	
	return s;
}

- (void)dealloc {
	self.URL = nil;
	[super dealloc];
}

@end
