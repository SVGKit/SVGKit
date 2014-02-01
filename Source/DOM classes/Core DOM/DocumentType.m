//
//  DocumentType.m
//  SVGKit
//
//  Created by adam on 23/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DocumentType.h"

/*
 in case we need to redeclare them readwrite:
 @property(nonatomic, STRONG,readonly) NSString* name;
 @property(nonatomic, STRONG,readonly) NamedNodeMap* entities;
 @property(nonatomic, STRONG,readonly) NamedNodeMap* notations;
 
 // Introduced in DOM Level 2:
 @property(nonatomic, STRONG,readonly) NSString* publicId;
 
 // Introduced in DOM Level 2:
 @property(nonatomic, STRONG,readonly) NSString* systemId;
 
 // Introduced in DOM Level 2:
 @property(nonatomic, STRONG,readonly) NSString* internalSubset;

 */

@implementation DocumentType

@synthesize name;
@synthesize entities;
@synthesize notations;

// Introduced in DOM Level 2:
@synthesize publicId;

// Introduced in DOM Level 2:
@synthesize systemId;

// Introduced in DOM Level 2:
@synthesize internalSubset;

- (void)dealloc {
  [name RELEASE];
  [entities RELEASE];
  [notations RELEASE];
  [publicId RELEASE];
  [systemId RELEASE];
  [internalSubset RELEASE];
  [super DEALLOC];
}

@end
