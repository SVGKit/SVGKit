#import "SVGKSourceLocalFile.h"

@interface SVGKSourceLocalFile()
@property (nonatomic, readwrite) BOOL wasRelative;
@end

@implementation SVGKSourceLocalFile

+(uint64_t) sizeInBytesOfFilePath:(NSString*) filePath
{
	NSError* errorReadingFileAttributes;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSDictionary* atts = [fileManager attributesOfItemAtPath:filePath error:&errorReadingFileAttributes];
	
	if( atts == nil )
		return -1;
	else
		return atts.fileSize;
}

+ (SVGKSourceLocalFile*)sourceFromFilename:(NSString*)p {
	NSInputStream* stream = [NSInputStream inputStreamWithFileAtPath:p];
	//DO NOT DO THIS: let the parser do it at last possible moment (Apple has threading problems otherwise!) [stream open];
	
	SVGKSourceLocalFile* s = [[[SVGKSourceLocalFile alloc] initWithInputSteam:stream] autorelease];
	s.filePath = p;
	s.approximateLengthInBytesOr0 = [self sizeInBytesOfFilePath:p];
	
	return s;
}

- (SVGKSource *)sourceFromRelativePath:(NSString *)relative {
    NSString *absolute = ((NSURL*)[NSURL URLWithString:relative relativeToURL:[NSURL fileURLWithPath:self.filePath]]).path;
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

- (void)dealloc {
	self.filePath = nil;
	[super dealloc];
}

@end
