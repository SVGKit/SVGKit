#import "SVGImageElement.h"

#import "CALayerWithClipRender.h"
#import "SVGHelperUtilities.h"
#import "NSData+NSInputStream.h"

#import "SVGKImage.h"
#import "SVGKSourceURL.h"
#import "SVGKSourceNSData.h"
#import "SVGSVGElement.h"

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#else
#endif

#if TARGET_OS_IPHONE
#define AppleNativeImage UIImage
#else
#define AppleNativeImage CIImage
#endif

#define AppleNativeImageRef AppleNativeImage*

CGImageRef SVGImageCGImage(AppleNativeImageRef img)
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
    
    [SVGHelperUtilities parsePreserveAspectRatioFor:self];
}


- (CALayer *) newLayer
{
	CALayer* newLayer = [[CALayerWithClipRender layer] retain];
	
	[SVGHelperUtilities configureCALayer:newLayer usingElement:self];
	
	NSData *imageData;
	NSURL* imageURL = [NSURL URLWithString:_href];
	SVGKSource* effectiveSource = nil;
	if( [_href hasPrefix:@"data:"] || [_href hasPrefix:@"http:"] )
		imageData = [NSData dataWithContentsOfURL:imageURL];
	else
	{
		effectiveSource = [self.rootOfCurrentDocumentFragment.source sourceFromRelativePath:_href];
		NSInputStream *stream = effectiveSource.stream;
		[stream open]; // if we do this, we CANNOT parse from this source again in future
        NSError *error = nil;
		imageData = [NSData dataWithContentsOfStream:stream initialCapacity:NSUIntegerMax error:&error];
		if( error )
			DDLogError(@"[%@] ERROR: unable to read stream from %@ into NSData: %@", [self class], _href, error);
	}
	
	/** Now we have some raw bytes, try to load using Apple's image loaders
	 (will fail if the image is an SVG file)
	 */
	AppleNativeImageRef image = [AppleNativeImage imageWithData:imageData];
	
    if( image == nil && imageURL ) // NSData doesn't contain an imageformat Apple supports; might be an SVG instead
    {
        SVGKImage *svg = nil;
        
        if( effectiveSource == nil )
            effectiveSource = [SVGKSourceURL sourceFromURL:imageURL];
        
        if( effectiveSource != nil )
        {
            DDLogInfo(@"Attempting to interpret the image at URL as an embedded SVG link (Apple failed to parse it): %@", _href );
            if( imageData != nil )
            {
                /** NB: sources can only be used once; we've already opened the stream for the source
                 earlier, so we MUST pass-in the already-downloaded NSData
                 
                 (if not, we'd be downloading it twice anyway, which can be lethal with large
                 SVG files!)
                 */
                svg = [SVGKImage imageWithSource: [SVGKSourceNSData sourceFromData:imageData URLForRelativeLinks:imageURL]];
            }
            else
            {
                svg = [SVGKImage imageWithSource: effectiveSource];
            }
            
            if( svg != nil )
            {
                image = svg.UIImage;
            }
        }
    }
    
	if( image != nil )
	{
        CGRect frame = CGRectMake(_x, _y, _width, _height);
        
        if( imageData )
            self.viewBox = SVGRectMake(0, 0, image.size.width, image.size.height);
        else
            self.viewBox = SVGRectMake(0, 0, _width, _height);
        
        CGImageRef imageRef = SVGImageCGImage(image);
        
        // apply preserveAspectRatio
        if( self.preserveAspectRatio.baseVal.align != SVG_PRESERVEASPECTRATIO_NONE
           && ABS( self.aspectRatioFromWidthPerHeight - self.aspectRatioFromViewBox) > 0.00001 )
        {
            double ratioOfRatios = self.aspectRatioFromWidthPerHeight / self.aspectRatioFromViewBox;
            if( self.preserveAspectRatio.baseVal.meetOrSlice == SVG_MEETORSLICE_MEET )
            {
                // shrink the image to fit in the frame, preserving the aspect ratio
                frame = [self clipFrame:frame fromRatio:ratioOfRatios];
            }
            else if( self.preserveAspectRatio.baseVal.meetOrSlice == SVG_MEETORSLICE_SLICE )
            {
                // crop the image
                CGRect cropRect = CGRectMake(0, 0, image.size.width, image.size.height);
                cropRect = [self clipFrame:cropRect fromRatio:1.0 / ratioOfRatios];
                
                CGImageRef croppedRef = CGImageCreateWithImageInRect(imageRef, cropRect);
                CGImageRelease(imageRef);
                imageRef = croppedRef;
            }
        }
        
        /** transform our LOCAL path into ABSOLUTE space */
        frame = CGRectApplyAffineTransform(frame, [SVGHelperUtilities transformAbsoluteIncludingViewportForTransformableOrViewportEstablishingElement:self]);
        newLayer.frame = frame;
        
        newLayer.contents = (id)imageRef;
	}
		
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

- (CGRect)clipFrame:(CGRect)frame fromRatio:(double)ratioOfRatios
{
    if( ratioOfRatios > 1 ) // if we're going to have space to either side
    {
        CGFloat width = frame.size.width;
        frame.size.width = frame.size.width / ratioOfRatios;
        switch( self.preserveAspectRatio.baseVal.align )
        {
            case SVG_PRESERVEASPECTRATIO_XMIDYMIN:
            case SVG_PRESERVEASPECTRATIO_XMIDYMID:
            case SVG_PRESERVEASPECTRATIO_XMIDYMAX:
            {
                frame.origin.x = frame.origin.x + ((width - frame.size.width) / 2);
            }break;
                
            case SVG_PRESERVEASPECTRATIO_XMAXYMIN:
            case SVG_PRESERVEASPECTRATIO_XMAXYMID:
            case SVG_PRESERVEASPECTRATIO_XMAXYMAX:
            {
                frame.origin.x = frame.origin.x + width - frame.size.width;
            }break;
                
            default:
                break;
        }
    }
    else // if we're going to have space above and below
    {
        CGFloat height = frame.size.height;
        frame.size.height = frame.size.height * ratioOfRatios;
        switch( self.preserveAspectRatio.baseVal.align )
        {
            case SVG_PRESERVEASPECTRATIO_XMINYMID:
            case SVG_PRESERVEASPECTRATIO_XMIDYMID:
            case SVG_PRESERVEASPECTRATIO_XMAXYMID:
            {
                frame.origin.y = frame.origin.y + ((height - frame.size.height) / 2);
            }break;
                
            case SVG_PRESERVEASPECTRATIO_XMINYMAX:
            case SVG_PRESERVEASPECTRATIO_XMIDYMAX:
            case SVG_PRESERVEASPECTRATIO_XMAXYMAX:
            {
                frame.origin.y = frame.origin.y + height - frame.size.height;
            }break;
                
            default:
                break;
        }
    }
    return frame;
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
