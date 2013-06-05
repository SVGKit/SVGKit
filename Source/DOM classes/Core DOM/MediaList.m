#import "MediaList.h"

@implementation MediaList

@synthesize mediaText;
@synthesize length;

- (void)dealloc {
	[mediaText release];
	[super dealloc];
}

-(NSString*) item:(unsigned long) index
{
	NSAssert( FALSE, @"Not implemented yet");
	return nil;
}
-(void) deleteMedium:(NSString*) oldMedium
{
	NSAssert( FALSE, @"Not implemented yet");
}
-(void) appendMedium:(NSString*) newMedium
{
	NSAssert( FALSE, @"Not implemented yet");
}

@end
