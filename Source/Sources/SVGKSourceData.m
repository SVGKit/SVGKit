//
//  SVGKSourceData.m
//  SVGKit-OSX
//
//  Created by C.W. Betts on 6/24/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SVGKSourceData.h"

@implementation SVGKSourceData

- (id)copyWithZone:(NSZone *)zone
{
	return [[SVGKSourceData alloc] initFromData:self.data];
}

- (id)initFromData:(NSData*)data
{
	if ([data isKindOfClass:[NSMutableData class]]) {
		data = [[NSData alloc] initWithData:data];
	} else {
		[data retain];
	}
	NSInputStream* stream = [NSInputStream inputStreamWithData:data];
	[stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.data = data;
	}
	[data release];

	return self;
}

+ (SVGKSource*)sourceFromData:(NSData*)data {
	SVGKSourceData* s = [[[SVGKSourceData alloc] initFromData:data] autorelease];
	return s;
}

- (void)dealloc
{
	self.data = nil;
	
	[super dealloc];
}

@end
