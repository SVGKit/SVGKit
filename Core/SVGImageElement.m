//
//  SVGImageElement.m
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

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)parseAttributes:(NSDictionary *)attributes {
	id value = nil;

	if ((value = [attributes objectForKey:@"x"])) {
		_x = [value floatValue];
	}

	if ((value = [attributes objectForKey:@"y"])) {
		_y = [value floatValue];
	}

	if ((value = [attributes objectForKey:@"width"])) {
		_width = [value floatValue];
	}

	if ((value = [attributes objectForKey:@"height"])) {
		_height = [value floatValue];
	}

	if ((value = [attributes objectForKey:@"href"])) {
		_href = [value retain];
	}
}

- (CALayer *)newLayer {
	__block CALayer *layer = [CALayer layer];

	layer.name = self.identifier;
	[layer setValue:self.identifier forKey:kSVGElementIdentifier];
    layer.frame = CGRectMake(_x, _y, _width, _height);
    
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
