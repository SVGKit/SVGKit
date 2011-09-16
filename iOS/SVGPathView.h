//
//  SVGPathView.h
//  ElectionMeterDemo
//
//  Created by Steven Fusco on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SVGView.h"

@class SVGPathElement;

@protocol SVGPathViewDelegate;

@interface SVGPathView : SVGView
{
    
}

@property (readwrite,nonatomic,assign) id<SVGPathViewDelegate> delegate;

@end


@protocol SVGPathViewDelegate <NSObject>

@optional

- (void) pathView:(SVGPathView*)v pathTouched:(SVGPathElement*)path atPoint:(CGPoint)p;

@end