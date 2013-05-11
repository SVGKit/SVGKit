#import "SVGKSourceURL.h"

@implementation SVGKSourceURL

+ (SVGKSource*)sourceFromURL:(NSURL*)u {
	NSInputStream* stream = [NSInputStream inputStreamWithURL:u];
	[stream open];
	
	SVGKSourceURL* s = [[SVGKSourceURL alloc] initWithInputSteam:stream];
	s.URL = u;
	
	return s;
}


@end
