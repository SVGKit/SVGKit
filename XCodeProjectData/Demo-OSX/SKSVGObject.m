//
//  SKSVGObject.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SKSVGObject.h"

@interface SKSVGBundleObject ()
@property (copy) NSString *bundleName;
@property (retain) NSBundle *theBundle;
@end

@implementation SKSVGBundleObject

- (id)initWithName:(NSString *)theName
{
	return [self initWithName:theName bundle:[NSBundle mainBundle]];
}

- (id)initWithName:(NSString *)theName bundle:(NSBundle*)aBundle
{
	if (self = [super init]) {
		self.bundleName = theName;
		self.theBundle = aBundle;
	}
	return self;
}

- (NSURL*)svgURL
{
	return [[self.theBundle resourceURL] URLByAppendingPathComponent:self.bundleName];
}

- (NSString*)fileName
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	return [manager displayNameAtPath:[[self.theBundle resourcePath] stringByAppendingPathComponent:self.bundleName]];
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

@end
