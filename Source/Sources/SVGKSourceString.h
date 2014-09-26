/**
 
 */
#import <SVGKit/SVGKSource.h>

@interface SVGKSourceString : SVGKSource <NSCopying>

@property (nonatomic, retain, readonly) NSString* rawString;

- (instancetype)initWithString:(NSString*)theStr NS_DESIGNATED_INITIALIZER;
+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString;

@end
