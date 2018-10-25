//
//  DemoSVGObject.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "DemoSVGObject.h"

@implementation DemoSVGObject

#define NotImplemented() \
if ([self isMemberOfClass:[DemoSVGObject class]]) { \
NSLog(@"The class %@ is meant to be subclassed, and not accessed directly.", [self class]); \
} else { \
NSLog(@"The subclass %@ of class %@ should implement %s.", [self class], [DemoSVGObject class], sel_getName(_cmd)); \
} \
[self doesNotRecognizeSelector:_cmd]; \
return nil

- (NSURL *)svgURL
{
	NotImplemented();
}

- (NSString *)fileName
{
	NotImplemented();
}

- (NSString *)fullFileName
{
	NotImplemented();
}

- (BOOL)isEqualToURL:(NSURL*)theURL
{
	if ([self.svgURL isFileURL] && [theURL isFileURL]) {
		id dat1, dat2;
		BOOL bothareValid = YES;
		BOOL theSame = NO;
		if (![[self svgURL] getResourceValue:&dat1 forKey:NSURLFileResourceIdentifierKey error:NULL]) {
			bothareValid = NO;
		}
		if (![theURL getResourceValue:&dat2 forKey:NSURLFileResourceIdentifierKey error:NULL]) {
			bothareValid = NO;
		}
		if (bothareValid) {
			theSame = [dat1 isEqual:dat2];
		}
		return theSame;
	} else if (![self.svgURL isFileURL] && ![theURL isFileURL]) {
		return [[self.svgURL absoluteURL] isEqual:[theURL absoluteURL]];
	} else
		return NO;
}

- (NSUInteger)hash
{
	return [[[self svgURL] absoluteURL] hash];
}

@end

@interface DemoSVGBundleObject ()
@property (readwrite, copy) NSString* fullFileName;
@property (readwrite, strong) NSBundle *theBundle;
@end

@implementation DemoSVGBundleObject

- (id)initWithName:(NSString *)theName
{
	return [self initWithName:theName bundle:[NSBundle mainBundle]];
}

- (id)initWithName:(NSString *)theName bundle:(NSBundle*)aBundle
{
	if (self = [super init]) {
		self.fullFileName = theName;
		self.theBundle = aBundle;
	}
	return self;
}

- (void)getFileName:(out NSString **)filNam extension:(out NSString **)ext
{
	NSParameterAssert(filNam != nil);
	NSParameterAssert(ext != nil);

	*filNam = [self.fullFileName stringByDeletingPathExtension];
	NSString *extension = [self.fullFileName pathExtension];
	*ext = extension ? extension : @"svg";
}

- (NSURL*)svgURL
{
	NSString *newName;
	NSString *extension;
	[self getFileName:&newName extension:&extension];
	
	NSURL *retURL = [self.theBundle URLForResource:newName withExtension:extension];
	return retURL;
}

- (NSString*)fileName
{
	NSString *newName;
	NSString *extension;
	[self getFileName:&newName extension:&extension];
	
	NSString *fullPath = [self.theBundle pathForResource:newName ofType:extension];
	NSString *retShortName = [[NSFileManager defaultManager] displayNameAtPath:fullPath];
	return retShortName;
}

- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[DemoSVGBundleObject class]]) {
		DemoSVGBundleObject* bundObj = object;
		return [bundObj.fullFileName isEqualToString:self.fullFileName] && [bundObj.theBundle isEqual:self.theBundle];
	} else if ([object conformsToProtocol:@protocol(DemoSVGObject)] || [object isKindOfClass:[DemoSVGObject class]]) {
		return [self isEqualToURL:[object svgURL]];
	} else {
		return NO;
	}
}

@end

@interface DemoSVGURLObject ()
@property (strong, readwrite) NSURL *svgURL;
@end

@implementation DemoSVGURLObject

- (id)initWithURL:(NSURL *)aURL
{
	if (self = [super init]) {
		self.svgURL = aURL;
	}
	return self;
}

- (NSString *)fileName
{
	NSURL *tmpURL = self.svgURL;
	
	if([tmpURL isFileURL]){
		NSString *val;
		NSError *err;
		if([tmpURL getResourceValue:&val forKey:NSURLLocalizedNameKey error:&err] == NO)
		{
			NSLog(@"DemoSVGObject: Could not find out if extension is hidden in file \"%@\", error: %@", [tmpURL path], [err localizedDescription]);
			return [tmpURL lastPathComponent];
		} else {
			return val;
		}
	}
	else return [tmpURL lastPathComponent];
}

- (NSString*)fullFileName
{
	return [self.svgURL lastPathComponent];
}

- (BOOL)isEqual:(id)object
{
	if (/*[object isKindOfClass:[DemoSVGURLObject class]] ||*/ [object conformsToProtocol:@protocol(DemoSVGObject)] || [object isKindOfClass:[DemoSVGObject class]]) {
		return [self isEqualToURL:[object svgURL]];
	} else {
		return NO;
	}
}

@end
