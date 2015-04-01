#import "SampleFileInfo.h"

@implementation SampleFileInfo

+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f source:(NSURL*) s
{
	SampleFileInfo* value = [[SampleFileInfo new] autorelease];
	
	value.filename = f;
	value.source = s;
	
	return value;
}
@end
