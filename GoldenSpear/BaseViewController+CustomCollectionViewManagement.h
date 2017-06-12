//
//  BaseViewController+CustomCollectionViewManagement.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 23/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

#import "CollectionViewCustomLayout.h"
#import "CellBackgroundView.h"
#import "GSBaseElementCell.h"
#import "CommentCell.h"
#import "ReviewCell.h"
#import "ContentCell.h"
#import "FeatureCell.h"
#import "RateView.h"
#import "SearchFeatureCell.h"
#import "NotificationCell.h"


#define MAIN_CV 0
#define SECOND_CV 1
#define THIRD_CV 2

// Struct to save the set of layout properties
typedef struct
{
    int numberOfColumns;
    float itemHeight;
    float itemWidth;
    float verticalSpacing;
    float topInset;
    float bottomInset;
    float sideInset;        // solo aplica en el iphone 6
    float horizontalSpacing;
    float headerHeight;
    float footerHeight;
    float headerAndFooterInset;
    BOOL adjustTopInset;
    BOOL adjustBottomInset;
    BOOL adjustSideInset;
    BOOL forceStagging;
    BOOL forceEqualHeights;
    BOOL allowMultipleSelection;
}
layoutProperties;

@interface BaseViewController (CustomCollectionViewManagement) <UICollectionViewDataSource, UICollectionViewDelegateCustomLayout>

// Property for a block-based operation queue that allows setting priorities to the operations. Photos will be loaded in the background rather than on the main queue.
@property (nonatomic, strong) NSOperationQueue *imagesQueue;
- (void) initImagesQueue;

// Data management
- (void)updateCollectionViewWithCellType:(NSString *)cellType fromItem:(int)startItem toItem:(int)endItem deleting:(BOOL)deleting;

// Collection views setup
- (void)setupCollectionViewsWithCellTypes:(NSMutableArray *)cellTypes;

// Collection views layout setup
- (void)initCollectionViewsLayout;
- (void)initOperationsLoadingImages;

// Scroll Main Collection View to top
- (void)scrollMainCollectionViewToTop;

// Collection views
@property NSString *mainCollectionCellType;
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (weak, nonatomic) IBOutlet CollectionViewCustomLayout *mainCollectionViewLayout;

@property NSString *secondCollectionCellType;
@property (weak, nonatomic) IBOutlet UICollectionView *secondCollectionView;
@property (weak, nonatomic) IBOutlet CollectionViewCustomLayout *secondCollectionViewLayout;

@property NSString *thirdCollectionCellType;
@property (weak, nonatomic) IBOutlet UICollectionView *thirdCollectionView;
@property (weak, nonatomic) IBOutlet CollectionViewCustomLayout *thirdCollectionViewLayout;

@end
