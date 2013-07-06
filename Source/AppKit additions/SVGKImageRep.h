//
//  SVGKitImageRep.h
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import <AppKit/AppKit.h>
@class SVGKImage;
@class SVGKSource;

@interface SVGKImageRep : NSImageRep
@property (nonatomic, strong, readonly) SVGKImage *image;

//Function used by NSImageRep to init.
+ (id)imageRepWithData:(NSData *)d;
+ (id)imageRepWithContentsOfFile:(NSString *)filename;
+ (id)imageRepWithContentsOfURL:(NSURL *)url;
+ (id)imageRepWithSVGImage:(SVGKImage*)theImage;
+ (id)imageRepWithSVGSource:(SVGKSource*)theSource;

- (id)initWithData:(NSData *)theData;
- (id)initWithContentsOfURL:(NSURL *)theURL;
- (id)initWithContentsOfFile:(NSString *)thePath;
- (id)initWithSVGString:(NSString *)theString;
- (id)initWithSVGImage:(SVGKImage*)theImage;
- (id)initWithSVGSource:(SVGKSource*)theSource;

- (NSData *)TIFFRepresentation;
- (NSData *)TIFFRepresentationWithSize:(NSSize)theSize;
- (NSData *)TIFFRepresentationUsingCompression:(NSTIFFCompression)comp factor:(float)factor;
- (NSData *)TIFFRepresentationUsingCompression:(NSTIFFCompression)comp factor:(float)factor size:(NSSize)asize;

+ (void)loadSVGKImageRep;
+ (void)unloadSVGKImageRep;

@end
