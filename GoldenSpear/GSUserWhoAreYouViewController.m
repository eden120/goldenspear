//
//  GSUserWhoAreYouViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 15/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSUserWhoAreYouViewController.h"
#import "GSAccountCreatorManager.h"
#import "BaseViewController+StoryboardManagement.h"
#import "UIImage+ImageCache.h"

@implementation GSUserWhoAreYouCell

@end

@interface GSUserWhoAreYouViewController (){
    NSArray* userTypeArray;
    NSInteger itemsPerRow;
    NSInteger cellWidth;
}

@end

@implementation GSUserWhoAreYouViewController

static NSString * const reuseIdentifier = @"WhoAreYouCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userTypeArray = [[GSAccountCreatorManager sharedManager] getUserTypes];
    
    //  Operation queue initialization
    if(self.imagesQueue == nil)
    {
        self.imagesQueue = [[NSOperationQueue alloc] init];
        
        // Set max number of concurrent operations it can perform at 3, which will make things load even faster
        self.imagesQueue.maxConcurrentOperationCount = 3;
    }
    itemsPerRow = 3;
    cellWidth = 0;
}

- (BOOL)shouldCenterTitle{
    return YES;
}

- (BOOL)shouldCreateMenuButton{
    return NO;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [userTypeArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GSUserWhoAreYouCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    GSAccountType* acType = [userTypeArray objectAtIndex:indexPath.row];
    
    // Configure the cell
    cell.userTypeLabel.text = [acType.appName uppercaseString];
    [cell.userTypeImage setImageWithURL:[NSURL URLWithString:acType.iconUrl] placeholderImage:[UIImage imageNamed:@"no_image.png"]];
    /*
    UIImage* cellImage = [UIImage cachedImageWithURL:acType.iconUrl];
    if(cellImage!=nil){
        cell.userTypeImage.image = cellImage;
        cell.userTypeIndicator.hidden = YES;
    }else{
        [cell.userTypeImage setImageWithURL:[NSURL URLWithString:acType.iconUrl] placeholderImage:[UIImage imageNamed:@"no_image.png"]];
    }
    */
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(cellWidth<=0){
        cellWidth = floor((collectionView.frame.size.width - (itemsPerRow-1))/itemsPerRow);
    }
    return CGSizeMake(cellWidth, cellWidth);
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath: (NSIndexPath *)indexPath{
    GSAccountType* acType = [userTypeArray objectAtIndex:indexPath.row];
    [self.delegate setUserIdentity:acType];
}

- (IBAction)cancelPushed:(id)sender {
    [(UIViewController*)self.delegate dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
