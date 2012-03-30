//
//  SVGElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGElement.h"
#import "SVGUtils.h"

@interface SVGElement ()

@property (nonatomic, copy) NSString *stringValue;

@end

/*! main class implementation for the base SVGElement: NOTE: in practice, most of the interesting
 stuff happens in subclasses, e.g.:
 
 SVGShapeElement
 SVGGroupElement
 SVGImageElement
 SVGLineElement
 SVGPathElement
 ...etc
 */
@implementation SVGElement


@synthesize document = _document;

@synthesize children = _children;
@synthesize stringValue = _stringValue;
@synthesize localName = _localName;

@synthesize identifier = _identifier;

@synthesize metadataChildren;

+ (BOOL)shouldStoreContent {
	return NO;
}

- (id)init {
    self = [super init];
    if (self) {
		[self loadDefaults];
        _children = [NSMutableArray new];
        self->metadataChildren = [NSMutableArray new];
    }
    return self;
}

- (id)initWithDocument:(SVGDocument *)aDocument name:(NSString *)name {
	self = [self init];
	if (self) {
		_document = aDocument;
		_localName = [name copy];
	}
	return self;
}

- (void)dealloc {
    [self setMetadataChildren:nil];
//	self.metadataChildren = nil;
	[_children release];
	[_stringValue release];
	[_localName release];
	[_identifier release];
	
	[super dealloc];
}

- (void)loadDefaults {
	// to be overriden by subclasses
}

- (void)addChild:(SVGElement *)element {
	[_children addObject:element];
}

-(void) addMetadataChild:(NSObject*) child
{
	[self.metadataChildren addObject:child];
}

- (void)parseAttributes:(NSDictionary *)attributes {
	// to be overriden by subclasses
	// make sure super implementation is called
	
	id value = nil;
	
	if ((value = [attributes objectForKey:@"id"])) {
		_identifier = [value copy];
	}
}

- (void)parseContent:(NSString *)content {
	self.stringValue = content;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p | id=%@ | localName=%@ | stringValue=%@ | children=%d>", 
			[self class], self, _identifier, _localName, _stringValue, [_children count]];
}


+(void)trim
{
    //remove statically allocated stuffs to free up memory
}

//- (void)setTrackShapeLayers:(BOOL)track
//{
//    if( track == (_createdShapes == nil) ) // need to change, track and nil set or !track and set created
//    {
//        if( track ) //need to create set
//            _createdShapes = [NSMutableSet new];
//        else
//        {
//            [_createdShapes release];
//            _createdShapes = nil;
//        }
//    }
//}



//proof of concept, would probably want to update the entire style if you were going to do this right
//- (void)updateFill:(SVGColor)fill
//{
//    if( _createdShapes != nil )
//    {
//        for (CAShapeLayer *shape in _createdShapes) {
//            shape.fillColor = CGColorWithSVGColor(fill);//
//        }
//        
//    }
//}

@end
