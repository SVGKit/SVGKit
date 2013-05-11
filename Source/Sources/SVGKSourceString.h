/**
 
 */
#import <SVGKit/SVGKSource.h>

@interface SVGKSourceString : SVGKSource

@property (nonatomic, retain) NSString* rawString;

+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString;

@end
