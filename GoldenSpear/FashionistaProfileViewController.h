//
//  FashionistaProfileViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 28/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomCameraViewController.h"
#import "PlaceHolderUITextView.h"
#import "CustomAlertView.h"

#import "GSDoubleDisplayViewController.h"
#import "GSTextEditViewController.h"
#import "GSUserVideosViewController.h"

#import "GSOptionsView.h"
#import "FullVideoViewController.h"

// Types of user reports
typedef enum userReportType
{
    OFFENSE,
    HARASSMENT,
    THREATING,
    PRIVACY,
    SPAMMING,
    
    maxUserReportTypes
}
userReportType;

typedef enum
{
    profileEditFieldModeName,
    profileEditFieldModeTitle,
    profileEditFieldModeWebpage
}
profileEditFieldMode;

#import <NYTPhotoViewer/NYTPhoto.h>

@interface NYTExamplePhotoUserProf : NSObject <NYTPhoto>

// Redeclare all the properties as readwrite for sample/testing purposes.
@property (nonatomic) UIImage *image;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

@end

@interface FashionistaProfileViewController : BaseViewController <UITextFieldDelegate, SlideButtonViewDelegate, CustomCameraViewControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate, UITextViewDelegate, CustomAlertViewDelegate,GSDoubleDisplayDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,GSTextEditViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,GSOptionsViewDelegate,GSUserVideosViewControllerDelegate,FullVideoViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *TextFieldsUpperView;
@property (weak, nonatomic) IBOutlet UIView *LowerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TextFieldUpperViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *fashionistaImage;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
//@property (weak, nonatomic) IBOutlet UILabel *fashionistaName;
@property (weak, nonatomic) IBOutlet UILabel *fashionistaURL;
@property (weak, nonatomic) IBOutlet UIButton *editProfileImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedBadge;

@property (weak, nonatomic) IBOutlet UILabel *postNumber;
@property (weak, nonatomic) IBOutlet UILabel *followersNumber;
@property (weak, nonatomic) IBOutlet UILabel *followingNumbers;

@property int iNumberOfFollowers;
@property int iNumberOfFollowing;

@property (weak, nonatomic) IBOutlet UIButton *analyticsButton;
@property (weak, nonatomic) IBOutlet UILabel *lblAnalytics;

@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;

@property (weak, nonatomic) IBOutlet UIButton *editProfileCoverButton;

@property (weak, nonatomic) IBOutlet UILabel *addWebSiteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pencilImage;

@property NSString * addingProductsToWardrobeID;
@property Wardrobe * addingProductsToWardrobe;



//@property (weak, nonatomic) IBOutlet UITextField *fashionistaNameField;
@property (weak, nonatomic) IBOutlet UITextField *fashionistaURLField;
@property (weak, nonatomic) IBOutlet UIButton *headerButton;
@property (weak, nonatomic) IBOutlet UIButton *headerButtonCopy;

@property BOOL bEditionMode;
@property BOOL bPhotoChanged;

@property User * shownStylist;
//@property SlideButtonView * RibbonView;
//@property FashionistaPost * selectedPost;
//@property FashionistaPost * selectedPostToDelete;
@property NSString * selectedPostId;
@property GSBaseElement *selectedElement;

@property NSString * idPostToDelete;
@property NSMutableArray * pagesGroups;
@property NSMutableArray * postsArray;
@property NSMutableArray * wardrobesArray;
@property FashionistaPage * selectedPage;
@property NSMutableArray * selectedPagePosts;

// Fetch current user wardrobes
@property NSFetchedResultsController * wardrobesFetchedResultsController;
@property NSFetchRequest * wardrobesFetchRequest;

// Fetch current user follows
@property NSFetchedResultsController * followsFetchedResultsController;
@property NSFetchRequest * followsFetchRequest;

// Views to manage adding an item to a wardrobe
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeVCContainerView;
- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL) bSuccess;

// Search query (if any) that lead the user to this post  (for statistics)
@property SearchQuery * searchQuery;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightFollow;

@property (weak, nonatomic) IBOutlet UIImageView *profileHeaderImage;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *editViews;
@property (weak, nonatomic) IBOutlet UIView *postsContainerView;
@property (weak, nonatomic) IBOutlet UIView *wardrobesContainerView;
@property (weak, nonatomic) IBOutlet UIView *turnNotificationsView;
@property (weak, nonatomic) IBOutlet UIView *headerVideoContainer;
@property (weak, nonatomic) IBOutlet UIImageView *headerVideobackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *uploadImageLabel;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayButton;
@property (weak, nonatomic) IBOutlet UIView *infoViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UITableView *monthFilterTable;
@property (weak, nonatomic) IBOutlet UIView *monthFilterBackground;
@property (weak, nonatomic) IBOutlet UIView *monthFilterView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monthFilterCenterConstraint;
@property (weak, nonatomic) IBOutlet UIButton *calendarButton;
@property (weak, nonatomic) IBOutlet GSOptionsView *moreOptions;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet UIView *videoListContainer;
@property (weak, nonatomic) IBOutlet UIButton *videoMenuButton;
@property (nonatomic) BOOL showVideos;
@property (weak, nonatomic) IBOutlet UIButton *wardrobeButton;
@property (weak, nonatomic) IBOutlet UILabel *privateLabel;

@property (weak, nonatomic) IBOutlet UIView *suggestionView;
@property (weak, nonatomic) IBOutlet SuggestionCollectionView *suggestionCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *suggestionViewHeightConstraint;

- (IBAction)editWebpagePushed:(id)sender;
- (IBAction)continousButtonPushed:(UIButton*)sender;
- (IBAction)infoButtonPushed:(UIButton*)sender;
- (IBAction)wardrobeButtonPushed:(UIButton *)sender;
- (IBAction)mailButtonPushed:(UIButton *)sender;
- (IBAction)calendarButtonPushed:(UIButton *)sender;
- (IBAction)turnOnNotifications:(id)sender;
- (IBAction)turnOffNotifications:(id)sender;
- (IBAction)updateHeaderFile:(id)sender;
- (IBAction)videoPlay:(id)sender;
- (IBAction)videosMenuPushed:(UIButton*)sender;
- (IBAction)closeDateFilter:(id)sender;
- (IBAction)dismissOptionButtons:(id)sender;
- (void)showFullVideo:(NSInteger)orientation;
@end
