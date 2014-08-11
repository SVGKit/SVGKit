#import "SVGImageElement.h"

#import "SVGHelperUtilities.h"
#import "NSData+NSInputStream.h"

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#else
#endif

#if TARGET_OS_IPHONE
#define SVGImage UIImage
#else
#define SVGImage CIImage
#endif

#define SVGImageRef SVGImage*

CGImageRef SVGImageCGImage(SVGImageRef img)
{
#if TARGET_OS_IPHONE
    return img.CGImage;
#else
    NSBitmapImageRep* rep = [[[NSBitmapImageRep alloc] initWithCIImage:img] autorelease];
    return rep.CGImage;
#endif
}

@interface SVGImageElement()
@property (nonatomic, retain, readwrite) NSString *href;
@end

@implementation SVGImageElement

@synthesize transform; // each SVGElement subclass that conforms to protocol "SVGTransformable" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols
@synthesize viewBox; // each SVGElement subclass that conforms to protocol "SVGFitToViewBox" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols
@synthesize preserveAspectRatio; // each SVGElement subclass that conforms to protocol "SVGFitToViewBox" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols

@synthesize x = _x;
@synthesize y = _y;
@synthesize width = _width;
@synthesize height = _height;

@synthesize href = _href;

- (void)dealloc {
    [_href release], _href = nil;

    [super dealloc];
}

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult {
	[super postProcessAttributesAddingErrorsTo:parseResult];

	if( [[self getAttribute:@"x"] length] > 0 )
	_x = [[self getAttribute:@"x"] floatValue];

	if( [[self getAttribute:@"y"] length] > 0 )
	_y = [[self getAttribute:@"y"] floatValue];

	if( [[self getAttribute:@"width"] length] > 0 )
	_width = [[self getAttribute:@"width"] floatValue];

	if( [[self getAttribute:@"height"] length] > 0 )
	_height = [[self getAttribute:@"height"] floatValue];

	if( [[self getAttribute:@"href"] length] > 0 )
	self.href = [self getAttribute:@"href"];
}


- (CALayer *) newLayer
{
	CALayer* newLayer = [[CALayer alloc] init];
	
	[SVGHelperUtilities configureCALayer:newLayer usingElement:self];
	
	NSData *imageData;
	if( [_href hasPrefix:@"data:"] || [_href hasPrefix:@"http:"] )
		imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_href]];
	else
	{
		NSInputStream *stream = [self.rootOfCurrentDocumentFragment.source sourceFromRelativePath:_href].stream;
        NSError *error = nil;
		imageData = [NSData dataWithContentsOfStream:stream initialCapacity:NSUIntegerMax error:&error];
		if( error )
			DDLogError(@"[%@] ERROR: unable to read stream from %@ into NSData: %@", [self class], _href, error);
	}
    SVGImageRef image = [SVGImage imageWithData:imageData];
    if( image.size.width && image.size.height )
    {
        // TODO: do something different for retina displays?
        self.viewBox = SVGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    /** transform our LOCAL path into ABSOLUTE space */
    CGRect frame = CGRectMake(_x, _y, _width, _height);
    frame = CGRectApplyAffineTransform(frame, [SVGHelperUtilities transformAbsoluteIncludingViewportForTransformableOrViewportEstablishingElement:self]);
    newLayer.frame = frame;
	
	newLayer.contents = (id)SVGImageCGImage(image);
		
#if OLD_CODE
	__block CALayer *layer = [[CALayer layer] retain];

	layer.name = self.identifier;
	[layer setValue:self.identifier forKey:kSVGElementIdentifier];
	
	CGRect frame = CGRectMake(_x, _y, _width, _height);
	frame = CGRectApplyAffineTransform(frame, [SVGHelperUtilities transformAbsoluteIncludingViewportForTransformableOrViewportEstablishingElement:self]);
	layer.frame = frame;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_href]];
        SVGImageRef image = [SVGImage imageWithData:imageData];
        
        //    _href = @"http://b.dryicons.com/images/icon_sets/coquette_part_4_icons_set/png/128x128/png_file.png";
        //    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_href]];
        //    UIImage *image = [UIImage imageWithData:imageData];

        dispatch_async(dispatch_get_main_queue(), ^{
            layer.contents = (id)SVGImageCGImage(image);
        });
    });

    return layer;
#endif
	
	return newLayer;
}

- (void)layoutLayer:(CALayer *)layer {
    
}

-(double)aspectRatioFromWidthPerHeight
{
    return self.height == 0 ? 0 : self.width / self.height;
}

-(double)aspectRatioFromViewBox
{
    return self.viewBox.height == 0 ? 0 : self.viewBox.width / self.viewBox.height;
}

@end
