//
//  SVGKSourceData.m
//  SVGKit-OSX
//
//  Created by C.W. Betts on 6/24/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <SVGKit/SVGKSourceData.h>
#import "SVGKSource-private.h"

@interface SVGKSourceData ()
@property (readwrite, retain, nonatomic) NSData *data;
@end

@implementation SVGKSourceData

- (id)initWithDataNoMutableCheck:(NSData*)data
{
	NSInputStream* stream = [[NSInputStream alloc] initWithData:data];
	[stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.data = data;
	}
	[stream release];
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	//Use initFromDataNoMutableCheck because the data should already be immutable
	return [[SVGKSourceData alloc] initWithDataNoMutableCheck:self.data];
}

- (id)initFromData:(NSData*)data
{
	return [self initWithData:data];
}

- (id)initWithData:(NSData*)data
{
	if ([data isKindOfClass:[NSMutableData class]]) {
		data = [[NSData alloc] initWithData:data];
	} else {
		[data retain];
	}
	self = [self initWithDataNoMutableCheck:data];
	[data release];

	return self;
}

+ (SVGKSource*)sourceFromData:(NSData*)data {
	SVGKSourceData* s = [[[SVGKSourceData alloc] initWithData:data] autorelease];
	
	return s;
}

- (void)dealloc
{
	self.data = nil;
	
	[super dealloc];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@, data length: %lu", [self baseDescription], (unsigned long)[self.data length]];
}

- (NSString*)debugDescription
{
	return [NSString stringWithFormat:@"%@, data: %@", [self baseDescription], self.data];
}

@end
