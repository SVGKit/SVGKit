//
//  VCImageCollectionViewCell.m
//  Demo-iOS
//
//  Created by lizhuoli on 2018/10/17.
//  Copyright © 2018年 na. All rights reserved.
//

#import "VCImageCollectionViewCell.h"

@implementation VCImageCollectionViewCell

- (void)toggleLayerImageView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(collectionViewCell:toggleLayerImageView:)]) {
        [self.delegate collectionViewCell:self toggleLayerImageView:YES];
    }
}

- (void)toggleFastImageView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(collectionViewCell:toggleLayerImageView:)]) {
        [self.delegate collectionViewCell:self toggleLayerImageView:NO];
    }
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
