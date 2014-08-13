#import "SVGKSourceNSData.h"

#import "SVGKSourceURL.h" // used for delegating when asked to construct relative links

@implementation SVGKSourceNSData

+ (SVGKSource*)sourceFromData:(NSData*)data URLForRelativeLinks:(NSURL*) url
{
	NSInputStream* stream = [NSInputStream inputStreamWithData:data];
	//DO NOT DO THIS: let the parser do it at last possible moment (Apple has threading problems otherwise!) [stream open];
	
	SVGKSourceNSData* s = [[[SVGKSourceNSData alloc] initWithInputSteam:stream] autorelease];
	s.rawData = data;
	s.effectiveURL = url;
	return s;
}

-(SVGKSource *)sourceFromRelativePath:(NSString *)path
{
	if( self.effectiveURL != nil )
	{
		NSURL *url = [NSURL URLWithString:path relativeToURL:self.effectiveURL];
		return [SVGKSourceURL sourceFromURL:url];
	}
	else
	{
		DDLogError(@"Cannot construct a relative link for this SVGKSource; it was created from anonymous NSData with no source URL provided. Source = %@", self);
		return nil;
	}
}

- (void)dealloc {
	self.rawData = nil;
	[super dealloc];
}
@end
