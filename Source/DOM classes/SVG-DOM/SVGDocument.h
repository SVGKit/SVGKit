/*
 SVG DOM, cf:
 
 http://www.w3.org/TR/SVG11/struct.html#InterfaceSVGDocument
 
 interface SVGDocument : Document,
 DocumentEvent {
 readonly attribute DOMString title;
 readonly attribute DOMString referrer;
 readonly attribute DOMString domain;
 readonly attribute DOMString URL;
 readonly attribute SVGSVGElement rootElement;
 };
 */

#import <Foundation/Foundation.h>

#import <SVGKit/Document.h>
//#import "SVGSVGElement.h"
@class SVGSVGElement;

@interface SVGDocument : Document

@property (nonatomic, retain, readonly) NSString* title;
@property (nonatomic, retain, readonly) NSString* referrer;
@property (nonatomic, retain, readonly) NSString* domain;
@property (nonatomic, retain, readonly) NSString* URL;
@property (nonatomic, retain, readonly) SVGSVGElement* rootElement;

#pragma mark - Objective-C init methods (not part of DOM spec, but necessary!)

- (id)init;

@end
