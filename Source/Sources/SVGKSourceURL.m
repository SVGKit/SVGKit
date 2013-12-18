#import <SVGKit/SVGKSourceURL.h>
#import "SVGKSource-private.h"

@interface SVGKSourceURL ()
@property (readwrite, nonatomic, retain) NSURL* URL;
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
	[stream release];
	return self;
}

+ (SVGKSource*)sourceFromURL:(NSURL*)u {
	SVGKSourceURL* s = [[[SVGKSourceURL alloc] initWithURL:u] autorelease];
	
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

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@, URL: %@", [self baseDescription], self.URL];
}

@end
