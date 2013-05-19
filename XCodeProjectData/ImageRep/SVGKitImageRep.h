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

@property (nonatomic, strong) SVGKImage *image;

@end
