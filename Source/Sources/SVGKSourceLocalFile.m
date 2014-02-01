#import "SVGKSourceLocalFile.h"

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
	[stream open];
	
	SVGKSourceLocalFile* s = [[[SVGKSourceLocalFile alloc] initWithInputSteam:stream] autorelease];
	s.filePath = p;
	s.approximateLengthInBytesOr0 = [self sizeInBytesOfFilePath:p];
	
	return s;
}

- (SVGKSource *)sourceFromRelativePath:(NSString *)relative {
    NSString *absolute = [[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:relative];
    if ([[NSFileManager defaultManager] fileExistsAtPath:absolute])
        return [SVGKSourceLocalFile sourceFromFilename:absolute];
    return nil;
}

- (void)dealloc {
	self.filePath = nil;
	[super dealloc];
}

@end
