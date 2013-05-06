
#import "SVGKSource.h"


@implementation SVGKSource

@synthesize svgLanguageVersion;
@synthesize filePath, URL;
@synthesize stream;

+ (SVGKSource*)sourceFromFilename:(NSString*)p {
	NSInputStream* stream = [NSInputStream inputStreamWithFileAtPath:p];
	[stream open];
	
	SVGKSource* s = [[[SVGKSource alloc] initWithInputSteam:stream] autorelease];
	s.filePath = p;
	
	return s;
}

+ (SVGKSource*)sourceFromURL:(NSURL*)u {
	NSInputStream* stream = [NSInputStream inputStreamWithURL:u];
	[stream open];
	
	SVGKSource* s = [[[SVGKSource alloc] initWithInputSteam:stream] autorelease];
	s.URL = u;
	
	return s;
}

+ (SVGKSource*)sourceFromData:(NSData*)data {
	NSInputStream* stream = [NSInputStream inputStreamWithData:data];
	[stream open];
	
	SVGKSource* s = [[[SVGKSource alloc] initWithInputSteam:stream] autorelease];
	return s;
}

- (id)initWithInputSteam:(NSInputStream*)s {
	self = [super init];
	if (!self)
		return nil;
	
	self.stream = s;
	return self;
}

- (void)dealloc {
	self.filePath = nil;
	self.URL = nil;
	self.svgLanguageVersion = nil;
	self.stream = nil;
	[super dealloc];
}

@end
