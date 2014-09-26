#import "SVGKStyleSheet.h"

@implementation SVGKStyleSheet

@synthesize type;
@synthesize disabled;
@synthesize ownerNode;
@synthesize parentStyleSheet;
@synthesize href;
@synthesize title;
@synthesize media;

- (void)dealloc {
  [type release];
  [ownerNode release];
  [parentStyleSheet release];
  [href release];
  [title release];
  [media release];
  [super dealloc];
}

@end
