#import "SVGElementInstance.h"

@interface SVGElementInstance ()
@property(nonatomic, STRONG, readwrite) SVGElement* correspondingElement;
@property(nonatomic, STRONG, readwrite) SVGUseElement* correspondingUseElement;
@property(nonatomic, STRONG, readwrite) SVGElementInstance* parentNode;
@property(nonatomic, STRONG, readwrite) SVGElementInstanceList* childNodes;
@end
