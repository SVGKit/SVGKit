//
//  SKSVGObject.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SKSVGObject.h"

@interface SKSVGObject ()
@property (retain, nonatomic, readwrite) NSURL *svgURL;

@end

@implementation SKSVGObject

- (id)initWithURL:(NSURL *)aURL
{
	if (self = [super init]) {
		self.svgURL = aURL;
	}
	return self;
}

- (NSString *)fileName
{
	id val = nil;
	NSError *err = nil;
	NSURL *tmpURL = self.svgURL;
	
	if([tmpURL getResourceValue:&val forKey:NSURLLocalizedNameKey error:&err] == NO)
	{
		NSLog(@"SKSVGObject: Could not find out if extension is hidden in file \"%@\", error: %@", [tmpURL path], [err localizedDescription]);
		return [tmpURL lastPathComponent];
	} else {
		return val;
	}

}

- (void)dealloc
{
	self.svgURL = nil;
	
	[super dealloc];
}


@end
