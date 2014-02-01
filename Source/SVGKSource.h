/**
 SVGKSource.h
  
 SVGKSource represents the info about where an SVG image's data came from ... from disk, from URL, from raw string - or anywhere
 
 ----
 NOTE: you should avoid instantiating SVGKSource directly; it is better to instantiate one of the subclasses, both because this
 allows faster / more direct reading of raw data, and because it preserves the information about "where" the SVG was loaded from.
 ----
 
 Once it has been parsed / loaded, that info is NOT PART OF the in-memory SVG any more - if you were to save the file, you could
 save it in a different location, with a different SVG Spec, etc.
 
 However, it's useful for debugging (and for optional "save this document in same place it was loaded from / same format"
 to store this info at runtime just in case it's needed later.
 
 Also, it helps during parsing to keep track of some document-level information
 
 */

#import <Foundation/Foundation.h>

@interface SVGKSource : NSObject

@property (nonatomic, STRONG) NSString* svgLanguageVersion; /*< <svg version=""> */
@property (nonatomic, STRONG) NSInputStream* stream;

/** If known, the amount of data in bytes contained in this source (e.g. the filesize for a
 file, or the Content-Length header for a URL). Otherwise "0" for "unknown" */
@property (nonatomic) uint64_t approximateLengthInBytesOr0;

/**
 Subclasses convert their proprietary data into something that implements NSInputStream, which allows the
 base class to handle everything else
 */
- (id)initWithInputSteam:(NSInputStream*)stream;
- (SVGKSource *)sourceFromRelativePath:(NSString *)path;

@end
