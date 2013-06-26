
#import "SVGKImage.h"
#import "SVGKImage+CacheManagement.h"

@interface SVGKCache : NSObject
@property (readwrite, nonatomic, retain) NSMutableDictionary *imageCache;
@property (readwrite, nonatomic, getter = isCaching) BOOL caching;

- (NSArray *)allCachedImageNames;
- (void)addCachedObject:(SVGKImage*)theImage forName:(NSString*)theName;
- (void)removeCachedObjectWithName:(NSString*)theName;
- (void)removeAllCachedImages;
- (NSUInteger)count;
- (SVGKImage*)cachedImageForName:(NSString*)theName;

@end

static SVGKCache* cacheObject()
{
	static SVGKCache *svgCacheObject = nil;
	if (svgCacheObject == nil) {
		svgCacheObject = [[SVGKCache alloc] init];
	}
	return svgCacheObject;
}


#define svgCacheObject cacheObject()

@implementation SVGKCache
@synthesize caching = _caching;
- (void)setCaching:(BOOL)caching
{
	_caching = caching;
	if (caching) {
		if (!self.imageCache) {
			DDLogVerbose(@"[%@] INFO: generating image cache.", [self class]);
			self.imageCache = [NSMutableDictionary dictionary];
		}
	} else if (self.imageCache != nil) {
		DDLogVerbose(@"[%@] INFO: deleting image cache.", [self class]);
		self.imageCache = nil;
	}
}

- (id)init
{
	if (self = [super init]) {
		//self.caching = NO;
	}
	return self;
}

- (SVGKImage*)cachedImageForName:(NSString*)theName
{
	if (_caching) {
		return [self.imageCache objectForKey:theName];
	} else {
		DDLogWarn(@"[%@] Caching is currently disabled: no action taken", [self class]);
		return nil;
	}
}

- (NSUInteger)count
{
	if (_caching) {
		return [self.imageCache count];
	} else {
		DDLogWarn(@"[%@] Caching is currently disabled: no action taken", [self class]);
		return 0;
	}
}

- (void)removeAllCachedImages
{
	if (_caching) {
		[self.imageCache removeAllObjects];
	} else {
		DDLogWarn(@"[%@] Caching is currently disabled: no action taken", [self class]);
	}
}

- (void)removeCachedObjectWithName:(NSString*)theName
{
	if (_caching) {
		[self.imageCache removeObjectForKey:theName];
	} else {
		DDLogWarn(@"[%@] Caching is currently disabled: no action taken", [self class]);
	}
}

- (void)addCachedObject:(SVGKImage*)theImage forName:(NSString*)theName
{
	if (_caching) {
		[self.imageCache setObject:theImage forKey:theName];
	} else {
		DDLogWarn(@"[%@] Caching is currently disabled: no action taken", [self class]);
	}
}

- (NSArray *)allCachedImageNames
{
	if (self.caching) {
		return [self.imageCache allKeys];
	} else {
		DDLogWarn(@"[%@] Caching is currently disabled: no action taken", [self class]);
		return @[];
	}
}

- (void)dealloc
{
	DDLogError(@"[%@] ERROR: how did dealloc get called!?", [self class]);
}

@end


@implementation SVGKImage (CacheManagement)

@dynamic nameUsedToInstantiate;

+ (void)clearSVGImageCache
{
	if (svgCacheObject.caching) {
		DDLogInfo(@"[%@] Purging cache of %li SVGKImage's...", self, (long)[svgCacheObject count] );
		[svgCacheObject removeAllCachedImages];
	}else {
		DDLogInfo(@"[%@] Nothing to purge...", self);
	}
}

+ (void)removeSVGImageCacheNamed:(NSString*)theName
{
	if (svgCacheObject.caching) {
		[svgCacheObject removeCachedObjectWithName:theName];
	}
}

+ (NSArray*)storedCacheNames
{
	if (svgCacheObject.caching) {
		return [svgCacheObject allCachedImageNames];
	} else {
		return @[];
	}
}

+ (BOOL)isCacheEnabled
{
	return svgCacheObject.caching;
}

+ (void)enableCache
{
	svgCacheObject.caching = YES;
}

+ (void)disableCache
{
	svgCacheObject.caching = NO;
}

@end

@implementation SVGKImage (CacheManagementPrivate)

+ (SVGKImage*)cachedImageForName:(NSString*)theName
{
	return [svgCacheObject cachedImageForName:theName];
}

+ (void)storeImageCache:(SVGKImage*)theImage forName:(NSString*)theName
{
	[svgCacheObject addCachedObject:theImage forName:theName];
}

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
+(void) didReceiveMemoryWarningNotification:(NSNotification*) notification
{
	if (svgCacheObject.caching) {
		DDLogWarn(@"[%@] Low-mem; purging cache of %li SVGKImage's...", self, (long)[svgCacheObject count] );
		
		[svgCacheObject removeAllCachedImages]; // once they leave the cache, if they are no longer referred to, they should automatically dealloc
	} else {
		DDLogWarn(@"[%@] Low-mem, but no cache to purge...", self);
	}
}
#endif

@end
