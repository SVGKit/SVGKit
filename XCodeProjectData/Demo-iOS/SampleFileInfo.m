#import "SampleFileInfo.h"

#import "SVGKSourceLocalFile.h"
#import "SVGKSourceURL.h"

@interface SampleFileInfo ()
@property(nonatomic,retain) NSString* originalFilename;
@property(nonatomic,retain) NSURL* originalURL;
@end

@implementation SampleFileInfo

+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f
{
	return [self sampleFileInfoWithFilename:f URL:nil name:f];
}

+(SampleFileInfo*) sampleFileInfoWithURL:(NSURL*) s
{
	return [self sampleFileInfoWithFilename:nil URL:s name:[s relativeString]];
}

+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f URL:(NSURL*) s
{
	return [self sampleFileInfoWithFilename:f URL:s name:(f!=nil) ? f : [s relativeString]];
}

+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f URL:(NSURL*) s name:(NSString*) n
{
	SampleFileInfo* value = [[SampleFileInfo new] autorelease];
	
	value.originalFilename = f;
	value.originalURL = s;
	
	value.name = n;
	
	return value;
}

-(SVGKSource *)source
{
	if( self.originalFilename != nil )
		return [self sourceFromLocalFile];
	else if( self.originalURL != nil )
		return [self sourceFromWeb];
	else
	{
//		D(false, @"Cannot return an SVGKSource; no valid filename nor url");
		return nil;
	}
}

-(SVGKSource *)sourceFromLocalFile
{
	return [SVGKSourceLocalFile internalSourceAnywhereInBundleUsingName:self.originalFilename];
}

-(SVGKSource *)sourceFromWeb
{
	return [SVGKSourceURL sourceFromURL:self.originalURL];
}

-(NSString *)savedBitmapFilename
{
	if( self.originalFilename != nil )
	{
		return [self.originalFilename stringByDeletingPathExtension];
	}
	else if( self.originalURL != nil )
	{
		return [[self.originalURL relativeString] stringByDeletingPathExtension];
	}
	else
		return nil;
}

@end
