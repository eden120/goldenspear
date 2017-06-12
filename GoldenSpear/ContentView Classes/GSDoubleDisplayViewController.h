//
//  GSDoubleDisplayViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 29/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "GSChangingCollectionView.h"
#import "GSPostTableViewCell.h"
#import "FashionistaAddCommentViewController.h"
#import "CustomAlertView.h"
#import "GSImageCollectionViewCell.h"
#import "GSQuickViewViewController.h"
#import "GSCommentViewController.h"
#import "GSContentSectionHeaderView.h"

typedef enum
{
    GSDoubleDisplayModeCollection = 0,
    GSDoubleDisplayModeList
}
GSDoubleDisplayMode;

@class GSDoubleDisplayViewController;

@protocol GSDoubleDisplayDelegate <NSObject>

-(void)doubleDisplay:(GSDoubleDisplayViewController *)displayController openPostFromAD:(NSString*)postID;
-(void)doubleDisplay:(GSDoubleDisplayViewController *)displayController openProfileFromAD:(NSString*)profileID;
-(void)doubleDisplay:(GSDoubleDisplayViewController *)displayController openProductFromAD:(NSString*)productID;
-(void)doubleDisplay:(GSDoubleDisplayViewController *)displayController openWebFromAD:(NSString*)webLink;
- (NSInteger)numberOfSectionsInDataForDoubleDisplay:(GSDoubleDisplayViewController*)displayController forMode:(GSDoubleDisplayMode)displayMode;
- (NSInteger)doubleDisplay:(GSDoubleDisplayViewController*)displayController numberOfRowsInSection:(NSInteger)section forMode:(GSDoubleDisplayMode)displayMode;
- (id)doubleDisplay:(GSDoubleDisplayViewController*)displayController objectForRowAtIndexPath:(NSIndexPath*)indexPath forMode:(GSDoubleDisplayMode)displayMode;
- (NSArray*)doubleDisplay:(GSDoubleDisplayViewController*)displayController dataForRowAtIndexPath:(NSIndexPath*)indexPath forMode:(GSDoubleDisplayMode)displayMode;
- (void)doubleDisplay:(GSDoubleDisplayViewController*)displayController selectItemAtIndexPath:(NSIndexPath*)indexPath isMagazine:(BOOL)isMagazine;
- (void)doubleDisplay:(GSDoubleDisplayViewController*)displayController notifyPanGesture:(UIPanGestureRecognizer *)sender;
- (void)doubleDisplay:(GSDoubleDisplayViewController*)displayController objectDeleted:(id)object;
- (void)doubleDisplay:(GSDoubleDisplayViewController*)displayController commentAdded:(Comment*)comment toPost:(NSString*)idPost updated:(NSInteger)updated;
- (void)doubleDisplay:(GSDoubleDisplayViewController*)displayController commentDeleted:(NSInteger)comment fromPost:(NSString*)idPost;
- (void)doubleDisplay:(GSDoubleDisplayViewController *)vC viewProfilePushed:(User *)theUser;
- (void)doubleDisplay:(NSString*)postId;
- (void)askForMoreDataInDoubleDisplay:(GSDoubleDisplayViewController *)vC;
- (void)askForMoreUserInDoubleDisplay:(GSDoubleDisplayViewController *)vC;
- (void)showMessageWithImageNamed:(NSString*)imageNamed andSharedObject:(Share*)sharedObject;

- (void)doubleDisplayLikeUpdatingFinished;
- (void)updateUserSearch;

- (void)addToWardrobe:(id)content button:(UIButton*)sender;
- (GSBaseElement*)getElement:(id)content;

@end

@interface GSDoubleDisplayViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,GSPostTableViewCellDelegate,GSContentViewPostDelegate,FashionistaAddCommentDelegate,CustomAlertViewDelegate,GSImageCollectionCellDelegate,GSQuickViewDelegate,GSOptionsViewDelegate,GSCommentViewDelegate,GSContentSectionHeaderDelegate>

@property (nonatomic, strong) NSOperationQueue *imagesQueue;

@property (weak, nonatomic) IBOutlet UITableView *listView;
@property (weak, nonatomic) IBOutlet GSChangingCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *emptyListLabel;

@property (weak, nonatomic) id<GSDoubleDisplayDelegate> delegate;
@property (nonatomic) BOOL cellsHideHeader;
@property (nonatomic) BOOL showingExtendedView;
@property (nonatomic) NSInteger itemsPerRow;
@property (weak, nonatomic) IBOutlet UIView *optionsBackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionsViewHeight;
@property (weak, nonatomic) IBOutlet GSOptionsView *optionsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionsViewTop;
@property (nonatomic) BOOL alwaysHideEmptyListLabel;
@property (nonatomic) GSQuickViewViewController *quickVC;

@property NSFetchedResultsController * followsFetchedResultsController;
@property NSFetchRequest * followsFetchRequest;
@property BOOL isOwner;
@property BOOL isWardrobe;
@property BOOL bFromNewsFeed;

- (void)refreshData;
- (void)setupAutolayout;
- (void)switchView;
- (void)refreshVisibleView;
- (void)setSuggestList:(NSMutableArray*)data;
-(void)setAdList:(NSMutableArray*)data;

- (void)newDataObjectGathered:(NSArray*)data;
- (IBAction)closeListOptions:(id)sender;

- (NSString*)getCurrentVideoURL;
- (CMTime)getCurrentTime;
-(BOOL)hasSoundNow;
-(void)setCurrentTime:(CMTime)time hassound:(BOOL)sound;

@end
