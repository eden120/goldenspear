//
//  GSDiscoverCollectionViewLayout.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 22/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSVideoCollectionViewLayout.h"

@implementation GSVideoCollectionViewLayout{
    NSMutableArray* cache;
    CGFloat contentHeight;
    CGFloat contentWidth;
    CGFloat cellPadding;
    
    CGFloat cellHeight;
    
    NSInteger elems;
}

- (void)setDefaults{
    cache = [NSMutableArray new];
    contentHeight = 0;
    contentWidth = self.collectionView.frame.size.width;
    cellPadding = 1;
    cellHeight = 160;
    elems = [self.videoCollectionDelegate numberOfItemsInCollection];
}

- (GSVideoCollectionViewLayoutCellType)cellTypeWithIndex:(NSInteger)index{
    if (index==0) {
        return GSVideoCollectionViewLayoutCellTypeBig;
    }
    index -= 1;
    index = index%5;
    if(index<3){
        return GSVideoCollectionViewLayoutCellTypeSmall;
    }
    return GSVideoCollectionViewLayoutCellTypeMedium;
}

- (CGSize)sizeWithCellType:(GSVideoCollectionViewLayoutCellType)cellType{
    switch (cellType) {
        case GSVideoCollectionViewLayoutCellTypeBig:
            return CGSizeMake(contentWidth, cellHeight);
            break;
        case GSVideoCollectionViewLayoutCellTypeMedium:
            return CGSizeMake((contentWidth/2)-cellPadding, cellHeight);
            break;
        case GSVideoCollectionViewLayoutCellTypeSmall:
        default:
            return CGSizeMake((contentWidth/3)-2*cellPadding, cellHeight);
            break;
    }
}

- (void)prepareLayout{
    if(!cache||[cache count]==0||self.forceReLayout){
        [self setDefaults];
        
        CGRect frame = CGRectMake(0, 0, 0, 0);
        GSVideoCollectionViewLayoutCellType lastCellType = GSVideoCollectionViewLayoutCellTypeNone;
        for(NSInteger i=0;i<elems;i++){
            GSVideoCollectionViewLayoutCellType cellType = [self cellTypeWithIndex:i];
            if(cellType==GSVideoCollectionViewLayoutCellTypeMedium &&
                lastCellType==GSVideoCollectionViewLayoutCellTypeSmall){
                frame.origin.x = 0;
                frame.origin.y += frame.size.height+cellPadding;
            }
            
            frame.size = [self sizeWithCellType:cellType];
            NSIndexPath* thePath = [NSIndexPath indexPathForRow:i inSection:0];
            UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:thePath];
            attributes.frame = frame;
            [cache addObject:attributes];
            switch (cellType) {
                case GSVideoCollectionViewLayoutCellTypeBig:
                    frame.origin.y += frame.size.height+cellPadding;
                    break;
                case GSVideoCollectionViewLayoutCellTypeMedium:
                {
                    if (lastCellType==GSVideoCollectionViewLayoutCellTypeSmall) {
                        frame.origin.x += frame.size.width+cellPadding;
                    }else{
                        frame.origin.x = 0;
                        frame.origin.y += frame.size.height+cellPadding;
                    }
                    break;
                }
                case GSVideoCollectionViewLayoutCellTypeSmall:
                {
                    frame.origin.x += frame.size.width+cellPadding;
                    break;
                }
                default:
                    break;
            }
            lastCellType = cellType;
        }
        GSVideoCollectionViewLayoutCellType nextType = [self cellTypeWithIndex:(int)[cache count]];
        if (nextType==lastCellType||lastCellType==GSVideoCollectionViewLayoutCellTypeSmall) {
            frame.origin.y += frame.size.height+cellPadding;
        }
        contentHeight = frame.origin.y;
    }
    self.forceReLayout = NO;
}

- (CGSize)collectionViewContentSize{
    return CGSizeMake(contentWidth, contentHeight);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray* layoutAttributes = [NSMutableArray new];
    
    for(UICollectionViewLayoutAttributes* attributes in cache) {
        if(CGRectIntersectsRect(attributes.frame, rect)) {
            [layoutAttributes addObject:attributes];
        }
    }
    return layoutAttributes;
}

@end
