//
//  SVGKSourceData.m
//  SVGKit-OSX
//
//  Created by C.W. Betts on 6/24/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SVGKSourceData.h"

@interface SVGKSourceData ()
@property (readwrite, strong, nonatomic) NSData *data;
@end

@implementation SVGKSourceData

- (id)initFromDataNoMutableCheck:(NSData*)data
{
	NSInputStream* stream = [[NSInputStream alloc] initWithData:data];
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
	return [self initFromDataNoMutableCheck:data];
}

+ (SVGKSource*)sourceFromData:(NSData*)data {
	SVGKSourceData* s = [[SVGKSourceData alloc] initFromData:data];
	
	return s;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@: Stream: %@, SVG Version: %@, data length: %lu", [self class], [self.stream description], [self.svgLanguageVersion description], [self.data length]];
}

- (NSString*)debugDescription
{
	return [NSString stringWithFormat:@"%@: Stream: %@, SVG Version: %@, data: %@", [self class], [self.stream description], [self.svgLanguageVersion description], [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];
}

@end
