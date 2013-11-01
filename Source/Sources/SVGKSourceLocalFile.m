#import "SVGKSourceLocalFile.h"

@implementation SVGKSourceLocalFile

+ (SVGKSource*)sourceFromFilename:(NSString*)p {
	NSInputStream* stream = [NSInputStream inputStreamWithFileAtPath:p];
	[stream open];
	
	SVGKSourceLocalFile* s = [[[SVGKSourceLocalFile alloc] initWithInputSteam:stream] autorelease];
	s.filePath = p;
	
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
