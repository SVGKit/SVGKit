//
//  VCAllSpecImages.h
//  Demo-iOS
//
//  Created by adam on 11/04/2015.
//  Copyright (c) 2015 na. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCAllSpecImages : UIViewController

@property(nonatomic,retain) IBOutlet UICollectionView* collectionView;

@property(nonatomic,retain) NSString* pathInBundleToSVGSpecTestSuiteFolder;

@end
