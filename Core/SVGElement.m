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

@synthesize parent = _parent;
#if EXPERIMENTAL_SUPPORT_FOR_SVG_TRANSFORM_ATTRIBUTES
@synthesize transformRelative = _transformRelative;
#endif

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
        
#if EXPERIMENTAL_SUPPORT_FOR_SVG_TRANSFORM_ATTRIBUTES
		self.transformRelative = CGAffineTransformIdentity;
#endif
    }
    return self;
}

- (id)initWithDocument:(SVGDocument *)aDocument name:(NSString *)name {
	self = [self init];
	if (self) {
		_document = aDocument;
		_localName = [name retain]; //stich: i believe a copy is identical in this case since name ends up being non-mutable (maybe not for URL loads?)
#if EXPERIMENTAL_SUPPORT_FOR_SVG_TRANSFORM_ATTRIBUTES
		self.transformRelative = CGAffineTransformIdentity;
#endif
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
    //stich: this is being set by SVGParserSVG in handleStartElement now so that it can be used more reliably
//#if EXPERIMENTAL_SUPPORT_FOR_SVG_TRANSFORM_ATTRIBUTES
//	element.parent = self;
//#endif
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
	
#if EXPERIMENTAL_SUPPORT_FOR_SVG_TRANSFORM_ATTRIBUTES
	/**
	 http://www.w3.org/TR/SVG/coords.html#TransformAttribute
	 
	 The available types of transform definitions include:
	 
	 * matrix(<a> <b> <c> <d> <e> <f>), which specifies a transformation in the form of a transformation matrix of six values. matrix(a,b,c,d,e,f) is equivalent to applying the transformation matrix [a b c d e f].
	 
	 * translate(<tx> [<ty>]), which specifies a translation by tx and ty. If <ty> is not provided, it is assumed to be zero.
	 
	 * scale(<sx> [<sy>]), which specifies a scale operation by sx and sy. If <sy> is not provided, it is assumed to be equal to <sx>.
	 
	 * rotate(<rotate-angle> [<cx> <cy>]), which specifies a rotation by <rotate-angle> degrees about a given point.
	 If optional parameters <cx> and <cy> are not supplied, the rotate is about the origin of the current user coordinate system. The operation corresponds to the matrix [cos(a) sin(a) -sin(a) cos(a) 0 0].
	 If optional parameters <cx> and <cy> are supplied, the rotate is about the point (cx, cy). The operation represents the equivalent of the following specification: translate(<cx>, <cy>) rotate(<rotate-angle>) translate(-<cx>, -<cy>).
	 
	 * skewX(<skew-angle>), which specifies a skew transformation along the x-axis.
	 
	 * skewY(<skew-angle>), which specifies a skew transformation along the y-axis.
	 */
	if( (value = [attributes objectForKey:@"transform"]) )
	{
		/**
		 http://www.w3.org/TR/SVG/coords.html#TransformAttribute
		 
		 The individual transform definitions are separated by whitespace and/or a comma. 
		 */
		
		NSError* error = nil;
		NSRegularExpression* regexpTransformListItem = [NSRegularExpression regularExpressionWithPattern:@"[^\\(,]*\\([^\\)]*\\)" options:0 error:&error];
		
		[regexpTransformListItem enumerateMatchesInString:value options:0 range:NSMakeRange(0, [value length]) usingBlock:
		 ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		{
			NSString* transformString = [value substringWithRange:[result range]];
			
			NSRange loc = [transformString rangeOfString:@"("];
			if( loc.length == 0 )
			{
				NSLog(@"[%@] ERROR: input file is illegal, has an item in the SVG transform attribute which has no open-bracket. Item = %@, transform attribute value = %@", [self class], transformString, value );
				return;
			}
			NSString* command = [transformString substringToIndex:loc.location];
			NSArray* parameterStrings = [[transformString substringFromIndex:loc.location+1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
			
			if( [command isEqualToString:@"translate"] )
			{
				CGFloat xtrans = [(NSString*)[parameterStrings objectAtIndex:0] floatValue];
				CGFloat ytrans = [parameterStrings count] > 1 ? [(NSString*)[parameterStrings objectAtIndex:1] floatValue] : 0.0;
				
				CGAffineTransform nt = CGAffineTransformMakeTranslation(xtrans, ytrans);
				self.transformRelative = CGAffineTransformConcat( self.transformRelative, nt );
				
			}
		}];
		
		NSLog(@"[%@] Set local / relative transform = (%2.2f, %2.2f // %2.2f, %2.2f) + (%2.2f, %2.2f translate)", [self class], self.transformRelative.a, self.transformRelative.b, self.transformRelative.c, self.transformRelative.d, self.transformRelative.tx, self.transformRelative.ty );
	}
#endif
}

#if EXPERIMENTAL_SUPPORT_FOR_SVG_TRANSFORM_ATTRIBUTES
-(CGAffineTransform) transformAbsolute
{
	if( self.parent == nil )
		return self.transformRelative;
	else
	{
		CGAffineTransform inheritedTransform = [self.parent transformAbsolute];
		
		return CGAffineTransformConcat( inheritedTransform, self.transformRelative );
	}
}
#endif

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
