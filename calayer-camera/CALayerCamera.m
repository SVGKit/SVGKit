//
//  CALayerCamera.m
//  StyleTouch
//
//  Created by Kevin Stich on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
//#import "Rasterizable.h"

#import <objc/runtime.h>

#import "CALayerCamera.h"
#import "CALayerFilm.h"


typedef struct {
    CallbackBlock theCallback;
    CGImageRef callbackParam;
    
} CallbackFormat;


static void *Block_copy_release(void *block);
//guaranteed to return a stack block without leaking any memory
//current implementation is unoptimal, it should be possible to check before making a copy
static void *Block_copy_release(void *block)
{
    void *temp = Block_copy(block);
    Block_release(block);
    return temp;
}

//static dispatch_group_t everythingGroup = NULL;
static void mainThreadCallback(void *callbackInfo)
{
    CallbackFormat *callbackFormat = (CallbackFormat *)callbackInfo;
    CallbackBlock callback = callbackFormat->theCallback;
    CGImageRef callbackParam = callbackFormat->callbackParam;
    
    
    callback(callbackParam);
    
    free(callbackInfo);
    Block_release(callback);
    CGImageRelease(callbackParam);
}

static void dispatchTrampoline(void *context) //could be anything
{
    CallbackFormat *callbackInfo = NULL;
    //   @try
    //    {
    CALayerFilm *filmContext = (CALayerFilm *)context;
    CGImageRef thePicture = [filmContext newPhoto];
    
    callbackInfo = malloc(sizeof(CallbackFormat));
    callbackInfo->theCallback = Block_copy(filmContext->_callbackBlock);
    callbackInfo->callbackParam = thePicture;
    
    CALayerCamera *fromCamera = filmContext->inCamera;
    dispatch_group_t fileGroup = fromCamera->myThings;
    [filmContext release]; //done with that ish, eventually put this back in the film pool?
    
    //    if( fileGroup == NULL )
    //        fileGroup = everythingGroup;
    
    dispatch_group_async_f( fileGroup, fromCamera->returnQueue, (void *)callbackInfo, mainThreadCallback );
    
    //    }
    //    @catch(NSError *e)
    //    {
    //        if( callbackInfo != NULL )
    //            free(callbackInfo);
    //        NSLog(@"Holy crap the universe has failed %@", e);
    //    }
}

@implementation CALayerCamera

//@synthesize queueCompleteCallback;

+(void)initialize
{
    //    if( self == [CALayerCamera class] )
    //        everythingGroup = dispatch_group_create();
}

+(CALayerCamera *)mainCamera
{
    static CALayerCamera *_mainCamera = nil;
    if(_mainCamera == nil )
        _mainCamera = [[CALayerCamera alloc] initWithPriority:DISPATCH_QUEUE_PRIORITY_HIGH];
    return _mainCamera;
}

-(CALayerCamera *)initWithPriority:(dispatch_queue_priority_t)priority
{
    return [self initWithPriority:priority keepAwayFromMainThread:NO];
}

-(CALayerCamera *)initWithRenderQueue:(dispatch_queue_t)queueToUse callbackQueue:(dispatch_queue_t)callbackQueue andGroup:(dispatch_group_t)newGroup
{
    self = [super init];
    if( self != nil )
    {
        dispatch_retain(queueToUse);
        dispatch_retain(newGroup);
        dispatch_retain(callbackQueue);
        
        filmRoll = queueToUse;
        myThings = newGroup;
        returnQueue = callbackQueue;
    }
    return self;
}

-(CALayerCamera *)initWithPriority:(dispatch_queue_priority_t)priority keepAwayFromMainThread:(BOOL)backgroundOnly
{
    self = [super init];
    if( self != nil )
    {
        filmRoll = dispatch_get_global_queue(priority, 0ul);//dispatch_queue_create("CameraQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_retain(filmRoll); //unnecessary, technically, but makes me sleep better at night
        
        myThings = dispatch_group_create();
        
        returnQueue = (backgroundOnly) ? dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul) : dispatch_get_main_queue();
        dispatch_retain(returnQueue);
    }
    return self;
}

