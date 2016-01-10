#import "SVGElementInstance.h"

@interface SVGElementInstance ()
@property(nonatomic,weak /*weak*/, readwrite) SVGElement* correspondingElement;
@property(nonatomic,weak /*weak*/, readwrite) SVGUseElement* correspondingUseElement;
@property(nonatomic,strong, readwrite) SVGElementInstance* parentNode;
@property(nonatomic,strong, readwrite) SVGElementInstanceList* childNodes;
@end
