/**
 SVGShapeElement
 
 NB: half of this class is stored in the secret header file "SVGShapeElement+Private". Due to bugs in
 Apple's Xcode, you may not be able to view that file - or come back to the class file - using the
 standard Xcode controls
 
 The majority of real-world SVG elements are Shapes: arbitrary shapes made out of line segments, curves, etc.
 
 Co-ordinate system
 ---

 Many SVG files have poor internal formatting. We deliberately DO NOT FIX THEM (maybe a future feature).
 
 We store the EXACT WAY THE SVG SHAPE WAS SPECIFIED. If that means the parent had no transform (even though it
 obviously should have done), we leave it that way.
 
 
 Data:
 - "pathRelative": the actual path as parsed from the original file. THIS MIGHT NOT BE NORMALISED (maybe a future feature)
 
 - "opacity", "fillColor", "strokeColor", "strokeWidth", "fillPattern", "fillType": SVG info telling you how to paint the shape
 */

#import "SVGElement.h"
#import "SVGLayeredElement.h"
#import "SVGUtils.h"

@class SVGGradientElement;
@class SVGKPattern;

typedef enum {
	SVGFillTypeNone = 0,
	SVGFillTypeSolid,
} SVGFillType;

@interface SVGShapeElement : SVGElement < SVGLayeredElement > { }

@property (nonatomic, readwrite) CGFloat opacity;

@property (nonatomic, readwrite) SVGFillType fillType;
@property (nonatomic, readwrite) SVGColor fillColor;
@property (nonatomic, readwrite, retain) SVGKPattern* fillPattern;

@property (nonatomic, readwrite) CGFloat strokeWidth;
@property (nonatomic, readwrite) SVGColor strokeColor;

@property (nonatomic, readonly) CGPathRef pathRelative;

/*!
 The provided path will be cloned, and set as the new "pathRelative"
 
 The provided path MUST already be in the local co-ordinate space, i.e. when rendering,
 0,0 in this path will be transformed by the local transform, and the parent's
 transform, and all grandparents in the tree, etc
 */
- (void)setPathByCopyingPathFromLocalSpace:(CGPathRef)aPath;

@end
