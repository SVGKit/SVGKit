#import <SVGKit/SVGElementInstance.h>

@interface SVGElementInstance ()
@property(nonatomic,strong, readwrite) SVGElement* correspondingElement;
@property(nonatomic,strong, readwrite) SVGUseElement* correspondingUseElement;
@property(nonatomic,strong, readwrite) SVGElementInstance* parentNode;
@property(nonatomic,strong, readwrite) SVGElementInstanceList* childNodes;
@end
