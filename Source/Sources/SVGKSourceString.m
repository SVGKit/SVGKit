#import "SVGKSourceString.h"
#import "SVGKSource-private.h"

@interface SVGKSourceString ()
@property (nonatomic, retain, readwrite) NSString* rawString;
@end

@implementation SVGKSourceString

- (id)initWithString:(NSString*)theStr
{
	NSString *tmpStr = [[NSString alloc] initWithString:theStr];
	NSInputStream* stream = [[NSInputStream alloc] initWithData:[tmpStr dataUsingEncoding:NSUTF8StringEncoding]];
	[stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.rawString = tmpStr;
	}
	
	return self;
}

+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString
{
	SVGKSourceString *s = [[self alloc] initWithString:rawString];
	
	return s;
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[[self class] alloc] initWithString:self.rawString];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@, string length: %lu", [self baseDescription], (unsigned long)[self.rawString length]];
}

- (NSString*)debugDescription
{
	return [NSString stringWithFormat:@"%@, string: %@", [self baseDescription], self.rawString];
}

@end
