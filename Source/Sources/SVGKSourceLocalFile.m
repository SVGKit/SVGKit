#import "SVGKSourceLocalFile.h"

@interface SVGKSourceLocalFile ()
@property (readwrite, nonatomic, copy) NSString* filePath;
@end

@implementation SVGKSourceLocalFile

- (id)copyWithZone:(NSZone *)zone
{
	return [[SVGKSourceLocalFile alloc] initFromFilename:self.filePath];
}

- (id)initFromFilename:(NSString*)p
{
	NSInputStream* stream = [NSInputStream inputStreamWithFileAtPath:p];
	[stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.filePath = p;
	}
	return self;
}

+ (SVGKSource*)sourceFromFilename:(NSString*)p {
	SVGKSourceLocalFile* s = [[SVGKSourceLocalFile alloc] initFromFilename:p];
		
	return s;
}


@end
