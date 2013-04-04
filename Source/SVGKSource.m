
#import "SVGKSource.h"

@implementation SVGKSourceFileReader
-(void) setFileHandle:(FILE*) f
{
    fileHandle = f;
}

-(FILE*) fileHandle
{
    return fileHandle;
}
@end

@implementation SVGKSourceURLReader
@synthesize httpDataFullyDownloaded;
@end


@implementation SVGKSource

@synthesize svgLanguageVersion;
@synthesize hasSourceFile, hasSourceURL;
@synthesize filePath, URL;

+(SVGKSource*) sourceFromFilename:(NSString*) p
{
	SVGKSource* d = [[[SVGKSource alloc] init] autorelease];
	
	d.hasSourceFile = TRUE;
	d.filePath = p;
	
	return d;
}

+(SVGKSource*) sourceFromURL:(NSURL*) u
{
	SVGKSource* d = [[[SVGKSource alloc] init] autorelease];
	
	d.hasSourceURL = TRUE;
	d.URL = u;
	
	return d;
}

-(NSObject<SVGKSourceReader>*) newReader:(NSError**) error
{
	/**
	 Is this file being loaded from disk?
	 Or from network?
	 */
	if( self.hasSourceURL )
	{
		/**
		 NB:
		 
		 Currently reads the ENTIRE web file synchronously, holding the entire
		 thing in memory.
		 
		 Not efficient, might crash for 'huge' files (would need to be large numbers of megabytes, though)
		 
		 But ... since we want a synchronous parse ... 
		 */
		NSURLResponse* response;
		NSData* httpData = nil;
		
		NSURLRequest* request = [NSURLRequest requestWithURL:self.URL];
		
		httpData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
		
		if( httpData == nil )
		{
			NSLog( @"[%@] ERROR: failed to parse SVG from URL, because failed to download file at URL = %@, error = %@", [self class], self.URL, *error );
			return nil;
		}
		
        SVGKSourceURLReader* urlReader = [[SVGKSourceURLReader alloc] init];
        urlReader.httpDataFullyDownloaded = httpData;
        
		return urlReader;
	}
	else
	{
		FILE *file; // C is wonderful (ly obscure, with mem management)
		const char *cPath = [self.filePath fileSystemRepresentation];
		file = fopen(cPath, "r");
		
		if (!file)
		{
			if( error != nil )
				*error = [NSError errorWithDomain:@"SVGKit" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																		 [NSString stringWithFormat:@"Couldn't open the file %@ for reading", self.filePath], NSLocalizedDescriptionKey,
																		 nil]];
		}
		
        SVGKSourceFileReader* fileReader = [[SVGKSourceFileReader alloc] init];
        fileReader.fileHandle = file;
        
		return fileReader;
	}

}

-(void) closeReader:(NSObject<SVGKSourceReader>*) reader
{
	/**
	 Is this file being loaded from disk?
	 Or from network?
	 */
	if( self.hasSourceURL )
	{
		// nothing needed - the asynch call was already complete
	}
	else
	{
		fclose([((SVGKSourceFileReader*)reader) fileHandle]);
	}
}

-(int) reader:(NSObject<SVGKSourceReader>*) reader readNextChunk:(char *) chunk maxBytes:(int) READ_CHUNK_SZ
{
	/**
	 Is this file being loaded from disk?
	 Or from network?
	 */
	if( self.hasSourceURL )
	{
        SVGKSourceURLReader* urlReader = (SVGKSourceURLReader*) reader;
        
		const char* dataAsBytes = [urlReader.httpDataFullyDownloaded bytes];
		NSUInteger dataLength = [urlReader.httpDataFullyDownloaded length];
		
		NSUInteger actualBytesCopied = MIN( dataLength, READ_CHUNK_SZ );
		memcpy( chunk, dataAsBytes, actualBytesCopied);
		
		/** trim the copied bytes out of the 'handle' NSData object */
		NSRange newRange = { actualBytesCopied, dataLength - actualBytesCopied };
		urlReader.httpDataFullyDownloaded = [urlReader.httpDataFullyDownloaded subdataWithRange:newRange];
		
		return (int)actualBytesCopied;
	}
	else
	{
        SVGKSourceFileReader* fileReader = (SVGKSourceFileReader*) reader;
        
		size_t bytesRead = 0;

		bytesRead = fread(chunk, 1, READ_CHUNK_SZ, [fileReader fileHandle]);
		
		return (int)bytesRead;
	}
}


@end
