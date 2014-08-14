#import "SVGKSourceString.h"

@implementation SVGKSourceString

+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString {
	NSInputStream* stream = [NSInputStream inputStreamWithData:[rawString dataUsingEncoding:NSUTF8StringEncoding]];
	//DO NOT DO THIS: let the parser do it at last possible moment (Apple has threading problems otherwise!) [stream open];
	
	SVGKSource* s = [[[SVGKSourceString alloc] initWithInputSteam:stream] autorelease];
	s.approximateLengthInBytesOr0 = [rawString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
	return s;
}

- (void)dealloc {
	self.rawString = nil;
	[super dealloc];
}
@end
