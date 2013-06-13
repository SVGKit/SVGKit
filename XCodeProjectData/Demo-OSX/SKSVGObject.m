//
//  SKSVGObject.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SKSVGObject.h"

@interface SKSVGBundleObject ()
@property (readwrite, copy) NSString* fullFileName;
@property (strong) NSBundle *theBundle;
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

@end
