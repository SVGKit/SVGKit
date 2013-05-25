/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceString : SVGKSource

@property (nonatomic, copy) NSString* rawString;

+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString;

@end
