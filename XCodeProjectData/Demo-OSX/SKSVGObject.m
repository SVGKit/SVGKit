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
@end

@implementation SKSVGBundleObject

- (id)initWithName:(NSString *)theName
{
	if (self = [super init]) {
		self.bundleName = theName;
	}
	return self;
}

- (NSURL*)svgURL
{
	return [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:self.bundleName];
}

- (NSString*)fileName
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	return [manager displayNameAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.bundleName]];
}

- (void)dealloc
{
	self.bundleName = nil;
	
	[super dealloc];
}

@end



@interface SKSVGURLObject ()
@property (retain, nonatomic, readwrite) NSURL *svgURL;

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

- (void)dealloc
{
	self.svgURL = nil;
	
	[super dealloc];
}


@end
