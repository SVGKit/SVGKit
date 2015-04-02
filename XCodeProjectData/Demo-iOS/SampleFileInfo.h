#import <Foundation/Foundation.h>

@interface SampleFileInfo : NSObject

@property(nonatomic,retain) NSString* author, * filename, * licenseType;
@property(nonatomic,retain) NSURL* source;

+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f source:(NSURL*) s;

@end
