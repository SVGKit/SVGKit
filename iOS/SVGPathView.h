//
//  SVGPathView.h
//  SVGKit
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CAShapeLayer.h>

#import "SVGView.h"


#if NS_BLOCKS_AVAILABLE

typedef void (^layerTreeEnumerator)(CALayer* child);

#endif

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

#if NS_BLOCKS_AVAILABLE

- (void) enumerateChildLayersUsingBlock:(layerTreeEnumerator)callback;

#endif


@end


@protocol SVGPathViewDelegate <NSObject>

@optional

- (void) pathView:(SVGPathView*)v path:(SVGPathElement*)path touch:(UITouch*)touch;

@end