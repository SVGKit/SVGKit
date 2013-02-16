#import "SVGElementInstance.h"

@interface SVGElementInstance ()
@property(nonatomic,retain, readwrite) SVGElement* correspondingElement;
@property(nonatomic,retain, readwrite) SVGUseElement* correspondingUseElement;
@property(nonatomic,retain, readwrite) SVGElementInstance* parentNode;
@property(nonatomic,retain, readwrite) SVGElementInstanceList* childNodes;
@end