-(void)dealloc
{
    //    dispatch_release(filmRoll); //this is a global queue, shouldn't release it :X
    dispatch_release(myThings);
    dispatch_release(filmRoll);
    dispatch_release(returnQueue);
    
//    [self setQueueCompleteCallback:nil];
    
    [super dealloc];
}

-(void)shootOut:(CACameraCallback)finishBlock
{
    dispatch_async(filmRoll, ^(void){
        dispatch_group_wait(myThings, DISPATCH_TIME_FOREVER); //these will schedule file operations on the main queue, we will wait forever for this part to complete
        dispatch_async(returnQueue, finishBlock);
    });
    
    //file operations will be scheduled on the mainqueue, worst case schenario WebKit should retry until it gets them
    
    //    dispatch_group_wait(everythingGroup, dispatch_time(DISPATCH_TIME_NOW, 3.0)); //wait 3 seconds for file operations, this tends to deadlock a lot :( Times < 10 seconds aren't handled accurately
}

-(void)takeImageWithFilm:(CALayerFilm *)film
{
    [film retain]; //need to retain for non-main threads
    film->inCamera = self;
    dispatch_group_async_f(myThings, filmRoll, (void *)film, dispatchTrampoline);
}

-(void)takeUIImageOf:(CALayer *)sourceLayer withCallback:(CACameraUIImageCallback)callbackBlock
{
    callbackBlock = Block_copy_release(callbackBlock);
    [self takeImageOf:sourceLayer withCallback:^(CGImageRef imageRef) {
        UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        callbackBlock(image);
        Block_release(callbackBlock);
        [image release];
    }];
}

-(void)takeUIImageOf:(CALayer *)sourceLayer withMask:(CALayer *)maskLayer withCallback:(CACameraUIImageCallback)callbackBlock andScale:(CGFloat)targetScale
{
    callbackBlock = Block_copy_release(callbackBlock);
    
    [self takeImageOf:sourceLayer withMask:maskLayer withCallback:^(CGImageRef imageRef) {
        UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        callbackBlock(image);
        Block_release(callbackBlock);
        [image release];
    } andScale:targetScale];
}

-(void)takeImageOf:(CALayer *)targetLayer withCallback:(void (^)(CGImageRef image))callbackBlock
{
    CALayerFilm *thisFilm = [[CALayerFilm alloc] initWithSource:targetLayer];
    [thisFilm setOnCompleteCallbackBlock:callbackBlock];
    
    //    [thisFilm setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.5f]];
    
    CATransform3D layerTransform = targetLayer.transform;
    thisFilm->contextTransformForSource = CGAffineTransformMakeTranslation(-layerTransform.m41, -layerTransform.m42);
    //    dispatch_function_t
    [self takeImageWithFilm:thisFilm];
    [thisFilm release];
}

-(void)saveImagesOf:(CALayer *)rasterLayer forSizes:(NSDictionary *)filmPathsAndSizes withPathCallback:(void (^)(NSString *filePath))pathCallback
{
    //    CALayer *rasterLayer = [rasterizable rasterizableLayer];
    
    //    void (^pathCallCopy)(NSString) = Block_copy(pathCallback);
    for ( NSObject *saveStructure in filmPathsAndSizes )
    {
        CGSize imageSize = [(NSValue *)[filmPathsAndSizes objectForKey:saveStructure] CGSizeValue];
        if( [saveStructure isKindOfClass:[NSArray class]] )
            [self saveImageOf:rasterLayer forSize:imageSize toPaths:(NSArray *)saveStructure withPathCallback:pathCallback];
        else
            [self saveImageOf:rasterLayer forSize:imageSize toPath:(NSString *)saveStructure withPathCallback:pathCallback];
    }
}

