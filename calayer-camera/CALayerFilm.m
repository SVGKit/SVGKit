//
//  CALayerFilm.m
//  StyleTouch
//
//  Created by Kevin Stich on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CALayerFilm.h"


typedef enum {
    USE_NATIVE_SIZE = 1,
    USE_MASK        = 2,
    ALPHA_ONLY      = 4,
    FOR_CGLAYER     = 8,
    FOR_RESAMPLE    = 16
} CALayerFilmFlag;
static inline CGFloat CGFloatScaleFromCGAffineTransform(CGAffineTransform transform)
{
    CGFloat scale = sqrtf((transform.a * transform.a) + (transform.c * transform.c));
    //NSLog(@"Transform scale is %f", scale);
    return scale;
}

static inline BOOL useNativeSize(CALayerFilmFlag targetFlag)
{
    return (targetFlag & USE_NATIVE_SIZE) != 0;
}
static inline BOOL isAlphaOnly(CALayerFilmFlag targetFlag)
{
    return (targetFlag & ALPHA_ONLY) != 0;
}
static inline BOOL useMask(CALayerFilmFlag targetFlag)
{
    return (targetFlag & USE_MASK) != 0;
}
static inline BOOL forCGLayer(CALayerFilmFlag targetFlag)
{
    return (targetFlag & FOR_CGLAYER) != 0;
}
static inline BOOL forResample(CALayerFilmFlag targetFlag)
{
    return (targetFlag & FOR_RESAMPLE) != 0;
}

static inline void setBitToValue(CALayerFilmFlag *sourceFlags, CALayerFilmFlag bit, BOOL targetValue)
{
    if( targetValue )
        *sourceFlags = *sourceFlags | bit; //set alpha only
    else {
        *sourceFlags = (*sourceFlags & (NSUIntegerMax ^ bit)); //everything but
    }
}


CGFloat CGFloat2DScaleFromCATransform3D(CATransform3D transform);


CGFloat CGFloat2DScaleFromCATransform3D(CATransform3D transform)
{
    CGFloat partialDeterminate = (transform.m11 * transform.m22 * transform.m33);
    partialDeterminate -= (transform.m13 * transform.m22 * transform.m31);
    return powf(partialDeterminate, 1.0f/3.0f);
}

@interface CALayerFilm ()


void dataProviderReleaseData (
                              void *info,
                              const void *data,
                              size_t size
                              );

@end

@implementation CALayerFilm

@synthesize subjectLayer = _source;
//@synthesize backgroundColor = _bgColor;
@synthesize callbackParams = _callbackParams;
@synthesize onCompleteCallbackBlock = _callbackBlock;


static CGColorRef WHITE_COLOR;
static CGFloat GLOBAL_SCALE_CACHE;
+(void)initialize
{
    if( self == [CALayerFilm class] )
    {
        WHITE_COLOR = CGColorRetain([UIColor whiteColor].CGColor);
        GLOBAL_SCALE_CACHE = [UIScreen mainScreen].scale;
    }
}

-(BOOL)isMask
{
    return isAlphaOnly(_typeFlags);
}

-(void)setIsMask:(BOOL)isMask
{
    if( isMask )
        _typeFlags = _typeFlags | ALPHA_ONLY; //set alpha only
    else {
        _typeFlags = (_typeFlags & (NSUIntegerMax ^ ALPHA_ONLY)); //everything but
    }
}
-(BOOL)forResample
{
    return forResample(_typeFlags);
}

-(void)setForResample:(BOOL)forResample
{
    if( forResample )
        _typeFlags = _typeFlags | FOR_RESAMPLE; //set alpha only
    else {
        _typeFlags = (_typeFlags & (NSUIntegerMax ^ FOR_RESAMPLE)); //everything but
    }
}

-(UIColor *)backgroundColor
{
    return [UIColor colorWithCGColor:bgColor];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    CGColorRef oldColor = bgColor;
    bgColor = CGColorRetain([backgroundColor CGColor]);
    CGColorRelease(oldColor);
}

