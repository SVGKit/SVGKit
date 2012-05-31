//
//  CALayerFilm.h
//  StyleTouch
//
//  Created by Kevin Stich on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CALayerCamera;

typedef void (^CallbackBlock)(CGImageRef);
//CALayerFilm handles actual image creation
//If you need to take large images or a large number of images in succession use CALayerCamera to facilitate asyncronous picture making
//CALayerFilm operates syncronously, CALayerCamera facilitates asyncronous action of CALayerFilm objects.
//callbackBlock is not implicitly invoked by CALayerFilm, It is invoked by CALayerCamera, therefore invoking -[CALayerFilm snapPhoto] by itself will never invoke callbackBlock as it is a purely syncronous operation
@interface CALayerFilm : NSObject
{
    NSValue *_frameRef;
    CALayer *_source;
    CGImageRef _mask; //optional
    CGColorRef bgColor;
    
@public
    CGAffineTransform contextTransformForSource;
    CallbackBlock _callbackBlock;
    BOOL skipAA;
    //    dispatch_group_t fileGroup; //for syncing file operations (which happen long after intial rendering)
    CALayerCamera *inCamera;
    
@private
    //    CGContextRef _developmentContext; //will be fetched when needed
    NSUInteger _typeFlags; //for internal use only
}


@property (nonatomic, assign)BOOL isMask;
@property (nonatomic, assign)BOOL forResample;
@property (atomic, retain)CALayer *subjectLayer;

@property (atomic, copy)CallbackBlock onCompleteCallbackBlock;
@property (nonatomic, retain)UIColor *backgroundColor;
@property (nonatomic, retain)id callbackParams; //if nil then UIImage is used as callback param (CALayerFilm callback always has 1 param)

-(CALayerFilm *)initWithSource:(CALayer *)sourceLayer;
-(CALayerFilm *)initWithSource:(CALayer *)sourceLayer andMask:(CGImageRef)imageMask;
-(CALayerFilm *)initWithSource:(CALayer *)sourceLayer filmSize:(CGSize)filmSize;
//-(UIImage *)developImage; //Immediately creates a UIImage based on this CALayerFilm instance. Generally should be done off of the main thread
//-(CGLayerRef)developNegatives; //CGLayerRefs cannot be added to View or Layer trees, it can however be used to draw to a context very quickly

-(CGImageRef)newPhoto;

@end
