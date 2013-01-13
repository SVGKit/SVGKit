/**
 SVGElement
 
 http://www.w3.org/TR/SVG/types.html#InterfaceSVGElement

 NB: "id" is illegal in Objective-C language, so we use "identifier" instead
 
 
 + NON STANDARD: "transformRelative": identity OR the transform to apply BEFORE rendering this element (and its children)
 
 */
#import <QuartzCore/QuartzCore.h>

#import "Element.h"
#import "Node+Mutable.h"
#import "SVGStylable.h"

#define DEBUG_SVG_ELEMENT_PARSING 0

@class SVGSVGElement;
//obj-c's compiler sucks, and doesn't allow this line: #import "SVGSVGElement.h"

@interface SVGElement : Element <SVGStylable>

@property (nonatomic, readwrite, retain) NSString *identifier; // 'id' is reserved in Obj-C, so we have to break SVG Spec here, slightly
@property (nonatomic, retain) NSString* xmlbase;
/*!
 
 http://www.w3.org/TR/SVG/intro.html#TermSVGDocumentFragment
 
 SVG document fragment
 The XML document sub-tree which starts with an ‘svg’ element. An SVG document fragment can consist of a stand-alone SVG document, or a fragment of a parent XML document enclosed by an ‘svg’ element. When an ‘svg’ element is a descendant of another ‘svg’ element, there are two SVG document fragments, one for each ‘svg’ element. (One SVG document fragment is contained within another SVG document fragment.)
 */
@property (nonatomic, assign) SVGSVGElement* rootOfCurrentDocumentFragment;

/*! The viewport is set / re-set whenever an SVG node specifies a "width" (and optionally: a "height") attribute,
 assuming that SVG node is one of: svg, symbol, image, foreignobject
 
 The spec isn't clear what happens if this element redefines the viewport itself, but IMHO it implies that the
 viewportElement becomes a reference to "self" */
@property (nonatomic, assign) SVGElement* viewportElement;


#pragma mark - NON-STANDARD features of class (these are things that are NOT in the SVG spec, and should NOT be in SVGKit's implementation - they should be moved to a different class, although WE DO STILL NEED THESE in order to implement the spec, and to provide SVGKit features!)

/*! This is used when generating CALayer objects, to store the id of the SVGElement that created the CALayer */
#define kSVGElementIdentifier @"SVGElementIdentifier"


/*! Transform to be applied to this node and all sub-nodes; does NOT take account of any transforms applied by parent / ancestor nodes
 
 FIXME: this method could be removed by some careful refactoring of the code in SVGKImage and its CALayer generation
 code. You need to also refactor / merge the method "transformAbsolute" in the .m file of this class.
 */
@property (nonatomic) CGAffineTransform transformRelative;


#pragma mark - SVG-spec supporting methods that aren't in the Spec itself

- (id)initWithLocalName:(NSString*) n attributes:(NSMutableDictionary*) attributes;
- (id)initWithQualifiedName:(NSString*) n inNameSpaceURI:(NSString*) nsURI attributes:(NSMutableDictionary*) attributes;

-(void) reCalculateAndSetViewportElementReferenceUsingFirstSVGAncestor:(SVGElement*) firstAncestor;

#pragma mark - CSS cascading special attributes. c.f. full list here: http://www.w3.org/TR/SVG/propidx.html

-(NSString*) cascadedValueForStylableProperty:(NSString*) stylableProperty;

/** FIXME: delete all these fake properties, and refactor code to directly call the method these are all delegating to
 FIXME: also - work out what the 'correct' way is to achieve the cascade using DOM-calls in the CSS-DOM specification */
@property(nonatomic,readonly) NSString* cascadedFill, * cascadedFillOpacity, * cascadedStroke, * cascadedStrokeWidth, * cascadedStrokeOpacity;

@end