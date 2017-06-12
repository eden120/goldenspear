//
//  GSDiscoverCollectionViewLayout.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 22/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    GSDiscoverCollectionViewLayoutCellTypeNone,
    GSDiscoverCollectionViewLayoutCellTypeBig,
    GSDiscoverCollectionViewLayoutCellTypeSmall,
    GSDiscoverCollectionViewLayoutCellTypeMedium
}GSDiscoverCollectionViewLayoutCellType;

@protocol GSDiscoverCollectionViewLayoutDelegate <NSObject>

- (void)finishedLayouting:(NSArray*)outPostsOrder andOutPosts:(NSArray*)outPostsIdOrder;
- (NSArray*)getAllPosts;

@end

@interface GSDiscoverCollectionViewLayout : UICollectionViewLayout

@property (weak,nonatomic) id<GSDiscoverCollectionViewLayoutDelegate> discoverCollectionDelegate;
@property (nonatomic) BOOL forceReLayout;

@end
