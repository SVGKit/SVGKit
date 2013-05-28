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

- (id)initWithData:(NSData *)theData;
- (id)initWithURL:(NSURL *)theURL;
- (id)initWithPath:(NSString *)thePath;
- (id)initWithSVGString:(NSString *)theString;

@end
