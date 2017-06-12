//
//  GSDiscoverCollectionViewLayout.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 22/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    GSVideoCollectionViewLayoutCellTypeNone,
    GSVideoCollectionViewLayoutCellTypeBig,
    GSVideoCollectionViewLayoutCellTypeMedium,
    GSVideoCollectionViewLayoutCellTypeSmall
}GSVideoCollectionViewLayoutCellType;

@protocol GSVideoCollectionViewLayoutDelegate <NSObject>

- (CGFloat)numberOfItemsInCollection;

@end

@interface GSVideoCollectionViewLayout : UICollectionViewLayout

@property (weak,nonatomic) id<GSVideoCollectionViewLayoutDelegate> videoCollectionDelegate;
@property (nonatomic) BOOL forceReLayout;

@end
