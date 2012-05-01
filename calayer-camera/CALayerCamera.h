//
//  CACamera.h
//  StyleTouch
//
//  Created by Kevin Stich on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@class CALayerFilm;

typedef void(^CACameraCallback)(void);


typedef void (^CACameraUIImageCallback)(UIImage *);
typedef void (^CACameraCGImageCallback)(CGImageRef);
typedef void (^CACameraCGSaveCallback)(NSString *);


//singleton, doesn't need more than one instance, CAFilm primarily influences behavior
//CACamera just handles high level management, ensuring expensive operations do not occur on the main thread 
//MFCamear (rarely needs explicit allocation except for very special behavior)
//CACamera operates primarily on the main thread, and can facilitate callbacks from batched CAFilm instances.
@interface CALayerCamera : NSObject
{
    dispatch_queue_t filmRoll;
    dispatch_queue_t rasterQueue; //used for creating CALayers
    
    
@public
    dispatch_group_t myThings;
    dispatch_queue_t returnQueue;
    
@private
    //    NSUInteger _flags; //not currently used
    //    NSArray *_photoQueue; //contains CAFilm instances
    //    NSArray *_contextPool; //may be needed for optimization, unused for now
}

+(CALayerCamera *)mainCamera;



//@property (nonatomic, copy)CACameraCallback queueCompleteCallback;

-(CALayerCamera *)initWithPriority:(dispatch_queue_priority_t)priority;
-(CALayerCamera *)initWithRenderQueue:(dispatch_queue_t)queueToUse callbackQueue:(dispatch_queue_t)callbackQueue andGroup:(dispatch_group_t)newGroup;
-(CALayerCamera *)initWithPriority:(dispatch_queue_priority_t)priority keepAwayFromMainThread:(BOOL)backgroundOnly;


-(void)shootOut:(CACameraCallback)finishBlock;





-(void)takeImageWithFilm:(CALayerFilm *)film;






//Save image functions callback after writing a file to disk!
-(void)saveImagesOf:(CALayer *)rasterLayer forSizes:(NSDictionary *)filmPathsAndSizes withPathCallback:(void (^)(NSString *filePath))pathCallback;

-(void)saveImageOf:(CALayer *)rasterLayer forSize:(CGSize)filmSize toPath:(NSString *)savePath withPathCallback:(void (^)(NSString *filePath))pathCallback;
-(void)saveImageOf:(CALayer *)rasterLayer forSize:(CGSize)filmSize toPaths:(NSArray *)savePaths withPathCallback:(void (^)(NSString *filePath))pathCallback;
//-(void)rasterize:(id<Rasterizable>)rasterizable forSize:(CGSize)filmSize toPath:(NSString *)savePath withPathCallback:(void (^)(NSString *filePath))pathCallback;

//no mask will be applied, even if targetLayer.mask != nil
-(void)takeImageOf:(CALayer *)targetLayer withCallback:(void (^)(CGImageRef image))callbackBlock;                                

//if mask image is nil , an image is taken from targetLayer.mask


//Take image functions returns CGImageRefs (easily wrappable in UIImages)
-(void)takeImageOf:(CALayer *)targetLayer withMask:(CALayer *)maskLayer withCallback:(void (^)(CGImageRef image))callbackBlock; 
-(void)takeImageOf:(CALayer *)targetLayer withMask:(CALayer *)maskLayer withCallback:(void (^)(CGImageRef image))callbackBlock andScale:(CGFloat)targetScale; 

-(void)takeImageOf:(CALayer *)targetLayer withMaskImage:(CGImageRef)maskImage withCallback:(void (^)(CGImageRef image))callbackBlock withOffset:(CGPoint)offsetPoint andScale:(CGFloat)scale;



-(void)scaleImage:(CGImageRef)targetImage byAmount:(CGFloat)scaleFactor withCallback:(void (^)(CGImageRef image))callbackBlock;

-(void)takeUIImageOf:(CALayer *)sourceLayer withCallback:(CACameraUIImageCallback)callbackBlock;
-(void)takeUIImageOf:(CALayer *)targetLayer withMask:(CALayer *)maskLayer withCallback:(CACameraUIImageCallback)callbackBlock andScale:(CGFloat)targetScale; 

#pragma mark callbacks from CAFilm
//currently unneeded, maybe useful in the future...
//-(void)filmDeveloped:(CAFilm *)finishedFilm;

@end
