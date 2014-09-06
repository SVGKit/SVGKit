#import <SVGKit/SVGKImageView.h>

@implementation SVGKImageView
@dynamic image;

@synthesize showBorder = _showBorder;


- (id)initWithSVGKImage:(SVGKImage*)im frame:(NSRect)theFrame
{
	if ([self isMemberOfClass:[SVGKImageView class]]) {
		NSAssert(NO, @"[%@] The function %s is meant to be implemented from a subclass, but you called the %@ class directly. This is not a good thing.", [self class], sel_getName(_cmd), [SVGKImageView class]);
	} else {
		NSAssert(NO, @"[%@] The function %s should be implemented by the subclass %@. You are currently using the function from %@, which is not good.", [self class], sel_getName(_cmd), [self class], [SVGKImageView class]);
	}
	return nil;
}

- (id)init
{
	if( [self isMemberOfClass:[SVGKImageView class]])
	{
		NSAssert(false, @"You cannot init this class directly. Instead, use a subclass e.g. SVGKFastImageView");
		
		return nil;
	}
	else
		return self = [super init];
}

- (void)setImage:(SVGKImage*)image
{
	NSAssert(NO, @"[%@] The function %s should be implemented by the subclass %@. You are currently using the function from %@, which is not good.", [self class], sel_getName(_cmd), [self class], [SVGKImageView class]);
}

- (SVGKImage *)image
{
	NSAssert(NO, @"[%@] The function %s should be implemented by the subclass %@. You are currently using the function from %@, which is not good.", [self class], sel_getName(_cmd), [self class], [SVGKImageView class]);
	return nil;
}

-(id)initWithFrame:(NSRect)frame
{
	if( [self isMemberOfClass:[SVGKImageView class]])
	{
		NSAssert(false, @"You cannot init this class directly. Instead, use a subclass e.g. SVGKFastImageView");
		
		return nil;
	}
	else
		return [super initWithFrame:frame];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if( [self isMemberOfClass:[SVGKImageView class]])
	{
		NSAssert(false, @"Xcode is trying to load this class from a StoryBoard or from a NIB/XIB files. You cannot init this class directly - in your Storyboard/NIB file, set the Class type to one of the subclasses, e.g. SVGKFastImageView");
		
		return nil;
	}
	else
		return [super initWithCoder:aDecoder];
}

- (id)initWithSVGKImage:(SVGKImage*) im
{
	NSAssert(false, @"Your subclass implementation is broken, it should be calling [super init] not [super initWithSVGKImage:]. Instead, use a subclass e.g. SVGKFastImageView");
    
    return nil;
}

- (BOOL)isFlipped
{
	return YES;
}

@end