-(void)saveImageOf:(CALayer *)rasterLayer forSize:(CGSize)filmSize toPath:(NSString *)savePath withPathCallback:(void (^)(NSString *filePath))pathCallback
{
    
    CALayerFilm *rasterFilm = [[CALayerFilm alloc] initWithSource:rasterLayer];// handling this here for easier debugging filmSize:filmSize];
    
    
    CGSize nativeSize = rasterLayer.bounds.size;
    CGFloat width = nativeSize.width;//[theDocument width];
    CGFloat height = nativeSize.height;//[theDocument height];
    
    CGFloat scaleX = filmSize.width / width;
    CGFloat scaleY = filmSize.height / height;
    CGFloat scale = (scaleX < scaleY) ? scaleX : scaleY;
    
    
    rasterFilm->contextTransformForSource = CGAffineTransformMakeScale(scale, scale);
    
    [rasterFilm setOnCompleteCallbackBlock:^(CGImageRef imageRef) {
        
        NSString *saveTarget = nil;
        NSData *imageData = nil;
        if( imageRef != NULL )
            imageData = UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]);
        if( [imageData length] == 0 )
        {
            //error generating file
            NSLog(@"Error generating image for path %@", savePath);
        }
        else 
        {
            [imageData writeToFile:savePath atomically:YES];
            saveTarget = savePath;
        }
        
        if( pathCallback != nil )
            pathCallback(saveTarget);
    }];
    
    [self takeImageWithFilm:rasterFilm];
    [rasterFilm release];
}

//copy pasta'd for quick testing, should only need one function doing this
-(void)saveImageOf:(CALayer *)rasterLayer forSize:(CGSize)filmSize toPaths:(NSArray *)savePaths withPathCallback:(void (^)(NSString *filePath))pathCallback
{
    
    CALayerFilm *rasterFilm = [[CALayerFilm alloc] initWithSource:rasterLayer];// handling this here for easier debugging filmSize:filmSize];
    
    
    CGSize nativeSize = rasterLayer.bounds.size;
    CGFloat width = nativeSize.width;//[theDocument width];
    CGFloat height = nativeSize.height;//[theDocument height];
    
    CGFloat scaleX = filmSize.width / width;
    CGFloat scaleY = filmSize.height / height;
    CGFloat scale = (scaleX < scaleY) ? scaleX : scaleY;
    
    
    rasterFilm->contextTransformForSource = CGAffineTransformMakeScale(scale, scale);
    
    [rasterFilm setOnCompleteCallbackBlock:^(CGImageRef imageRef) 
     {
         NSData *imageData = nil;
         if( imageRef != NULL )
             imageData = UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]);
         if( [imageData length] == 0 )
         {
             //error generating file
             NSLog(@"Error generating image for path %@", [savePaths objectAtIndex:0]);
             
             if( pathCallback != nil )
                 pathCallback(nil);
         }
         else 
         {
             NSFileManager *fileManager = [[NSFileManager alloc] init];
             NSString *firstPath = nil;
             NSError *theError = nil;
             for( NSString *savePath in savePaths )
             {
                 if( firstPath == nil )
                 {
                     firstPath = savePath;
                     [imageData writeToFile:savePath atomically:YES];
                 }
                 else {
                     [fileManager createSymbolicLinkAtPath:savePath withDestinationPath:firstPath error:&theError];
                     //                [fileManager copyItemAtPath:firstPath toPath:savePath error:&theError];
                     if( theError != nil && [theError code] != 516 ) //516 is fileALreadyExists error, likely during testing, impossible in app (we don't want to override our fiels unless we havea d amned good reason)
                         NSLog(@"Error copying file %@ to %@ with error %@", firstPath, savePath, theError);
                 }
                 
                 if( pathCallback != nil )
                 {
                     //                @synchronized(pathCallback)
                     //                {
                     pathCallback(savePath);
                     //                }
                 }
             }
             [fileManager release];
         }
     }];
    
    [self takeImageWithFilm:rasterFilm];
    [rasterFilm release];
}


