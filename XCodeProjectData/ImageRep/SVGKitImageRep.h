//
//  SVGKitImageRep.h
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

//This will cause problems...
#define Comment AIFFComment
#include <CoreServices/CoreServices.h>
#undef Comment

#import <Cocoa/Cocoa.h>
#import "SVGKit.h"

@interface SVGKitImageRep : NSImageRep

@property (nonatomic, retain) SVGKImage *image;

- (id)initWithData:(NSData *)theData;
- (id)initWithURL:(NSURL *)theURL;
- (id)initWithPath:(NSString *)thePath;

@end
