//
//  SVGKitFramework_OSXTests.m
//  SVGKitFramework-OSXTests
//
//  Created by lizhuoli on 2018/10/15.
//  Copyright © 2018年 na. All rights reserved.
//

#import <XCTest/XCTest.h>
@import SVGKit;

@interface SVGKitFramework_OSXTests : XCTestCase

@end

@implementation SVGKitFramework_OSXTests

- (CATextLayer *)textLayerWithContent:(NSString *)content x:(NSInteger)x y:(NSInteger)y
{
    NSString *svg = [NSString stringWithFormat:
                     @"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"200\" height=\"100\">"
                     "<text x=\"%ld\" y=\"%ld\" font-size=\"24\">%@</text></svg>",
                     (long)x, (long)y, content];
    SVGKImage *image = [SVGKImage imageWithData:[svg dataUsingEncoding:NSUTF8StringEncoding]];
    CALayer *root = image.CALayerTree;
    XCTAssertNotNil(root);
    if (root == nil)
        return nil;

    NSMutableArray<CALayer *> *pending = [NSMutableArray arrayWithObject:root];
    NSMutableArray<CATextLayer *> *textLayers = [NSMutableArray array];
    while (pending.count > 0)
    {
        CALayer *layer = pending.lastObject;
        [pending removeLastObject];
        if ([layer isKindOfClass:[CATextLayer class]])
            [textLayers addObject:(CATextLayer *)layer];
        if (layer.sublayers != nil)
            [pending addObjectsFromArray:layer.sublayers];
    }
    XCTAssertEqual(textLayers.count, 1U);
    return textLayers.firstObject;
}

- (void)testMixedTextAroundSingleTspanPreservesText
{
    CATextLayer *reference = [self textLayerWithContent:@"ABC" x:10 y:30];
    NSArray<NSString *> *contents = @[
        @"A<tspan x=\"90\" y=\"70\">B</tspan>C",
        @"<![CDATA[A]]><tspan x=\"90\" y=\"70\">B</tspan><![CDATA[C]]>",
        @"A<tspan x=\"90\" y=\"70\">BC</tspan>",
        @"<tspan x=\"90\" y=\"70\">AB</tspan>C"
    ];
    for (NSString *content in contents)
    {
        CATextLayer *layer = [self textLayerWithContent:content x:10 y:30];
        XCTAssertEqualObjects([(NSAttributedString *)layer.string string], @"ABC", @"%@", content);
        XCTAssertEqualWithAccuracy(layer.frame.origin.x, reference.frame.origin.x, 0.001, @"%@", content);
        XCTAssertEqualWithAccuracy(layer.frame.origin.y, reference.frame.origin.y, 0.001, @"%@", content);
    }
}

- (void)testSingleTspanWithIndentationUsesChildPosition
{
    CATextLayer *reference = [self textLayerWithContent:@"ABC" x:90 y:70];
    CATextLayer *layer = [self textLayerWithContent:@"\n\t <tspan x=\"90\" y=\"70\">ABC</tspan>\r\n" x:10 y:30];
    XCTAssertEqualObjects([(NSAttributedString *)layer.string string], @"ABC");
    XCTAssertEqualWithAccuracy(layer.frame.origin.x, reference.frame.origin.x, 0.001);
    XCTAssertEqualWithAccuracy(layer.frame.origin.y, reference.frame.origin.y, 0.001);
}

- (void)testMultipleTspansPreserveText
{
    CATextLayer *reference = [self textLayerWithContent:@"ABCD" x:10 y:30];
    CATextLayer *layer = [self textLayerWithContent:@"A<tspan x=\"90\" y=\"70\">B</tspan><tspan x=\"140\" y=\"80\">C</tspan>D" x:10 y:30];
    XCTAssertEqualObjects([(NSAttributedString *)layer.string string], @"ABCD");
    XCTAssertEqualWithAccuracy(layer.frame.origin.x, reference.frame.origin.x, 0.001);
    XCTAssertEqualWithAccuracy(layer.frame.origin.y, reference.frame.origin.y, 0.001);
}

@end
