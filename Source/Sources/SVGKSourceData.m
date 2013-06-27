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
	return [[SVGKSourceData sourceFromData:self.data] retain];
}

+ (SVGKSource*)sourceFromData:(NSData*)data {
	if ([data isKindOfClass:[NSMutableData class]]) {
		data = [[NSData alloc] initWithData:data];
	} else {
		[data retain];
	}
	NSInputStream* stream = [NSInputStream inputStreamWithData:data];
	[stream open];
	
	SVGKSourceData* s = [[[SVGKSourceData alloc] initWithInputSteam:stream] autorelease];
	s.data = data;
	[data release];
	return s;
}

- (void)dealloc
{
	self.data = nil;
	
	[super dealloc];
}

@end
