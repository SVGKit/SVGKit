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
+ (NSImageRep *)imageRepWithData:(NSData *)d;

+ (id)imageRepWithContentsOfFile:(NSString *)filename;
+ (id)imageRepWithContentsOfURL:(NSURL *)url;

- (id)initWithData:(NSData *)theData;
- (id)initWithContentsOfURL:(NSURL *)theURL;
- (id)initWithContentsOfFile:(NSString *)thePath;
- (id)initWithSVGString:(NSString *)theString;
- (NSData *)TIFFRepresentation;
- (NSData *)TIFFRepresentationUsingCompression:(NSTIFFCompression)comp factor:(float)factor;

@end
