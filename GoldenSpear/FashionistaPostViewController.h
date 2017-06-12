//
//  FashionistaPostViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomCameraViewController.h"
#import "CustomAlertView.h"
#import "CommentCell.h"
#import <CoreLocation/CoreLocation.h>


@import AVKit;

/*
// Types of post content reports
typedef enum postContentReportType
{
    NUDITY,
    DRUGS,
    SEXUAL,
    VIOLENCE,
    TERRORISM,

    maxPostContentReportTypes
}
postContentReportType;
 */


#import <NYTPhotoViewer/NYTPhoto.h>

@interface NYTExamplePhoto : NSObject <NYTPhoto>

// Redeclare all the properties as readwrite for sample/testing purposes.
@property (nonatomic) UIImage *image;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

@end

// Content types
typedef enum contentType
{
    IMAGE_CONTENT,
    VIDEO_CONTENT,
    TEXT_CONTENT,

    maxContentTypes
}
contentType;

@protocol FashionistaPostDelegate;

@interface FashionistaPostViewController : BaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate, NSFetchedResultsControllerDelegate, UITextViewDelegate, SlideButtonViewDelegate, UITextFieldDelegate, CustomCameraViewControllerDelegate, CLLocationManagerDelegate, CustomAlertViewDelegate>

// Current post
@property GSBaseElement * shownGSBaseElement;
@property FashionistaPost * shownPost;
@property User * shownPostUser;

// Post editing
@property BOOL bIsNewPost;
@property BOOL bWasNewPost;

@property BOOL bEditingMode;
@property BOOL bIsVideo;
@property BOOL bVideoReviewing;
@property FashionistaPage * parentFashionistaPage;
@property FashionistaContent * selectedContentToDelete;
@property FashionistaContent * selectedContentToEdit;
@property FashionistaContent * selectedContentToAddKeyword;
@property NSNumber * selectedGroupToAddKeyword;
@property FashionistaContent * selectedContentToAddWardrobe;

@property (weak, nonatomic) IBOutlet UIView *editTextContentSuperView;
@property (weak, nonatomic) IBOutlet UITextView *editTextContentTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraints;

// Post Contents
@property NSMutableArray * shownFashionistaPostContent;
// Images queue for background loading
@property (nonatomic, strong) NSOperationQueue *imagesQueue;

// To manage full-sized images view
@property NSInteger iSelectedContent;
@property NSString * tempImagePath;
@property NSMutableDictionary * kwDict;
@property NSMutableDictionary * wardrobeDict;
@property NSMutableDictionary * videoDict;

@property NSMutableDictionary * viewsDict;

// Background Ad
@property BackgroundAd * currentBackgroundAd;
@property UIImageView *backgroundAdImageView;


// Add Terms Text Field
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addTermTextFieldBottomConstraints;
@property (weak, nonatomic) IBOutlet UITextField *addTermTextField;
- (void)hideAddSearchTerm;

// Fetch keywords to force selecting one of them
@property NSFetchedResultsController * keywordsFetchedResultsController;
@property NSFetchRequest * keywordssFetchRequest;



@property NSMutableArray * keywordsSelected;
@property (weak, nonatomic) IBOutlet UIView *containerTagsByFilter;
-(void) addSearchTermWithName:(NSString *) name animated:(BOOL) bAnimated;
-(void) removeSearchTermAtIndex:(int) iIndex;
-(void) hideFilterSearch;

// Search query (if any) that lead the user to this post  (for statistics)
@property SearchQuery * searchQuery;

// Main scroll view to host all content
@property (weak, nonatomic) IBOutlet UIScrollView *FashionistaPostView;

// Comments view
@property NSMutableArray *postComments;
@property Comment *postCommentObjs;
@property (weak, nonatomic) IBOutlet UIView *CommentsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CommentsViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *CommentsShadowView;
@property (weak, nonatomic) IBOutlet UILabel *commentsLocDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsComLikesLabel;
@property (weak, nonatomic) IBOutlet UIButton *likePostButton;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIView *writeCommentView;
@property (weak, nonatomic) IBOutlet UIButton *addVideoToCommentButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * commentTextSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CommentsViewBottomConstraint;
- (IBAction)onTapGetUsersLike:(UIButton *)sender;

- (IBAction)onTapAddVideoToComment:(UIButton *)sender;
- (IBAction)onTapShowVideoComment:(UIButton*)sender;
@property AVPlayerViewController * player;
@property NSString *temporalCommentURL;
@property NSString *currentUserLocation;
@property NSNumber * postLikesNumber;
@property BOOL currentUserLikesPost;


// Hanger button to launch the 'Add to Wardrobe' feature
@property UIButton * hangerButton;

// Fetch current user wardrobes
@property NSFetchedResultsController * wardrobesFetchedResultsController;
@property NSFetchRequest * wardrobesFetchRequest;
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeVCContainerView;
- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL) bSuccess;
//ADD_Osama
@property NSMutableArray *tempPostingUserTagArry;
@property NSMutableArray *PostedUserTagArry;
@property NSMutableArray *PostedProductArry;
@property NSMutableArray *removingUserTagArry;
@property NSMutableArray *removingProductTagArry;
@property GSBaseElement* selectedProductItem;
@property FashionistaPost *tagLocationPost;
@property NSMutableArray *postActionArray;

- (void)postLocation:(NSString*)locationStr;
- (void)getCurrentLocation;
- (void)deleteComment;
- (void)uploadComment:(NSString *)commentString;
- (void)showProductDetailsView:(GSBaseElement*)bsElement;
-(void) removeItemfromContent:(GSBaseElement*)removingItem;
- (void)addWardrobeToContent:(GSBaseElement*)itemToAdd;
- (void)addContentWardrobeWithIndex:(NSInteger)index;
- (void)removeKyewordFromContent:(NSString*)title;
- (BOOL)addKeywordFromNameWithIndex:(NSString*)name Index:(NSInteger)tag XPos:(CGFloat)xPos YPos: (CGFloat)yPos;
-(void)createWardrobeWithName:(NSString *)wardrobeName;
- (void)closeAddingPostToPageWithSuccess:(BOOL) bSuccess;
- (void)closeAddingProductsToContentWithSuccess:(BOOL)bSuccess;
- (void)uploadImageFashionstaContent:(UIImage*)chosenImage;

@property SlideButtonView *searchTermsListView;

@property UIButton * addImageButton;
@property UIButton * addVideoButton;
@property UIButton * addTextButton;

@property CGPoint currentScrollPosition;

@property (strong, nonatomic) CustomCameraViewController *imagePicker;

// To make sure that the user will leave post edition and discard changes
-(BOOL) checkPostEditionBeforeTransition;

@property (nonatomic, assign) id <FashionistaPostDelegate> fashionistaPostDelegate;
@end

@protocol FashionistaPostDelegate <NSObject>
@optional
-(void) showProductSearchViewController:(FashionistaPostViewController *)viewcontroller;
-(void) postedImage;
-(void) showFeedbackActivity:(NSString*)message;
-(void) hideFeedbackActivity:(NSString*)title;
@end