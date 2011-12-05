#import <Foundation/Foundation.h>

#import "SVGDocument.h"

/*!
 * CALayer can't be stored in NSDictionary as a key. Instead, the SVGParser stores the
 * returned layer has - as its "name" property - the "identifier" property of the SVGElement that created it
 */
@interface SVGDocumentView : NSObject
{
    
}

+(SVGDocumentView*) documentViewWithDocument:(SVGDocument*) d;

-(id) initWithDocument:(SVGDocument*) d;

@property(nonatomic,retain, readonly) SVGDocument* svg;
@property(nonatomic,retain, readonly) CALayer* rootLayer;
@property(nonatomic,retain, readonly) NSMutableDictionary* layersByElementId;

@end
