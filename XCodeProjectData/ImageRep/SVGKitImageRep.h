//
//  SVGKitImageRep.h
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import <Cocoa/Cocoa.h>

@interface SVGKitImageRep : NSImageRep

//Function used by NSImageRep to init.
+ (id)imageRepWithData:(NSData *)d;

+ (id)imageRepWithContentsOfFile:(NSString *)filename;
+ (id)imageRepWithContentsOfURL:(NSURL *)url;

- (id)initWithData:(NSData *)theData;
- (id)initWithContentsOfURL:(NSURL *)theURL;
- (id)initWithContentsOfFile:(NSString *)thePath;
- (id)initWithSVGString:(NSString *)theString;
- (NSData *)TIFFRepresentation;
- (NSData *)TIFFRepresentationWithSize:(NSSize)theSize;
- (NSData *)TIFFRepresentationUsingCompression:(NSTIFFCompression)comp factor:(float)factor;
- (NSData *)TIFFRepresentationUsingCompression:(NSTIFFCompression)comp factor:(float)factor size:(NSSize)asize;

@end

//Deprecated functions: DO NOT USE
@interface SVGKitImageRep (deprecated)
- (id)initWithPath:(NSString *)thePath DEPRECATED_ATTRIBUTE;
- (id)initWithURL:(NSURL *)theURL DEPRECATED_ATTRIBUTE;
@end
