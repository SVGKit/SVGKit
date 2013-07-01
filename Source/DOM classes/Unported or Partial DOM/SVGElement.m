//
//  SVGElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGElement.h"

#import "SVGElement_ForParser.h" //.h" // to solve insane Xcode circular dependencies
#import "StyleSheetList+Mutable.h"

#import "CSSStyleSheet.h"
#import "CSSStyleRule.h"
#import "CSSRuleList+Mutable.h"

#import "SVGGElement.h"

#import "SVGRect.h"

#import "SVGTransformable.h"

#import "SVGKCGFloatAdditions.h"

@interface SVGElement ()

@property (nonatomic, copy) NSString *stringValue;

@end

/*! main class implementation for the base SVGElement: NOTE: in practice, most of the interesting
 stuff happens in subclasses, e.g.:
 
 SVGShapeElement
 SVGGroupElement
 SVGKImageElement
 SVGLineElement
 SVGPathElement
 ...etc
 */
@implementation SVGElement

@synthesize identifier = _identifier;
@synthesize xmlbase;
@synthesize rootOfCurrentDocumentFragment;
@synthesize viewportElement;
@synthesize stringValue = _stringValue;

@synthesize className; /**< CSS class, from SVGStylable interface */
@synthesize style; /**< CSS style, from SVGStylable interface */

/** from SVGStylable interface */
-(CSSValue*) getPresentationAttribute:(NSString*) name
{
	NSAssert(FALSE, @"getPresentationAttribute: not implemented yet");
	return nil;
}


+ (BOOL)shouldStoreContent {
	return NO;
}

/*! As per the SVG Spec, the local reference to "viewportElement" depends on the values of the
 attributes of the node - does it have a "width" attribute?
 
 NB: by definition, <svg> tags MAY NOT have a width, but they are still viewports */
-(void) reCalculateAndSetViewportElementReferenceUsingFirstSVGAncestor:(SVGElement*) firstAncestor
{
	// NB the root svg element IS a viewport, but SVG Spec defines it as NOT a viewport, and so we will overwrite this later
	BOOL isTagAllowedToBeAViewport = [self.tagName isEqualToString:@"svg"] || [self.tagName isEqualToString:@"foreignObject"]; // NB: Spec lists "image" tag too but only as an IMPLICIT CREATOR - we don't actually handle it (it creates an <SVG> tag ... that will be handled later)
	
	BOOL isTagDefiningAViewport = [self.attributes getNamedItem:@"width"] != nil || [self.attributes getNamedItem:@"height"] != nil;
	
	if( isTagAllowedToBeAViewport && isTagDefiningAViewport )
	{
		DDLogVerbose(@"[%@] WARNING: setting self (tag = %@) to be a viewport", [self class], self.tagName );
		self.viewportElement =  self;
	}
	else
	{
		SVGElement* ancestorsViewport = firstAncestor.viewportElement;
		
		if( ancestorsViewport == nil )
		{
			/**
			 Because of the poorly-designed SVG Spec on Viewports, all the children of the root
			 SVG node will find that their ancestor has a nil viewport! (this is defined in the spec)
			 
			 So, in that special case, we INSTEAD guess that the ancestor itself was the viewport...
			 */
			self.viewportElement = firstAncestor;
		}
		else
			self.viewportElement = ancestorsViewport;
	}
}

/*! Override so that we can automatically set / unset the ownerSVGElement and viewportElement properties,
 as required by SVG Spec */
