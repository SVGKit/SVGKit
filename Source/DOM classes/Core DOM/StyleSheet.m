#import "StyleSheet.h"
#import "Node.h"
#import "MediaList.h"

@implementation StyleSheet

@synthesize type;
@synthesize disabled;
@synthesize ownerNode;
@synthesize parentStyleSheet;
@synthesize href;
@synthesize title;
@synthesize media;

- (void)dealloc {
  [type RELEASE];
  [ownerNode RELEASE];
  [parentStyleSheet RELEASE];
  [href RELEASE];
  [title RELEASE];
  [media RELEASE];
  [super DEALLOC];
}

@end
