//
//  SVGKImage+CSS.m
//  DMSeatCore
//
//  Created by lichentao on 2019/9/17.
//  Copyright © 2019 damai. All rights reserved.
//

#import "SVGKImage+CSS.h"
#import "CSSStyleSheet.h"
#import "CSSStyleRule.h"
#import "StyleSheetList+Mutable.h"
#import "CSSRuleList+Mutable.h"

@implementation SVGKImage (CSS)

// 样式Style 字符串
- (BOOL)configStyleSheetStr:(NSString *)cssString{
    // 遍历styleRule (selector如果有则z替换，其他selector追加到最后一个object的s样式表中)
    BOOL styleHasRule = NO;
    NSString* c = [cssString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if( c.length > 0 )
    {
        CSSStyleSheet* parsedStylesheet = [[CSSStyleSheet alloc] initWithString:c];
        if (self.DOMDocument.rootElement.styleSheets.internalArray.count == 0) {
            // 如果没有直接添加CSSStyleSheet
            [self.DOMDocument.rootElement.styleSheets.internalArray addObject:parsedStylesheet];
        }else{
            // 存在StyleSheet 则 查找是否z存在StyleRule
            // 有则忽略，没有加到最后的stylesheet中
            for(CSSStyleRule* genericRule in parsedStylesheet.cssRules.internalArray.reverseObjectEnumerator) {
              styleHasRule= [self constructStyleSheetsInternalArray:genericRule];
            }
        }
    }
    return styleHasRule;
}

// 遍历stylelist sheet  CSSStyleRule
- (BOOL)constructStyleSheetsInternalArray:(CSSStyleRule *)styleConfigRule{
    BOOL isCompareSelector = NO;
    @autoreleasepool
    {
        for( StyleSheet* genericSheet in self.DOMDocument.rootElement.styleSheets.internalArray.reverseObjectEnumerator)
        {
            if( [genericSheet isKindOfClass:[CSSStyleSheet class]])
            {
                CSSStyleSheet* cssSheet = (CSSStyleSheet*) genericSheet;
                for( CSSStyleRule* genericRule in cssSheet.cssRules.internalArray.reverseObjectEnumerator)
                {
                    if( [genericRule isKindOfClass:[CSSStyleRule class]])
                    {
                        CSSStyleRule* styleRule = (CSSStyleRule*) genericRule;
                        if (styleRule.selectorText != nil && ![styleRule.selectorText isEqualToString:@""]) {
                            NSRange styleRange = [styleConfigRule.selectorText rangeOfString:styleRule.selectorText];
                            if (styleRange.length > 0) {
                                if (![styleRule.style.cssText isEqualToString:styleConfigRule.style.cssText]) {
                                    styleRule.style = styleConfigRule.style;
                                }
                                isCompareSelector= YES;
                            }
                        }
                    }
                }
            }
        }
    }
    if (!isCompareSelector && self.DOMDocument.rootElement.styleSheets.internalArray.count > 0) {
        CSSStyleSheet* genericSheet =(CSSStyleSheet *)self.DOMDocument.rootElement.styleSheets.internalArray.lastObject;
        [genericSheet.cssRules.internalArray addObject:styleConfigRule];
    }
    return isCompareSelector;
}

/**
 *配置Node Name-Value
 */
- (void)configNodeSelector:(Element *)element NodeName:(NSString *)nodeName SelectorName:(NSString *)selName{

    Attr *att = [[Attr alloc] initWithNamespace:@"http://www.w3.org/2000/svg" qualifiedName:nodeName value:selName];
    [element.attributes setNamedItemNS:att];
}

@end
