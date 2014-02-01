/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceString : SVGKSource

@property (nonatomic, STRONG) NSString* rawString;

+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString;

@end
