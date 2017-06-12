//
//  ReviewView.h
//  GoldenSpear
//
//  Created by jcb on 7/24/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ReviewCell.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+UserManagement.h"
#import "AddItemToWardrobeViewController.h"
#import "WardrobeViewController.h"
#import "ProductFeatureSearchViewController.h"
#import "SearchBaseViewController.h"
#import "BaseViewController+MainMenuManagement.h"
#import "ShopsCell.h"
#import "UILabel+CustomCreation.h"
#import "NYTPhotosViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "WardrobeContentViewController.h"
#import "FashionistaPostViewController.h"
#import "ReviewTableViewCell.h"

@protocol Delegate <NSObject>

-(void)onTapWriteReview;
-(void)onTapSeeMoreReviews;

@end

@interface ReviewView : UIViewController

@property(nonatomic, retain) id<Delegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *noReviewTxt;
@property (weak, nonatomic) IBOutlet UIButton *writeReviewBTN;
@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (weak, nonatomic) IBOutlet RateView *overallView;
@property (weak, nonatomic) IBOutlet RateView *comfortView;
@property (weak, nonatomic) IBOutlet RateView *qualityView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noReviewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ratingViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *writeReviewButtonTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIView *totalView;

@property (weak, nonatomic) IBOutlet UIView *userReviewView;
@property (weak, nonatomic) IBOutlet UIButton *seemoreButton;

@property (weak, nonatomic) IBOutlet UITableView *reviewList;

@property (weak, nonatomic) IBOutlet UIView *firstReviewView;
@property (weak, nonatomic) IBOutlet UILabel *firstUserNameLabel;
@property (weak, nonatomic) IBOutlet RateView *firstUserRatingView;
@property (weak, nonatomic) IBOutlet UILabel *firstUserCommentLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstUserDateLabel;

@property (weak, nonatomic) IBOutlet UIView *secondReviewView;
@property (weak, nonatomic) IBOutlet UILabel *secondUserNameLabel;
@property (weak, nonatomic) IBOutlet RateView *secondUserRatingView;
@property (weak, nonatomic) IBOutlet UILabel *secondUserCommentLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondUserDateLabel;

@property (weak, nonatomic) IBOutlet UIView *thirdReviewView;
@property (weak, nonatomic) IBOutlet UILabel *thirdUserNameLabel;
@property (weak, nonatomic) IBOutlet RateView *thirdUserRatingView;
@property (weak, nonatomic) IBOutlet UILabel *thirdUserCommentLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdUserDateLabel;

@property (nonatomic) BOOL hasReview;
@property (nonatomic) BOOL availableWriteReview;
@property (nonnull) NSMutableArray *reviews;
@property (nonatomic) BOOL isShownReview;
@property (nonatomic) NSInteger reviewCount;
@property (nonatomic) BOOL isFill;

-(void)shownUserReviews:(NSInteger)height;
-(void)hiddenUserReview;
-(void)initView;

@end