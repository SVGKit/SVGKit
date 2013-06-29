//
//  SVGKitImageRep.h
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import <Cocoa/Cocoa.h>
#import "SVGKImage.h"

@interface SVGKImageRep : NSImageRep
@property (nonatomic, retain, readonly) SVGKImage *image;

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

+ (void)loadSVGKImageRep;
+ (void)unloadSVGKImageRep;

- (id)initWithSVGSource:(SVGKSource*)theSource;
- (id)initWithSVGImage:(SVGKImage*)theImage;
+ (id)imageRepWithSVGSource:(SVGKSource*)theSource;
+ (id)imageRepWithSVGImage:(SVGKImage*)theImage;

@end

//Deprecated functions: DO NOT USE
@interface SVGKImageRep (deprecated)
- (id)initWithPath:(NSString *)thePath DEPRECATED_ATTRIBUTE;
- (id)initWithURL:(NSURL *)theURL DEPRECATED_ATTRIBUTE;
@end