#pragma mark Initialization messages
-(CALayerFilm *)initWithSource:(CALayer *)sourceLayer
{
    self = [super init];
    if( self != nil )
    {
        contextTransformForSource = CGAffineTransformIdentity;
        _source = [sourceLayer retain];
    }
    return self;
}

-(CALayerFilm *)initWithSource:(CALayer *)sourceLayer andMask:(CGImageRef)imageMask
{
    self = [self initWithSource:sourceLayer];
    if( self != nil )
    {
        if( imageMask != NULL ) {
            _mask = CGImageRetain(imageMask);
        }
        
    }
    return self;
}

-(CALayerFilm *)initWithSource:(CALayer *)sourceLayer filmSize:(CGSize)filmSize
{
    self = [self initWithSource:sourceLayer];
    if( self != nil )
    {
        _frameRef = [[NSValue valueWithCGRect:CGRectMake(0.0f, 0.0f, filmSize.width, filmSize.height)] retain];
    }
    return self;
}


//trying to see if this works better on the main thread.... negative
//-(void)renderInContext:(NSValue *)contextPtr
//{
//    [_source renderInContext:(CGContextRef)[contextPtr pointerValue]];
//}


-(CGImageRef)newPhoto
{
    BOOL IS_MASK = isAlphaOnly(_typeFlags);
    BOOL USE_MASK = _mask != nil;//useMask(_typeFlags);
    //    BOOL FOR_CG_LAYER = forCGLayer(_typeFlags);
    BOOL IS_FOR_RESAMPLE = forResample(_typeFlags);
    BOOL NO_ALPHA = bgColor != nil;
    
    CGFloat transformScaleFactor = CGFloatScaleFromCGAffineTransform(contextTransformForSource);
    CGFloat totalScaleFactor = transformScaleFactor; 
    if( !IS_FOR_RESAMPLE )
        totalScaleFactor *= GLOBAL_SCALE_CACHE;
    
    
    CGRect photoFrame = (USE_MASK) ? CGRectMake(0, 0, CGImageGetWidth(_mask), CGImageGetHeight(_mask)) : (_frameRef == nil) ? _source.bounds : [_frameRef CGRectValue];
    
    if( CGRectIsEmpty(photoFrame) ) {
        NSLog(@"Oh noes no frame found");
        photoFrame = CGRectMake(0.0f, 0.0f, 200.0f, 200.0f);
        
    }
    //    else {
    //        NSLog(@"Frame is %@ totalScaleFactor is %f", NSStringFromCGRect(photoFrame), totalScaleFactor);
    //    }
    
    
    
    CGSize layerSize = photoFrame.size;
    CGFloat originalWidth = layerSize.width;
    CGFloat originalHeight = layerSize.height;
    
    if( !USE_MASK )
    {
        layerSize.width = originalWidth * totalScaleFactor;
        layerSize.height = originalHeight * totalScaleFactor;
        
        photoFrame.size = layerSize;
    }
    
    
    //there are currently no subpixel errors @ this level so this isn't doing anything
    //    CGPoint subPixelAdjustment = photoFrame.origin;
    photoFrame = CGRectIntegral(photoFrame);
    //    subPixelAdjustment.x -= photoFrame.origin.x;
    //    subPixelAdjustment.y -= photoFrame.origin.y;
    layerSize = photoFrame.size;
    
    //there are currently no subpixel errors @ this level so this isn't doing anything
    //    NSLog(@"Subpixel offset is %@", NSStringFromCGPoint(subPixelAdjustment));
    
    size_t imageWidth = (size_t)layerSize.width;
    size_t imageHeight = (size_t)layerSize.height;
    
    size_t bitmapBytesPerRow = (imageWidth);
    CGBitmapInfo myBitmapInfo;// IS_MASK ? kCGImageAlphaNone : kCGImageAlphaPremultipliedFirst;
    CGColorSpaceRef myColorSpace;// = (IS_MASK) ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB();
    
    size_t bitsPerComponent = 8;
    if( IS_MASK )
    {
        myColorSpace = CGColorSpaceCreateDeviceGray();
        myBitmapInfo = kCGImageAlphaNone;
    }
    else {
        myColorSpace = CGColorSpaceCreateDeviceRGB();
        if( NO_ALPHA )
        {
            bitmapBytesPerRow *= 2; //3 components, RGB, 5 + 5 + 6 == 16bits per pixel
            bitsPerComponent = 5;
            myBitmapInfo = kCGImageAlphaNoneSkipFirst;
        }
        else 
        {
            bitmapBytesPerRow *= 4;
            myBitmapInfo = kCGImageAlphaPremultipliedFirst;
        }
    }
    
    
    CFIndex bitmapByteCount = (bitmapBytesPerRow * imageHeight);
    UInt8 *bitmapData = malloc(bitmapByteCount);
    
    
    CGContextRef context = CGBitmapContextCreate(bitmapData,
                                                 imageWidth,
                                                 imageHeight,
                                                 bitsPerComponent,
                                                 bitmapBytesPerRow,
                                                 myColorSpace,
                                                 myBitmapInfo);
    
    CGContextClipToRect(context, photoFrame);
    if( !skipAA )
    {
        CGContextSetShouldAntialias(context, true);
        CGContextSetAllowsAntialiasing(context, true);
    }
    
    
    if( bgColor == NULL )
        CGContextClearRect(context, photoFrame);
    else 
    {
        CGContextSetFillColorWithColor(context, bgColor);
        CGContextFillRect(context, photoFrame);
    }
    
    if( _mask != NULL )
        CGContextClipToMask(context, photoFrame, _mask);
    //         CGContextTranslateCTM(context, offsetX, offsetY);
    
    CGContextTranslateCTM(context, 0.0f, imageHeight);
    
    totalScaleFactor /= transformScaleFactor; //we are going to apply the transform, so we don't need tos cale by its scale factor, or we'll scale twice, transformScaleFactor is almost always 1.0f
    CGContextScaleCTM(context, totalScaleFactor, -totalScaleFactor); //we should factor this into contextTransformForSource, would simplify things greatly
    
    CGContextConcatCTM(context, self->contextTransformForSource); //trying here with flipped y scale
    
    [_source renderInContext:context]; //all the work we're doign in this function is for this call...
    
    
    
    
    
    
    if( IS_MASK )
    {
        CGContextSetBlendMode(context, kCGBlendModeDifference);
        CGContextSetFillColorWithColor(context, WHITE_COLOR);
        CGContextFillRect(context, photoFrame);
    }
    
    CGContextRelease(context); //we're done with this, we just needed it as a vessel to populate our BMP data
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(bitmapData, bitmapData, bitmapByteCount, dataProviderReleaseData);
    CGImageRef detailImage = nil;
    bitmapData = NULL;
    if( IS_MASK )
    {
        
        detailImage = CGImageMaskCreate(imageWidth, imageHeight, bitsPerComponent, 8, bitmapBytesPerRow, dataProvider, NULL, YES);
        
    }
    else// if( !FOR_CG_LAYER ) {
    {
        detailImage = CGImageCreate(imageWidth, imageHeight
                                    , bitsPerComponent, NO_ALPHA ? 16 : 32
                                    , bitmapBytesPerRow
                                    , myColorSpace
                                    , myBitmapInfo
                                    , dataProvider
                                    , NULL, YES// looks a lot better, eprformance be damned! !skipAA
                                    , kCGRenderingIntentPerceptual);
    }
    
    CGDataProviderRelease(dataProvider);    
    
    
    CFRelease(myColorSpace);
    
    return detailImage; //(id) to send autorelease message, (CGImageRef) to have correct return type
}

//turned out to be TOTALLY needed, otherwise memory gets freed right out from under the imagemask's feet, but might be useful for later optimization (pooling memory space during heavy filming)
void dataProviderReleaseData (
                              void *info,
                              const void *data,
                              size_t size
                              )
{
    free(info);
}

-(void)dealloc
{
    [_source release];
    CGImageRelease(_mask);
    CGColorRelease(bgColor);
    
    [_frameRef release];
    
    [self setOnCompleteCallbackBlock:nil];
    [super dealloc];
}

@end
