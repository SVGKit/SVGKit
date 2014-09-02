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

+ (SVGKSourceURL*)sourceFromURL:(NSURL*)u {
	SVGKSourceURL* s = [[SVGKSourceURL alloc] initWithURL:u];
	
	return s;
}

- (SVGKSource *)sourceFromRelativePath:(NSString *)path {
	NSURL *url = [NSURL URLWithString:path relativeToURL:self.URL];
	return [SVGKSourceURL sourceFromURL:url];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"[SVGKSource: URL = \"%@\"]", self.URL ];
}

@end
