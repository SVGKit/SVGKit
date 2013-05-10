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

@interface SVGKSource : NSObject

@property (nonatomic, strong) NSString* svgLanguageVersion; /*< <svg version=""> */
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSInputStream* stream;

+ (SVGKSource*)sourceFromFilename:(NSString*)p;
+ (SVGKSource*)sourceFromURL:(NSURL*)u;
+ (SVGKSource*)sourceFromData:(NSData*)data;

- (id)initWithInputSteam:(NSInputStream*)stream;

@end
