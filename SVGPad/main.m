//
//  main.m
//  SVGPad
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

int main (int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	int retVal = UIApplicationMain(argc, argv, nil, nil);
	[pool release];
	
	return retVal;
}
