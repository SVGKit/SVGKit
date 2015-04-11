#import <Foundation/Foundation.h>

#import "SVGKSource.h"

@interface SampleFileInfo : NSObject

@property(nonatomic,retain) NSString* author, * licenseType, * name;

@property(nonatomic,readonly) SVGKSource* source;

-(SVGKSource*) sourceFromWeb;
-(SVGKSource*) sourceFromLocalFile;

-(NSString*) savedBitmapFilename;

+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f;
+(SampleFileInfo*) sampleFileInfoWithURL:(NSURL*) s;
+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f URL:(NSURL*) s;

@end