-(void)setParentNode:(Node *)newParent
{
	[super setParentNode:newParent];
	
	/** SVG Spec: if "outermost SVG tag" then both element refs should be nil */
	if( [self isKindOfClass:[SVGSVGElement class]]
	   && (self.parentNode == nil || ! [self.parentNode isKindOfClass:[SVGElement class]]) )
	{
		self.rootOfCurrentDocumentFragment = nil;
		self.viewportElement = nil;
	}
	else
	{
		/**
		 SVG Spec: we have to set a reference to the "root SVG tag of this part of the tree".
		 
		 If the tree is purely SVGElement nodes / subclasses, that's easy.
		 
		 But if there are custom nodes in there (any other DOM node, for instance), it gets
		 more tricky. We have to recurse up the tree until we find an SVGElement we can latch
		 onto
		 */
		
		if( [self isKindOfClass:[SVGSVGElement class]] )
		{
			self.rootOfCurrentDocumentFragment = (SVGSVGElement*) self;
			self.viewportElement = self;
		}
		else
		{
			Node* currentAncestor = newParent;
			SVGElement*	firstAncestorThatIsAnyKindOfSVGElement = nil;
			while( firstAncestorThatIsAnyKindOfSVGElement == nil
				  && currentAncestor != nil ) // if we run out of tree! This would be an error (see below)
			{
				if( [currentAncestor isKindOfClass:[SVGElement class]] )
					firstAncestorThatIsAnyKindOfSVGElement = (SVGElement*) currentAncestor;
				else
					currentAncestor = currentAncestor.parentNode;
			}
			
			NSAssert( firstAncestorThatIsAnyKindOfSVGElement != nil, @"This node has no valid SVG tags as ancestor, but it's not an <svg> tag, so this is an impossible SVG file" );
			
			
			if( [firstAncestorThatIsAnyKindOfSVGElement isKindOfClass:[SVGSVGElement class]] )
				self.rootOfCurrentDocumentFragment = (SVGSVGElement*) firstAncestorThatIsAnyKindOfSVGElement;
			else
				self.rootOfCurrentDocumentFragment = firstAncestorThatIsAnyKindOfSVGElement.rootOfCurrentDocumentFragment;
			
			[self reCalculateAndSetViewportElementReferenceUsingFirstSVGAncestor:firstAncestorThatIsAnyKindOfSVGElement];
			
#if DEBUG_SVG_ELEMENT_PARSING
			DDLogVerbose(@"viewport Element = %@ ... for node/element = %@", self.viewportElement, self.tagName);
#endif
		}
	}
}

- (void)loadDefaults {
	// to be overriden by subclasses
}

