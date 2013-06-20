//
//  SKSVGObject.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SKSVGObject.h"

@implementation SKSVGObject

- (NSURL *)svgURL
{
	if ([self isKindOfClass:[SKSVGObject class]]) {
		NSAssert(NO, @"This class is meant to be subclassed, and not accessed directly");
	}else {
		NSAssert(NO, @"The subclass should implement %s.", sel_getName(_cmd));
	}
	return nil;
}

- (NSString *)fileName
{
	if ([self isKindOfClass:[SKSVGObject class]]) {
		NSAssert(NO, @"This class is meant to be subclassed, and not accessed directly");
	}else {
		NSAssert(NO, @"The subclass should implement %s.", sel_getName(_cmd));
	}
	return nil;
}

- (NSString *)fullFileName
{
	if ([self isKindOfClass:[SKSVGObject class]]) {
		NSAssert(NO, @"This class is meant to be subclassed, and not accessed directly");
	}else {
		NSAssert(NO, @"The subclass should implement %s.", sel_getName(_cmd));
	}
	return nil;
}

- (BOOL)isEqualURL:(NSURL*)theURL
{
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
}

- (NSUInteger)hash
{
	return [[[self svgURL] absoluteURL] hash];
}

@end

@interface SKSVGBundleObject ()
@property (readwrite, copy) NSString* fullFileName;
@property (strong, readwrite) NSBundle *theBundle;
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

- (NSURL*)svgURL
{
	NSString *name = self.fullFileName;
	NSString *newName = [name stringByDeletingPathExtension];
	NSString *extension = [name pathExtension];
    if ([@"" isEqualToString:extension]) {
        extension = @"svg";
    }
	
	NSURL *retURL = [self.theBundle URLForResource:newName withExtension:extension];
	return retURL;
}

- (NSString*)fileName
{
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *name = self.fullFileName;
	NSString *newName = [name stringByDeletingPathExtension];
	NSString *extension = [name pathExtension];
    if ([@"" isEqualToString:extension]) {
        extension = @"svg";
    }
	
	NSString *fullPath = [self.theBundle pathForResource:newName ofType:extension];
	NSString *retShortName = [manager displayNameAtPath:fullPath];
	return retShortName;
}

- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[SKSVGBundleObject class]]) {
		SKSVGBundleObject* bundObj = object;
		return [bundObj.fullFileName isEqualToString:self.fullFileName] && [bundObj.theBundle isEqual:self.theBundle];
	} else if ([object conformsToProtocol:@protocol(SKSVGObject)] || [object isKindOfClass:[SKSVGObject class]]) {
		return [self isEqualURL:[object svgURL]];
	} else {
		return NO;
	}
}

@end

@interface SKSVGURLObject ()
@property (strong, readwrite) NSURL *svgURL;
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
		id val = nil;
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
		return [self isEqualURL:[object svgURL]];
	} else {
		return NO;
	}
}

@end
