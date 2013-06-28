
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

static SVGKCache *cacheObject = nil;
static SVGKCache *cacheObjectGenerator()
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cacheObject = [[SVGKCache alloc] init];
	});
	
	return cacheObject;
}

#define CacheObjectCreateOnDemand (cacheObject ? cacheObject : cacheObjectGenerator())

#define isNotCached() DDLogError(@"[%@] ERROR: Caching is currently disabled: no action taken.", [SVGKImage class])

@implementation SVGKCache
@synthesize caching = _caching;
- (void)setCaching:(BOOL)caching
{
	if (caching) {
		if (!self.imageCache) {
			DDLogVerbose(@"[%@] INFO: generating image cache.", [SVGKImage class]);
			self.imageCache = [NSMutableDictionary dictionary];
		}
	} else if (self.imageCache != nil) {
		DDLogVerbose(@"[%@] INFO: deleting image cache, %li images purged.", [SVGKImage class], (long)[self count]);
		self.imageCache = nil;
	}
	_caching = caching;
}

- (SVGKImage*)cachedImageForName:(NSString*)theName
{
	if (_caching) {
		return (self.imageCache)[theName];
	} else {
		isNotCached();
		return nil;
	}
}

- (NSUInteger)count
{
	if (_caching) {
		return [self.imageCache count];
	} else {
		isNotCached();
		return 0;
	}
}

- (void)removeAllCachedImages
{
	if (_caching) {
		[self.imageCache removeAllObjects];
	} else {
		isNotCached();
	}
}

- (void)removeCachedObjectWithName:(NSString*)theName
{
	if (_caching) {
		[self.imageCache removeObjectForKey:theName];
	} else {
		isNotCached();
	}
}

- (void)addCachedObject:(SVGKImage*)theImage forName:(NSString*)theName
{
	if (_caching) {
		(self.imageCache)[theName] = theImage;
	} else {
		isNotCached();
	}
}

- (NSArray *)allCachedImageNames
{
	if (self.caching) {
		return [self.imageCache allKeys];
	} else {
		isNotCached();
		return @[];
	}
}

- (void)dealloc
{
	DDLogError(@"[%@] ERROR: How did dealloc get called!?", [self class]);
	self.imageCache = nil;
	
	[super dealloc];
}

@end

@implementation SVGKImage (CacheManagement)
@dynamic nameUsedToInstantiate;

+ (void)clearSVGImageCache
{
	if (CacheObjectCreateOnDemand.caching) {
		DDLogInfo(@"[%@] Purging cache of %li SVGKImage's...", self, (long)[cacheObject count] );
		[cacheObject removeAllCachedImages];
	}else {
		DDLogInfo(@"[%@] Nothing to purge...", self);
	}
}

+ (void)removeSVGImageCacheNamed:(NSString*)theName
{
	if (CacheObjectCreateOnDemand.caching) {
		[cacheObject removeCachedObjectWithName:theName];
	}
}

+ (NSArray*)storedCacheNames
{
	if (CacheObjectCreateOnDemand.caching) {
		return [cacheObject allCachedImageNames];
	} else {
		return @[];
	}
}

+ (BOOL)isCacheEnabled
{
	return CacheObjectCreateOnDemand.caching;
}

+ (void)enableCache
{
	CacheObjectCreateOnDemand.caching = YES;
}

+ (void)disableCache
{
	CacheObjectCreateOnDemand.caching = NO;
}

+ (SVGKImage*)cachedImageForName:(NSString*)theName
{
	if (CacheObjectCreateOnDemand.caching) {
		return [cacheObject cachedImageForName:theName];
	} else {
		return nil;
	}
}

@end

@implementation SVGKImage (CacheManagementPrivate)

+ (void)storeImageCache:(SVGKImage*)theImage forName:(NSString*)theName
{
	if (CacheObjectCreateOnDemand.caching) {
		[cacheObject addCachedObject:theImage forName:theName];
	}
}

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
+(void) didReceiveMemoryWarningNotification:(NSNotification*) notification
{
	if (CacheObjectCreateOnDemand.caching) {
		DDLogWarn(@"[%@] Low-mem; purging cache of %li SVGKImage's...", self, (long)[cacheObject count] );
		
		[cacheObject removeAllCachedImages]; // once they leave the cache, if they are no longer referred to, they should automatically dealloc
	} else {
		DDLogWarn(@"[%@] Low-mem, but no cache to purge...", self);
	}
}
#endif

@end
