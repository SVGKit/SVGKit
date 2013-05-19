//
//  SVGKitImageRep.h
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import <Cocoa/Cocoa.h>

@interface SVGKitImageRep : NSImageRep

- (id)initWithData:(NSData *)theData;
- (id)initWithURL:(NSURL *)theURL;
- (id)initWithPath:(NSString *)thePath;

@end
