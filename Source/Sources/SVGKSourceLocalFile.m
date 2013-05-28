#import "SVGKSourceLocalFile.h"

@implementation SVGKSourceLocalFile

@synthesize filePath = _filePath;
- (void)setFilePath:(NSString *)filePath
{
	if (_filePath != filePath) {
		[_filePath release];
		_filePath = [[NSString alloc] initWithString:filePath];
	}
}

+ (SVGKSource*)sourceFromFilename:(NSString*)p {
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
