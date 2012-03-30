//
//  SVGElement.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SVGUtils.h"

#import "SVGStyleCatcher.h"
@class SVGDocument;

#define EXPERIMENTAL_SUPPORT_FOR_SVG_TRANSFORM_ATTRIBUTES 1

@interface SVGElement : NSObject {
@protected
    
    @protected
    SVGDocument *_document;
  @private
	NSMutableArray *_children;
}

/*! This is used when generating CALayer objects, to store the id of the SVGElement that created the CALayer */
#define kSVGElementIdentifier @"SVGElementIdentifier"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
@property (nonatomic, readonly)  SVGDocument *document;
#else
@property (nonatomic, readonly)  __weak  SVGDocument *document;
#endif

@property (nonatomic, readonly) NSArray *children;
@property (nonatomic, readonly, copy) NSString *stringValue;
@property (nonatomic, readonly) NSString *localName;

@property (nonatomic, readwrite, retain) NSString *identifier; // 'id' is reserved

@property (nonatomic, retain) NSMutableArray* metadataChildren;

#if EXPERIMENTAL_SUPPORT_FOR_SVG_TRANSFORM_ATTRIBUTES
/*! Transform to be applied to this node and all sub-nodes; does NOT take account of any transforms applied by parent / ancestor nodes */
@property (nonatomic) CGAffineTransform transformRelative;
/*! Required by SVG transform and SVG viewbox: you have to be able to query your parent nodes at all times to find out your actual values */
@property (nonatomic, retain) SVGElement *parent;
#endif

+ (BOOL)shouldStoreContent; // to optimize parser, default is NO

- (id)initWithDocument:(SVGDocument *)aDocument name:(NSString *)name;

- (void)loadDefaults; // should be overriden to set element defaults

/*! Parser uses this to add non-rendering-SVG XML tags to the element they were embedded in */
- (void) addMetadataChild:(NSObject*) child;

/*! Overridden by sub-classes.  Be sure to call [super parseAttributes:attributes]; */
- (void)parseAttributes:(NSDictionary *)attributes;

#if EXPERIMENTAL_SUPPORT_FOR_SVG_TRANSFORM_ATTRIBUTES
/*! Re-calculates the absolute transform on-demand by querying parent's absolute transform and appending self's relative transform */
-(CGAffineTransform) transformAbsolute;
#endif

@end

@protocol SVGLayeredElement < NSObject >

/*!
 NB: the returned layer has - as its "name" property - the "identifier" property of the SVGElement that created it;
 but that can be overwritten by applications (for valid reasons), so we ADDITIONALLY store the identifier into a
 custom key - kSVGElementIdentifier - on the CALayer. Because it's a custom key, it's (almost) guaranteed not to be
 overwritten / altered by other application code
 */
- (CALayer *)autoreleasedLayer;
- (void)layoutLayer:(CALayer *)layer;

+(void)trim;

@end
