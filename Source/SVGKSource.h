/**
 SVGKSource.h
  
 SVGKSource represents the info about a file that was read from disk or over the web during parsing.
 
 Once it has been parsed / loaded, that info is NOT PART OF the in-memory SVG any more - if you were to save the file, you could
 save it in a different location, with a different SVG Spec, etc.
 
 However, it's useful for debugging (and for optional "save this document in same place it was loaded from / same format"
 to store this info at runtime just in case it's needed later.
 
 Also, it helps during parsing to keep track of some document-level information
 
 */

#import <Foundation/Foundation.h>

@protocol SVGKSourceReader <NSObject>
@end

@interface SVGKSourceFileReader : NSObject <SVGKSourceReader>
{
    FILE *fileHandle;
}
@end

@interface SVGKSourceURLReader : NSObject <SVGKSourceReader>
@property(nonatomic,retain) NSData* httpDataFullyDownloaded;
@end

@interface SVGKSource : NSObject

@property(nonatomic,retain) NSString* svgLanguageVersion; /*< <svg version=""> */
@property(nonatomic) BOOL hasSourceFile, hasSourceURL;
@property(nonatomic,retain) NSString* filePath;
@property(nonatomic,retain) NSURL* URL;

+(SVGKSource*) sourceFromFilename:(NSString*) p;
+(SVGKSource*) sourceFromURL:(NSURL*) u;

-(NSObject<SVGKSourceReader>*) newReader:(NSError**) error;
-(void) closeReader:(NSObject<SVGKSourceReader>*) reader;
-(int) reader:(NSObject<SVGKSourceReader>*) reader readNextChunk:(char *) chunk maxBytes:(int) READ_CHUNK_SZ;

@end
