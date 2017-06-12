//
//  FashionistaMainPageViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 22/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "GSChangingCollectionView.h"

@interface FashionistaMainPageViewController : BaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIImageView *fashionistaHeaderImageView;

@property (weak, nonatomic) IBOutlet UIView *fashionistaDetailsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fashionistaDetailsViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIButton *fashionistaDetailsTitle;

@property (weak, nonatomic) IBOutlet UILabel *fashionistaDetailsAuthorTitle;

@property (weak, nonatomic) IBOutlet UIButton *fashionistaDetailsWardrobesButton;

@property (weak, nonatomic) IBOutlet UIButton *fashionistaDetailsArticlesButton;

@property (weak, nonatomic) IBOutlet UIButton *fashionistaDetailsTutorialsButton;

@property (weak, nonatomic) IBOutlet UIWebView *fashionistaWebView;

@property (weak, nonatomic) IBOutlet GSChangingCollectionView *changingCollectionView;

@property FashionistaPage * shownFashionistaPage;

@property BOOL bEditionMode;
@property FashionistaPage * creatingFashionistaPage;

@property FashionistaPost * selectedPost;
@property FashionistaPost * selectedPostToDelete;
@property NSMutableArray * postsGroups;
@property NSMutableArray * postsArray;

// Fetch current user wardrobes
@property NSFetchedResultsController * wardrobesFetchedResultsController;
@property NSFetchRequest * wardrobesFetchRequest;

// Views to manage adding an item to a wardrobe
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeVCContainerView;
- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL) bSuccess;

- (IBAction)analyticsPushed:(UIButton*)sender;
- (IBAction)continousButtonPushed:(UIButton*)sender;
- (IBAction)infoButtonPushed:(UIButton*)sender;
- (IBAction)wardrobeButtonPushed:(UIButton *)sender;
- (IBAction)mailButtonPushed:(UIButton *)sender;
- (IBAction)calendarButtonPushed:(UIButton *)sender;
@end
