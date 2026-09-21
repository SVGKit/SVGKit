//
//  SVGKImage+CSS.h
//  DMSeatCore
//
//  Created by lichentao on 2019/9/17.
//  Copyright © 2019 damai. All rights reserved.
//

#import "SVGKImage.h"
NS_ASSUME_NONNULL_BEGIN

@interface SVGKImage (CSS)

#pragma mark - CSS
/**
    @description 通过字符串设置CSS-Selector属性
    @param cssString: @".testid {fill : #0ff;} #testclass {fill : #0f0;opacity : 1;}"
    @return BOOL 注入成功
    
    @Example
    NSString *testCssString = [NSString stringWithFormat:@".testid {fill : #0ff;} #testclass {fill : #0f0;opacity : 1;}"];
    [svgkimage configStyleSheetStr:testCssString];
 */
- (BOOL)configStyleSheetStr:(NSString *)cssString;

/**
    给Element注入Selector (nodeName : selName)
    @param nodeName:(@"id" || @"class")
    @param selName: @".testid" || @"#testclass"
    @Example
    @id-mode
    [svgImage configNodeSelector:element NodeName:@“id” SelectorName:@“.testid”];
    @class-mode
    [svgImage configNodeSelector:element NodeName:@“class”    SelectorName:@“#testclass”];
 */
- (void)configNodeSelector:(Element *)element NodeName:(NSString *)nodeName SelectorName:(NSString *)selName;

@end

NS_ASSUME_NONNULL_END
