/**
 SVGDocument
 
 SVG spec defines this as part of the DOM version of SVG:
 
 http://www.w3.org/TR/SVG11/struct.html#InterfaceSVGDocument
 */

#import "Document+Mutable.h"
#import "SVGSVGElement.h"
#import "SVGDocument.h"
#import "SVGDocument_Mutable.h"

@implementation SVGDocument


@synthesize title;
@synthesize referrer;
@synthesize domain;
@synthesize URL;
@synthesize rootElement=_rootElement;


- (void)dealloc {
  [title release];
  [referrer release];
  [domain release];
  [URL release];
  [_rootElement release];
  [super dealloc];
}

- (id)init
{
    self = [super initType:DOMNodeType_DOCUMENT_NODE name:@"#document"];
    if (self) {
        
    }
    return self;
}

-(void)setRootElement:(SVGSVGElement *)rootElement
{
	[_rootElement release];
	_rootElement = rootElement;
	[_rootElement retain];
	
	/*! SVG spec has two variables with same name, because DOM was written to support
	 weak programming languages that don't provide full OOP polymorphism.
	 
	 So, we'd better keep the two variables in sync!
	 */
	super.documentElement = rootElement;
}

-(void)setDocumentElement:(Element *)newDocumentElement
{
	NSAssert( [newDocumentElement isKindOfClass:[SVGSVGElement class]], @"Cannot set the documentElement property on an SVG doc unless it's of type SVGSVGDocument" );
	
	super.documentElement = newDocumentElement;
	
	/*! SVG spec has two variables with same name, because DOM was written to support
	 weak programming languages that don't provide full OOP polymorphism.
	 
	 So, we'd better keep the two variables in sync!
	 */
	self.rootElement = (SVGSVGElement*) self.documentElement;
}

@end
