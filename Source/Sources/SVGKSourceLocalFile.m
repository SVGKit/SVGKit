#import "SVGKSourceLocalFile.h"

@implementation SVGKSourceLocalFile

@synthesize filePath = _filePath;
- (void)setFilePath:(NSString *)filePath
{
	if (!filePath) {
		_filePath = nil;
	} else {
		_filePath = [[NSString alloc] initWithString:filePath];
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
