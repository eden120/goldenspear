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
#import "GSDiscoverCollectionViewLayout.h"    
#import "GSQuickViewViewController.h"

@class GSDiscoverCollectionViewCell, GSDiscoverHomeTableViewCell;

@protocol GSDiscoverHomeTableViewCellDelegate <NSObject>

- (void)longPressedHomeCell:(GSDiscoverHomeTableViewCell*)theCell;
- (void)closeHomeQV;

@end

@interface GSDiscoverHomeTableViewCell : UITableViewCell

@property (nonatomic, weak) id<GSDiscoverHomeTableViewCellDelegate> cellDelegate;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UILabel *sectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UIButton *headerButton;
@end

@protocol GSDiscoverCollectionViewCellDelegate <NSObject>

- (void)longPressedCollectionCell:(GSDiscoverCollectionViewCell*)theCell;
- (void)closeCollectionQV;

@end

@interface GSDiscoverCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<GSDiscoverCollectionViewCellDelegate> cellDelegate;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UIButton *userButton;

@end

@interface GSDiscoverViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SlideButtonViewDelegate,UITextFieldDelegate,GSOptionsViewDelegate,GSDiscoverCollectionViewLayoutDelegate,GSDiscoverHomeTableViewCellDelegate,GSDiscoverCollectionViewCellDelegate,GSQuickViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *sectionContainer;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *homeTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *emptyListLabel;

@property (strong, nonatomic) SearchQuery * currentSearchQuery;
@property (strong, nonatomic) NSMutableArray* postsArray;
@property (weak, nonatomic) IBOutlet GSOptionsView *optionsView;
@property (nonatomic) GSQuickViewViewController *quickVC;

@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)sortPush:(UIButton*)sender;
- (IBAction)headerPushed:(UIButton*)sender;
- (IBAction)closeOptions:(id)sender;
- (IBAction)userPushed:(UIButton *)sender;
- (IBAction)searchPushed:(id)sender;

@end
