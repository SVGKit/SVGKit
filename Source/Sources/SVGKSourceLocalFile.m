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
	NSInputStream* stream = [[NSInputStream alloc] initWithFileAtPath:p];
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

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@: Stream: %@, SVG Version: %@, file path: %@", [self class], [self.stream description], [self.svgLanguageVersion description], self.filePath];
}

@end
