#import <Foundation/Foundation.h>

#import <SVGKit/SVGTextPositioningElement.h>
#import <SVGKit/SVGLayeredElement.h>
#import <SVGKit/SVGTransformable.h>

/**
 http://www.w3.org/TR/2011/REC-SVG11-20110816/text.html#TextElement
 
 interface SVGTextElement : SVGTextPositioningElement, SVGTransformable
 */
@interface SVGTextElement : SVGTextPositioningElement <SVGTransformable, SVGLayeredElement>

@end
