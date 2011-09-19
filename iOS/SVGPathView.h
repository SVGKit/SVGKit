//
//  SVGPathView.h
//  ElectionMeterDemo
//
//  Created by Steven Fusco on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CAShapeLayer.h>

#import "SVGView.h"

@class SVGPathElement;

@protocol SVGPathViewDelegate;

@interface SVGPathView : SVGView
{
    
}

/** Initializes the view with a copy of the path element selected.
 @param pathElement a path element either manually created or extracted from another document
 @param shouldTranslate if YES, will translate the path existing in the other document to match toward the origin so that the drawing will have an origin at 0,0 rather than where it was in the original document
 */
- (id)initWithPathElement:(SVGPathElement*)pathElement translateTowardOrigin:(BOOL)shouldTranslate;

- (CAShapeLayer*) pathElementLayer;

@property (readwrite,nonatomic,assign) id<SVGPathViewDelegate> delegate;
@property (readonly) SVGPathElement* pathElement;

@end


@protocol SVGPathViewDelegate <NSObject>

@optional

- (void) pathView:(SVGPathView*)v pathTouched:(SVGPathElement*)path atPoint:(CGPoint)p;

@end