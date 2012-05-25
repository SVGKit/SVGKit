//
//  SVGStyelCatcher.h
//  StyleTouch
//
//  Created by Kevin Stich on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef StyleTouch_SVGStyelCatcher_h
#define StyleTouch_SVGStyelCatcher_h

@class SVGElement;

@protocol SVGStyleCatcher <NSObject>

//-(void)styleCatchElement:(SVGElement *)styledLayer forClass:(NSString *)colorIndex;
//-(void)styleCatchNewStyle:(NSString *)className;
-(void)styleCatchLayer:(CALayer *)styledLayer forClass:(NSString *)colorIndex;
#if TARGET_OS_IPHONE
-(UIColor *)styleCatchOverrideFill:(NSString *)fillClassName;
#endif
@end



#endif
