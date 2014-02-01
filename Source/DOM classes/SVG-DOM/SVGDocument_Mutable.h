/**
 Makes the writable properties all package-private, effectively
 */

#import "SVGDocument.h"

@interface SVGDocument ()
@property (nonatomic, STRONG, readwrite) NSString* title;
@property (nonatomic, STRONG, readwrite) NSString* referrer;
@property (nonatomic, STRONG, readwrite) NSString* domain;
@property (nonatomic, STRONG, readwrite) NSString* URL;
@property (nonatomic, STRONG, readwrite) SVGSVGElement* rootElement;
@end
