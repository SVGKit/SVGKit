/*
 From SVG-DOM, via Core DOM:
 
 http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-1728279322

 interface Comment : CharacterData {
 };
*/

#import <Foundation/Foundation.h>

#import "SVGKCharacterData.h"

@interface SVGKComment : SVGKCharacterData

- (id)initWithValue:(NSString*) v;

@end
