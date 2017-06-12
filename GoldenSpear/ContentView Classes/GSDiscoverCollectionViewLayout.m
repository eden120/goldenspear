//
//  GSDiscoverCollectionViewLayout.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 22/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSDiscoverCollectionViewLayout.h"
#import "GSBaseElement.h"

@implementation GSDiscoverCollectionViewLayout{
    NSMutableArray* cache;
    CGFloat contentHeight;
    CGFloat contentWidth;
    CGFloat numberOfColumns;
    CGFloat cellPadding;
    
    CGFloat smallCellWidth;
    
    NSMutableArray* outPostsOrder;
    NSMutableArray* outPostsOrderIds;
    
    NSArray* premiumPosts;
    NSArray* normalsPosts;
    
    NSInteger premiumIndex;
    NSInteger normalIndex;
    
    BOOL checkRight;
}

- (void)setDefaults{
    cache = [NSMutableArray new];
    contentHeight = 0;
    contentWidth = self.collectionView.frame.size.width;
    cellPadding = 1;
    
    outPostsOrder = [NSMutableArray new];
    outPostsOrderIds = [NSMutableArray new];
    
    numberOfColumns = 3;
    
    premiumIndex = 0;
    normalIndex = 0;
    
    checkRight = NO;
    
    smallCellWidth = contentWidth/numberOfColumns-(numberOfColumns-1)*cellPadding;
}

- (GSDiscoverCollectionViewLayoutCellType)cellTypeWithIndex:(NSInteger)index{
    if (normalIndex>=[normalsPosts count] && premiumIndex>=[premiumPosts count]) {
        return GSDiscoverCollectionViewLayoutCellTypeNone;
    }
    if (premiumIndex>=[premiumPosts count]) {
        return GSDiscoverCollectionViewLayoutCellTypeSmall;
    }
    
    index = index%6;
    if((!checkRight&&index==0)||(checkRight&&index==1)){
        if(checkRight){
            if (premiumIndex<[premiumPosts count]) {
                return GSDiscoverCollectionViewLayoutCellTypeMedium;
            }
        }else{
            if (normalIndex>=[normalsPosts count]) {
                return GSDiscoverCollectionViewLayoutCellTypeBig;
            }else if (premiumIndex<[premiumPosts count]) {
                return GSDiscoverCollectionViewLayoutCellTypeMedium;
            }
        }
    }
    
    if (index==5) {
        checkRight = !checkRight;
    }
    if (normalIndex<[normalsPosts count]) {
        return GSDiscoverCollectionViewLayoutCellTypeSmall;
    }
    
    if (normalIndex>=[normalsPosts count]) {
        return GSDiscoverCollectionViewLayoutCellTypeBig;
    }
    
    return GSDiscoverCollectionViewLayoutCellTypeNone;
}

- (CGSize)sizeWithCellType:(GSDiscoverCollectionViewLayoutCellType)cellType{
    CGFloat width;
    switch (cellType) {
        case GSDiscoverCollectionViewLayoutCellTypeMedium:
            width = smallCellWidth*2+cellPadding;
            break;
        case GSDiscoverCollectionViewLayoutCellTypeBig:
            width = smallCellWidth*2+cellPadding;
            return CGSizeMake(contentWidth, width);
            break;
        case GSDiscoverCollectionViewLayoutCellTypeSmall:
        default:
            width = smallCellWidth;
            break;
    }
    return CGSizeMake(width, width);
}

- (void)prepareLayout{
    if(!cache||[cache count]==0||self.forceReLayout){
        NSArray* inPosts = [self.discoverCollectionDelegate getAllPosts];
        if([inPosts count]>1){
            premiumPosts = [inPosts objectAtIndex:0];
            normalsPosts = [inPosts objectAtIndex:1];
            [self setDefaults];
            CGRect frame = CGRectMake(0, 0, 0, 0);
            GSDiscoverCollectionViewLayoutCellType lastCellType = GSDiscoverCollectionViewLayoutCellTypeNone;
            NSInteger elemsPerRow = 0;
            BOOL keepRow = NO;
            for(NSInteger i=0;i<[premiumPosts count]+[normalsPosts count];i++){
                GSDiscoverCollectionViewLayoutCellType cellType = [self cellTypeWithIndex:i];
                if(cellType==GSDiscoverCollectionViewLayoutCellTypeBig){
                    elemsPerRow = 0;
                    frame.origin.x = 0;
                    frame.origin.y = contentHeight;
                }else if(elemsPerRow==3){
                    if(lastCellType==GSDiscoverCollectionViewLayoutCellTypeMedium&&cellType==GSDiscoverCollectionViewLayoutCellTypeSmall){
                        frame.origin.y += (frame.size.height-cellPadding)/2;
                        elemsPerRow--;
                    }else{
                        frame.origin.y += frame.size.height+cellPadding;
                        if(!keepRow){
                            elemsPerRow = 0;
                        }else{
                            keepRow = NO;
                            elemsPerRow--;
                        }
                    }
                }
                
                frame.size = [self sizeWithCellType:cellType];
                NSIndexPath* thePath = [NSIndexPath indexPathForRow:i inSection:0];
                UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:thePath];
                attributes.frame = frame;
                [cache addObject:attributes];
                
                [self processPostWithType:cellType];
                
                contentHeight = MAX(frame.origin.y+frame.size.height+cellPadding,contentHeight);
                switch (cellType) {
                    case GSDiscoverCollectionViewLayoutCellTypeMedium:
                    {
                        elemsPerRow +=2;
                        if (frame.origin.x==0) {
                            frame.origin.x += frame.size.width+cellPadding;
                        }else{
                            frame.origin.x = 0;
                        }
                    }
                        break;
                    case GSDiscoverCollectionViewLayoutCellTypeSmall:
                    default:
                    {
                        frame.origin.x += frame.size.width+cellPadding;
                        elemsPerRow++;
                        if (elemsPerRow==3) {
                            if (lastCellType==GSDiscoverCollectionViewLayoutCellTypeMedium) {
                                //Last column upper row
                                if (frame.origin.x>(2*smallCellWidth+2*cellPadding)) {
                                    frame.origin.x -= frame.size.width+cellPadding;
                                    keepRow = YES;
                                }else{
                                    frame.origin.x = 0;
                                }
                            }else{
                                frame.origin.x = 0;
                            }
                        }
                    }
                        break;
                }
                
                lastCellType = cellType;
            }
        }
    }
    self.forceReLayout = NO;
    [self.discoverCollectionDelegate finishedLayouting:outPostsOrderIds andOutPosts:outPostsOrder];
}

- (void)processPostWithType:(GSDiscoverCollectionViewLayoutCellType)cellType{
    switch (cellType) {
        case GSDiscoverCollectionViewLayoutCellTypeMedium:
        case GSDiscoverCollectionViewLayoutCellTypeBig:
        {
            GSBaseElement* post = [premiumPosts objectAtIndex:premiumIndex];
            [outPostsOrder addObject:post];
            [outPostsOrderIds addObject:post.fashionistaPostId];
            premiumIndex++;
        }
            break;
        case GSDiscoverCollectionViewLayoutCellTypeSmall:
        {
            GSBaseElement* post = [normalsPosts objectAtIndex:normalIndex];
            [outPostsOrder addObject:post];
            [outPostsOrderIds addObject:post.fashionistaPostId];
            normalIndex++;
        }
            break;
        default:
            break;
    }
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
