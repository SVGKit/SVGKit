#import "SVGKSourceLocalFile.h"

@implementation SVGKSourceLocalFile

+ (SVGKSource*)sourceFromFilename:(NSString*)p {
	NSInputStream* stream = [NSInputStream inputStreamWithFileAtPath:p];
	[stream open];
	
	SVGKSourceLocalFile* s = [[SVGKSourceLocalFile alloc] initWithInputSteam:stream];
	s.filePath = p;
	
	return s;
}


@end
