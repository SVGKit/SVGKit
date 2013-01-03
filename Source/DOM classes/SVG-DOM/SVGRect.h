/*
 http://www.w3.org/TR/SVG/types.html#InterfaceSVGRect
 
 interface SVGRect {
 attribute float x setraises(DOMException);
 attribute float y setraises(DOMException);
 attribute float width setraises(DOMException);
 attribute float height setraises(DOMException);
 };
 */
#import <Foundation/Foundation.h>

#import <CoreGraphics/CoreGraphics.h>

typedef struct
{
	float x;
	float y;
	float width;
	float height;
} SVGRect;

CGRect CGRectFromSVGRect( SVGRect rect );