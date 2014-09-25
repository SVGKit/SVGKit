//
//  Attr.m
//  SVGKit
//
//  Created by adam on 22/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SVGKAttr.h"

#import "SVGKNode+Mutable.h"

@interface SVGKAttr()
 @property(nonatomic,retain,readwrite) NSString* name;
 @property(nonatomic,readwrite) BOOL specified;
 @property(nonatomic,retain,readwrite) NSString* value;
 
 // Introduced in DOM Level 2:
 @property(nonatomic,retain,readwrite) SVGKElement* ownerElement;
@end

@implementation SVGKAttr

@synthesize name;
@synthesize specified;
@synthesize value;

// Introduced in DOM Level 2:
@synthesize ownerElement;

- (id)initWithName:(NSString*) n value:(NSString*) v
{
    self = [super initType:DOMNodeType_ATTRIBUTE_NODE name:n value:v];
    if (self)
	{
		self.name = n;
		self.value = v;
    }
    return self;
}

- (id)initWithNamespace:(NSString*) ns qualifiedName:(NSString*) qn value:(NSString *)v
{
    self = [super initType:DOMNodeType_ATTRIBUTE_NODE name:qn value:v inNamespace:ns];
	if (self)
	{
		self.name = qn;
		self.value = v;
    }
    return self;
}

- (void)dealloc {
    self.name = nil;
	self.value = nil;
  self.ownerElement = nil;
    [super dealloc];
}

@end
