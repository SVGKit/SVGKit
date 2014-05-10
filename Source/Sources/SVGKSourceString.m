#import "SVGKSourceString.h"

@implementation SVGKSourceString

+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString {
	NSInputStream* stream = [NSInputStream inputStreamWithData:[rawString dataUsingEncoding:NSUTF8StringEncoding]];
	[stream open];
	
	SVGKSource* s = [[[SVGKSource alloc] initWithInputSteam:stream] autorelease];
	s.approximateLengthInBytesOr0 = [rawString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
	return s;
}

- (void)dealloc {
	self.rawString = nil;
	[super dealloc];
}
@end
