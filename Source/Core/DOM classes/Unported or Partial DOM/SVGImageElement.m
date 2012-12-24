//
//  SVGKImageElement.m
//  SvgLoader
//
//  Created by Joshua May on 24/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVGImageElement.h"

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
	NSAssert( FALSE, @"NOT SUPPORTED: SVG Image Element . newLayer -- must be upgraded using the algorithm in SVGShapeElement.newLayer");
	
	__block CALayer *layer = [[CALayer layer] retain];

	layer.name = self.identifier;
	[layer setValue:self.identifier forKey:kSVGElementIdentifier];
	
	CGRect frame = CGRectMake(_x, _y, _width, _height);
	frame = CGRectApplyAffineTransform(frame, [self transformAbsolute]);
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
}

- (void)layoutLayer:(CALayer *)layer {
    
}

@end
