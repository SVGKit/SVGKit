/**
 Makes the writable properties all package-private, effectively
 */

#import <SVGKit/SVGDocument.h>

@interface SVGDocument ()
@property (nonatomic, retain, readwrite) NSString* title;
@property (nonatomic, retain, readwrite) NSString* referrer;
@property (nonatomic, retain, readwrite) NSString* domain;
@property (nonatomic, retain, readwrite) NSString* URL;
@property (nonatomic, retain, readwrite) SVGSVGElement* rootElement;
@end
