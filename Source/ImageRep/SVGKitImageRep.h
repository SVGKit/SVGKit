//
//  SVGKitImageRep.h
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import <Cocoa/Cocoa.h>
#import <SVGKit/SVGKit.h>

@interface SVGKitImageRep : NSImageRep

@property (nonatomic, retain) SVGDocument *document;

@end
