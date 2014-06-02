#import "SVGKImageView.h"

@implementation SVGKImageView

//@synthesize image = _image;
@synthesize showBorder = _showBorder;

- (void)setImage:(SVGKImage*)image
{
	NSAssert(NO, @"[%@] The function %s should be implemented by a subclass!", [self class], sel_getName(_cmd));
}

- (SVGKImage *)image
{
	NSAssert(NO, @"[%@] The function %s should be implemented by a subclass!", [self class], sel_getName(_cmd));
	return nil;
}

- (id)init
{
	if( [self class] == [SVGKImageView class ])
	{
		NSAssert(false, @"You cannot init this class directly. Instead, use a subclass e.g. SVGKFastImageView");
		
		return nil;
	}
	else
		return [super init];
}

-(id)initWithFrame:(CGRect)frame
{
	if( [self class] == [SVGKImageView class ])
	{
		NSAssert(false, @"You cannot init this class directly. Instead, use a subclass e.g. SVGKFastImageView");
		
		return nil;
	}
	else
		return [super initWithFrame:frame];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if( [self class] == [SVGKImageView class ])
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

/**
 The intrinsic sized of the image view.
 
 This is useful for playing nicely with autolayout.

 @return The size of the image if it has one, or CGSizeZero if not
 */
- (CGSize)intrinsicContentSize {
    if ([self.image hasSize]) {
        return self.image.size;
    }

    return CGSizeZero;
}

@end
