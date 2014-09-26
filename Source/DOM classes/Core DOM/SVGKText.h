/*
 SVG-DOM, via Core DOM:
 
 http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-1312295772
 
 interface Text : CharacterData {
 Text               splitText(in unsigned long offset)
 raises(DOMException);
 };
*/

#import <Foundation/Foundation.h>

@class SVGKCharacterData;
#import "SVGKCharacterData.h"

@interface SVGKText : SVGKCharacterData

- (id)initWithValue:(NSString*) v;

-(SVGKText*) splitText:(unsigned long) offset;

@end
