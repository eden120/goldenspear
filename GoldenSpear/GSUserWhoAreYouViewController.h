//
//  GSUserWhoAreYouViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 15/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "GSAccountType.h"

@protocol GSUserWhoAreYouDelegate <NSObject>

- (void)setUserIdentity:(GSAccountType*)account;

@end

@interface GSUserWhoAreYouCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *userTypeIndicator;

@end

@interface GSUserWhoAreYouViewController : BaseViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) id<GSUserWhoAreYouDelegate> delegate;
@property (nonatomic, strong) NSOperationQueue *imagesQueue;
- (IBAction)cancelPushed:(id)sender;

@end
