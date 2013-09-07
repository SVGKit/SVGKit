#import "SVGKSource.h"


@implementation SVGKSource

@synthesize svgLanguageVersion;
@synthesize stream;

- (id)initWithInputSteam:(NSInputStream*)s {
	self = [super init];
	if (!self)
		return nil;
	
	self.stream = s;
	return self;
}

- (void)dealloc {
	self.svgLanguageVersion = nil;
	self.stream = nil;
	[super dealloc];
}

@end
