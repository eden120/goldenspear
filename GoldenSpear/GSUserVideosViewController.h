//
//  GSDiscoverViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "SlideButtonView.h"
#import "GSOptionsView.h"
#import "GSVideoCollectionViewLayout.h"

@class GSUserVideosViewController;

@protocol GSUserVideosViewControllerDelegate <NSObject>

- (void)videosController:(GSUserVideosViewController*)controller notifyPanGesture:(UIPanGestureRecognizer *)sender;

@end

@interface GSUserVideosCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UILabel *cellTitle;

@end

@interface GSUserVideosViewController : BaseViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SlideButtonViewDelegate,UITextFieldDelegate,GSOptionsViewDelegate,GSVideoCollectionViewLayoutDelegate>

@property (weak, nonatomic) IBOutlet UIView *sectionContainer;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *emptyListLabel;

@property (strong, nonatomic) SearchQuery * currentSearchQuery;
@property (strong, nonatomic) NSMutableArray* postsArray;
@property (weak, nonatomic) IBOutlet GSOptionsView *optionsView;

@property (weak, nonatomic) User* shownStylist;

@property (weak, nonatomic) id<GSUserVideosViewControllerDelegate> delegate;

- (IBAction)sortPush:(UIButton*)sender;
- (IBAction)closeOptions:(id)sender;

- (void)fixLayout;
- (IBAction)searchPushed:(id)sender;

@end
