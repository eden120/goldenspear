//
//  GSChangingCollectionView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSChangingCollectionView.h"

@interface GSChangingCollectionView (){
    NSMutableArray* cellIdentifiersArray;
    NSInteger currentCellIdentifierIndex;
}

@end

@implementation GSChangingCollectionView

- (void)dealloc{
    self.currentCellIdentifier = nil;
    cellIdentifiersArray = nil;
}

- (void)setCollectionCellIdentifiers:(NSArray*)idsArray withClasses:(NSArray*)classesArray{
    if ([idsArray count]!=[classesArray count]) {
        return;
    }
    for(NSInteger i=0;i<[idsArray count];i++){
        [self registerClass:[classesArray objectAtIndex:i] forCellWithReuseIdentifier:[idsArray objectAtIndex:i]];
    }
    cellIdentifiersArray = [NSMutableArray arrayWithArray:idsArray];
    currentCellIdentifierIndex = -1;
    [self changeCellStyle];
}

- (void)addCollectionCellIdentifiersFromStoryboard:(NSArray*)idsArray{
    if(!cellIdentifiersArray){
        cellIdentifiersArray = [NSMutableArray arrayWithArray:idsArray];
    }
    [cellIdentifiersArray addObjectsFromArray:idsArray];
    currentCellIdentifierIndex = -1;
    [self changeCellStyle];
}

- (void)changeCellStyle{
    if([cellIdentifiersArray count]>0){
        currentCellIdentifierIndex = (currentCellIdentifierIndex+1)%[cellIdentifiersArray count];
        self.currentCellIdentifier = [cellIdentifiersArray objectAtIndex:currentCellIdentifierIndex];
        [self reloadData];
    }
}

@end
