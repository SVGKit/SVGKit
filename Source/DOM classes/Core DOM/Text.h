/*
 SVG-DOM, via Core DOM:
 
 http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-1312295772
 
 interface Text : CharacterData {
 Text               splitText(in unsigned long offset)
 raises(DOMException);
 };
*/

#import <Foundation/Foundation.h>

//@class CharacterData;
#import <SVGKit/CharacterData.h>

@interface Text : CharacterData

- (instancetype)initWithValue:(NSString*) v NS_DESIGNATED_INITIALIZER;

-(Text*) splitText:(NSUInteger) offset;

@end
