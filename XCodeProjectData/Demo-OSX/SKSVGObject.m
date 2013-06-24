//
//  SKSVGObject.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SKSVGObject.h"

@implementation SKSVGObject

#define NotImplemented() \
if ([self class] == [SKSVGObject class]) { \
NSAssert(NO, @"This class is meant to be subclassed, and not accessed directly."); \
} else { \
NSAssert(NO, @"The subclass %@ should implement %s.", [self class],  sel_getName(_cmd)); \
} \
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

@interface SKSVGBundleObject ()
@property (readwrite, copy) NSString* fullFileName;
@property (retain, readwrite) NSBundle *theBundle;
@end

@implementation SKSVGBundleObject

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
	NSString *newName = nil;
	NSString *extension = nil;
	[self getFileName:&newName extension:&extension];
	
	NSURL *retURL = [self.theBundle URLForResource:newName withExtension:extension];
	return retURL;
}

- (NSString*)fileName
{
	NSString *newName = nil;
	NSString *extension = nil;
	[self getFileName:&newName extension:&extension];
	
	NSString *fullPath = [self.theBundle pathForResource:newName ofType:extension];
	NSString *retShortName = [[NSFileManager defaultManager] displayNameAtPath:fullPath];
	return retShortName;
}

- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[SKSVGBundleObject class]]) {
		SKSVGBundleObject* bundObj = object;
		return [bundObj.fullFileName isEqualToString:self.fullFileName] && [bundObj.theBundle isEqual:self.theBundle];
	} else if ([object conformsToProtocol:@protocol(SKSVGObject)] || [object isKindOfClass:[SKSVGObject class]]) {
		return [self isEqualToURL:[object svgURL]];
	} else {
		return NO;
	}
}

- (void)dealloc
{
	self.fullFileName = nil;
	self.theBundle = nil;
	
	[super dealloc];
}

@end

@interface SKSVGURLObject ()
@property (retain, readwrite) NSURL *svgURL;
@end

@implementation SKSVGURLObject

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
		NSString *val = nil;
		NSError *err = nil;
		if([tmpURL getResourceValue:&val forKey:NSURLLocalizedNameKey error:&err] == NO)
		{
			NSLog(@"SKSVGObject: Could not find out if extension is hidden in file \"%@\", error: %@", [tmpURL path], [err localizedDescription]);
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
	if (/*[object isKindOfClass:[SKSVGURLObject class]] ||*/ [object conformsToProtocol:@protocol(SKSVGObject)] || [object isKindOfClass:[SKSVGObject class]]) {
		return [self isEqualToURL:[object svgURL]];
	} else {
		return NO;
	}
}

- (void)dealloc
{
	self.svgURL = nil;
	
	[super dealloc];
}

@end
