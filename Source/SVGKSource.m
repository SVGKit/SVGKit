#import <SVGKit/SVGKSource.h>
#import <SVGKit/SVGKSourceLocalFile.h>
#import <SVGKit/SVGKSourceURL.h>
#import <SVGKit/SVGKSourceData.h>
#import <SVGKit/SVGKSourceString.h>
#import "SVGKSource-private.h"

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
	return [SVGKSourceString sourceFromContentsOfString:rawString];
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

- (NSString*)baseDescription
{
	return [NSString stringWithFormat:@"%@: Stream: %@, SVG Version: %@", [self class], [self.stream description], [self.svgLanguageVersion description]];
}

- (NSString*)description
{
	BOOL isBaseClass = NO;
	if ([self isMemberOfClass:[SVGKSource class]]) {
		isBaseClass = YES;
	}
	return [NSString stringWithFormat:@"%@: %@Stream: %@, SVG Version: %@", [self class], isBaseClass ? @"" : @"(Not base class) ", [self.stream description], [self.svgLanguageVersion description]];
}

@end
