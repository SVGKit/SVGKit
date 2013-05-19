//
//  SVGKitImageRep.h
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import <Cocoa/Cocoa.h>
@class SVGKImage;

@interface SVGKitImageRep : NSImageRep

@property (nonatomic, retain, readonly) SVGKImage *image;

- (id)initWithData:(NSData *)theData;
- (id)initWithURL:(NSURL *)theURL;
- (id)initWithPath:(NSString *)thePath;

@end
