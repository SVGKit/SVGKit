#import "SVGKSourceString.h"

@implementation SVGKSourceString

+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString {
	SVGKSourceString *s = nil;
	@autoreleasepool {
		NSInputStream* stream = [NSInputStream inputStreamWithData:[rawString dataUsingEncoding:NSUTF8StringEncoding]];
		[stream open];
		
		s = [[SVGKSourceString alloc] initWithInputSteam:stream];
		s.rawString = rawString;
	}
	return s;
}

@end
