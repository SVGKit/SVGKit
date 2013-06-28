#import "SVGKSource.h"
#import "SVGKSourceLocalFile.h"
#import "SVGKSourceURL.h"
#import "SVGKSourceData.h"

@interface SVGKSource ()
@property (readwrite, nonatomic, retain) NSInputStream* stream;
@end

@implementation SVGKSource

@synthesize svgLanguageVersion;
@synthesize stream;

- (id)initWithInputSteam:(NSInputStream*)s {
	self = [super init];
	if (!self)
		return nil;
	
	self.stream = s;
	return self;
}

+ (SVGKSource*)sourceFromFilename:(NSString*)p
{
	return [SVGKSourceLocalFile sourceFromFilename:p];
}

+ (SVGKSource*)sourceFromURL:(NSURL*)u
{
	return [SVGKSourceURL sourceFromURL:u];
}

+ (SVGKSource*)sourceFromData:(NSData*)data {
	return [SVGKSourceData sourceFromData:data];
}

+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString {
	return [self sourceFromData:[rawString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)dealloc {
	self.svgLanguageVersion = nil;
	self.stream = nil;
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	if ([self isMemberOfClass:[SVGKSource class]]) {
		DDLogError(@"[%@] ERROR: %@ does not implement %@. You will need to get the data to make a new SVGKSource object some other way.", [self class], [self class], NSStringFromSelector(_cmd));
		[self doesNotRecognizeSelector:_cmd];
	} else {
		DDLogError(@"[%@] ERROR: %@ from class %@ should be in a subclass!", [self class], NSStringFromSelector(_cmd), [SVGKSource class]);
	}
	
	return nil;
}

@end
