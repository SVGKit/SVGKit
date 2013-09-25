/**
 
 */
#import <SVGKit/SVGKSource.h>

@interface SVGKSourceString : SVGKSource <NSCopying>

@property (nonatomic, retain, readonly) NSString* rawString;

- (id)initWithString:(NSString*)theStr;
+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString;

@end