-(void)takeImageOf:(CALayer *)targetLayer withMask:(CALayer *)maskLayer withCallback:(void (^)(CGImageRef))callbackBlock andScale:(CGFloat)targetScale
{
    CALayerFilm *theFilm = [[CALayerFilm alloc] initWithSource:maskLayer];
    [theFilm setIsMask:YES]; //tells it to draw alpha only
    
    //    callbackBlock = Block_copy(callbackBlock);
    CATransform3D layerTransform = maskLayer.transform;
    CGPoint offsetPoint = CGPointMake(layerTransform.m41, layerTransform.m42);
    //    theFilm->contextTransformForSource = CGAffineTransformMakeTranslation(-layerTransform.m41, -layerTransform.m42);
    [theFilm setOnCompleteCallbackBlock:(CallbackBlock)^(CGImageRef imageRef) {
        [self takeImageOf:targetLayer withMaskImage:imageRef withCallback:callbackBlock withOffset:offsetPoint andScale:targetScale];
    }];
    theFilm->contextTransformForSource = CGAffineTransformMakeScale(targetScale, targetScale);
    
    [self takeImageWithFilm:theFilm];
    [theFilm release];
}

-(void)takeImageOf:(CALayer *)targetLayer withMask:(CALayer *)maskLayer withCallback:(void (^)(CGImageRef image))callbackBlock
{
    CALayerFilm *theFilm = [[CALayerFilm alloc] initWithSource:maskLayer];
    [theFilm setIsMask:YES]; //tells it to draw alpha only
    
    callbackBlock = Block_copy(callbackBlock);
    CATransform3D layerTransform = maskLayer.transform;
    CGPoint offsetPoint = CGPointMake(layerTransform.m41, layerTransform.m42);
    //    theFilm->contextTransformForSource = CGAffineTransformMakeTranslation(-layerTransform.m41, -layerTransform.m42);
    [theFilm setOnCompleteCallbackBlock:(CallbackBlock)^(CGImageRef maskImageRef) {
        [self takeImageOf:targetLayer withMaskImage:maskImageRef withCallback:callbackBlock withOffset:offsetPoint andScale:1.0f];
    }];
    [self takeImageWithFilm:theFilm];
    [theFilm release];
}

-(void)takeImageOf:(CALayer *)targetLayer withMaskImage:(CGImageRef)maskImage withCallback:(void (^)(CGImageRef image))callbackBlock withOffset:(CGPoint)offsetPoint andScale:(CGFloat)scale 
{
    CALayerFilm *theFilm = [[CALayerFilm alloc] initWithSource:targetLayer andMask:maskImage];
    
    if( callbackBlock != nil )
        [theFilm setOnCompleteCallbackBlock:(CallbackBlock)callbackBlock];
    
    //    CATransform3D layerTransform = targetLayer.transform;
    //this is just by happenstance...
    //    theFilm->contextTransformForSource = CGAffineTransformScale(CGAffineTransformMakeTranslation(-offsetPoint.x, -offsetPoint.y), scale, scale);
    theFilm->contextTransformForSource = CGAffineTransformTranslate(CGAffineTransformMakeScale(scale, scale), -offsetPoint.x, -offsetPoint.y);
    [self takeImageWithFilm:theFilm];
    [theFilm release];
}

-(void)scaleImage:(CGImageRef)targetImage byAmount:(CGFloat)scaleFactor withCallback:(void (^)(CGImageRef image))callbackBlock
{
    CALayer *imageLayer = [CALayer layer];
    [imageLayer setFrame:CGRectMake(0.0f, 0.0f, CGImageGetWidth(targetImage), CGImageGetHeight(targetImage))];
    [imageLayer setContents:(id)targetImage];
    
    CALayerFilm *theFilm = [[CALayerFilm alloc] initWithSource:imageLayer];
    [theFilm setOnCompleteCallbackBlock:callbackBlock];
    theFilm->contextTransformForSource = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    
    [theFilm setForResample:YES];
    
    [self takeImageWithFilm:theFilm];
    [theFilm release];
}


@end
