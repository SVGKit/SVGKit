
#import "CSSStyleRule.h"
#import "CSSSelectors.h"

@interface CSSStyleRule()

@property(nonatomic,retain) NSArray* selectors;

@end

@implementation CSSStyleRule

@synthesize selectorText;
@synthesize selectors;
@synthesize style;

- (void)dealloc {
    self.style = nil;
    self.selectorText = nil;
    [super dealloc];
}

- (id)init
{
	NSAssert(FALSE, @"Can't be init'd, use the right method, idiot");
	return nil;
}

#pragma mark - methods needed for ObjectiveC implementation

- (CSSSelectorBase *)selectorFromText:(NSString *) text withRange:(NSRange) range
{
    CSSSelectorBase *selector;
    if( [text characterAtIndex:range.location] == '.' )
        selector = [[CSSClassSelector alloc] initWithSelector:[text substringWithRange:range]];
    else if( [text characterAtIndex:range.location] == '#' )
        selector = [[CSSIdSelector alloc] initWithSelector:[text substringWithRange:range]];
    else
        selector = [[CSSElementSelector alloc] initWithSelector:[text substringWithRange:range]];
    return [selector autorelease];
}

- (NSArray *)selectorsFromText:(NSString *) text
{
    NSMutableArray* result = [[[NSMutableArray alloc] init] autorelease];
    
    NSCharacterSet *alphaNum = [NSCharacterSet alphanumericCharacterSet];
	NSCharacterSet *selectorStart = [NSCharacterSet characterSetWithCharactersInString:@"#."];
    
    NSInteger start = -1;
    NSUInteger end = 0;
    for( NSUInteger i = 0; i < text.length; i++ )
    {
        unichar c = [text characterAtIndex:i];
        if( [selectorStart characterIsMember:c] )
        {
            start = i;
        }
        else if( [alphaNum characterIsMember:c] )
        {
            if( start == -1 )
                start = i;
            end = i;
        }
        else
        {
            // add the latest selector to the list
            if( start != -1 )
            {
                [result addObject:[self selectorFromText:text withRange:NSMakeRange(start, end + 1 - start)]];
                start = -1;
            }
        }
    }
    
    if( start != -1 )
        [result addObject:[self selectorFromText:text withRange:NSMakeRange(start, end + 1 - start)]];
    
    return result;
}

- (id)initWithSelectorText:(NSString*) selector styleText:(NSString*) styleText;
{
    self = [super init];
    if (self) {
        self.selectorText = selector;
        self.selectors = [self selectorsFromText:selector];
		
		CSSStyleDeclaration* styleDeclaration = [[[CSSStyleDeclaration alloc] init] autorelease];
		styleDeclaration.cssText = styleText;
		
		self.style = styleDeclaration;
    }
    return self;
}

- (BOOL)appliesTo:(SVGElement *) element
{
    if( selectors.count == 0 )
        return NO;
    
    for( id<CSSSelector> selector in self.selectors )
    {
        if( ![selector appliesTo:element] )
            return NO;
    }
    return YES;
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"%@ : { %@ }", self.selectorText, self.style ];
}

@end
