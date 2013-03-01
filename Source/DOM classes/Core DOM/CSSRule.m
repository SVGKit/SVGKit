#import "CSSRule.h"

@implementation CSSRule

@synthesize type;
@synthesize cssText;

@synthesize parentStyleSheet;
@synthesize parentRule;

- (void)dealloc {
  self.cssText = nil;
  self.parentRule = nil;
  self.parentStyleSheet = nil;
  [super dealloc];
}

@end
