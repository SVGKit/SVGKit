/*
 http://www.w3.org/TR/SVG/struct.html#InterfaceSVGElementInstance
 
 interface SVGElementInstance : EventTarget {
 readonly attribute SVGElement correspondingElement;
 readonly attribute SVGUseElement correspondingUseElement;
 readonly attribute SVGElementInstance parentNode;
 readonly attribute SVGElementInstanceList childNodes;
 readonly attribute SVGElementInstance firstChild;
 readonly attribute SVGElementInstance lastChild;
 readonly attribute SVGElementInstance previousSibling;
 readonly attribute SVGElementInstance nextSibling;
 */

//#import <SVGKit/SVGElement.h>
//#import <SVGKit/SVGElementInstanceList.h>

#import <Foundation/Foundation.h>

@class SVGElement, SVGElementInstanceList;

@class SVGUseElement;
//#import "SVGUseElement.h"


@interface SVGElementInstance : NSObject


/*The corresponding element to which this object is an instance. For example, if a ‘use’ element references a ‘rect’ element, then an SVGElementInstance is created, with its correspondingElement being the SVGRectElement object for the ‘rect’ element. */
@property(nonatomic,retain, readonly) SVGElement* correspondingElement;


/* The corresponding ‘use’ element to which this SVGElementInstance object belongs. When ‘use’ elements are nested (e.g., a ‘use’ references another ‘use’ which references a graphics element such as a ‘rect’), then the correspondingUseElement is the outermost ‘use’ (i.e., the one which indirectly references the ‘rect’, not the one with the direct reference). */
@property(nonatomic,retain, readonly) SVGUseElement* correspondingUseElement;

/* The parent of this SVGElementInstance within the instance tree. All SVGElementInstance objects have a parent except the SVGElementInstance which corresponds to the element which was directly referenced by the ‘use’ element, in which case parentNode is null. */
@property(nonatomic,retain, readonly) SVGElementInstance* parentNode;

/* An SVGElementInstanceList that contains all children of this SVGElementInstance within the instance tree. If there are no children, this is an SVGElementInstanceList containing no entries (i.e., an empty list). 
firstChild (readonly SVGElementInstance) */
@property(nonatomic,retain, readonly) SVGElementInstanceList* childNodes;


/* The first child of this SVGElementInstance within the instance tree. If there is no such SVGElementInstance, this returns null. */
@property(nonatomic,retain, readonly) SVGElementInstance* firstChild;

/* The last child of this SVGElementInstance within the instance tree. If there is no such SVGElementInstance, this returns null. */
@property(nonatomic,retain, readonly) SVGElementInstance* lastChild;

/* The SVGElementInstance immediately preceding this SVGElementInstance. If there is no such SVGElementInstance, this returns null.  */
@property(nonatomic,retain, readonly) SVGElementInstance* previousSibling;

/* The SVGElementInstance immediately following this SVGElementInstance. If there is no such SVGElementInstance, this returns null. */
@property(nonatomic,retain, readonly) SVGElementInstance* nextSibling;

@end
