#import "SVGKSourceURL.h"

@interface SVGKSourceURL ()
@property (readwrite, nonatomic, retain) NSURL* URL;
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
	[stream release];
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
