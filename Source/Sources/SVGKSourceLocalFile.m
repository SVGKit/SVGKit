#import <SVGKit/SVGKSourceLocalFile.h>
#import "SVGKSource-private.h"

@interface SVGKSourceLocalFile()
@property (nonatomic, readwrite) BOOL wasRelative;
@end

@implementation SVGKSourceLocalFile

- (id)copyWithZone:(NSZone *)zone
{
	return [[SVGKSourceLocalFile alloc] initWithFilename:self.filePath];
}

- (instancetype)initWithFilename:(NSString*)p
{
	NSInputStream* stream = [[NSInputStream alloc] initWithFileAtPath:p];
	[stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.filePath = p;
	}
	return self;
}

+ (SVGKSourceLocalFile*)sourceFromFilename:(NSString*)p {
	SVGKSourceLocalFile* s = [[SVGKSourceLocalFile alloc] initWithFilename:p];
		
	return s;
}

- (SVGKSourceLocalFile *)sourceFromRelativePath:(NSString *)relative {
    NSString *absolute = [[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:relative];
    if ([[NSFileManager defaultManager] fileExistsAtPath:absolute])
	{
       SVGKSourceLocalFile* result = [SVGKSourceLocalFile sourceFromFilename:absolute];
		result.wasRelative = true;
		return result;
	}
    return nil;
}

-(NSString *)description
{
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.filePath];
	return [NSString stringWithFormat:@"File: %@%@\"%@\" (%llu bytes)", self.wasRelative? @"(relative) " : @"", fileExists?@"":@"NOT FOUND!  ", self.filePath, self.approximateLengthInBytesOr0 ];
}

@end
