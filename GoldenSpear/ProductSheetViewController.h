//
//  ProductSheetViewController.h
//  GoldenSpear
//
//  Created by JAVIER CASTAN SANCHEZ on 27/4/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "Rateview.h"
#import "ReviewCell.h"
#import "CustomAlertView.h"
#import "PriceView.h"
#import "InfoView.h"
#import "DetailView.h"
#import "ProductImageView.h"
#import "ReviewView.h"
#import "SizeView.h"
#import "ShippingView.h"
#import "ShareView.h"
#import "GetTheLookView.h"
#import "SimilarView.h"
#import "AvailabiliyView.h"

#import <CoreLocation/CoreLocation.h>

#import "HTHorizontalSelectionList.h"

@import AVKit;

// Types of product error reports
typedef enum productReportType
{
    BADIMAGE,
    BADPRICE,
    BADDESCRIPTION,
    BADURL,
    
    maxProductReportTypes
}
productReportType;


#import <NYTPhotoViewer/NYTPhoto.h>

@interface NYTExamplePhotoProd : NSObject <NYTPhoto>

// Redeclare all the properties as readwrite for sample/testing purposes.
@property (nonatomic) UIImage *image;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

@end

@class PriceView, InfoView, DetailView, ProductImageView, ReviewView, SizeView, AvailabiliyView, ShippingView, GetTheLookView, SimilarView, ShareView;

@interface ProductSheetViewController : BaseViewController <UIWebViewDelegate, CLLocationManagerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, CustomAlertViewDelegate> {
	
	UIViewController *defaultVC;
	PriceView *priceVC;
	InfoView *infoVC;
	DetailView *detailVC;
	ProductImageView *productImageVC;
	ReviewView *reviewVC;
	SizeView *sizeVC;
    AvailabiliyView *availabilityVC;
	ShippingView *shippingVC;
	ShareView *shareVC;
	GetTheLookView *getLookVC;
    SimilarView *similarVC;
}

// Top View controls
@property (strong, nonatomic) UIImage * missingImage;
@property (strong, nonatomic) UIImage * portraitImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorLineHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *wardrobeButton;

// Fetch current user wardrobes
@property NSFetchedResultsController * wardrobesFetchedResultsController;
@property NSFetchRequest * wardrobesFetchRequest;

// Fetch current user follows
@property NSFetchedResultsController * followsFetchedResultsController;
@property NSFetchRequest * followsFetchRequest;

// Product info
@property NSMutableArray *shownProductFeatureTerms;
@property (weak, nonatomic) IBOutlet UITextView *productInfoTextView;

// Review controls
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UIView *reviewShadowView;
@property (weak, nonatomic) IBOutlet RateView * overallRateView;
@property (weak, nonatomic) IBOutlet RateView * comfortRateView;
@property (weak, nonatomic) IBOutlet RateView * qualityRateView;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property (weak, nonatomic) IBOutlet UIView *writeReviewView;
@property (weak, nonatomic) IBOutlet UIButton *addVideoToReviewButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * reviewTextSpaceConstraint;
- (IBAction)onTapWriteReview;
- (IBAction)onTapAddVideoToReview:(UIButton *)sender;
- (IBAction)onTapShowVideoReviews:(UIButton*)sender;
@property AVPlayerViewController * player;

// To post review including the current user location
@property NSString *currentUserLocation;
@property NSString *temporalReviewURL;

@property (weak, nonatomic) IBOutlet UIView *infoView;

// Zoomed image controls
@property  NSInteger iSelectedContent;

@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;

@property (weak, nonatomic) IBOutlet UIButton *findSimilarButton;


// Full screen availability view
@property bool bShowWebShops;
@property bool bShowInStoreShops;
- (IBAction)onTapAvailabilityAll:(UIButton *)sender;
- (IBAction)onTapAvailabilityWeb:(UIButton *)sender;
- (IBAction)onTapAvailabilityInStore:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITableView *availabilityTableView;

@property (weak, nonatomic) IBOutlet UIView *availabilityDetailView;
@property (weak, nonatomic) IBOutlet UIWebView *availabilityWebView;
- (IBAction)onTapOpenWebsite:(UIButton *)sender;
- (IBAction)onTapShowMap:(UIButton *)sender;


// Actions
- (IBAction)onTapProductInfo:(UIButton *)sender;
- (IBAction)onTapAvailability:(UIButton *)sender;
- (IBAction)onTapReviews:(UIButton *)sender;
- (IBAction)onTapPurchase:(UIButton *)sender;
- (IBAction)onTapFindSimilar:(UIButton *)sender;
- (IBAction)onTapProductImage:(UITapGestureRecognizer *)sender;
- (IBAction)onTapAddToWardrobe:(UIButton *)sender;

// General
@property GSBaseElement * shownGSBaseElement;
@property Product * shownProduct;
@property NSMutableArray *productContent;
@property NSMutableArray *productReviews;
@property NSMutableArray *productAvailabilies;
@property NSMutableArray *reviews;
@property SearchQuery * searchQuery;
@property Content * shownContent;
@property NSString * tempImagePath;
@property NSMutableArray * similarProductsSearchTerms;
@property (weak, nonatomic) IBOutlet UIView *ProductTopView;
@property (weak, nonatomic) IBOutlet UIView *ProductBottomView;
@property (weak, nonatomic) IBOutlet UIImageView *ProductImageView;
@property (weak, nonatomic) IBOutlet UILabel *PriceLabel;


// Manage adding an item to a wardrobe
@property NSString * addingProductsToWardrobeID;
@property Wardrobe * addingProductsToWardrobe;


@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIView *reviewsView;
@property (weak, nonatomic) IBOutlet UIView *productInfoView;
@property (weak, nonatomic) IBOutlet UIView *availabilityView;

@property (weak, nonatomic) IBOutlet UIView *addToWardrobeBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeVCContainerView;
- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL) bSuccess;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ProductInfoToReviewsSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ReviewsToPurchaseSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *PurchaseToFindSimilarSpaceConstraint;


//Main View ( Background scroll View )

@property (weak, nonatomic) IBOutlet UIView *productimgView;
@property (weak, nonatomic) IBOutlet HTHorizontalSelectionList *topNaviListView;
@property (weak, nonatomic) IBOutlet UIView *productView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property BOOL isFollowing;
@property (weak, nonatomic) IBOutlet UIView *seeMoreView
;
@property (weak, nonatomic) IBOutlet UILabel *seeMoreLabel;
@property (weak, nonatomic) IBOutlet UIView *reviewContant;
@property GSBaseElement * selectedResult;
@property (weak, nonatomic) IBOutlet UIButton *leftImagebutton;
@property (weak, nonatomic) IBOutlet UIButton *rightImagebutton;
@property (weak, nonatomic) IBOutlet UIView *availabilityVCContainerView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
- (void)closeSeeMoreAvailability;
- (void)showWebsite;
- (void)showFullViewAvailability:(ProductAvailability*)availability;
@end
