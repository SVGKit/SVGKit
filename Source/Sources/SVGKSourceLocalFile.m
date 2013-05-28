#import "SVGKSourceLocalFile.h"

@implementation SVGKSourceLocalFile

@synthesize filePath = _filePath;
- (void)setFilePath:(NSString *)filePath
{
	if (_filePath != filePath) {
		[_filePath release];
		if (filePath) {
			_filePath = [[NSString alloc] initWithString:filePath];
		} else {
			_filePath = nil;
		}
	}
}

+ (SVGKSource*)sourceFromFilename:(NSString*)p {
	NSInputStream* stream = [NSInputStream inputStreamWithFileAtPath:p];
	[stream open];
	
	SVGKSourceLocalFile* s = [[SVGKSourceLocalFile alloc] initWithInputSteam:stream];
	s.filePath = p;
	
	return s;
}


@end
