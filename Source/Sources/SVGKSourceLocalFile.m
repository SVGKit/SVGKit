#import "SVGKSourceLocalFile.h"

@implementation SVGKSourceLocalFile

+ (SVGKSourceLocalFile*)sourceFromFilename:(NSString*)p {
	NSInputStream* stream = [NSInputStream inputStreamWithFileAtPath:p];
	[stream open];
	
	SVGKSourceLocalFile* s = [[[SVGKSourceLocalFile alloc] initWithInputSteam:stream] autorelease];
	s.filePath = p;
	
	return s;
}

- (void)dealloc {
	self.filePath = nil;
	[super dealloc];
}

@end
