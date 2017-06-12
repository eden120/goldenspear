//
//  GSContentCollectionViewCell.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSContentView.h"

@class GSContentCollectionViewCell;

@protocol GSContentCollectionViewCellDelegate <NSObject>

-(void)contentCollectionView:(GSContentCollectionViewCell*)collectionView heightChanged:(CGFloat)newHeight;

@optional
-(void)contentCollectionView:(GSContentCollectionViewCell*)collectionView downloadProfileImage:(NSString*)imageURL;
-(void)contentCollectionView:(GSContentCollectionViewCell*)collectionView downloadContentImage:(NSString*)imageURL;

@end

@interface GSContentCollectionViewCell : UITableViewCell<GSContentViewDelegate>

@property (nonatomic,strong) IBOutlet GSContentView* theContent;

@property (nonatomic, weak) id<GSContentCollectionViewCellDelegate> cellDelegate;

- (void)setupContentView;

- (void)setCellHidesHeader:(BOOL)hideHeader;

@end
