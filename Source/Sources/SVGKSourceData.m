//
//  SVGKSourceData.m
//  SVGKit-OSX
//
//  Created by C.W. Betts on 6/24/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SVGKSourceData.h"

@implementation SVGKSourceData

- (id)initFromDataNoMutableCheck:(NSData*)data
{
	NSInputStream* stream = [NSInputStream inputStreamWithData:data];
	[stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.data = data;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	//Use initFromDataNoMutableCheck because the data should already be immutable
	return [[SVGKSourceData alloc] initFromDataNoMutableCheck:self.data];
}

- (id)initFromData:(NSData*)data
{
	if ([data isKindOfClass:[NSMutableData class]]) {
		data = [[NSData alloc] initWithData:data];
	}
	self = [self initFromDataNoMutableCheck:data];

	return self;
}

+ (SVGKSource*)sourceFromData:(NSData*)data {
	SVGKSourceData* s = [[SVGKSourceData alloc] initFromData:data];
	
	return s;
}

@end