-(SVGLength*) getAttributeAsSVGLength:(NSString*) attributeName
{
	NSString* attributeAsString = [self getAttribute:attributeName];
	SVGLength* svgLength = [SVGLength svgLengthFromNSString:attributeAsString];
	
	return svgLength;
}

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult  {
	// to be overriden by subclasses
	// make sure super implementation is called
	
	if( [[self getAttribute:@"id"] length] > 0 )
		self.identifier = [self getAttribute:@"id"];
	
	/** CSS styles and classes */
	if ( [self getAttributeNode:@"style"] )
	{
		self.style = [[CSSStyleDeclaration alloc] init];
		self.style.cssText = [self getAttribute:@"style"]; // causes all the LOCALLY EMBEDDED style info to be parsed
	}
	if( [self getAttributeNode:@"class"])
	{
		self.className = [self getAttribute:@"class"];
	}
	
	
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
	if( [[self getAttribute:@"transform"] length] > 0  || [[self getAttribute:@"gradientTransform"] length] > 0)
	{
		if( [self conformsToProtocol:@protocol(SVGTransformable)] )
		{
			SVGElement<SVGTransformable>* selfTransformable = (SVGElement<SVGTransformable>*) self;
			
			/**
			 http://www.w3.org/TR/SVG/coords.html#TransformAttribute
			 
			 The individual transform definitions are separated by whitespace and/or a comma.
			 */
			NSString* value = [self getAttribute:@"transform"];
            if (!value.length) {
                value = [self getAttribute:@"gradientTransform"];
            }
			
		NSError* error = nil;
		NSRegularExpression* regexpTransformListItem = [NSRegularExpression regularExpressionWithPattern:@"[^\\(\\),]*\\([^\\)]*" options:0 error:&error]; // anything except space and brackets ... followed by anything except open bracket ... plus anything until you hit a close bracket
		
		[regexpTransformListItem enumerateMatchesInString:value options:0 range:NSMakeRange(0, [value length]) usingBlock:
		 ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		{
			NSString* transformString = [value substringWithRange:[result range]];
			
			//EXTREME DEBUG: DDLogVerbose(@"[%@] DEBUG: found a transform element (should be command + open bracket + args + close bracket) = %@", [self class], transformString);
			
			NSRange loc = [transformString rangeOfString:@"("];
			if( loc.length == 0 )
			{
				DDLogError(@"[%@] ERROR: input file is illegal, has an item in the SVG transform attribute which has no open-bracket. Item = %@, transform attribute value = %@", [self class], transformString, value );
				return;
			}
			NSString* command = [transformString substringToIndex:loc.location];
			NSArray* parameterStrings = [[transformString substringFromIndex:loc.location+1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
			
			/** if you get ", " (comma AND space), Apple sends you an extra 0-length match - "" - between your args. We strip that here */
			parameterStrings = [parameterStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
			
			//EXTREME DEBUG: NSLog(@"[%@] DEBUG: found parameters = %@", [self class], parameterStrings);
			
			command = [command stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
			
			if( [command isEqualToString:@"translate"] )
			{
				CGFloat xtrans = [(NSString*)parameterStrings[0] SVGKCGFloatValue];
				CGFloat ytrans = [parameterStrings count] > 1 ? [(NSString*)parameterStrings[1] SVGKCGFloatValue] : 0.0;
				
				CGAffineTransform nt = CGAffineTransformMakeTranslation(xtrans, ytrans);
				selfTransformable.transform = CGAffineTransformConcat( nt, selfTransformable.transform ); // Apple's method appears to be backwards, and not doing what Apple's docs state
				
			}
			else if( [command isEqualToString:@"scale"] )
			{
				CGFloat xScale = [(NSString*)parameterStrings[0] SVGKCGFloatValue];
				CGFloat yScale = [parameterStrings count] > 1 ? [(NSString*)parameterStrings[1] SVGKCGFloatValue] : xScale;
				
				CGAffineTransform nt = CGAffineTransformMakeScale(xScale, yScale);
				selfTransformable.transform = CGAffineTransformConcat( nt, selfTransformable.transform ); // Apple's method appears to be backwards, and not doing what Apple's docs state
			}
			else if( [command isEqualToString:@"matrix"] )
			{
				CGFloat a = [(NSString*)parameterStrings[0] SVGKCGFloatValue];
				CGFloat b = [(NSString*)parameterStrings[1] SVGKCGFloatValue];
				CGFloat c = [(NSString*)parameterStrings[2] SVGKCGFloatValue];
				CGFloat d = [(NSString*)parameterStrings[3] SVGKCGFloatValue];
				CGFloat tx = [(NSString*)parameterStrings[4] SVGKCGFloatValue];
				CGFloat ty = [(NSString*)parameterStrings[5] SVGKCGFloatValue];
				
				CGAffineTransform nt = CGAffineTransformMake(a, b, c, d, tx, ty );
				selfTransformable.transform = CGAffineTransformConcat( nt, selfTransformable.transform ); // Apple's method appears to be backwards, and not doing what Apple's docs state
				
			}
			else if( [command isEqualToString:@"rotate"] )
			{
				/**
				 This section merged from warpflyght's commit:
				 
				 https://github.com/warpflyght/SVGKit/commit/c1bd9b3d0607635dda14ec03579793fc682763d9
				 
				 */
				if( [parameterStrings count] == 1)
				{
					CGFloat degrees = [parameterStrings[0] SVGKCGFloatValue];
					CGFloat radians = degrees * M_PI / 180.0;
					
					CGAffineTransform nt = CGAffineTransformMakeRotation(radians);
					selfTransformable.transform = CGAffineTransformConcat( nt, selfTransformable.transform ); // Apple's method appears to be backwards, and not doing what Apple's docs state
				}
				else if( [parameterStrings count] == 3)
				{
					CGFloat degrees = [parameterStrings[0] SVGKCGFloatValue];
					CGFloat radians = degrees * M_PI / 180.0;
					CGFloat centerX = [parameterStrings[1] SVGKCGFloatValue];
					CGFloat centerY = [parameterStrings[2] SVGKCGFloatValue];
					CGAffineTransform nt = CGAffineTransformIdentity;
					nt = CGAffineTransformConcat( nt, CGAffineTransformMakeTranslation(centerX, centerY) );
					nt = CGAffineTransformConcat( nt, CGAffineTransformMakeRotation(radians) );
					nt = CGAffineTransformConcat( nt, CGAffineTransformMakeTranslation(-1.0 * centerX, -1.0 * centerY) );
					selfTransformable.transform = CGAffineTransformConcat( nt, selfTransformable.transform ); // Apple's method appears to be backwards, and not doing what Apple's docs state
					} else
					{
					DDLogError(@"[%@] ERROR: input file is illegal, has an SVG matrix transform attribute without the required 1 or 3 parameters. Item = %@, transform attribute value = %@", [self class], transformString, value );
					return;
				}
			}
			else if( [command isEqualToString:@"skewX"] )
			{
				DDLogWarn(@"[%@] ERROR: skew is unsupported: %@", [self class], command );
				
				[parseResult addParseErrorRecoverable: [NSError errorWithDomain:@"SVGKit" code:15184 userInfo:@{NSLocalizedDescriptionKey: @"transform=skewX is unsupported"}]];
			}
			else if( [command isEqualToString:@"skewY"] )
			{
				DDLogWarn(@"[%@] ERROR: skew is unsupported: %@", [self class], command );
				[parseResult addParseErrorRecoverable: [NSError errorWithDomain:@"SVGKit" code:15184 userInfo:@{NSLocalizedDescriptionKey: @"transform=skewY is unsupported"}]];
			}
			else
			{
				NSAssert( FALSE, @"Not implemented yet: transform = %@ %@", command, transformString );
			}
		}];
		
		//DEBUG: DDLogVerbose(@"[%@] Set local / relative transform = (%2.2f, %2.2f // %2.2f, %2.2f) + (%2.2f, %2.2f translate)", [self class], selfTransformable.transform.a, selfTransformable.transform.b, selfTransformable.transform.c, selfTransformable.transform.d, selfTransformable.transform.tx, selfTransformable.transform.ty );
		}
	}
	
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p | id=%@ | prefix:localName=%@:%@ | tagName=%@ | stringValue=%@ | children=%ld>",
			[self class], self, _identifier, self.prefix, self.localName, self.tagName, _stringValue, self.childNodes.length];
}

#pragma mark - Objective-C init methods (not in SVG Spec - the official spec has no explicit way to create nodes, which is clearly a bug in the Spec. Until they fix the spec, we have to do something or else SVG would be unusable)

- (id)initWithLocalName:(NSString*) n attributes:(NSMutableDictionary*) attributes
{
	self = [super initWithLocalName:n attributes:attributes];
	if( self )
	{
		[self loadDefaults];
		
		if( [self conformsToProtocol:@protocol(SVGTransformable)] )
		{
			SVGElement<SVGTransformable>* selfTransformable = (SVGElement<SVGTransformable>*) self;
			selfTransformable.transform = CGAffineTransformIdentity;
		}
	}
	return self;
}

- (id)initWithQualifiedName:(NSString*) n inNameSpaceURI:(NSString*) nsURI attributes:(NSMutableDictionary*) attributes
{
	self = [super initWithQualifiedName:n inNameSpaceURI:nsURI attributes:attributes];
	if( self )
	{
		[self loadDefaults];
		
		if( [self conformsToProtocol:@protocol(SVGTransformable)] )
		{
			SVGElement<SVGTransformable>* selfTransformable = (SVGElement<SVGTransformable>*) self;
			selfTransformable.transform = CGAffineTransformIdentity;
		}
	}
	return self;
}

#pragma mark - CSS cascading special attributes
-(NSString*) cascadedValueForStylableProperty:(NSString*) stylableProperty
{
	/**
	 This is the core implementation of Cascading Style Sheets, inside SVG.
	 
	 c.f.: http://www.w3.org/TR/SVG/styling.html
	 
	 In SVG, the set of things that can be cascaded is strictly defined, c.f.:
	 
	 http://www.w3.org/TR/SVG/propidx.html
	 
	 For each of those, the implementaiton is the same.
	 
	 ********* WAWRNING: THE CURRENT IMPLEMENTATION BELOW IS VEYR MUCH INCOMPLETE, BUT IT WORKS FOR VERY SIMPLE SVG'S ************
	 */
	if( [self hasAttribute:stylableProperty])
		return [self getAttribute:stylableProperty];
	else
	{
		NSString* localStyleValue = [self.style getPropertyValue:stylableProperty];
		
		if( localStyleValue != nil )
			return localStyleValue;
		else
		{
			if( self.className != nil )
			{
				/** we have a locally declared CSS class; let's go hunt for it in the document's stylesheets */
				
				@autoreleasepool /** DOM / CSS is insanely verbose, so this is likely to generate a lot of crud objects */
				{
					for( StyleSheet* genericSheet in self.rootOfCurrentDocumentFragment.styleSheets.internalArray ) // because it's far too much effort to use CSS's low-quality iteration here...
					{
						if( [genericSheet isKindOfClass:[CSSStyleSheet class]])
						{
							CSSStyleSheet* cssSheet = (CSSStyleSheet*) genericSheet;
							
							for( CSSRule* genericRule in cssSheet.cssRules.internalArray)
							{
								if( [genericRule isKindOfClass:[CSSStyleRule class]])
								{
									CSSStyleRule* styleRule = (CSSStyleRule*) genericRule;
									
									if( [styleRule.selectorText isEqualToString:self.className] )
									{
										return [styleRule.style getPropertyValue:stylableProperty];
									}
								}
							}
						}
					}
				}
			}
			
			/** either there's no class *OR* it found no match for the class in the stylesheets */
			
			/** Finally: move up the tree until you find a <G> node, and ask it to provide the value
			 OR: if you find an <SVG> tag before you find a <G> tag, give up
			 */
			
			Node* parentElement = self.parentNode;
			while( parentElement != nil
				  && ! [parentElement isKindOfClass:[SVGGElement class]]
				  && ! [parentElement isKindOfClass:[SVGSVGElement class]])
			{
				parentElement = parentElement.parentNode;
			}
			
			if( parentElement == nil
			   || [parentElement isKindOfClass:[SVGSVGElement class]] )
				return nil; // give up!
			else
			{
				return [((SVGElement*)parentElement) cascadedValueForStylableProperty:stylableProperty];
			}
		}
	}
}

@end
