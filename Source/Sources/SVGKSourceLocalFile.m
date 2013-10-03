#import <SVGKit/SVGKSourceLocalFile.h>
#import "SVGKSource-private.h"

@interface SVGKSourceLocalFile ()
@property (readwrite, nonatomic, copy) NSString* filePath;
@end

@implementation SVGKSourceLocalFile

- (id)copyWithZone:(NSZone *)zone
{
	return [[SVGKSourceLocalFile alloc] initWithFilename:self.filePath];
}

- (id)initFromFilename:(NSString*)p
{
	return [self initWithFilename:p];
}

- (id)initWithFilename:(NSString*)p
{
	NSInputStream* stream = [[NSInputStream alloc] initWithFileAtPath:p];
	[stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.filePath = p;
	}
	[stream release];
	return self;
}

+ (SVGKSource*)sourceFromFilename:(NSString*)p {
	SVGKSourceLocalFile* s = [[[SVGKSourceLocalFile alloc] initWithFilename:p] autorelease];
		
	return s;
}

- (void)dealloc {
	self.filePath = nil;
	[super dealloc];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@, file path: %@", [self debugDescription], self.filePath];
}

@end
