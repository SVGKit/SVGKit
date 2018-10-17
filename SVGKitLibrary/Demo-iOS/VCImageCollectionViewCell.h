//
//  VCImageCollectionViewCell.h
//  Demo-iOS
//
//  Created by lizhuoli on 2018/10/17.
//  Copyright © 2018年 na. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VCImageCollectionViewCell;
@protocol VCImageCollectionViewCellDelegate <NSObject>

- (void)collectionViewCell:(VCImageCollectionViewCell *)cell toggleLayerImageView:(BOOL)requiresLayeredImageView;

@end

@interface VCImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<VCImageCollectionViewCellDelegate> delegate;
- (void)toggleLayerImageView:(id)sender;
- (void)toggleFastImageView:(id)sender;

@end
