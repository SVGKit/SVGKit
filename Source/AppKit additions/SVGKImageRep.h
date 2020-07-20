//
//  SVGKitImageRep.h
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import "SVGKDefine.h"

#if SVGKIT_MAC
#import <Cocoa/Cocoa.h>
@class SVGKImage;
@class SVGKSource;

@interface SVGKImageRep : NSImageRep
@property (nonatomic, strong, readonly) SVGKImage *image;

//Function used by NSImageRep to init.
+ (instancetype)imageRepWithData:(NSData *)d;
+ (instancetype)imageRepWithContentsOfFile:(NSString *)filename;
+ (instancetype)imageRepWithContentsOfURL:(NSURL *)url;
+ (instancetype)imageRepWithSVGImage:(SVGKImage*)theImage;
+ (instancetype)imageRepWithSVGSource:(SVGKSource*)theSource;

- (instancetype)initWithData:(NSData *)theData;
- (instancetype)initWithContentsOfURL:(NSURL *)theURL;
- (instancetype)initWithContentsOfFile:(NSString *)thePath;
- (instancetype)initWithSVGString:(NSString *)theString;
- (instancetype)initWithSVGImage:(SVGKImage*)theImage;
- (instancetype)initWithSVGSource:(SVGKSource*)theSource;

- (NSData *)TIFFRepresentation;
- (NSData *)TIFFRepresentationWithSize:(NSSize)theSize;
- (NSData *)TIFFRepresentationUsingCompression:(NSTIFFCompression)comp factor:(float)factor;
- (NSData *)TIFFRepresentationUsingCompression:(NSTIFFCompression)comp factor:(float)factor size:(NSSize)asize;

+ (void)loadSVGKImageRep;
+ (void)unloadSVGKImageRep;

@end

#endif /* SVGKIT_MAC */
