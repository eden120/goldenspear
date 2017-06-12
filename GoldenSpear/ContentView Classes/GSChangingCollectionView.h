//
//  GSChangingCollectionView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSChangingCollectionView : UICollectionView

@property (nonatomic,strong) NSString* currentCellIdentifier;
@property (nonatomic) BOOL cellsHideHeader;

//Adds and register cell ids with classes
- (void)setCollectionCellIdentifiers:(NSArray*)idsArray withClasses:(NSArray*)classesArray;
//Adds already storyboard's registered cell ids
- (void)addCollectionCellIdentifiersFromStoryboard:(NSArray*)idsArray;
- (void)changeCellStyle;

@end
