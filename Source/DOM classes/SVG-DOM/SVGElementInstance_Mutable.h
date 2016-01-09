#import "SVGElementInstance.h"

@interface SVGElementInstance ()
@property(nonatomic,assign /*weak*/, readwrite) SVGElement* correspondingElement;
@property(nonatomic,assign /*weak*/, readwrite) SVGUseElement* correspondingUseElement;
@property(nonatomic,retain, readwrite) SVGElementInstance* parentNode;
@property(nonatomic,retain, readwrite) SVGElementInstanceList* childNodes;
@end
