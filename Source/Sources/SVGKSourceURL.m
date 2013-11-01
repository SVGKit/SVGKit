#import "SVGKSourceURL.h"

@implementation SVGKSourceURL

+ (SVGKSource*)sourceFromURL:(NSURL*)u {
	NSInputStream* stream = [NSInputStream inputStreamWithURL:u];
	[stream open];
	
	SVGKSourceURL* s = [[[SVGKSourceURL alloc] initWithInputSteam:stream] autorelease];
	s.URL = u;
	
	return s;
}

- (SVGKSource *)sourceFromRelativePath:(NSString *)path {
    NSURL *url = [[self.URL URLByDeletingLastPathComponent] URLByAppendingPathComponent:path];
    return [SVGKSourceURL sourceFromURL:url];
}

- (void)dealloc {
	self.URL = nil;
	[super dealloc];
}

@end
