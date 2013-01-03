#import "SVGRect.h"

CGRect CGRectFromSVGRect( SVGRect rect )
{
	CGRect result = CGRectMake(rect.x, rect.y, rect.width, rect.height);
	
	return result;
}