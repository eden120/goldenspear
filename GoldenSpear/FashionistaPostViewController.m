//
//  FashionistaPostViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//
#import "FashionistaPostViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+KeyboardSuggestionBarManagement.h"
#import "FashionistaMainPageViewController.h"
#import "AddItemToWardrobeViewController.h"
#import "AddPostToPageViewController.h"
#import "SearchBaseViewController.h"
#import "UIButton+CustomCreation.h"
#import "UILabel+CustomCreation.h"
#import "TextPostLabel.h"
#import "FilterSearchViewController.h"
#import "FashionistaPost+Manage.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "FashionistaProfileViewController.h"
#import "GSTaggingProductSearchViewController.h"
#import "NYTPhotosViewController.h"
#import "NSString+AttributtedNSString.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "PeopleTagClass.h"

@import AVKit;
@import AVFoundation;
@import ImageIO;

#define kFontInHangerButton "Avenir-Light"
#define kFontSizeInHangerButton 12
#define kHangerButtonHorizontalInset 10
#define kHangerButtonVerticalInset 80
#define kHangerButtonWidth 35
#define kHangerButtonHeight 35

#define kPostViewHorizontalInset 2
#define kPostViewVerticalInset 5

#define kTopExtraSpace 65
#define kBottomExtraSpace 87

#define kLocationAndDateLabelHeight 15
#define kAlphaInLocationAndDateLabel 1.0
#define kFontInLocationAndDateLabel "GillSans-Italic"
#define kFontColorInLocationAndDateLabel whiteColor
#define kFontSizeInLocationAndDateLabel 14

#define kAlphaInNoContentsLabel 1.0
#define kFontInNoContentsLabel "GillSans-Italic"
#define kFontSizeInNoContentsLabel 18

#define kFontInPostText "Avenir-Light"
#define kFontSizeInPostText 16

#define kDefaultImageWidth 150
#define kDefaultImageHeight 150

#define kFontInCreateViewDeleteButton "Avenir-Roman"
#define kFontSizeInCreateViewDeleteButton 16
#define kCreateViewDeleteButtonBorderWidth 1
#define kCreateViewDeleteButtonBorderColor darkGrayColor
#define kCreateViewDeleteButtonsInset 20
#define kDeleteAndEditExtraSpace 0
#define kCreateViewDeleteButtonsHeight 32
#define kCreateViewDeleteButtonsWidth 80

#define kWardrobeButtonWidth 35
#define kWardrobeButtonHeight 35

#define kAddTagsViewHeight 60
#define kAddProductsViewHeight 60
#define kAddProductsViewHeightOnNOTEditing 35
#define kCreateViewDeleteButtonsInsetOnNOTEditing 5
#define kCreateViewDeleteButtonsExtraSpaceOnNOTEditing 45

#define kMultiplierTagForGroup 100000


@implementation NYTExamplePhoto

@end

@interface FashionistaPostViewController ()

@end

@implementation FashionistaPostViewController
{
    SearchBaseViewController *searchBaseVC;
    GSTaggingProductSearchViewController *productSearchVC;
}

BOOL bIsChangingBackgroundAd;

// Object to get location data
CLLocationManager *commentLocationManager;
// Class providing services for converting between a GPS coordinate and a user-readable address
CLGeocoder *commentGeocoder;
// Object containing the result returned by CLGeocoder
CLPlacemark *commentPlacemark;

// Save controller in charge of filter search
FilterSearchViewController *_filterTagVC = nil;

CGFloat postViewY;
BOOL bIsAnimating = NO;
BOOL _bEditingChanges = NO;
BOOL _bFinishedTakingImage = NO;
BOOL _PostAlreadyContainsImages = NO;
BOOL _PostAlreadyContainsVideos = NO;
BOOL _PostAlreadyContainsTexts = NO;
BOOL _bConfirmingTextEditDiscard = NO;
Wardrobe *_wardrobeSelected = nil;
NSString *_idProductToRemoveFromWardrobeSelected = nil;
Wardrobe *_wardrobeSelectedToDelete = nil;
NSString * _sProductImagePathToRemove = nil;
UIView * kwsView = nil;
UIView * wardrobeView = nil;
UIView * lastAddedSubview = nil;
BOOL _bComingFromTagsSearch = NO;

- (BOOL)shouldCenterTitle{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    searchBaseVC = nil;
    productSearchVC = nil;
    _currentUserLikesPost = NO;
    
    _bFinishedTakingImage = NO;
    
    _bComingFromTagsSearch = NO;
    
    _selectedContentToEdit = nil;
    _selectedContentToDelete = nil;
    _selectedContentToAddKeyword = nil;
    _selectedContentToAddWardrobe = nil;
    kwsView = nil;
    wardrobeView = nil;
    _viewsDict = nil;
    
    _kwDict = [[NSMutableDictionary alloc]init];
    _viewsDict = [[NSMutableDictionary alloc]init];
    _wardrobeDict = [[NSMutableDictionary alloc]init];
    _videoDict = [[NSMutableDictionary alloc]init];
    
    _tempPostingUserTagArry = [[NSMutableArray alloc]init];
    _PostedUserTagArry = [[NSMutableArray alloc]init];
    _removingUserTagArry = [[NSMutableArray alloc]init];
    _removingProductTagArry = [[NSMutableArray alloc]init];
    _PostedProductArry = [[NSMutableArray alloc]init];
    _postActionArray = [[NSMutableArray alloc] init];
    
    [super hideMainMenu];
    // Do any additional setup after loading the view.
    _bIsNewPost = NO;
    
    if(_bEditingMode == YES)
//      if(_bEditingMode == NO)
    {
        if(_shownPost == nil)
        {
            _bIsNewPost = YES;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if(!(appDelegate.currentUser.idUser == nil))
                {
                    if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                        
                        _shownPost = [[FashionistaPost alloc] initWithEntity:[NSEntityDescription entityForName:@"FashionistaPost" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                        
                        [_shownPost setUserId:appDelegate.currentUser.idUser];
                        
                        if(!(_parentFashionistaPage == nil))
                        {
                            if(!(_parentFashionistaPage.idFashionistaPage == nil))
                            {
                                if(!([_parentFashionistaPage.idFashionistaPage isEqualToString:@""]))
                                {
                                    [_shownPost setFashionistaPageId:_parentFashionistaPage.idFashionistaPage];
                                }
                            }
                        }
                        
                        [currentContext processPendingChanges];

                        [currentContext save:nil];
                    }
                }
            }
        }
        
    }
    else
    {
        //Setup a fetched results controller to fetch the current user wardrobes
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if(appDelegate.currentUser)
        {
            [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"userId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idWardrobe" ascending:YES];
            
            if (!(_wardrobesFetchedResultsController == nil))
            {
                NSMutableArray * userWardrobesElements = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < [[_wardrobesFetchedResultsController fetchedObjects] count]; i++)
                {
                    Wardrobe * tmpWardrobe = [[_wardrobesFetchedResultsController fetchedObjects] objectAtIndex:i];
                    
                    [userWardrobesElements addObjectsFromArray:tmpWardrobe.itemsId];
                }
                
                _wardrobesFetchedResultsController = nil;
                _wardrobesFetchRequest = nil;
                
                [self initFetchedResultsControllerWithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:userWardrobesElements sortingWithKey:@"idGSBaseElement" ascending:YES];
            }
        }
        
        if(!([appDelegate.currentUser.idUser isEqualToString:_shownPost.userId]))
        {
            // Appropriately setup the hanger button
            [self setupHangerButton:[self doesCurrentUserWardrobesContainPostWithId:_shownPost.idFashionistaPost]];

            [self uploadPostView];
        }
        
    }
    
    // Setup Post View
    [self setupPostTopView];
    
    // Setup the post content
    [self setupPostViews: YES];
    
    // Setup the 'Add term' button
    [self setupAddTermButton];
    
    //[self stopActivityFeedback];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UIWindowDidRotateNotification" object:nil queue:nil usingBlock:^(NSNotification *note) {
        if ([note.userInfo[@"UIWindowOldOrientationUserInfoKey"] intValue] >= 3) {
            self.navigationController.navigationBar.frame = (CGRect){0, 0, self.view.frame.size.width, 64};
        }
    }];
    
}

- (void)selectAButton{
    [self selectTheButton:self.homeButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getBackgroundAdForCurrentUser];
    
    // Observe the notification for keyboard appearing/dissappearing in order to properly animate Add Terms text field
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameWithNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    // Setup the 'Add term' button
    [self setupEditTextContentTextView];
    
    if((!(_selectedContentToAddWardrobe == nil)) || (!(_wardrobeSelected == nil)))
    {
        if(!(_shownPost.idFashionistaPost == nil))
        {
            if(!([_shownPost.idFashionistaPost isEqualToString:@""]))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownPost.idFashionistaPost, nil];
                [self performRestGet:GET_POST_CONTENT withParamaters:requestParameters];
            }
        }
        
        _wardrobeSelected = nil;
        _selectedContentToAddWardrobe = nil;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.addingProductsToWardrobeID = nil;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Initialize a specific Fetched Results Controller to fetch the local keywords in order to force user to select one
- (BOOL)initFetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate withString:(NSString *)stringForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    BOOL bReturn = FALSE;
    
    if(_keywordsFetchedResultsController == nil)
    {
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        if (_keywordssFetchRequest == nil)
        {
            if(!(stringForPredicate == nil))
            {
                if(!([stringForPredicate isEqualToString:@""]))
                {
                    _keywordssFetchRequest = [[NSFetchRequest alloc] init];
                    
                    // Entity to look for
                    
                    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                    
                    [_keywordssFetchRequest setEntity:entity];
                    
                    // Filter results
                    
                    [_keywordssFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, stringForPredicate]];
                    
                    // Sort results
                    
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                    
                    [_keywordssFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                    
                    [_keywordssFetchRequest setFetchBatchSize:20];
                }
            }
        }
        
        if(_keywordssFetchRequest)
        {
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_keywordssFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
            
            _keywordsFetchedResultsController = fetchedResultsController;
            
            _keywordsFetchedResultsController.delegate = self;
        }
        
        if(_keywordsFetchedResultsController)
        {
            // Perform fetch
            
            NSError *error = nil;
            
            if (![_keywordsFetchedResultsController performFetch:&error])
            {
                // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                
                NSLog(@"Couldn't fetch wardrobes. Unresolved error: %@, %@", error, [error userInfo]);
                
                return FALSE;
            }
            
            bReturn = ([_keywordsFetchedResultsController fetchedObjects].count > 0);
        }
    }
    
    return bReturn;
}

- (void) setupPostTopView
{
    // Top bar title
    NSString * title = NSLocalizedString(([NSString stringWithFormat:@"_VCTITLE_%i_",[self.restorationIdentifier intValue]]), nil);

    // Top bar subtitle
    NSString * subtitle = ( (_bEditingMode) ? (NSLocalizedString(@"_ADD_IMAGESVIDEOTEXTANDTAG_", nil)) : (nil) );
    
    if (!(_shownPostUser == nil))
    {
        if(!(_shownPostUser.fashionistaName == nil))
        {
            if(!([_shownPostUser.fashionistaName isEqualToString:@""]))
            {
                title = [NSString stringWithFormat:@"@%@", _shownPostUser.fashionistaName];
            }
        }

        if(!(_shownPost.name == nil))
        {
            if(!([_shownPost.name isEqualToString:@""]))
            {
                // Set top bar subtitle
                subtitle = _shownPost.name;
            }
        }
    }
    
    // Set top bar title and subtitle
    [self setTopBarTitle:title andSubtitle:subtitle];
}



// OVERRIDE: Title button action
- (void)titleButtonAction:(UIButton *)sender
{
    if(_bEditingMode)
    {
        return;
    }

    if(!(_shownPost.userId == nil))
    {
        if(!([_shownPost.userId isEqualToString:@""]))
        {
            if(!(self.fromViewController == nil))
            {
                if ([[self fromViewController] isKindOfClass: [FashionistaProfileViewController class]])
                {
                    if([[[((FashionistaProfileViewController *)[self fromViewController]) shownStylist] idUser] isEqualToString:_shownPost.userId])
                    {
                        [self dismissViewController];
                        
                        return;
                    }
                }
            }
            
            // Perform request to get the result contents
            NSLog(@"Getting contents for Fashionista: %@", _shownPost.userId);
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownPost.userId, nil];
            
            [self performRestGet:GET_FASHIONISTA withParamaters:requestParameters];
        }
    }
}

//-(void) setupPostCreationView
//{
//    _postCategories = [[NSMutableArray alloc] initWithObjects:  NSLocalizedString(@"_GENERALFASHION_CAT_", nil), NSLocalizedString(@"_MAKEUP_CAT_", nil), NSLocalizedString(@"_DEISGNERS_CAT_", nil), NSLocalizedString(@"_FOOTWEAR_CAT_", nil), NSLocalizedString(@"_SWINWEARANDCOVERUPS_CAT_", nil), NSLocalizedString(@"_MENSFASHION_CAT_", nil), NSLocalizedString(@"_WOMENSFASHION_CAT_", nil), NSLocalizedString(@"_KIDSFASHION_CAT_", nil), NSLocalizedString(@"_COATS_CAT_", nil), NSLocalizedString(@"_TOPS_CAT_", nil), NSLocalizedString(@"_SWEATERS_CAT_", nil), NSLocalizedString(@"_JACKETSANDVESTS_CAT_", nil), NSLocalizedString(@"_JEANS_CAT_", nil), NSLocalizedString(@"_PANTSANDSHORTS_CAT_", nil), NSLocalizedString(@"_SKIRTS_CAT_", nil), NSLocalizedString(@"_JUMPSUITSANDROMPERS_CAT_", nil), NSLocalizedString(@"_SUITSANDSEPERATES_CAT_", nil), NSLocalizedString(@"_LINGERIE_CAT_", nil), NSLocalizedString(@"_LOUNGEANDSLEEPWEAR_CAT_", nil), NSLocalizedString(@"_OTHERS_CAT_", nil), nil];
//    
//    //    [_postCategoryPickerSuperView.layer setCornerRadius:5];
//    //    [_postCategoryPickerView.layer setCornerRadius:10];
//    
//    [_postCategoryPickerView selectRow:0 inComponent:0 animated:NO];
//    
//    [_postTypeSegmentedControl setSelectedSegmentIndex:0];
//    
//    if (_bEditingMode)
//    {
//        // Set 'Add image' button
//        UIButton * addImageButton = [UIButton createButtonWithOrigin:CGPointMake(self.postCreationView.frame.origin.x + (2*kCreateViewDeleteButtonsInset), (_postCategoryPickerView.frame.origin.y + _postCategoryPickerView.frame.size.height)+(((_postCreationView.frame.size.height - (_postCategoryPickerView.frame.origin.y + _postCategoryPickerView.frame.size.height) - kCreateViewDeleteButtonsHeight)) / 2))
//                                                             andSize:CGSizeMake(self.view.frame.size.width - (2*(2*kCreateViewDeleteButtonsInset)) - (IS_IPHONE_6P ? 8 : 0), kCreateViewDeleteButtonsHeight)
//                                                      andBorderWidth:kCreateViewDeleteButtonBorderWidth
//                                                      andBorderColor:[UIColor kCreateViewDeleteButtonBorderColor]
//                                                             andText:NSLocalizedString(@"_ADDPREVIEWIMAGETOPOST_BTN_", nil)
//                                                             andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
//                                                        andFontColor:[UIColor blackColor]
//                                                      andUppercasing:NO
//                                                        andAlignment:UIControlContentHorizontalAlignmentCenter
//                                                            andImage:nil
//                                                        andImageMode:UIViewContentModeScaleAspectFit
//                                                  andBackgroundImage:nil];
//        
//        [addImageButton setBackgroundColor:[UIColor whiteColor]];
//        [addImageButton setAlpha:0.7];
//        
//        // Button action
//        [addImageButton addTarget:self action:@selector(addImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        
//        // Insert button into Post View
//        [self.postCreationView addSubview:addImageButton];
//        [self.postCreationView bringSubviewToFront:addImageButton];
//        
//    }
//}


#pragma mark - Post views setup


-(void) setupPostViews:(BOOL) bUpdateContentPosition
{
    if (_kwDict != nil)
    {
        [_kwDict removeAllObjects];
    }
    
    if (_viewsDict != nil)
    {
        [_viewsDict removeAllObjects];
    }
    
    if (_wardrobeDict != nil)
        [_wardrobeDict removeAllObjects];
    
    NSArray * sortedFashionistaContent = nil;
    _PostAlreadyContainsImages = NO;
    _PostAlreadyContainsVideos = NO;
    _PostAlreadyContainsTexts = NO;

    //  Operation queue initialization
    if(self.imagesQueue == nil)
    {
        self.imagesQueue = [[NSOperationQueue alloc] init];
        
        // Set max number of concurrent operations it can perform at 3, which will make things load even faster
        self.imagesQueue.maxConcurrentOperationCount = 3;
    }
    
    _iSelectedContent = -1;
    
     @autoreleasepool {
         
    // Remove subviews
         for(UIView * view in [self.FashionistaPostView subviews])
         {
             if(view != self.CommentsView)
             {
                 [view removeFromSuperview];
             }
         }
     }

//    [[self.FashionistaPostView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.FashionistaPostView setFrame:self.view.frame];
    
    postViewY = kTopExtraSpace + kPostViewVerticalInset;
    
    if(!(_shownPost == nil))
    {
        if(!(_shownFashionistaPostContent == nil))
        {
            if([_shownFashionistaPostContent count] > 0)
            {
                sortedFashionistaContent = [_shownFashionistaPostContent sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
            }
        }
    }
    
    if(!(sortedFashionistaContent == nil))
    {
        if([sortedFashionistaContent count] > 0)
        {
            self.tempImagePath = @"";
            
            for (int i = 0; i < [sortedFashionistaContent count]; i++)
            {
                FashionistaContent * fashionistaContent = [sortedFashionistaContent objectAtIndex:i];
                
                if (!(fashionistaContent == nil))
                {
                    NSMutableArray * arrViewsContent = [[NSMutableArray alloc] init];
                    [_viewsDict setValue:arrViewsContent forKey:fashionistaContent.idFashionistaContent];
                    
                    if(!(fashionistaContent.image == nil))
                    {
                        if (!([fashionistaContent.image isEqualToString:@""]))
                        {
                            _PostAlreadyContainsImages = YES;
                            
//                            [_webViewArray addObject:[[UIWebView alloc]initWithFrame:self.view.frame]];
                            
  //                          [self addPostImage:fashionistaContent.image atIndex:(int)([_webViewArray count] - 1)];
                            
                            [self setupImageViewWithTag:i andContent:fashionistaContent andImage:fashionistaContent.image withSize:CGSizeMake(((fashionistaContent.image_width == nil) || (!([fashionistaContent.image_width floatValue] > 0)) ? (kDefaultImageWidth) : ([fashionistaContent.image_width floatValue])), ((fashionistaContent.image_height == nil) || (!([fashionistaContent.image_height floatValue] > 0)) ? (kDefaultImageHeight) : ([fashionistaContent.image_height floatValue]))) ];
                        }
                    }
                    else if(!(fashionistaContent.video == nil))
                    {
                        if (!([fashionistaContent.video isEqualToString:@""]))
                        {
                            _PostAlreadyContainsVideos = YES;
                            
                            //[self setupVideoViewWithTag:i andVideo:fashionistaContent.video];
                            [self setupVideoViewWithTag:i andContent:fashionistaContent andVideo:fashionistaContent.video ];
                        }
                    }
                    else if(!(fashionistaContent.text == nil))
                    {
                        if (!([fashionistaContent.text isEqualToString:@""]))
                        {
                            _PostAlreadyContainsTexts = YES;
                            
                            [self setupTextViewWithTag:i andText:fashionistaContent.text fashionistaContent:fashionistaContent];
                        }
                    }
                    
                }
            }
            
            if(_bEditingMode)
            {
                [self setupEditPostButtons];

                if(self.FashionistaPostView.contentSize.height > self.FashionistaPostView.bounds.size.height)
                {
                    if (bUpdateContentPosition)
                    {
                        CGPoint bottomOffset = CGPointMake(0, self.FashionistaPostView.contentSize.height - self.FashionistaPostView.bounds.size.height + self.FashionistaPostView.contentInset.bottom);
                        [self.FashionistaPostView setContentOffset:bottomOffset animated:YES];
                    }
                    else
                    {
                        [self.FashionistaPostView setContentOffset:self.currentScrollPosition animated:NO];
                    }
                }
            }
            else
            {
                [self setupCommentsView];
            }
            
            return;
        }
    }
    
    [self setupBackgroundImage];
    
    if(!_bEditingMode)
    {
        // Set the title label
        UILabel * noContentsLabel = [UILabel createLabelWithOrigin:CGPointMake(self.FashionistaPostView.frame.origin.x, self.FashionistaPostView.frame.origin.y)
                                                           andSize:CGSizeMake(self.FashionistaPostView.frame.size.width,self.FashionistaPostView.frame.size.height)
                                                andBackgroundColor:[UIColor clearColor]
                                                          andAlpha:kAlphaInNoContentsLabel
                                                           andText:NSLocalizedString(@"_NO_FASHIONISTA_CONTENT_MSG_", nil)
                                                      andTextColor:[UIColor whiteColor]
                                                           andFont:[UIFont fontWithName:@kFontInNoContentsLabel size:kFontSizeInNoContentsLabel]
                                                    andUppercasing:NO
                                                        andAligned:NSTextAlignmentCenter];
        
        [noContentsLabel setNumberOfLines:0];
        
        // Add title to view
        [self.view addSubview:noContentsLabel];
    }
    else
    {
        [self setupEditPostButtons];
    }
}


// Setup Main Collection View background image
- (void) setupBackgroundImage
{
    self.backgroundAdImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    [self.backgroundAdImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.backgroundAdImageView setBackgroundColor:[UIColor clearColor]];
    
    [self.backgroundAdImageView setAlpha:1.00];

    [self setBackgroundImage];
    
    [self.FashionistaPostView addSubview:self.backgroundAdImageView];
}

// Set a specific image as background
-(void) setBackgroundImage
{
    if((!(_shownFashionistaPostContent == nil)) && ([_shownFashionistaPostContent count] > 0))
    {
        return;
    }
    
    if(bIsChangingBackgroundAd)
    {
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!(appDelegate.nextPostAdaptedBackgroundAd == nil))
    {
        if(!([appDelegate.nextPostAdaptedBackgroundAd imageURL ] == nil))
        {
            if(!([[appDelegate.nextPostAdaptedBackgroundAd imageURL] isEqualToString:@""]))
            {
                if(!([_backgroundAdImageView image] == nil))
                {
                    if(!(_currentBackgroundAd == nil))
                    {
                        if(!(_currentBackgroundAd.imageURL == nil))
                        {
                            if(!([_currentBackgroundAd.imageURL isEqualToString:@""]))
                            {
                                if([[appDelegate.nextPostAdaptedBackgroundAd imageURL] isEqualToString:_currentBackgroundAd.imageURL])
                                {
                                    return;
                                }
                            }
                        }
                    }
                }
                
                bIsChangingBackgroundAd = YES;
                
                _currentBackgroundAd = appDelegate.nextPostAdaptedBackgroundAd;
                
                NSString *backgroundImageURL = [_currentBackgroundAd imageURL];
                
                if ([UIImage isCached:backgroundImageURL])
                {
                    UIImage * image = [UIImage cachedImageWithURL:backgroundImageURL];
                    
                    if(image == nil)
                    {
                        return;//image = nil;//[UIImage imageNamed:@"Splash_Background.png"];
                    }
                    
                    [UIView animateWithDuration:1.0
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^ {
                                         
                                         [_backgroundAdImageView setAlpha:0.01];
                                         
                                         [self.view setBackgroundColor:[UIColor whiteColor]];
                                     }
                                     completion:^(BOOL finished) {
                                         
                                         [_backgroundAdImageView setImage:image];
                                         
                                         [UIView animateWithDuration:1.0
                                                               delay:0
                                                             options:UIViewAnimationOptionCurveEaseOut
                                                          animations:^ {
                                                              
                                                              [_backgroundAdImageView setAlpha:1.0];
                                                              
                                                              [self.view setBackgroundColor:[UIColor lightGrayColor]];

                                                          }
                                                          completion:^(BOOL finished) {
                                                              
                                                              bIsChangingBackgroundAd = NO;
                                                              
                                                          }];
                                     }];
                }
                else
                {
                    // Load image in the background
                    
                    __weak FashionistaPostViewController *weakSelf = self;
                    
                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        
                        UIImage * image = [UIImage cachedImageWithURL:backgroundImageURL];
                        
                        if(image == nil)
                        {
                            return;//image = nil;//[UIImage imageNamed:@"Splash_Background.png"];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            // Then set them via the main queue if the cell is still visible.
                            
                            [UIView animateWithDuration:1.0
                                                  delay:0
                                                options:UIViewAnimationOptionCurveEaseOut
                                             animations:^ {
                                                 
                                                 [weakSelf.backgroundAdImageView setAlpha:0.01];
                                                 
                                                 [weakSelf.view setBackgroundColor:[UIColor whiteColor]];
                                             }
                                             completion:^(BOOL finished) {
                                                 
                                                 [weakSelf.backgroundAdImageView setImage:image];
                                                 
                                                 [UIView animateWithDuration:1.0
                                                                       delay:0
                                                                     options:UIViewAnimationOptionCurveEaseOut
                                                                  animations:^ {
                                                                      
                                                                      [weakSelf.backgroundAdImageView setAlpha:1.0];
                                                                      
                                                                      [weakSelf.view setBackgroundColor:[UIColor lightGrayColor]];
                                                                  }
                                                                  completion:^(BOOL finished) {
                                                                      
                                                                      bIsChangingBackgroundAd = NO;
                                                                      
                                                                  }];
                                             }];
                        });
                    }];
                    
                    operation.queuePriority = NSOperationQueuePriorityHigh;
                    
                    [self.imagesQueue addOperation:operation];
                }
                
                return;
            }
        }
    }
    
    [_backgroundAdImageView setImage:nil];
}

// Request the BackgroundAd to be shown to the user
- (void) getBackgroundAdForCurrentUser
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                
                [self performRestGet:GET_POSTADAPTEDBACKGROUNDAD withParamaters:requestParameters];
                
                return;
            }
        }
    }
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:@"", nil];
    
    [self performRestGet:GET_POSTADAPTEDBACKGROUNDAD withParamaters:requestParameters];
}

// Setup and init the search terms list
-(void)initSearchTermsListView:(SlideButtonView *)TermsListView
{
    // Setup the search terms list
    
    if(_bEditingMode)
    {
        [TermsListView setMinWidthButton:50];
    }
    else
    {
        [TermsListView setMinWidthButton:5];
    }
    
    [TermsListView setSpaceBetweenButtons:0];
    [TermsListView setBShowShadowsSides:YES];
    [TermsListView setBShowPointRight:YES];
    [TermsListView setBButtonsCentered:NO];
    
    [TermsListView setSNameButtonImageHighlighted:@"termListButtonBackground.png"];
    
    // array of the string with the names of the buttons
    NSMutableArray * arButtons = [[NSMutableArray alloc] init];
    
    // add any option
    [TermsListView initSlideButtonWithButtons:arButtons andDelegate:self];
    
    [TermsListView setBackgroundColor:[UIColor clearColor]];
    [TermsListView setColorBackgroundButtons:[UIColor clearColor]];
}

-(UIView*) getViewFromTag:(long) tag
{
    AVPlayerViewController *  player = [[AVPlayerViewController alloc] init];
    
    for (UIView * view in self.FashionistaPostView.subviews)
    {
        // only check the image view, because they are the "parent" of the other view of the postcontent
        if (([view isKindOfClass:[UIImageView class]]) || ([view isKindOfClass:[player.view class]]))
        {
            if (view.tag == tag)
            {
                player = nil;
    
                return view;
            }
        }
    }

    player = nil;
    
    return nil;
}

-(int) getTagFromFashionistaContentId:(NSString * )idContent
{
    NSArray * sortedFashionistaContent = nil;
    
    if(!(_shownPost == nil))
    {
        if(!(_shownFashionistaPostContent == nil))
        {
            if([_shownFashionistaPostContent count] > 0)
            {
                sortedFashionistaContent = [_shownFashionistaPostContent sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
            }
        }
    }
    
    if(!(sortedFashionistaContent == nil))
    {
        if([sortedFashionistaContent count] > 0)
        {
            int iIndex = 0;
            for (FashionistaContent * contentToCheck in sortedFashionistaContent)
            {
                if ([contentToCheck.idFashionistaContent isEqualToString:idContent])
                {
                    return iIndex;
                }
                iIndex++;
            }
        }
    }
    
    return -1;
}

// Setup and init the search terms list
-(void)initWardrobeProductsView:(SlideButtonView *)wardrobeProductsView
{
    // Setup the thumbnails list
    
    [wardrobeProductsView setMinWidthButton:50];
    [wardrobeProductsView setSpaceBetweenButtons:2];
    [wardrobeProductsView setBShowShadowsSides:YES];
    [wardrobeProductsView setBShowPointRight:YES];
    [wardrobeProductsView setBButtonsCentered:NO];
    [wardrobeProductsView setBackgroundColor:[UIColor clearColor]];
    [wardrobeProductsView setTypeButton:IMAGE];
    
    
    // array of the string with the names of the buttons
    NSMutableArray * arButtons = [[NSMutableArray alloc] init];
    
    [wardrobeProductsView initSlideButtonWithButtons:arButtons andDelegate:self];
    
    [wardrobeProductsView setBackgroundColor:[UIColor clearColor]];
    [wardrobeProductsView setColorBackgroundButtons:[UIColor clearColor]];
}

-(void)createWardrobeView:(UIView *) contentView withTag:(int)tag andContent:(FashionistaContent*)content andYpos:(CGFloat*) postViewY
{
    NSMutableArray * arrayViews = [_viewsDict valueForKey:content.idFashionistaContent];
    
    // Setup the container view
    // TO CREATE IT OUTSIDE THE CONTENT VIEW:
    //wardrobeView = [[UIView alloc] initWithFrame:CGRectMake(2, *postViewY-5, contentView.frame.size.width, kAddProductsViewHeight)];
    // TO CREATE IT WITHIN THE CONTENT VIEW:
    
    wardrobeView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.origin.x+kCreateViewDeleteButtonsInset,
                                                            contentView.frame.origin.y + ((contentView.frame.size.height - ((2*kCreateViewDeleteButtonsHeight) + (1*(kCreateViewDeleteButtonsInset + kDeleteAndEditExtraSpace)) + ((2*kCreateViewDeleteButtonsInset) + kAddProductsViewHeight + kAddTagsViewHeight)))/2) + (kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset) + (kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset),
                                                            contentView.frame.size.width - (2*kCreateViewDeleteButtonsInset),
                                                            kAddProductsViewHeight)];
    
    // Label appearance
    [[wardrobeView layer] setCornerRadius:5.0];
    [[wardrobeView layer] setBorderWidth:1];//kCreateViewDeleteButtonBorderWidth];
    [[wardrobeView layer] setBorderColor:[UIColor blackColor].CGColor];//kCreateViewDeleteButtonBorderColor].CGColor];
    [wardrobeView setBackgroundColor:[UIColor clearColor]];
    [wardrobeView setAlpha:0.9];
    [wardrobeView setClipsToBounds:YES];
    [wardrobeView setTag:tag];
    
    UIImageView * backgroundWardrobeView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,wardrobeView.frame.size.width,wardrobeView.frame.size.height)];
    
    [backgroundWardrobeView setContentMode:UIViewContentModeScaleAspectFill];
    
    [backgroundWardrobeView setBackgroundColor:[UIColor clearColor]];
    
    [backgroundWardrobeView setAlpha:1.0];
    
    [backgroundWardrobeView setImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"]];
    
    [wardrobeView addSubview:backgroundWardrobeView];
    
    
    if(_bEditingMode)
    {
        if ([self existsWardrobeInContent: content])
        {
            
//        }
//        if((!(content.wardrobeId == nil)) && (!([content.wardrobeId isEqualToString:@""])))
//        {
            // Set the delete wardrobe button
            UIButton * deleteWardrobeButton = [UIButton createButtonWithOrigin:CGPointMake(wardrobeView.frame.size.width - 50, self.searchTermsListView.frame.origin.y+10)
                                                                       andSize:CGSizeMake(40, 40)
                                                                andBorderWidth:0.0
                                                                andBorderColor:[UIColor clearColor]
                                                                       andText:NSLocalizedString(@"_DELETEWARDROBE_BTN_", nil)
                                                                       andFont:[UIFont fontWithName:@"Avenir-Light" size:16]
                                                                  andFontColor:[UIColor blackColor]
                                                                andUppercasing:NO
                                                                  andAlignment:UIControlContentHorizontalAlignmentCenter
                                                                      andImage:[UIImage imageNamed:@"Clear.png"]
                                                                  andImageMode:UIViewContentModeScaleAspectFit
                                                            andBackgroundImage:nil];
            
            [deleteWardrobeButton addTarget:self action:@selector(deleteContentWardrobe:) forControlEvents:UIControlEventTouchUpInside];
            
            [deleteWardrobeButton setAlpha:0.35];
            
            [deleteWardrobeButton setTag: [[NSNumber numberWithInt:tag] integerValue]];
            
            [wardrobeView addSubview:deleteWardrobeButton];
            
            // Set the edit wardrobe button
            UIButton * editWardrobeButton = [UIButton createButtonWithOrigin:CGPointMake(wardrobeView.frame.size.width - 100, self.searchTermsListView.frame.origin.y+10)
                                                                     andSize:CGSizeMake(40, 40)
                                                              andBorderWidth:0.0
                                                              andBorderColor:[UIColor clearColor]
                                                                     andText:NSLocalizedString(@"_EDITWARDROBE_BTN_", nil)
                                                                     andFont:[UIFont fontWithName:@"Avenir-Light" size:16]
                                                                andFontColor:[UIColor blackColor]
                                                              andUppercasing:NO
                                                                andAlignment:UIControlContentHorizontalAlignmentCenter
                                                                    andImage:[UIImage imageNamed:@"add_wardrobe_to_postcontent.png"]
                                                                andImageMode:UIViewContentModeScaleAspectFit
                                                          andBackgroundImage:nil];
            
            
            [editWardrobeButton addTarget:self action:@selector(editContentWardrobe:) forControlEvents:UIControlEventTouchUpInside];
            
            [editWardrobeButton setAlpha:0.35];
            
            [editWardrobeButton setTag: [[NSNumber numberWithInt:tag] integerValue]];
            
            [wardrobeView addSubview:editWardrobeButton];
        }
        else
        {
            // Set the add wardrobe button
            UIButton * addWardrobeButton = [UIButton createButtonWithOrigin:CGPointMake(wardrobeView.frame.size.width - 50, self.searchTermsListView.frame.origin.y+10)
                                                                    andSize:CGSizeMake(40, 40)
                                                             andBorderWidth:0.0
                                                             andBorderColor:[UIColor clearColor]
                                                                    andText:NSLocalizedString(@"_ADDWARDROBE_BTN_", nil)
                                                                    andFont:[UIFont fontWithName:@"Avenir-Light" size:16]
                                                               andFontColor:[UIColor blackColor]
                                                             andUppercasing:NO
                                                               andAlignment:UIControlContentHorizontalAlignmentCenter
                                                                   andImage:[UIImage imageNamed:@"add_wardrobe_to_postcontent.png"]
                                                               andImageMode:UIViewContentModeScaleAspectFit
                                                         andBackgroundImage:nil];
            
            [addWardrobeButton addTarget:self action:@selector(addContentWardrobe:) forControlEvents:UIControlEventTouchUpInside];
            
            [addWardrobeButton setAlpha:0.35];

            // Set button tag for later image identification
            [addWardrobeButton setTag: [[NSNumber numberWithInt:tag] integerValue]];
            
            // Add button to view
            [wardrobeView addSubview:addWardrobeButton];
        }
    }
    
    
    // Add label with the action to perform
    UILabel * messageLabel = [UILabel createLabelWithOrigin:CGPointMake(10, 0)
                                                    andSize:CGSizeMake(wardrobeView.frame.size.width - 110, wardrobeView.frame.size.height)
                                         andBackgroundColor:[UIColor clearColor]
                                                   andAlpha:1.0
                                                    andText:(((content.video != nil) && (!([content.video isEqualToString:@""]))) ? (NSLocalizedString(@"_ADDPRODUCTSTOVIDEO_", nil)) : (NSLocalizedString(@"_ADDPRODUCTSTOIMAGE_", nil)))
                                               andTextColor:[UIColor blackColor]
                                                    andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
                                             andUppercasing:NO
                                                 andAligned:NSTextAlignmentLeft];
    
    [wardrobeView addSubview:messageLabel];

    // Add to dictionary
    SlideButtonView * productImagesList = [_wardrobeDict valueForKey:content.idFashionistaContent];
    
    if(!productImagesList)
    {
        SlideButtonView * pWardrobeProductsView = [[SlideButtonView alloc] initWithFrame:CGRectMake(5, 5, wardrobeView.frame.size.width-((_bEditingMode) ? ((((!(content.wardrobeId == nil)) && (!([content.wardrobeId isEqualToString:@""]))) ? 110 : 60)) : (5)), 50)];
        
        [_wardrobeDict setValue:pWardrobeProductsView forKey:content.idFashionistaContent];
        
        [wardrobeView addSubview:pWardrobeProductsView];
        [self initWardrobeProductsView:pWardrobeProductsView];
    }
    else
    {
        [wardrobeView addSubview:productImagesList];
        [self initWardrobeProductsView:productImagesList];
    }
    
    [self.FashionistaPostView addSubview:wardrobeView];
    [self.FashionistaPostView bringSubviewToFront:wardrobeView];

    [arrayViews addObject:wardrobeView];
    
    // Get the content products
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:content.idFashionistaContent, nil];
    
    [self performOwnRestGet:GET_POST_CONTENT_WARDROBE withParamaters:requestParameters];
    
//    *postViewY += 60;
}

-(void) setupImageViewWithTag:(int)tag andContent:(FashionistaContent*)content andImage:(NSString *) imageURL withSize:(CGSize) imageSize
{
    NSMutableArray * arrayViews = [_viewsDict valueForKey:content.idFashionistaContent];
    
    if ([UIImage isCached:imageURL])
    {

        
        // Get image
        UIImage * image = [UIImage cachedImageWithURL:imageURL];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        // Calculate the proper dimensions for the image view
        double scale = image.size.height / image.size.width;
        
        // Setup View
        
        float viewWidth = (self.FashionistaPostView.frame.size.width - (2*kPostViewHorizontalInset) - (IS_IPHONE_6P ? 8 : 0));
        float viewHeight = (viewWidth * scale);
        float viewHeightWithButtons = (kCreateViewDeleteButtonsInset + kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset + kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset + kAddProductsViewHeight + kCreateViewDeleteButtonsInset + kAddTagsViewHeight + kCreateViewDeleteButtonsInset);
        
        if ( (self.bEditingMode) && ( viewHeightWithButtons > viewHeight ) )
        {
            viewHeight = viewHeightWithButtons;
        }
        
        CGRect viewRect = CGRectMake(self.FashionistaPostView.frame.origin.x + kPostViewHorizontalInset, postViewY, viewWidth, viewHeight);
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:viewRect];
        
        [imageView setBackgroundColor:[UIColor whiteColor]];
        
        //        [[imageView layer] setCornerRadius:5.0];
        
        [[imageView layer] setBorderWidth:1];
        
        [[imageView layer] setBorderColor:[UIColor darkGrayColor].CGColor];
        
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [imageView setClipsToBounds:YES];
        
        [imageView setImage:image];
        
        [imageView setTag:tag];
        
        // Set the button to view zoomed image
        UIButton * imageButton = [UIButton createButtonWithOrigin:viewRect.origin
                                                          andSize:viewRect.size
                                                   andBorderWidth:0.0
                                                   andBorderColor:[UIColor clearColor]
                                                          andText:nil
                                                          andFont:nil
                                                     andFontColor:[UIColor clearColor]
                                                   andUppercasing:NO
                                                     andAlignment:UIControlContentHorizontalAlignmentCenter
                                                         andImage:nil
                                                     andImageMode:UIViewContentModeScaleAspectFit
                                               andBackgroundImage:nil];
        
        // Button action
        [imageButton addTarget:self action:@selector(onTapZoomPostImage:) forControlEvents:UIControlEventTouchUpInside];
        
        // Set button tag for later image identification
        [imageButton setTag: tag];//[[NSNumber numberWithInt:tag] integerValue]];
        
        // Insert View into Post View
        [self.FashionistaPostView addSubview:imageView];
        [self.FashionistaPostView bringSubviewToFront:imageView];
        [arrayViews addObject:imageView];
        lastAddedSubview = imageView;
        
        // Insert the Button into Post View
        [self.FashionistaPostView addSubview:imageButton];
        [self.FashionistaPostView bringSubviewToFront:imageButton];
        [arrayViews addObject:imageButton];
        
        // If Editing Mode, insert Edit content buttons
        [self setupEditButtonsForContent:IMAGE_CONTENT withTag:tag withinRect:viewRect fashionistaContent:content.idFashionistaContent];
        
        // Draw post content's wardrobe
        if(_bEditingMode)
            [self createWardrobeView:imageView withTag:tag andContent:content andYpos:&postViewY];
        
        // Pintar keywords del post content
        // se crean una vez han sido devueltos del server
        //if(_bEditingMode)
        {
            //            [self createKeywordView:imageView withTag:tag andContent:content andYpos:&postViewY];
            // Get the content keywords
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:content.idFashionistaContent, nil];
            
            [self performOwnRestGet:GET_POST_CONTENT_KEYWORDS withParamaters:requestParameters];
            
            
        }
        
        // If NOT Editing Mode, insert View Tags and View Wardrobe buttons
        [self setupButtonsToViewTags:YES andViewWardrobe:((!(content.wardrobeId == nil)) && (!([content.wardrobeId isEqualToString:@""]))) forTag:tag withinRect:viewRect];
        
        // Update Height for next view, if any
        postViewY += (imageView.frame.size.height + kPostViewVerticalInset);
        
        // Update Post View Content Size
        self.FashionistaPostView.contentSize = CGSizeMake(self.FashionistaPostView.contentSize.width, postViewY+kBottomExtraSpace);
    }
    else
    {
        // Calculate the proper dimensions for the image view
        double scale = imageSize.height / imageSize.width;
        
        // Setup View
        
        float viewWidth = (self.FashionistaPostView.frame.size.width - (2*kPostViewHorizontalInset) - (IS_IPHONE_6P ? 8 : 0));
        float viewHeight = (viewWidth * scale);
        float viewHeightWithButtons = (kCreateViewDeleteButtonsInset + kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset + kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset + kAddProductsViewHeight + kCreateViewDeleteButtonsInset + kAddTagsViewHeight + kCreateViewDeleteButtonsInset);
        
        if ( (self.bEditingMode) && ( viewHeightWithButtons > viewHeight ) )
        {
            viewHeight = viewHeightWithButtons;
        }
        
        CGRect viewRect = CGRectMake(self.FashionistaPostView.frame.origin.x + kPostViewHorizontalInset, postViewY, viewWidth, viewHeight);
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:viewRect];
        
        [imageView setBackgroundColor:[UIColor whiteColor]];
        
        //        [[imageView layer] setCornerRadius:5.0];
        
        [[imageView layer] setBorderWidth:1];
        
        [[imageView layer] setBorderColor:[UIColor darkGrayColor].CGColor];
        
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [imageView setClipsToBounds:YES];
        
        [imageView setTag:tag];
        
        // Set the button to view zoomed image
        UIButton * imageButton = [UIButton createButtonWithOrigin:viewRect.origin
                                                          andSize:viewRect.size
                                                   andBorderWidth:0.0
                                                   andBorderColor:[UIColor clearColor]
                                                          andText:nil
                                                          andFont:nil
                                                     andFontColor:[UIColor clearColor]
                                                   andUppercasing:NO
                                                     andAlignment:UIControlContentHorizontalAlignmentCenter
                                                         andImage:nil
                                                     andImageMode:UIViewContentModeScaleAspectFit
                                               andBackgroundImage:nil];
        
        // Button action
        [imageButton addTarget:self action:@selector(onTapZoomPostImage:) forControlEvents:UIControlEventTouchUpInside];
        
        // Set button tag for later image identification
        [imageButton setTag: tag];//[[NSNumber numberWithInt:tag] integerValue]];
        
        // Init the activity indicator
        UIActivityIndicatorView *imgViewActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        // Position and show the activity indicator
        //[imgViewActivityIndicator setCenter:CGPointMake(imageView.frame.origin.x + (imageView.frame.size.width*0.5), imageView.frame.origin.y + (imageView.frame.size.height*0.5))];
        [imgViewActivityIndicator setFrame:[imageView frame]];
        [imgViewActivityIndicator setHidesWhenStopped:YES];
        [imgViewActivityIndicator startAnimating];
        
        // Insert View into Post View
        [self.FashionistaPostView addSubview:imageView];
        [self.FashionistaPostView bringSubviewToFront:imageView];
        [arrayViews addObject:imageView];
        
        // Insert the Button into Post View
        [self.FashionistaPostView addSubview:imageButton];
        [self.FashionistaPostView bringSubviewToFront:imageButton];
        [arrayViews addObject:imageButton];

        // If Editing Mode, insert Edit content buttons
        [self setupEditButtonsForContent:IMAGE_CONTENT withTag:tag withinRect:viewRect fashionistaContent:content.idFashionistaContent];
        
        // If NOT Editing Mode, insert View Tags and View Wardrobe buttons
        [self setupButtonsToViewTags:YES andViewWardrobe:((!(content.wardrobeId == nil)) && (!([content.wardrobeId isEqualToString:@""]))) forTag:tag withinRect:viewRect];
        
        // Insert the Activity Indicator View into Post View
        [self.FashionistaPostView addSubview:imgViewActivityIndicator];
        [self.FashionistaPostView bringSubviewToFront:imgViewActivityIndicator];
        
        
        // Update Height for next view, if any
        postViewY += (imageView.frame.size.height + kPostViewVerticalInset);
        
        
        // Draw post content's wardrobe
        if(_bEditingMode)
            [self createWardrobeView:imageView withTag:tag andContent:content andYpos:&postViewY];
        
        // Pintar keywords del post content
        // se crean una vez han sido devueltos del server
        //if(_bEditingMode)
        {
            //            [self createKeywordView:imageView withTag:tag andContent:content andYpos:&postViewY];
            // Get the content keywords
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:content.idFashionistaContent, nil];
            
            [self performOwnRestGet:GET_POST_CONTENT_KEYWORDS withParamaters:requestParameters];
        }
        
        // Update Post View Content Size
        self.FashionistaPostView.contentSize = CGSizeMake(self.FashionistaPostView.contentSize.width, postViewY+kBottomExtraSpace);
        
        
        // Load image in the background
        
        //__weak FashionistaPostViewController *weakSelf = self;
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            // Get image
            UIImage * image = [UIImage cachedImageWithURL:imageURL];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Then set image via the main queue
                [imageView setImage:image];
                
                [imgViewActivityIndicator stopAnimating];
                [imgViewActivityIndicator removeFromSuperview];
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }
}

-(void) setupVideoViewWithTag:(int)tag andContent:(FashionistaContent*)content andVideo:(NSString *) videoURL
{
    NSMutableArray * arrayViews = [_viewsDict valueForKey:content.idFashionistaContent];
    
    //
    //
    //[player play];
    
    // Calculate the proper dimensions for the image view
    //double scale = image.size.height / image.size.width;
    
    // Setup View
    
    float viewWidth = (self.FashionistaPostView.frame.size.width - (2*kPostViewHorizontalInset) - (IS_IPHONE_6P ? 8 : 0));
    float viewHeight = (viewWidth * 0.75);
    float viewHeightWithButtons = (kCreateViewDeleteButtonsInset + kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset + kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset + kAddProductsViewHeight + kCreateViewDeleteButtonsInset + kAddTagsViewHeight + kCreateViewDeleteButtonsInset + kBottomExtraSpace + 5);
    
    if ( (self.bEditingMode) && ( viewHeightWithButtons > viewHeight ) )
    {
        viewHeight = viewHeightWithButtons;
    }
    
    CGRect viewRect = CGRectMake(self.FashionistaPostView.frame.origin.x + kPostViewHorizontalInset, postViewY, viewWidth, viewHeight);
    
    // Añadimos al diccionario
    AVPlayerViewController * player = [_videoDict valueForKey:content.idFashionistaContent];
    
    
    if(!player)
    {
        player = [[AVPlayerViewController alloc] init];
        [_videoDict setValue:player forKey:content.idFashionistaContent];
    }
    
    player.player = [AVPlayer playerWithURL:[NSURL URLWithString:videoURL]];
    //player.URL = [NSURL URLWithString:videoURL];
    //    [player setScalingMode:MPMovieScalingModeAspectFit];
    //    [player setControlStyle: MPMovieControlStyleEmbedded];
    //    [player setShouldAutoplay:NO];
    //    [player prepareToPlay];
    player.view.frame = viewRect;
    
    
    UIView * pView = player.view;
    
    pView.tag = tag;
    
    //[self.view addSubview:player.view];
    
    
    //[player.view setBackgroundColor:[UIColor whiteColor]];
    
    //        [[imageView layer] setCornerRadius:5.0];
    
    //[[player.view layer] setBorderWidth:1];
    
    //[[player.view layer] setBorderColor:[UIColor darkGrayColor].CGColor];
    
    //[player.view setContentMode:UIViewContentModeScaleAspectFit];
    
    //[player.view setClipsToBounds:YES];
    //[player play];
    
    
    // Insert View into Post View
    [self.FashionistaPostView addSubview:pView];
    [self.FashionistaPostView bringSubviewToFront:pView];
    
    [arrayViews addObject:pView];
    lastAddedSubview = pView;
    
    // If Editing Mode, insert Edit content buttons
    [self setupEditButtonsForContent:VIDEO_CONTENT withTag:tag withinRect:viewRect fashionistaContent:content.idFashionistaContent];
    
    // If NOT Editing Mode, insert View Tags and View Wardrobe buttons
    [self setupButtonsToViewTags:YES andViewWardrobe:((!(content.wardrobeId == nil)) && (!([content.wardrobeId isEqualToString:@""]))) forTag:tag withinRect:viewRect];
    
    
    
    // Update Height for next view, if any
    postViewY += (pView.frame.size.height + kPostViewVerticalInset);
    
    
    // Draw post content's wardrobe
    if(_bEditingMode)
        [self createWardrobeView:pView withTag:tag andContent:content andYpos:&postViewY];
    
    // Pintar keywords del post content
    //if(_bEditingMode)
    {
        //            [self createKeywordView:imageView withTag:tag andContent:content andYpos:&postViewY];
        // Get the content keywords
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:content.idFashionistaContent, nil];
        
        [self performOwnRestGet:GET_POST_CONTENT_KEYWORDS withParamaters:requestParameters];
    }
    
    // Update Post View Content Size
    self.FashionistaPostView.contentSize = CGSizeMake(self.FashionistaPostView.contentSize.width, postViewY+kBottomExtraSpace);
    
}

////2. After to make tapping enables, assign a UITapGestureRecognizer and its IBAction should look something like this:
//
//- (IBAction)messageTapped:(UITapGestureRecognizer *)recognizer {
//    UITextView *textView = (UITextView *)recognizer.view;
//    
//    NSLayoutManager *layoutManager = textView.layoutManager;
//    CGPoint location = [recognizer locationInView:textView];
//    
//    NSUInteger characterIndex;
//    characterIndex = [layoutManager characterIndexForPoint:location
//                                           inTextContainer:textView.textContainer
//                  fractionOfDistanceBetweenInsertionPoints:NULL];
//    
//    if (characterIndex < textView.textStorage.length) {
//        
//        NSRange range;
//        id wordType = [textView.attributedText attribute:wordType
//                                                 atIndex:characterIndex
//                                          effectiveRange:&range];
//        
//        if([wordType isEqualToString:userNameKey]){
//            NSString *userName = [textView.attributedText attribute:userNameKey
//                                                            atIndex:characterIndex
//                                                     effectiveRange:&range];
//            [self openViewControllerForUserName:userName];
//        } else if([wordType isEqualToString:hashTagKey]){
//            // TODO: Segue to hashtag controller once it is in place.
//        }
//    }
//}


-(void) setupTextViewWithTag:(int)tag andText:(NSString *) text fashionistaContent:(FashionistaContent *) content
{
    NSMutableArray * arrayViews = [_viewsDict valueForKey:content.idFashionistaContent];
    // Setup the text label
    UITextView * textLabel = [[UITextView alloc] initWithFrame:CGRectMake(self.FashionistaPostView.frame.origin.x + kPostViewHorizontalInset, postViewY, self.FashionistaPostView.frame.size.width - (2*kPostViewHorizontalInset) - (IS_IPHONE_6P ? 8 : 0), (self.FashionistaPostView.frame.size.width - (2*kPostViewHorizontalInset) - (IS_IPHONE_6P ? 8 : 0)))];
    
    // Label appearance
    [[textLabel layer] setCornerRadius:5.0];
    [[textLabel layer] setBorderWidth:1];
    [[textLabel layer] setBorderColor:[UIColor darkGrayColor].CGColor];
    [textLabel setBackgroundColor:[UIColor whiteColor]];
    [textLabel setAlpha:1.0];
    [textLabel setClipsToBounds:YES];
    //    [textLabel setEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [textLabel setFont:[UIFont fontWithName:@kFontInPostText size:kFontSizeInPostText]];
    [textLabel setTextColor:[UIColor blackColor]];
    [textLabel setAttributedText:[NSString attributedMessageFromMessage:text withFont:@kFontInPostText andSize:[NSNumber numberWithInt:kFontSizeInPostText]]];
    [textLabel setTextAlignment:NSTextAlignmentLeft];
    //    [textLabel setAdjustsFontSizeToFitWidth:NO];
    //    [textLabel setNumberOfLines:0];
    [textLabel sizeToFit];
    [textLabel setEditable:NO];
    
    textLabel.frame = CGRectMake(textLabel.frame.origin.x, textLabel.frame.origin.y, self.FashionistaPostView.frame.size.width - (2*kPostViewHorizontalInset) - (IS_IPHONE_6P ? 8 : 0), textLabel.frame.size.height+(_bEditingMode ? (kCreateViewDeleteButtonsInset+kCreateViewDeleteButtonsHeight): 0));
    
    // Insert View into Post View
    [self.FashionistaPostView addSubview:textLabel];
    [self.FashionistaPostView bringSubviewToFront:textLabel];
    
    [arrayViews addObject:textLabel];
    lastAddedSubview = textLabel;
    
    // If Editing Mode, insert Edit content buttons
    [self setupEditButtonsForContent:TEXT_CONTENT withTag:tag withinRect:textLabel.frame fashionistaContent:content.idFashionistaContent];
    
    // Update Height for next view, if any
    postViewY += (textLabel.frame.size.height + kPostViewVerticalInset);
    
    // Update Post View Content Size
    self.FashionistaPostView.contentSize = CGSizeMake(self.FashionistaPostView.contentSize.width, postViewY+kBottomExtraSpace);
}

-(void) setupVideoViewWithTag:(int)tag andVideo:(NSString *) videoURL
{
    
}

-(void) updatePosYContent
{
    [self hideAddSearchTerm];

    if (!self.bEditingMode)
        return;
    
    NSArray * sortedFashionistaContent = nil;
    
    if(!(_shownPost == nil))
    {
        if(!(_shownFashionistaPostContent == nil))
        {
            if([_shownFashionistaPostContent count] > 0)
            {
                sortedFashionistaContent = [_shownFashionistaPostContent sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
            }
        }
    }
    
    if(!(sortedFashionistaContent == nil))
    {
        if([sortedFashionistaContent count] > 0)
        {
            // Prepare webviews
            postViewY = kTopExtraSpace + kPostViewVerticalInset;
            
            for (int i = 0; i < [sortedFashionistaContent count]; i++)
            {
                FashionistaContent * fashionistaContent = [sortedFashionistaContent objectAtIndex:i];
                NSMutableArray * arrayViews = [_viewsDict valueForKey:fashionistaContent.idFashionistaContent];
                
                UIView * mainView = arrayViews[0];
                
                float originalHeight = mainView.frame.size.height;
                CGRect rect = mainView.frame;
                rect.origin.y = postViewY;
                
                if ([mainView isKindOfClass:[UIImageView class]])
                {
                    // imagen
                    float viewHeightWithButtons = kCreateViewDeleteButtonsInset;
                    for(int iIdx = 2 ; iIdx < arrayViews.count; iIdx++)
                    {
                        UIView * view = [arrayViews objectAtIndex:iIdx];
                        viewHeightWithButtons += view.frame.size.height + kCreateViewDeleteButtonsInset;
                    }
                    
                    if (viewHeightWithButtons > originalHeight)
                    {
                        rect.size.height = viewHeightWithButtons;
                    }
                    
                    float newPosYSubviews = (rect.size.height / 2.0) - (viewHeightWithButtons / 2.0) + kCreateViewDeleteButtonsInset;
                    
                    for(int iIdx = 2 ; iIdx < arrayViews.count; iIdx++)
                    {
                        BOOL bViewIsButton = NO;
                        
                        UIView * view = [arrayViews objectAtIndex:iIdx];
                        
                        if([view isKindOfClass:[UIButton class]])
                        {
                            bViewIsButton = YES;;
                        }
                        
                        CGRect rectView = view.frame;
                        rectView.origin.y = rect.origin.y + newPosYSubviews;
                        view.frame = rectView;

                        if((!(bViewIsButton)) || ((bViewIsButton) && (!([((UIButton *)view) titleForState:UIControlStateNormal] == NSLocalizedString(@"_EDIT_BTN_", nil)))))
                        {
                            newPosYSubviews += rectView.size.height + kCreateViewDeleteButtonsInset;
                        }
                        
                        if((bViewIsButton) && (!([((UIButton *)view) titleForState:UIControlStateNormal] == NSLocalizedString(@"_EDIT_BTN_", nil))))
                        {
                            newPosYSubviews += kDeleteAndEditExtraSpace;
                        }
                    }
                }
                else if ([mainView isKindOfClass:[UITextView class]] )
                {
                    // texto
                    for(int iIdx = 1 ; iIdx < arrayViews.count; iIdx++)
                    {
                        UIView * view = [arrayViews objectAtIndex:iIdx];
                        CGRect rectView = view.frame;
                        rectView.origin.y = (rect.origin.y + (rect.size.height - (MIN((rect.size.height - (2*kCreateViewDeleteButtonsInset)), kCreateViewDeleteButtonsHeight) + kCreateViewDeleteButtonsInset)));//(rect.origin.y + rect.size.height) - (kCreateViewDeleteButtonsInset + kCreateViewDeleteButtonsHeight);
                        view.frame = rectView;
                    }
                    NSLog(@"Content text");
                }
                else if ([mainView isKindOfClass:[UIView class]])
                {
                    // video
                    float viewHeightWithButtons = kCreateViewDeleteButtonsInset;
                    for(int iIdx = 1 ; iIdx < arrayViews.count; iIdx++)
                    {
                        UIView * view = [arrayViews objectAtIndex:iIdx];
                        viewHeightWithButtons += view.frame.size.height + kCreateViewDeleteButtonsInset;
                    }
                    if (viewHeightWithButtons > originalHeight)
                    {
                        rect.size.height = viewHeightWithButtons;
                    }
                    
                    float newPosYSubviews = (rect.size.height / 2.0) - (viewHeightWithButtons / 2.0) + kCreateViewDeleteButtonsInset;
                    
                    for(int iIdx = 1 ; iIdx < arrayViews.count; iIdx++)
                    {
                        BOOL bViewIsButton = NO;
                        
                        UIView * view = [arrayViews objectAtIndex:iIdx];
                        
                        if([view isKindOfClass:[UIButton class]])
                        {
                            bViewIsButton = YES;;
                        }
                        
                        CGRect rectView = view.frame;
                        rectView.origin.y = rect.origin.y + newPosYSubviews;
                        view.frame = rectView;
                        
                        if((!(bViewIsButton)) || ((bViewIsButton) && (!([((UIButton *)view) titleForState:UIControlStateNormal] == NSLocalizedString(@"_EDIT_BTN_", nil)))))
                        {
                            newPosYSubviews += rectView.size.height + kCreateViewDeleteButtonsInset;
                        }
                        
                        if((bViewIsButton) && (!([((UIButton *)view) titleForState:UIControlStateNormal] == NSLocalizedString(@"_EDIT_BTN_", nil))))
                        {
                            newPosYSubviews += kDeleteAndEditExtraSpace;
                        }
                    }
                }
                
//                UIView * view = [self getViewFromTag:i];
                
                
                mainView.frame = rect;
                if ([mainView isKindOfClass:[UIImageView class]])
                {
                    ((UIView *)(arrayViews[1])).frame = rect;
                }
                
                // Update Height for next view, if any
                postViewY += (rect.size.height + kPostViewVerticalInset);
                
            }
            
            // Update Post View Content Size
            self.FashionistaPostView.contentSize = CGSizeMake(self.FashionistaPostView.contentSize.width, postViewY+kBottomExtraSpace);
            
            // update the buttons
            [self setupEditPostButtons];
            
        }
    }
    
}


#pragma mark - Fashionista Post EDIT


// Buttons for post edition (add content)
-(void)setupEditPostButtons
{
    if (_bEditingMode)
    {
        if (self.addImageButton != nil)
        {
            [self.addImageButton removeFromSuperview];
            self.addImageButton = nil;
        }
        if (self.addVideoButton != nil)
        {
            [self.addVideoButton removeFromSuperview];
            self.addVideoButton = nil;
        }
        if (self.addTextButton != nil)
        {
            [self.addTextButton removeFromSuperview];
            self.addTextButton = nil;
        }
        
        if(postViewY == (kTopExtraSpace + kPostViewVerticalInset))
        {
            postViewY = (((self.view.frame.size.height-kTopExtraSpace) - ((3*kCreateViewDeleteButtonsHeight)+(2*kCreateViewDeleteButtonsInset)))/2);
        }
        
        // Set 'Add image' button
        
        //Prepare the background image
        UIImageView * backgroundButtonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.FashionistaPostView.frame.size.width - (2*kCreateViewDeleteButtonsInset) - (IS_IPHONE_6P ? 8 : 0), kCreateViewDeleteButtonsHeight)];
        
        [backgroundButtonImageView setContentMode:UIViewContentModeScaleAspectFill];
        
        [backgroundButtonImageView setImage:[UIImage imageNamed:@"AddImageToPostBackground.png"]];

        UIGraphicsBeginImageContextWithOptions(backgroundButtonImageView.bounds.size, NO, 0.0);
        [backgroundButtonImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        self.addImageButton = [UIButton createButtonWithOrigin:CGPointMake(self.FashionistaPostView.frame.origin.x + kCreateViewDeleteButtonsInset, postViewY+kCreateViewDeleteButtonsInset)
                                                             andSize:CGSizeMake(self.FashionistaPostView.frame.size.width - (2*kCreateViewDeleteButtonsInset) - (IS_IPHONE_6P ? 8 : 0), kCreateViewDeleteButtonsHeight)
                                                      andBorderWidth:kCreateViewDeleteButtonBorderWidth
                                                      andBorderColor:[UIColor kCreateViewDeleteButtonBorderColor]
                                                             andText:((_PostAlreadyContainsImages) ? (NSLocalizedString(@"_ADDANOTHERIMAGETOPOST_BTN_", nil)) : (NSLocalizedString(@"_ADDIMAGETOPOST_BTN_", nil)))
                                                             andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
                                                        andFontColor:[UIColor blackColor]
                                                      andUppercasing:NO
                                                        andAlignment:UIControlContentHorizontalAlignmentLeft
                                                            andImage:nil
                                                        andImageMode:UIViewContentModeScaleAspectFit
                                            andBackgroundImage:backgroundImage];//[UIImage imageNamed:@"AddImageToPostBackground.png"]];
        
        [self.addImageButton setBackgroundColor:[UIColor clearColor]];//]whiteColor]];
        [[self.addImageButton layer] setCornerRadius:5];
        [self.addImageButton setClipsToBounds:YES];
        [self.addImageButton setAlpha:0.8];
        
        // Button action
        [self.addImageButton addTarget:self action:@selector(addImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // Insert button into Post View
        [self.FashionistaPostView addSubview:self.addImageButton];
        [self.FashionistaPostView bringSubviewToFront:self.addImageButton];

        
        // Set 'Add video' button
        
        //Prepare the background image
        [backgroundButtonImageView setImage:[UIImage imageNamed:@"AddVideoToPostBackground.png"]];
        
        UIGraphicsBeginImageContextWithOptions(backgroundButtonImageView.bounds.size, NO, 0.0);
        [backgroundButtonImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        self.addVideoButton = [UIButton createButtonWithOrigin:CGPointMake(self.FashionistaPostView.frame.origin.x + kCreateViewDeleteButtonsInset, self.addImageButton.frame.origin.y+self.addImageButton.frame.size.height+kCreateViewDeleteButtonsInset)
                                                             andSize:CGSizeMake(self.FashionistaPostView.frame.size.width - (2*kCreateViewDeleteButtonsInset) - (IS_IPHONE_6P ? 8 : 0), kCreateViewDeleteButtonsHeight)
                                                      andBorderWidth:kCreateViewDeleteButtonBorderWidth
                                                      andBorderColor:[UIColor kCreateViewDeleteButtonBorderColor]
                                                             andText:((_PostAlreadyContainsVideos) ? (NSLocalizedString(@"_ADDANOTHERVIDEOTOPOST_BTN_", nil)) : (NSLocalizedString(@"_ADDVIDEOTOPOST_BTN_", nil)))
                                                             andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
                                                        andFontColor:[UIColor blackColor]
                                                      andUppercasing:NO
                                                        andAlignment:UIControlContentHorizontalAlignmentLeft
                                                            andImage:nil
                                                        andImageMode:UIViewContentModeScaleAspectFit
                                                  andBackgroundImage:backgroundImage];//[UIImage imageNamed:@"AddVideoToPostBackground.png"]];
        
        [self.addVideoButton setBackgroundColor:[UIColor clearColor]];//whiteColor]];
        [[self.addVideoButton layer] setCornerRadius:5];
        [self.addVideoButton setClipsToBounds:YES];
        [self.addVideoButton setAlpha:0.8];
        
        // Button action
        [self.addVideoButton addTarget:self action:@selector(addVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // Insert button into Post View
        [self.FashionistaPostView addSubview:self.addVideoButton];
        [self.FashionistaPostView bringSubviewToFront:self.addVideoButton];
        

        // Set 'Add text' button
        
        //Prepare the background image
        [backgroundButtonImageView setImage:[UIImage imageNamed:@"AddTextToPostBackground.png"]];
        
        UIGraphicsBeginImageContextWithOptions(backgroundButtonImageView.bounds.size, NO, 0.0);
        [backgroundButtonImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        self.addTextButton = [UIButton createButtonWithOrigin:CGPointMake(self.FashionistaPostView.frame.origin.x + kCreateViewDeleteButtonsInset, self.addVideoButton.frame.origin.y+self.addVideoButton.frame.size.height+kCreateViewDeleteButtonsInset)
                                                            andSize:CGSizeMake(self.FashionistaPostView.frame.size.width - (2*kCreateViewDeleteButtonsInset) - (IS_IPHONE_6P ? 8 : 0), kCreateViewDeleteButtonsHeight)
                                                     andBorderWidth:kCreateViewDeleteButtonBorderWidth
                                                     andBorderColor:[UIColor kCreateViewDeleteButtonBorderColor]
                                                            andText:((_PostAlreadyContainsTexts) ? (NSLocalizedString(@"_ADDANOTHERTEXTTOPOST_BTN_", nil)) : (NSLocalizedString(@"_ADDTEXTTOPOST_BTN_", nil)))
                                                            andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
                                                       andFontColor:[UIColor blackColor]
                                                     andUppercasing:NO
                                                       andAlignment:UIControlContentHorizontalAlignmentLeft
                                                           andImage:nil
                                                       andImageMode:UIViewContentModeScaleAspectFit
                                                 andBackgroundImage:backgroundImage];//[UIImage imageNamed:@"AddTextToPostBackground.png"]];
        
        [self.addTextButton setBackgroundColor:[UIColor clearColor]];//whiteColor]];
        [[self.addTextButton layer] setCornerRadius:5];
        [self.addTextButton setClipsToBounds:YES];
        [self.addTextButton setAlpha:0.8];
        
        // Button action
        [self.addTextButton addTarget:self action:@selector(addTextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // Insert button into Post View
        [self.FashionistaPostView addSubview:self.addTextButton];
        [self.FashionistaPostView bringSubviewToFront:self.addTextButton];
        
        
        // Update Post View Content Size
        self.FashionistaPostView.contentSize = CGSizeMake(self.FashionistaPostView.contentSize.width, postViewY+((4*kCreateViewDeleteButtonsInset)+(3*kCreateViewDeleteButtonsHeight))+kBottomExtraSpace);
        
    }
}

// Buttons for content edition (edit, delete content)
-(void)setupEditButtonsForContent:(contentType)contentType withTag:(int)tag withinRect:(CGRect)contentRect fashionistaContent:(NSString *) idFashionistaContent
{
    NSMutableArray * arrayViews = [_viewsDict valueForKey:idFashionistaContent];

    if (_bEditingMode)
    {
        /*        // Set the button to view zoomed image
         UIButton * viewButton = [UIButton createButtonWithOrigin:CGPointMake(contentRect.origin.x+kCreateViewDeleteButtonsInset, contentRect.origin.y + ((contentRect.size.height - ((3*kCreateViewDeleteButtonsHeight) + (2*kCreateViewDeleteButtonsInset)))/2))
         andSize:CGSizeMake(contentRect.size.width - (2*kCreateViewDeleteButtonsInset), kCreateViewDeleteButtonsHeight)
         andBorderWidth:kCreateViewDeleteButtonBorderWidth
         andBorderColor:[UIColor kCreateViewDeleteButtonBorderColor]
         andText:NSLocalizedString(@"_VIEW_BTN_", nil)
         andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
         andFontColor:[UIColor blackColor]
         andUppercasing:NO
         andAlignment:UIControlContentHorizontalAlignmentCenter
         andImage:nil
         andImageMode:UIViewContentModeScaleAspectFit
         andBackgroundImage:nil];
         
         [viewButton setBackgroundColor:[UIColor whiteColor]];
         [viewButton setAlpha:0.7];
         
         // Button action
         [viewButton addTarget:self action:@selector(onTapZoomPostImage:) forControlEvents:UIControlEventTouchUpInside];
         
         // Set button tag for later image identification
         [viewButton setTag: tag];//[[NSNumber numberWithInt:tag] integerValue]];
         
         // Insert the Button into Post View
         [self.FashionistaPostView addSubview:viewButton];
         [self.FashionistaPostView bringSubviewToFront:viewButton];
         */
        
        CGRect firstButtonRect = CGRectMake(0,0,0,0);
        CGRect secondButtonRect = CGRectMake(0,0,0,0);

        firstButtonRect = CGRectMake(contentRect.origin.x + kCreateViewDeleteButtonsInset,
                                     (contentRect.origin.y + (contentRect.size.height - (MIN((contentRect.size.height - (2*kCreateViewDeleteButtonsInset)), kCreateViewDeleteButtonsHeight) + kCreateViewDeleteButtonsInset))),
                                     ((contentRect.size.width - (3*kCreateViewDeleteButtonsInset))/2),
                                     MIN((contentRect.size.height - (2*kCreateViewDeleteButtonsInset)), kCreateViewDeleteButtonsHeight));
        
        secondButtonRect = CGRectMake(contentRect.origin.x + kCreateViewDeleteButtonsInset + (((contentRect.size.width - (3*kCreateViewDeleteButtonsInset))/2) + kCreateViewDeleteButtonsInset),
                                      (contentRect.origin.y + (contentRect.size.height - (MIN((contentRect.size.height - (2*kCreateViewDeleteButtonsInset)), kCreateViewDeleteButtonsHeight) + kCreateViewDeleteButtonsInset))),
                                      ((contentRect.size.width - (3*kCreateViewDeleteButtonsInset))/2),
                                      MIN((contentRect.size.height - (2*kCreateViewDeleteButtonsInset)), kCreateViewDeleteButtonsHeight));

        
//        if(contentType == TEXT_CONTENT)
//        {
//            firstButtonRect = CGRectMake(contentRect.origin.x + ((contentRect.size.width - ((2*kCreateViewDeleteButtonsWidth) + (1*kCreateViewDeleteButtonsInset))) / 2), (contentRect.origin.y + (contentRect.size.height - (kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset))), kCreateViewDeleteButtonsWidth, MIN((contentRect.size.height - (2*kCreateViewDeleteButtonsInset)), kCreateViewDeleteButtonsHeight));
//            
//            secondButtonRect = CGRectMake(contentRect.origin.x + ((contentRect.size.width - ((2*kCreateViewDeleteButtonsWidth) + (1*kCreateViewDeleteButtonsInset))) / 2) + (kCreateViewDeleteButtonsWidth + kCreateViewDeleteButtonsInset), (contentRect.origin.y + (contentRect.size.height - (kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset))), kCreateViewDeleteButtonsWidth, MIN((contentRect.size.height - (2*kCreateViewDeleteButtonsInset)), kCreateViewDeleteButtonsHeight));
//        }
//        else
//        {
//            if(((2*kCreateViewDeleteButtonsHeight) + (1*kCreateViewDeleteButtonsInset)) < contentRect.size.height)
//            {
//                firstButtonRect = CGRectMake(contentRect.origin.x+kCreateViewDeleteButtonsInset, contentRect.origin.y + ((contentRect.size.height - ((2*kCreateViewDeleteButtonsHeight) + (1*kCreateViewDeleteButtonsInset) + ((2*kCreateViewDeleteButtonsInset) + kAddProductsViewHeight + kAddTagsViewHeight)))/2), contentRect.size.width - (2*kCreateViewDeleteButtonsInset), kCreateViewDeleteButtonsHeight);
//                
//                secondButtonRect = CGRectMake(contentRect.origin.x+kCreateViewDeleteButtonsInset,contentRect.origin.y + ((contentRect.size.height - ((2*kCreateViewDeleteButtonsHeight) + (1*kCreateViewDeleteButtonsInset) + ((2*kCreateViewDeleteButtonsInset) + kAddProductsViewHeight + kAddTagsViewHeight)))/2) + (kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset),contentRect.size.width - (2*kCreateViewDeleteButtonsInset),kCreateViewDeleteButtonsHeight);
//            }
//            else
//            {
//                firstButtonRect = CGRectMake(contentRect.origin.x + ((contentRect.size.width - ((2*kCreateViewDeleteButtonsWidth) + (1*kCreateViewDeleteButtonsInset))) / 2), contentRect.origin.y + ((kCreateViewDeleteButtonsHeight < (contentRect.size.height - (2*kCreateViewDeleteButtonsInset))) ? ((contentRect.size.height - (kCreateViewDeleteButtonsHeight)) /2) : (kCreateViewDeleteButtonsInset)), kCreateViewDeleteButtonsWidth, MIN((contentRect.size.height - (2*kCreateViewDeleteButtonsInset)), kCreateViewDeleteButtonsHeight));
//                
//                secondButtonRect = CGRectMake(contentRect.origin.x + ((contentRect.size.width - ((2*kCreateViewDeleteButtonsWidth) + (1*kCreateViewDeleteButtonsInset))) / 2) + (kCreateViewDeleteButtonsWidth + kCreateViewDeleteButtonsInset), contentRect.origin.y + ((kCreateViewDeleteButtonsHeight < (contentRect.size.height - (2*kCreateViewDeleteButtonsInset))) ? ((contentRect.size.height - (kCreateViewDeleteButtonsHeight)) /2) : (kCreateViewDeleteButtonsInset)), kCreateViewDeleteButtonsWidth, MIN((contentRect.size.height - (2*kCreateViewDeleteButtonsInset)), kCreateViewDeleteButtonsHeight));
//            }
//        }
//        
        // Set the button to edit content
        UIButton * editButton = [UIButton createButtonWithOrigin:firstButtonRect.origin
                                                         andSize:firstButtonRect.size
                                                  andBorderWidth:kCreateViewDeleteButtonBorderWidth
                                                  andBorderColor:[UIColor kCreateViewDeleteButtonBorderColor]
                                                         andText:NSLocalizedString(@"_EDIT_BTN_", nil)
                                                         andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
                                                    andFontColor:[UIColor blackColor]
                                                  andUppercasing:NO
                                                    andAlignment:UIControlContentHorizontalAlignmentCenter
                                                        andImage:nil
                                                    andImageMode:UIViewContentModeScaleAspectFit
                                              andBackgroundImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"]];
        
        [editButton setBackgroundColor:[UIColor clearColor]];//whiteColor]];
        [editButton setAlpha:0.9];
        [editButton setClipsToBounds:YES];
        [[editButton layer] setCornerRadius:5.0];
        [[editButton layer] setBorderWidth:1];//kCreateViewDeleteButtonBorderWidth];
        [[editButton layer] setBorderColor:[UIColor blackColor].CGColor];//kCreateViewDeleteButtonBorderColor].CGColor];

        // Button action
        [editButton addTarget:self action:@selector(onTapEditElement:) forControlEvents:UIControlEventTouchUpInside];
        
        // Set button tag for later image identification
        [editButton setTag: [[NSNumber numberWithInt:tag] integerValue]];
        
        // Insert the Button into Post View
        [self.FashionistaPostView addSubview:editButton];
        [self.FashionistaPostView bringSubviewToFront:editButton];
        [arrayViews addObject:editButton];
        
        
        // Set the button to delete content
        UIButton * deleteButton = [UIButton createButtonWithOrigin:secondButtonRect.origin
                                                           andSize:secondButtonRect.size
                                                    andBorderWidth:kCreateViewDeleteButtonBorderWidth
                                                    andBorderColor:[UIColor kCreateViewDeleteButtonBorderColor]
                                                           andText:NSLocalizedString(@"_DELETE_BTN_", nil)
                                                           andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
                                                      andFontColor:[UIColor blackColor]
                                                    andUppercasing:NO
                                                      andAlignment:UIControlContentHorizontalAlignmentCenter
                                                          andImage:nil
                                                      andImageMode:UIViewContentModeScaleAspectFit
                                                andBackgroundImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"]];
        
        [deleteButton setBackgroundColor:[UIColor clearColor]];//whiteColor]];
        [deleteButton setAlpha:0.9];
        [deleteButton setClipsToBounds:YES];
        [[deleteButton layer] setCornerRadius:5.0];
        [[deleteButton layer] setBorderWidth:1];//kCreateViewDeleteButtonBorderWidth];
        [[deleteButton layer] setBorderColor:[UIColor blackColor].CGColor];//kCreateViewDeleteButtonBorderColor].CGColor];

        // Button action
        [deleteButton addTarget:self action:@selector(onTapDelete:) forControlEvents:UIControlEventTouchUpInside];
        
        // Set button tag for later image identification
        [deleteButton setTag: [[NSNumber numberWithInt:tag] integerValue]];
        
        // Insert the Button into Post View
        [self.FashionistaPostView addSubview:deleteButton];
        [self.FashionistaPostView bringSubviewToFront:deleteButton];
        [arrayViews addObject:deleteButton];
    }
}

// Buttons for viewing Content Wardrobe or Tags
-(void)setupButtonsToViewTags:(BOOL)bViewTags andViewWardrobe:(BOOL) bViewWardrobe forTag:(int)tag withinRect:(CGRect)contentRect
{
    if (!(_bEditingMode))
    {
        CGRect firstButtonRect = CGRectMake(0,0,0,0);
        CGRect secondButtonRect = CGRectMake(0,0,0,0);
        
//        firstButtonRect = CGRectMake(contentRect.size.width-(((bViewWardrobe)*(kCreateViewDeleteButtonsInset+kWardrobeButtonWidth))+kCreateViewDeleteButtonsInset+kCreateViewDeleteButtonsWidth), contentRect.origin.y + (contentRect.size.height -(kCreateViewDeleteButtonsInset+kCreateViewDeleteButtonsHeight)), kCreateViewDeleteButtonsWidth, kCreateViewDeleteButtonsHeight);
//
//        secondButtonRect = CGRectMake(contentRect.size.width-(kCreateViewDeleteButtonsInset+kWardrobeButtonWidth), contentRect.origin.y + (contentRect.size.height -(kCreateViewDeleteButtonsInset+kWardrobeButtonHeight)), kWardrobeButtonWidth, kWardrobeButtonHeight);

        firstButtonRect = CGRectMake(contentRect.origin.x + kCreateViewDeleteButtonsInset/2, contentRect.origin.y + kCreateViewDeleteButtonsInset/2, kWardrobeButtonWidth, kWardrobeButtonHeight);

        secondButtonRect = CGRectMake(contentRect.origin.x + kCreateViewDeleteButtonsInset/2 + ((bViewWardrobe) * (kCreateViewDeleteButtonsInset/2 + kWardrobeButtonWidth)) , contentRect.origin.y + kCreateViewDeleteButtonsInset/2, kWardrobeButtonWidth, kWardrobeButtonHeight);

        if(bViewWardrobe)
        {
            // Set the button to delete content
            UIButton * wardrobeButton = [UIButton createButtonWithOrigin:firstButtonRect.origin
                                                                 andSize:firstButtonRect.size
                                                          andBorderWidth:0.0
                                                          andBorderColor:[UIColor clearColor]
                                                                 andText:NSLocalizedString(@"_CONTENTPRODUCTS_BTN_", nil)
                                                                 andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
                                                            andFontColor:[UIColor blackColor]
                                                          andUppercasing:NO
                                                            andAlignment:UIControlContentHorizontalAlignmentCenter
                                                                andImage:[UIImage imageNamed:@"PostProducts.png"]
                                                            andImageMode:UIViewContentModeScaleAspectFit
                                                      andBackgroundImage:nil];
            
//            [wardrobeButton setBackgroundColor:[UIColor whiteColor]];
//            [wardrobeButton setAlpha:0.9];
            
//            [wardrobeButton.layer setShadowColor:[UIColor whiteColor].CGColor];
//            [wardrobeButton.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
//            [wardrobeButton.layer setShadowRadius:1.0];
//            [wardrobeButton.layer setShadowOpacity:1.0];
//            [wardrobeButton.layer setMasksToBounds:NO];
////            [wardrobeButton.layer setShouldRasterize:YES];
            

            
            // Button action
            [wardrobeButton addTarget:self action:@selector(onTapShowContentWardrobe:) forControlEvents:UIControlEventTouchUpInside];
            
            // Set button tag for later image identification
            [wardrobeButton setTag: [[NSNumber numberWithInt:tag] integerValue]];
            
            // Insert the Button into Post View
            [self.FashionistaPostView addSubview:wardrobeButton];
            [self.FashionistaPostView bringSubviewToFront:wardrobeButton];
        }
        
        if(bViewTags)
        {
            // Set the button to view content tags
            UIButton * tagsButton = [UIButton createButtonWithOrigin:secondButtonRect.origin
                                                             andSize:secondButtonRect.size
                                                      andBorderWidth:0.0
                                                      andBorderColor:[UIColor clearColor]
                                                             andText:NSLocalizedString(@"_TAGS_BTN_", nil)
                                                             andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
                                                        andFontColor:[UIColor blackColor]
                                                      andUppercasing:NO
                                                        andAlignment:UIControlContentHorizontalAlignmentCenter
                                                            andImage:[UIImage imageNamed:@"PostTags.png"]
                                                        andImageMode:UIViewContentModeScaleAspectFit
                                                  andBackgroundImage:nil];
            
//            [tagsButton setBackgroundColor:[UIColor whiteColor]];
//            [tagsButton setAlpha:0.9];
            
            // Button action
            [tagsButton addTarget:self action:@selector(onTapShowContentTags:) forControlEvents:UIControlEventTouchUpInside];
            
            // Set button tag for later image identification
            [tagsButton setTag: [[NSNumber numberWithInt:tag] integerValue]];
            
            [tagsButton setHidden:YES];
            
            // Insert the Button into Post View
            [self.FashionistaPostView addSubview:tagsButton];
            [self.FashionistaPostView bringSubviewToFront:tagsButton];
        }
    }
}

-(void)showButtonToViewTagsForTagID:(long)tag
{
     NSArray * arrayViews = self.FashionistaPostView.subviews;
     
     for(int iIdx = 1 ; iIdx < arrayViews.count; iIdx++)
     {
         UIView * view = [arrayViews objectAtIndex:iIdx];
         
         if(([view isKindOfClass:[UIButton class]]))
         {
             if([((UIButton *)view) isHidden])
             {
                 if (((UIButton *)view).tag == tag)
                 {
                     [((UIButton *)view) setHidden:NO];
                 }
             }
         }
     }
}

// Setup 'Edit Text Content'
- (void)setupEditTextContentTextView
{
    // Set the delegate to the 'Edit Text Content' text view
    [self.editTextContentTextView setDelegate:self];
    
    // Setup the 'Edit Text Content' text view superview appearance
    [self.editTextContentSuperView setClipsToBounds:NO];
    [self.editTextContentSuperView.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [self.editTextContentSuperView.layer setShadowRadius:5];
    [self.editTextContentSuperView.layer setShadowOpacity:0.7];
    [self.editTextContentSuperView.layer setCornerRadius:0.5];
}

- (void)setupEditTextContentTextViewButtons
{
    // Setup 'Hide' button at left side
    
    UIButton * hideButton = [UIButton createButtonWithOrigin:CGPointMake(5,5)
                                                     andSize:CGSizeMake(80, 30) // CGSizeMake(30, 30)
                                              andBorderWidth:0.0
                                              andBorderColor:[UIColor clearColor]
                                                     andText:NSLocalizedString(@"_CANCEL_BTN_", nil)
                                                     andFont:[UIFont fontWithName:@"Avenir-Light" size:18]
                                                andFontColor:[UIColor darkGrayColor]
                                              andUppercasing:YES
                                                andAlignment:UIControlContentVerticalAlignmentTop | UIControlContentHorizontalAlignmentLeft
                                                    andImage:nil//[UIImage imageNamed:@"close.png"]
                                                andImageMode:UIViewContentModeScaleAspectFit
                                          andBackgroundImage:nil];
    
    // Button action
    [hideButton addTarget:self action:@selector(cancelEditTextContent) forControlEvents:UIControlEventTouchUpInside];
    
    // Add button to view
    [self.editTextContentSuperView addSubview:hideButton];
    
    
    // Setup 'OK' button at right side
    
    UIButton * okButton = [UIButton createButtonWithOrigin:CGPointMake(self.editTextContentSuperView.frame.size.width-70,5) // CGPointMake(self.editTextContentSuperView.frame.size.width-35,5)
                                                   andSize:CGSizeMake(80, 30) // CGSizeMake(30, 30)
                                            andBorderWidth:0.0
                                            andBorderColor:[UIColor clearColor]
                                                   andText:NSLocalizedString(@"_SAVE_", nil)
                                                   andFont:[UIFont fontWithName:@"Avenir-Light" size:18]
                                              andFontColor:[UIColor darkGrayColor]
                                            andUppercasing:YES
                                              andAlignment:UIControlContentVerticalAlignmentTop | UIControlContentHorizontalAlignmentLeft
                                                  andImage:nil//[UIImage imageNamed:@"ok.png"]
                                              andImageMode:UIViewContentModeScaleAspectFit
                                        andBackgroundImage:nil];
    
    // Button action
    [okButton addTarget:self action:@selector(confirmEditTextContent) forControlEvents:UIControlEventTouchUpInside];
    
    // Add button to view
    [self.editTextContentSuperView addSubview:okButton];
}

// OVERRIDE: Subtitle button action
//- (void)subtitleButtonAction:(UIButton *)sender
//{
//    if([_addTermTextField isHidden])
//    {
//        return;
//    }
//
//    NSString * title = NSLocalizedString(@"_SETPOSTTITLE_", nil);
//    NSString * message = NSLocalizedString(@"_SETPOSTTITLE_MSG_", nil);
//    NSString * placeholder = NSLocalizedString(@"_SETPOSTTITLE_LBL_", nil);
//    NSString * currenttitle = @"";
//    
//    if(_bEditingMode)
//    {
//        if(!(_shownPost == nil))
//        {
//            if(!(_shownPost.name == nil))
//            {
//                if(!([_shownPost.name isEqualToString:@""]))
//                {
//                    title = NSLocalizedString(@"_EDITPOSTTITLE_", nil);
//                    message = NSLocalizedString(@"_EDITPOSTTITLE_MSG_", nil);
//                    placeholder = NSLocalizedString(@"_EDITPOSTTITLE_LBL_", nil);
//                    currenttitle = _shownPost.name;
//                }
//            }
//        }
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_OK_", nil), nil];
//        
//        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//        
//        [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
//        
//        [alertView textFieldAtIndex:0].placeholder = placeholder;
//        
//        [alertView textFieldAtIndex:0].text = currenttitle;
//        
//        [alertView show];
//    }
//}

- (void)addVideoButtonAction:(UIButton *)sender
{
    // Let user opt between take a video or select from camera roll
    _bIsVideo = YES;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"_SELECT_SOURCE_PHOTO_",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"_TAKE_VIDEO_", nil), NSLocalizedString(@"_CHOOSE_VIDEO_", nil), nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)addImageButtonAction:(UIButton *)sender
{
    _bIsVideo = NO;

    // Instantiate the 'CustomCameraViewController' view controller
    
    if ([UIStoryboard storyboardWithName:@"BasicScreens" bundle:nil] != nil)
    {
        self.imagePicker = nil;
        
        @try {
            
            self.imagePicker = [[UIStoryboard storyboardWithName:@"BasicScreens" bundle:nil] instantiateViewControllerWithIdentifier:[@(CUSTOMCAMERA_VC) stringValue]];
            
        }
        @catch (NSException *exception) {
            
            return;
            
        }
        
        if (self.imagePicker != nil)
        {
            self.imagePicker.delegate = self;
            
            [self presentViewController:self.imagePicker animated:YES completion:nil];
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
    }
}

// Perform action to change user profile picture
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(!(self.currentSharedObject == nil))
    {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        return;
    }

    // Prepare Image Picker
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;

    if(_bVideoReviewing)
    {
        _temporalCommentURL = @"";
    }

    if((_bIsVideo) || (_bVideoReviewing))
    {
        imagePicker.allowsEditing = YES;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    }
    
    switch (buttonIndex)
    {
        case 0: //Take photo
            
            // Ensure that device has camera
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"Device has no camera", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
                
                [alertView show];
                
                return;
            }
            else
            {
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            
            break;
            
        case 1: // Select from camera roll
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            break;
            
        default:
            
            return;
    }
    
    
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

-(BOOL)saveImage:(CGImageRef)image savePath:(NSString*)savePath
{
   // @autoreleasepool {
        
        CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:savePath];
        
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
        
        CGImageDestinationAddImage(destination, image, nil);
        
        if (!CGImageDestinationFinalize(destination))
        {
            CFRelease(destination);
            
            CGImageRelease(image);

            NSLog(@"ERROR saving: %@", url);
            
            return NO;
        }
        
        CFRelease(destination);
        
        CGImageRelease(image);
        
        return YES;
   // }
}

// Image selected, now edit it
- (void)imagePickerController:(UIImagePickerController/*CustomCameraViewController*/ *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    
    if(_bVideoReviewing)
    {
        NSURL * URL = info[UIImagePickerControllerMediaURL];
        _temporalCommentURL = [URL absoluteString];
        
        // Save it to camera roll
        UISaveVideoAtPathToSavedPhotosAlbum([[info objectForKey:@"UIImagePickerControllerMediaURL"]relativePath], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        // Save the image to the filesystem
        //NSData *imageData = UIImagePNGRepresentation(croppedImage);
        //NSData *data = [[NSFileManager defaultManager] contentsAtPath:URL];
        _addVideoToCommentButton.titleLabel.text = NSLocalizedString(@"_REMOVE_COMMENT_VIDEO_", nil);
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        _commentTextSpaceConstraint.constant = 125;
        
        self.player = [[AVPlayerViewController alloc] init];
        self.player.player = [AVPlayer playerWithURL:[NSURL URLWithString:_temporalCommentURL]];
        float fFinalConstraint = _commentTextSpaceConstraint.constant + _commentTextView.frame.size.height * 0.7;
        
        float fW = _commentTextView.frame.size.width;
        float fFinalH = _commentTextView.frame.size.height * 0.7 - 1; //130;
        float fX = _commentTextView.frame.origin.x + (IS_IPHONE_6P ? 4 : 0);
        float fY = _commentTextView.frame.origin.y + _commentTextView.frame.size.height;
        float fYFinal = _writeCommentView.frame.origin.y +  _writeCommentView.frame.size.height -fFinalConstraint + 37;
        
        self.player.view.frame = CGRectMake(fX,fY,fW,0);
        UIView * pView = self.player.view;
        [self.view addSubview:pView];
        [self.view bringSubviewToFront:pView];
        
        
        [UIView animateWithDuration:0.30
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             self.player.view.frame = CGRectMake(fX,fYFinal,fW,fFinalH);
                             self.commentTextSpaceConstraint.constant = fFinalConstraint;//240;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             
                             
                         }];
        
        _bVideoReviewing = NO;
    }
    else if(_bIsVideo)
    {
        // Give feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTACONTENT_MSG_", nil)];

        NSURL * URL = info[UIImagePickerControllerMediaURL];
        NSString *sURL = [URL absoluteString];
        
        // Save it to camera roll
        UISaveVideoAtPathToSavedPhotosAlbum([[info objectForKey:@"UIImagePickerControllerMediaURL"]relativePath], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        if(_selectedContentToEdit == nil)
        {
            _selectedContentToEdit = [[FashionistaContent alloc] initWithEntity:[NSEntityDescription entityForName:@"FashionistaContent" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
            
            [_selectedContentToEdit setFashionistaPostId:((!(_shownPost == nil)) ? (_shownPost.idFashionistaPost) : (nil))];
            
            //[_selectedContentToEdit setFashionistaPost:((!(_shownPost == nil)) ? (_shownPost) : (nil))];
            
            // Esto está mal, hay huecos al borrar
            //[_selectedContentToEdit setOrder:((!(_shownPost == nil)) ? ((!(_shownFashionistaPostContent == nil)) ? ([NSNumber numberWithLong:[_shownFashionistaPostContent count]]) : ([NSNumber numberWithInt:0])) : ([NSNumber numberWithInt:0]))];
            NSNumber * iOrder = [NSNumber numberWithInt:0];
            
            if(_shownPost != nil && _shownFashionistaPostContent != nil)
            {
                for(FashionistaContent * content in _shownFashionistaPostContent)
                {
                    if(content.order > iOrder)
                        iOrder = [NSNumber numberWithInt:content.order.intValue];
                }
                
                // Sumamos 1 al orden maximo
                iOrder = [NSNumber numberWithInt:iOrder.intValue+1];
            }
            
            [_selectedContentToEdit setOrder:iOrder];
        }
        
        // Save the image to the filesystem
        //NSData *imageData = UIImagePNGRepresentation(croppedImage);
        //NSData *data = [[NSFileManager defaultManager] contentsAtPath:URL];
        [_selectedContentToEdit setVideo:sURL];
        
        [currentContext processPendingChanges];
        
        [currentContext save:nil];
        
        
        NSLog(@"Uploading fashionista content...");
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_selectedContentToEdit, [NSNumber numberWithBool:((!(_selectedContentToEdit.idFashionistaContent == nil)) && (!([_selectedContentToEdit.idFashionistaContent isEqualToString:@""])))], nil];
        
        [self performRestPost:UPLOAD_FASHIONISTACONTENT withParamaters:requestParameters];
        
        _bEditingChanges = YES;
        _selectedContentToEdit = nil;
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else
    {
        //UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        UIImage *chosenImage = [info objectForKey:@"data"];
        NSNumber* bDirty = [info objectForKey:@"dirty"];
        
        if(!(chosenImage == nil))
        {
            // Give feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTACONTENT_MSG_", nil)];

            // Save it to camera roll
            if ([bDirty boolValue])
                UIImageWriteToSavedPhotosAlbum(chosenImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
            _bFinishedTakingImage = YES;
            _bEditingChanges = YES;
            
            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            if(_selectedContentToEdit == nil)
            {
                _selectedContentToEdit = [[FashionistaContent alloc] initWithEntity:[NSEntityDescription entityForName:@"FashionistaContent" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                
                [_selectedContentToEdit setFashionistaPostId:((!(_shownPost == nil)) ? (_shownPost.idFashionistaPost) : (nil))];
                
                //[_selectedContentToEdit setFashionistaPost:((!(_shownPost == nil)) ? (_shownPost) : (nil))];
                
                // Esto está mal, hay huecos al borrar
                //[_selectedContentToEdit setOrder:((!(_shownPost == nil)) ? ((!(_shownFashionistaPostContent == nil)) ? ([NSNumber numberWithLong:[_shownFashionistaPostContent count]]) : ([NSNumber numberWithInt:0])) : ([NSNumber numberWithInt:0]))];
                NSNumber * iOrder = [NSNumber numberWithInt:0];
                
                if(_shownPost != nil && _shownFashionistaPostContent != nil)
                {
                    for(FashionistaContent * content in _shownFashionistaPostContent)
                    {
                        if(content.order > iOrder)
                            iOrder = [NSNumber numberWithInt:content.order.intValue];
                    }
                    
                    // Sumamos 1 al orden maximo
                    iOrder = [NSNumber numberWithInt:iOrder.intValue+1];
                }
                
                [_selectedContentToEdit setOrder:iOrder];
            }
            
            // Save the image to the filesystem

            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            NSString *documentsPath = [paths objectAtIndex:0];
            
            NSString* savePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"contentImageTemp_%@%@_%@_%d.png", _shownPost.fashionistaPageId, _shownPost.idFashionistaPost, _selectedContentToEdit.order, arc4random()]];
            
            [_selectedContentToEdit setImage_width:[NSNumber numberWithFloat:chosenImage.size.width]];
            [_selectedContentToEdit setImage_height:[NSNumber numberWithFloat:chosenImage.size.height]];

            
            @autoreleasepool {
                NSData *imageData = UIImagePNGRepresentation(chosenImage);
                BOOL result = [imageData writeToFile:savePath atomically:YES];
                imageData = nil;
                if(result)
                    //if([self saveImage:chosenImage.CGImage savePath:savePath])
                {
                    [_selectedContentToEdit setImage:[NSString stringWithFormat:@"file://%@",savePath]] ;
                }
            }
            
            [currentContext processPendingChanges];
            
            [currentContext save:nil];
            
            // Give feedback to user
            //        [self stopActivityFeedback];
            //        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTACONTENT_MSG_", nil)];
            
            NSLog(@"Uploading fashionista content...");
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_selectedContentToEdit, [NSNumber numberWithBool:((!(_selectedContentToEdit.idFashionistaContent == nil)) && (!([_selectedContentToEdit.idFashionistaContent isEqualToString:@""])))], nil];
            
            [self performRestPost:UPLOAD_FASHIONISTACONTENT withParamaters:requestParameters];
            
            _selectedContentToEdit = nil;
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    self.imagePicker = nil;
}

- (void)uploadImageFashionstaContent:(UIImage*)chosenImage
{
    if (_shownFashionistaPostContent != nil && _shownFashionistaPostContent.count > 0)
        return;
    
    if(!(chosenImage == nil))
    {
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"", nil)];
        // Save it to camera roll
//        if ([bDirty boolValue])
//            UIImageWriteToSavedPhotosAlbum(chosenImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        _bFinishedTakingImage = YES;
        _bEditingChanges = YES;
        
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        if(_selectedContentToEdit == nil)
        {
            _selectedContentToEdit = [[FashionistaContent alloc] initWithEntity:[NSEntityDescription entityForName:@"FashionistaContent" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
            
            [_selectedContentToEdit setFashionistaPostId:((!(_shownPost == nil)) ? (_shownPost.idFashionistaPost) : (nil))];
            
            //[_selectedContentToEdit setFashionistaPost:((!(_shownPost == nil)) ? (_shownPost) : (nil))];
            
            // Esto está mal, hay huecos al borrar
            //[_selectedContentToEdit setOrder:((!(_shownPost == nil)) ? ((!(_shownFashionistaPostContent == nil)) ? ([NSNumber numberWithLong:[_shownFashionistaPostContent count]]) : ([NSNumber numberWithInt:0])) : ([NSNumber numberWithInt:0]))];
            NSNumber * iOrder = [NSNumber numberWithInt:0];
            
            if(_shownPost != nil && _shownFashionistaPostContent != nil)
            {
                for(FashionistaContent * content in _shownFashionistaPostContent)
                {
                    if(content.order > iOrder)
                        iOrder = [NSNumber numberWithInt:content.order.intValue];
                }
                
                // Sumamos 1 al orden maximo
                iOrder = [NSNumber numberWithInt:iOrder.intValue+1];
            }
            
            [_selectedContentToEdit setOrder:iOrder];
        }
        
        // Save the image to the filesystem
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsPath = [paths objectAtIndex:0];
        
        NSString* savePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"contentImageTemp_%@%@_%@_%d.png", _shownPost.fashionistaPageId, _shownPost.idFashionistaPost, _selectedContentToEdit.order, arc4random()]];
        
        [_selectedContentToEdit setImage_width:[NSNumber numberWithFloat:chosenImage.size.width]];
        [_selectedContentToEdit setImage_height:[NSNumber numberWithFloat:chosenImage.size.height]];
        
        
        @autoreleasepool {
            NSData *imageData = UIImagePNGRepresentation(chosenImage);
            BOOL result = [imageData writeToFile:savePath atomically:YES];
            imageData = nil;
            if(result)
                //if([self saveImage:chosenImage.CGImage savePath:savePath])
            {
                [_selectedContentToEdit setImage:[NSString stringWithFormat:@"file://%@",savePath]] ;
            }
        }
        
        [currentContext processPendingChanges];
        
        [currentContext save:nil];
        
        // Give feedback to user
        //        [self stopActivityFeedback];
        //        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTACONTENT_MSG_", nil)];
        
        NSLog(@"Uploading fashionista content...");
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_selectedContentToEdit, [NSNumber numberWithBool:((!(_selectedContentToEdit.idFashionistaContent == nil)) && (!([_selectedContentToEdit.idFashionistaContent isEqualToString:@""])))], nil];
        
        [self performRestPost:UPLOAD_FASHIONISTACONTENT withParamaters:requestParameters];
        
        _selectedContentToEdit = nil;
        
    }
}
// Check if saving an image to camera roll succeed
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
//    if (error != NULL)
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Image couldn't be saved", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
//        
//        [alertView show];
//    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

// In case user cancels changing image
- (void) imagePickerControllerDidCancel:(/*UIImagePickerController*/CustomCameraViewController *)picker
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    _bFinishedTakingImage = YES;
    
    _bVideoReviewing = NO;
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(BOOL)prefersStatusBarHidden   // iOS8 definitely needs this one. checked.
{
    return YES;
}

-(UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}

- (void)addTextButtonAction:(UIButton *)sender
{
    [self showEditTextContentTextView];
    
    [_editTextContentTextView becomeFirstResponder];
}

// OVERRIDE: Action to perform if the user press the 'Edit' button on a PostCell
- (void)onTapEditElement:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    NSArray * sortedFashionistaContent = nil;
    
    if(!(_shownPost == nil))
    {
        if(!(_shownFashionistaPostContent == nil))
        {
            if([_shownFashionistaPostContent count] > 0)
            {
                sortedFashionistaContent = [_shownFashionistaPostContent sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
            }
        }
    }
    
    if(!(sortedFashionistaContent == nil))
    {
        if([sortedFashionistaContent count] > 0)
        {
            if(!(sender.tag > ([sortedFashionistaContent count] - 1)))
            {
                FashionistaContent * fashionistaContent = [sortedFashionistaContent objectAtIndex:sender.tag];
                
                if(!(fashionistaContent.image == nil))
                {
                    if(!([fashionistaContent.image isEqualToString:@""]))
                    {
                        // Get image
                        UIImage * image = [UIImage cachedImageWithURL:fashionistaContent.image];
                        
                        if(!(image == nil))
                        {
                            _selectedContentToEdit = fashionistaContent;
                            
                            _bIsVideo = NO;
                            
                            // Instantiate the 'CustomCameraViewController' view controller
                            
                            if ([UIStoryboard storyboardWithName:@"BasicScreens" bundle:nil] != nil)
                            {
                                self.imagePicker = nil;
                                
                                @try {
                                    
                                    self.imagePicker = [[UIStoryboard storyboardWithName:@"BasicScreens" bundle:nil] instantiateViewControllerWithIdentifier:[@(CUSTOMCAMERA_VC) stringValue]];
                                    
                                }
                                @catch (NSException *exception) {
                                    
                                    return;
                                    
                                }
                                
                                if (self.imagePicker != nil)
                                {
                                    self.imagePicker.delegate = self;
                                    
                                    [self.imagePicker setEditingImage:image];
                                    
                                    [self presentViewController:self.imagePicker animated:YES completion:nil];
                                    
                                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                                }
                            }
                        }
                        
                        // call to get the keywords of the postcontent
                    }
                }
                else if (!(fashionistaContent.video == nil))
                {
                    _selectedContentToEdit = fashionistaContent;
                    [self addVideoButtonAction:nil];
                    
                    
                }
                else if (!(fashionistaContent.text == nil))
                {
                    _selectedContentToEdit = fashionistaContent;
                    
                    [self showEditTextContentTextView];
                    
                    [_editTextContentTextView becomeFirstResponder];
                }
            }
        }
    }
}

// Catch the notification when keyboard appears
- (void)keyboardDidChangeFrameWithNotification:(NSNotification *)notification
{
    // Calculate vertical increase
    CGFloat keyboardVerticalIncrease = [self keyboardVerticalIncreaseForNotification:notification];
    
    if(keyboardVerticalIncrease < 0)
    {
        if(!([self.editTextContentSuperView isHidden]))
        {
            [self hideEditTextContentTextView];
        }
        else if(!([_addTermTextField isHidden]))
        {
            [self hideAddSearchTerm];
        }
    }
}

// Calculate the vertical increase when keyboard appears
- (CGFloat)keyboardVerticalIncreaseForNotification:(NSNotification *)notification
{
    CGFloat keyboardBeginY = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardEndY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardVerticalIncrease = keyboardBeginY - keyboardEndY;
    
    return keyboardVerticalIncrease;
}

- (void)confirmEditTextContent
{
    if (!(self.editTextContentTextView.text == nil))
    {
        if (!([self.editTextContentTextView.text isEqualToString:@""]))
        {
            // Give feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTACONTENT_MSG_", nil)];

            _bEditingChanges = YES;
            
            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            if(_selectedContentToEdit == nil)
            {
                _selectedContentToEdit = [[FashionistaContent alloc] initWithEntity:[NSEntityDescription entityForName:@"FashionistaContent" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                
                [_selectedContentToEdit setFashionistaPostId:((!(_shownPost == nil)) ? (_shownPost.idFashionistaPost) : (nil))];
                
                //[_selectedContentToEdit setFashionistaPost:((!(_shownPost == nil)) ? (_shownPost) : (nil))];
                
                // Esto está mal, hay huecos al borrar
                //[_selectedContentToEdit setOrder:((!(_shownPost == nil)) ? ((!(_shownFashionistaPostContent == nil)) ? ([NSNumber numberWithLong:[_shownFashionistaPostContent count]]) : ([NSNumber numberWithInt:0])) : ([NSNumber numberWithInt:0]))];
                NSNumber * iOrder = [NSNumber numberWithInt:0];
                
                if(_shownPost != nil && _shownFashionistaPostContent != nil)
                {
                    for(FashionistaContent * content in _shownFashionistaPostContent)
                    {
                        if(content.order > iOrder)
                            iOrder = [NSNumber numberWithInt:content.order.intValue];
                    }
                    
                    // Sumamos 1 al orden maximo
                    iOrder = [NSNumber numberWithInt:iOrder.intValue+1];
                }
                
                [_selectedContentToEdit setOrder:iOrder];
            }
            
            // Save the image to the filesystem
            [_selectedContentToEdit setText:self.editTextContentTextView.text];
            
            [currentContext processPendingChanges];

            [currentContext save:nil];
            
            NSLog(@"Uploading fashionista content...");
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_selectedContentToEdit, [NSNumber numberWithBool:((!(_selectedContentToEdit.idFashionistaContent == nil)) && (!([_selectedContentToEdit.idFashionistaContent isEqualToString:@""])))], nil];
            
            [self performRestPost:UPLOAD_FASHIONISTACONTENT withParamaters:requestParameters];
            
            _selectedContentToEdit = nil;
        }
    }
    
    [self hideEditTextContentTextView];
}

- (void)cancelEditTextContent
{
    if (!(self.editTextContentTextView.text == nil))
    {
        if (!([self.editTextContentTextView.text isEqualToString:@""]))
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELTEXTEDITION_", nil) message:NSLocalizedString(@"_CANCELTEXTEDITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_BACK_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
            
            [alertView show];
            
            _bConfirmingTextEditDiscard = YES;
            
            return;
        }
    }
    
    [self hideEditTextContentTextView];
}

- (void)showEditTextContentTextView
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }
    
    [self setupEditTextContentTextViewButtons];
    
    CGFloat offset = ((self.view.frame.size.height)*((IS_IPHONE_4_OR_LESS) ? (0.52) : (0.48)));
    
    // Empty Add Terms text field
    [_editTextContentTextView setText:@""];
    
    // If editing an existing Text Content, add its current text
    if(!(_selectedContentToEdit == nil))
    {
        if(!(_selectedContentToEdit.text == nil))
        {
            [_editTextContentTextView setText:_selectedContentToEdit.text];
        }
    }
    
    // Show Add Terms text field and set the focus
    [self.view bringSubviewToFront:_editTextContentSuperView];
    [_editTextContentSuperView setHidden:NO];
    
    CGFloat constant = self.bottomConstraints.constant;
    
    CGFloat newConstant = constant + offset;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.bottomConstraints.constant = newConstant;
                         
                         [_editTextContentSuperView setAlpha:1.0];
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                         // [_editTextContentTextView becomeFirstResponder];
                         
                     }];
}

- (void)hideEditTextContentTextView
{
    if([_editTextContentSuperView isHidden])
    {
        return;
    }
    
    if(_editTextContentSuperView.alpha < 1.0)
    {
        return;
    }
 
    if(_bConfirmingTextEditDiscard)
    {
        return;
    }
    
    for (UIView *view in [_editTextContentSuperView subviews])
    {
        if([view isKindOfClass:[UIButton class]])
        {
            [view removeFromSuperview];
        }
    }
    
    CGFloat offset = -((self.view.frame.size.height)*((IS_IPHONE_4_OR_LESS) ? (0.52) : (0.48)));
    
    [self.view endEditing:YES];
    
    CGFloat constant = self.bottomConstraints.constant;
    
    CGFloat newConstant = constant + offset;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.bottomConstraints.constant = newConstant;
                         
                         [_editTextContentSuperView setAlpha:0.01];
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                         
                         [_editTextContentSuperView setHidden:YES];
                         
                         [_editTextContentTextView resignFirstResponder];
                         
                     }];
}

- (void)onTapDelete:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    if(![[self activityIndicator] isHidden])
        return;
    
    NSArray * sortedFashionistaContent = nil;
    
    if(!(_shownPost == nil))
    {
        if(!(_shownFashionistaPostContent == nil))
        {
            if([_shownFashionistaPostContent count] > 0)
            {
                sortedFashionistaContent = [_shownFashionistaPostContent sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
            }
        }
    }
    
    if(!(sortedFashionistaContent == nil))
    {
        if([sortedFashionistaContent count] > 0)
        {
            if(!(sender.tag > ([sortedFashionistaContent count] - 1)))
            {
                FashionistaContent * fashionistaContent = [sortedFashionistaContent objectAtIndex:sender.tag];
                
                _selectedContentToDelete = fashionistaContent;
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_REMOVECONTENT_", nil) message:NSLocalizedString(@"_REMOVECONTENT_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
                
                [alertView show];
            }
        }
    }
}

// OVERRIDE: Hide Menu view or close any open keyboard if the user touches anywhere on the screen
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([_editTextContentSuperView isHidden])
    {
        [super touchesBegan:touches withEvent:event];
    }
    else
    {
        [self cancelEditTextContent];
    }
}

// UIPicker Delegate Methods

// Number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//// Number of rows of data
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
//{
//    return _postCategories.count;
//}
//
//// Data to return for the row and component (column) that's being passed in
//- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    return [_postCategories objectAtIndex:row];
//}
//
//// Catpure the picker view selection
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//    if(!(_shownPost == nil))
//    {
//        [_shownPost setGroup:[_postCategories objectAtIndex:row]];
//        
//    }
//    
//    _bEditingChanges = YES;
//}
//
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    UILabel* pickerLabel = (UILabel*)view;
//    
//    if (!pickerLabel)
//    {
//        pickerLabel = [[UILabel alloc] init];
//        
//        pickerLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14];
//        
//        pickerLabel.textAlignment=NSTextAlignmentCenter;
//    }
//    
//    [pickerLabel setText:[_postCategories objectAtIndex:row]];
//    
//    return pickerLabel;
//}
//

#pragma mark - Tags management

- (void)btnTagsByFilter:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    if ([UIStoryboard storyboardWithName:@"Search" bundle:nil] != nil)
    {
        
        @try {
            
            _filterTagVC = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateViewControllerWithIdentifier:[@(SEARCHFILTERS_VC) stringValue]];
            
        }
        @catch (NSException *exception) {
            
            return;
            
        }
        
        if (_filterTagVC != nil)
        {
            _selectedContentToAddKeyword = nil;
            _selectedContentToAddKeyword = [self setClickedContentGroup:sender];
            long iGroup = sender.tag % kMultiplierTagForGroup;
            _selectedGroupToAddKeyword = [NSNumber numberWithLong:iGroup];
            [self showFilterForTags];
        }
    }
    
}

-(void) showFilterForTags
{
    [self addChildViewController:_filterTagVC];
    
    if (self.keywordsSelected != nil)
    {
        [self.keywordsSelected removeAllObjects];
    }
    else
    {
        self.keywordsSelected = [[NSMutableArray alloc] init];
    }
    // TODO: add the existing keywords to this array self.keywordsSelected
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _filterTagVC.bAutoSwap = ([[appDelegate.config valueForKey:@"tag_post_auto_swap"] boolValue] == YES);
    
    
    //[_filterSearchVC willMoveToParentViewController:self];
    
    _filterTagVC.view.frame = CGRectMake(0,0,_containerTagsByFilter.frame.size.width, _containerTagsByFilter.frame.size.height);
    
    _containerTagsByFilter.backgroundColor = [UIColor whiteColor];
    
    [_containerTagsByFilter addSubview:_filterTagVC.view];
    
    [_filterTagVC didMoveToParentViewController:self];
    
    //Hide the filter terms ribbon
    [self hideSuggestedFiltersRibbonAnimated:YES];
    [self.noFilterTermsLabel setHidden:YES];
    // Set the property that controls whtether the ribbon should be shown or not
    self.bShouldShowSuggestedFiltersRibbonView = [NSNumber numberWithBool:NO];
    
    [_filterTagVC setSearchTerms:self.keywordsSelected];
    
    
    [_containerTagsByFilter setHidden:NO];
}

// SlideButtonViewDelegate function
- (void)slideButtonView:(SlideButtonView *)slideButtonView btnClick:(int)buttonEntry
{
    if(!_bEditingMode)
        return;
    
    // searching the slideview where the user has clicked
    for (NSString* key in [_kwDict allKeys] ) {
        NSDictionary* groupTagDict = [_kwDict objectForKey:key];
        for (NSString * keyGroup in groupTagDict.allKeys)
        {
            SlideButtonView * slide = [groupTagDict objectForKey:keyGroup];
            if (slide == slideButtonView)
            {
                NSString * idFashionistaPostContent = key;
                // get the keyword
//                NSString * sNameButton = [slideButtonView sGetNameButtonByIdx:buttonEntry];
//                Keyword * keywordToRemove = [self getKeywordFromName:sNameButton];
                Keyword * keywordToRemove = (Keyword *)[slideButtonView getObjectByIndex:buttonEntry];
                if (keywordToRemove != nil)
                {
                    self.currentScrollPosition = self.FashionistaPostView.contentOffset;

                    [self deleteKeyword:keywordToRemove fromPostContent:idFashionistaPostContent];
                    
                    [slideButtonView removeButton:buttonEntry];
                }
                else
                {
                    NSLog(@"Keyword nil in slidebuttonView of tags");
//                    NSLog(@"Keyword not found for name: %@", sNameButton);
                }
                
                return;
            }
        }
    }
    
    
    // search in wardrobeDictionary
    for (NSString *key in [_wardrobeDict allKeys])
    {
        SlideButtonView * slide = [_wardrobeDict objectForKey:key];
        if (slide == slideButtonView)
        {
            NSString * idFashionistaPostContent = key;
            
            _selectedContentToEdit = [self getPostContentById:idFashionistaPostContent];
            
            //          FashionistaContent * fashionistaPostContent = [self getPostContentById:idFashionistaPostContent];
            
            //            NSString * sIdWardrobeToRemoveProduct = fashionistaPostContent.wardrobeId;
            // get the keyword
            _sProductImagePathToRemove = [slideButtonView sGetNameButtonByIdx:buttonEntry];
            
            
            // Get the content products
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:idFashionistaPostContent, nil];
            
            [self performOwnRestGet:GET_POST_CONTENT_WARDROBE withParamaters:requestParameters];
            
            [slideButtonView removeButton:buttonEntry];
            
            return;
        }
    }
}

- (void)closeFilterForTags
{
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    
    [[_containerTagsByFilter subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    [_containerTagsByFilter setHidden:YES];
    
    _filterTagVC = nil;
}

-(void) addSearchTermWithName:(NSString *) name animated:(BOOL) bAnimated
{
    NSLog(@"New filter: %@", name);
    [self.keywordsSelected addObject:name];
}

-(void) removeSearchTermAtIndex:(int) iIndex
{
    [self.keywordsSelected removeObjectAtIndex:iIndex];
    //[self.TermsListView removeButton:iIndex];
}

-(void) hideFilterSearch
{
    [self closeFilterForTags];
}

-(void) cleantTagSlideViewForPostContent: (NSString *)idFashionistaContent
{
    NSMutableDictionary * groupDict = [_kwDict objectForKey:idFashionistaContent];
    
    if (groupDict)
    {
        for(NSString *keyGroup in groupDict.allKeys)
        {
            SlideButtonView * slide = [groupDict objectForKey:keyGroup];
            [slide removeAllButtons];
        }
    }
}


#pragma mark - Group tags management

-(void)createKeywordView:(UIView *) contentView byGroup:(NSNumber *) iGroup withTag:(long)tag andContent:(FashionistaContent*)content andYpos:(NSNumber*) iPosGroup isAddGroupButton:(BOOL) bAddGroup
{
    NSMutableArray * arrayViews = [_viewsDict valueForKey:content.idFashionistaContent];

    // Setup the text label
    // TO CREATE IT OUTSIDE THE CONTENT VIEW:
    //kwsView = [[UIView alloc] initWithFrame:CGRectMake(2, *postViewY-5, contentView.frame.size.width, kAddTagsViewHeight)];
    // TO CREATE IT WITHIN THE CONTENT VIEW:
    
    CGRect kwsViewFrame;
    
    if(_bEditingMode)
    {
        kwsViewFrame.origin.x = contentView.frame.origin.x+kCreateViewDeleteButtonsInset;
        kwsViewFrame.origin.y = contentView.frame.origin.y + ((contentView.frame.size.height - ((2*kCreateViewDeleteButtonsHeight) + (1*(kCreateViewDeleteButtonsInset + kDeleteAndEditExtraSpace)) + ((2*kCreateViewDeleteButtonsInset) + kAddProductsViewHeight + kAddTagsViewHeight)))/2) + (kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset) + (kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset) + (kAddProductsViewHeight + kCreateViewDeleteButtonsInset) + ([iPosGroup intValue] * (kAddTagsViewHeight + kCreateViewDeleteButtonsInset));
        kwsViewFrame.size.width = contentView.frame.size.width - (2*kCreateViewDeleteButtonsInset);
        kwsViewFrame.size.height = kAddTagsViewHeight;
    }
    else
    {
        kwsViewFrame.origin.x = contentView.frame.origin.x+(kCreateViewDeleteButtonsInsetOnNOTEditing);
        kwsViewFrame.origin.y = contentView.frame.origin.y + (kCreateViewDeleteButtonsInset + kWardrobeButtonWidth) + ([iPosGroup intValue] * (kAddProductsViewHeightOnNOTEditing + (kCreateViewDeleteButtonsInsetOnNOTEditing)));//contentView.frame.origin.y + (contentView.frame.size.height - ((kAddProductsViewHeightOnNOTEditing + (kCreateViewDeleteButtonsInsetOnNOTEditing)) + ([iPosGroup intValue] * (kAddProductsViewHeightOnNOTEditing + (kCreateViewDeleteButtonsInsetOnNOTEditing)))) - (((content.video != nil) && (!([content.video isEqualToString:@""]))) ? (kCreateViewDeleteButtonsExtraSpaceOnNOTEditing) : (0)));
        kwsViewFrame.size.width = contentView.frame.size.width - (2*(kCreateViewDeleteButtonsInsetOnNOTEditing));
        kwsViewFrame.size.height = kAddProductsViewHeightOnNOTEditing;
    }
    
    kwsView = [[UIView alloc] initWithFrame:CGRectMake(kwsViewFrame.origin.x,
                                                       kwsViewFrame.origin.y,
                                                       kwsViewFrame.size.width,
                                                       kwsViewFrame.size.height)];
    
    // Label appearance
    [[kwsView layer] setCornerRadius:5.0];
    [[kwsView layer] setBorderWidth:1];//kCreateViewDeleteButtonBorderWidth];
    [[kwsView layer] setBorderColor:[UIColor blackColor].CGColor];//kCreateViewDeleteButtonBorderColor].CGColor];
    [kwsView setBackgroundColor:[UIColor clearColor]];
    [kwsView setAlpha:0.9];
    [kwsView setClipsToBounds:YES];
    [kwsView setTag:tag];
    
    UIImageView * backgroundKwsView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,kwsView.frame.size.width,kwsView.frame.size.height)];
    
    [backgroundKwsView setContentMode:UIViewContentModeScaleAspectFill];
    
    [backgroundKwsView setBackgroundColor:[UIColor clearColor]];
    
    [backgroundKwsView setAlpha:1.0];
    
    [backgroundKwsView setImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"]];
    
    [kwsView addSubview:backgroundKwsView];

    if(_bEditingMode)
    {
        
        // Set the add term (written) button
        UIButton * addTermButton = [UIButton createButtonWithOrigin:CGPointMake(kwsView.frame.size.width - 50, self.searchTermsListView.frame.origin.y+10)
                                                            andSize:CGSizeMake(40, 40)
                                                     andBorderWidth:0.0
                                                     andBorderColor:[UIColor clearColor]
                                                            andText:NSLocalizedString(@"_ADDTERM_BTN_", nil)
                                                            andFont:[UIFont fontWithName:@"Avenir-Light" size:16]
                                                       andFontColor:[UIColor blackColor]
                                                     andUppercasing:NO
                                                       andAlignment:UIControlContentHorizontalAlignmentCenter
                                                           andImage:[UIImage imageNamed:@"Add_Term.png"]
                                                       andImageMode:UIViewContentModeScaleAspectFit
                                                 andBackgroundImage:nil];
        
        
        // Set the add term (smart filters) button
        UIButton * filterButton = [UIButton createButtonWithOrigin:CGPointMake(kwsView.frame.size.width - 100, self.searchTermsListView.frame.origin.y+10)
                                                           andSize:CGSizeMake(40, 40)
                                                    andBorderWidth:0.0
                                                    andBorderColor:[UIColor clearColor]
                                                           andText:NSLocalizedString(@"_ADDTERM_BTN_", nil)
                                                           andFont:[UIFont fontWithName:@"Avenir-Light" size:16]
                                                      andFontColor:[UIColor blackColor]
                                                    andUppercasing:NO
                                                      andAlignment:UIControlContentHorizontalAlignmentCenter
                                                          andImage:[UIImage imageNamed:@"Features.png"]
                                                      andImageMode:UIViewContentModeScaleAspectFit
                                                andBackgroundImage:nil];
        
        //    [filterButton setAlpha:0.35];
        //    [addTermButton setAlpha:0.35];
        
        [filterButton addTarget:self action:@selector(btnTagsByFilter:) forControlEvents:UIControlEventTouchUpInside];
        
        [addTermButton addTarget:self action:@selector(addWrittenTag:) forControlEvents:UIControlEventTouchUpInside];
        
        // Set button tag for later image identification
        long iTagForButton = tag * kMultiplierTagForGroup + [iGroup longValue];
        
        [filterButton setTag: iTagForButton];
        
        [addTermButton setTag: iTagForButton];
        
        
        // Add button to view
        [kwsView addSubview:addTermButton];
        [kwsView addSubview:filterButton];
        
        // Add label with the action to perform
        UILabel * messageLabel = [UILabel createLabelWithOrigin:CGPointMake(10, 0)
                                                        andSize:CGSizeMake(kwsView.frame.size.width - 110, kwsView.frame.size.height)
                                             andBackgroundColor:[UIColor clearColor]
                                                       andAlpha:1.0
                                                        andText:(([iGroup intValue] > 1) ? (NSLocalizedString(@"_ADDMORETAGSHERE_", nil)) : (NSLocalizedString(@"_ADDTAGSHERE_", nil)))
                                                   andTextColor:[UIColor blackColor]
                                                        andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
                                                 andUppercasing:NO
                                                     andAligned:NSTextAlignmentLeft];
        
        [kwsView addSubview:messageLabel];
    }
    else
    {
        // Set the search button
        UIButton * tagsSearchButton = [UIButton createButtonWithOrigin:CGPointMake(kwsView.frame.size.width - (kAddProductsViewHeightOnNOTEditing-5) - 2.5, self.searchTermsListView.frame.origin.y + 2.5)
                                                            andSize:CGSizeMake(kAddProductsViewHeightOnNOTEditing-5, kAddProductsViewHeightOnNOTEditing-5)
                                                     andBorderWidth:0.0
                                                     andBorderColor:[UIColor clearColor]
                                                            andText:NSLocalizedString(@"_ADDTERM_BTN_", nil)
                                                            andFont:[UIFont fontWithName:@"Avenir-Light" size:16]
                                                       andFontColor:[UIColor blackColor]
                                                     andUppercasing:NO
                                                       andAlignment:UIControlContentHorizontalAlignmentCenter
                                                           andImage:[UIImage imageNamed:@"Search_Tags.png"]
                                                       andImageMode:UIViewContentModeScaleAspectFit
                                                 andBackgroundImage:nil];
        
        [tagsSearchButton addTarget:self action:@selector(performTagsSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        // Set button tag for later image identification
        long iTagForButton = tag * kMultiplierTagForGroup + [iGroup longValue];

        [tagsSearchButton setTag: iTagForButton];
        
        
        // Add button to view
        [kwsView addSubview:tagsSearchButton];
    }
    
    CGRect slideBtnViewFrame;
    
    if(_bEditingMode)
    {
        slideBtnViewFrame = CGRectMake(5, 15, kwsView.frame.size.width-110, 30);
    }
    else
    {
        slideBtnViewFrame = CGRectMake(2.5, 5, kwsView.frame.size.width-(kAddProductsViewHeightOnNOTEditing), 25);
    }
    
    // Añadimos al diccionario de grupos
    NSMutableDictionary *groupKeywordDict = [_kwDict valueForKey: content.idFashionistaContent];
    if (groupKeywordDict)
    {
        // comporbamos ene ld iccionario de slideview
        SlideButtonView * termList = [groupKeywordDict valueForKey:[iGroup stringValue]];
        if(!termList)
        {
            // añadimos al diccionario de slide views
            SlideButtonView * pTermsListView = [[SlideButtonView alloc] initWithFrame:slideBtnViewFrame];
            if (bAddGroup)
                pTermsListView.tag = 1;
            else
                pTermsListView.tag = 0;
                
            
            [groupKeywordDict setValue:pTermsListView forKey:[iGroup stringValue]];
            [kwsView addSubview:pTermsListView];
            [self initSearchTermsListView:pTermsListView];
        }
        else{
            [kwsView addSubview:termList];
            [self initSearchTermsListView:termList];
        }
    }
    else{
        groupKeywordDict = [[NSMutableDictionary alloc]init];
        [_kwDict setValue:groupKeywordDict forKey:content.idFashionistaContent];
        
        SlideButtonView * pTermsListView = [[SlideButtonView alloc] initWithFrame:slideBtnViewFrame];
        if (bAddGroup)
            pTermsListView.tag = 1;
        else
            pTermsListView.tag = 0;
        
        [groupKeywordDict setValue:pTermsListView forKey:[iGroup stringValue]];
        [kwsView addSubview:pTermsListView];
        [self initSearchTermsListView:pTermsListView];
    }
    
    if(!_bEditingMode)
    {
        [kwsView setTransform:CGAffineTransformMakeTranslation((-1)*(contentView.frame.size.width), 0)];
        kwsView.hidden = YES;
    }
    else
    {
        kwsView.hidden = NO;
    }
    
    [self.FashionistaPostView addSubview:kwsView];
    [self.FashionistaPostView bringSubviewToFront:kwsView];
    
    if(!(_bEditingMode))
    {
        [self showButtonToViewTagsForTagID:tag];
    }
    
    [arrayViews addObject:kwsView];
}

-(SlideButtonView *) getKeywordViewForContent:(NSString*)idFashionistaContent andGroup:(NSNumber *) group
{
    // Añadimos al diccionario de grupos
    NSMutableDictionary *groupKeywordDict = [_kwDict valueForKey: idFashionistaContent];
    if (groupKeywordDict)
    {
        // comporbamos ene ld iccionario de slideview
        SlideButtonView * termList = [groupKeywordDict valueForKey:[group stringValue]];
        return termList;
    }
    
    return nil;
    
}

-(void) createButtonAddTagGroup:(UIView *) contentView andTag:(long) tag
{
    FashionistaContent *  fashionistaContent = [self getContentByTag:tag];
    
    // get the slideview for adding tag, searching for that whit tag = 1, that means it is the last slide view to add groups
    NSMutableDictionary *groupKeywordDict = [_kwDict valueForKey: fashionistaContent.idFashionistaContent];
    
    for(NSString * key in [groupKeywordDict allKeys])
    {
        SlideButtonView * termList = [groupKeywordDict valueForKey:key];
        // el slide es el ultimo vacio para añdir los tags
        if (termList.tag == 1)
            return;
        
    }

    long iNumGroups = [self getNumGroupsInContent:fashionistaContent.idFashionistaContent];
    
    NSNumber * group = [self getNumMaxGroupsInContent:fashionistaContent.idFashionistaContent];
    
    NSNumber * groupPos = [NSNumber numberWithLong:iNumGroups];
    group = [NSNumber numberWithInt:[group intValue]+1];
    [self createKeywordView:contentView byGroup:group withTag:tag andContent:fashionistaContent andYpos:groupPos isAddGroupButton:YES];
    
    
//    // Set the add term (written) button
//    UIButton * addGroupTagButton = [UIButton createButtonWithOrigin:CGPointMake(contentView.frame.origin.x+kCreateViewDeleteButtonsInset,
//                                                                                contentView.frame.origin.y + ((contentView.frame.size.height - ((2*kCreateViewDeleteButtonsHeight) + (1*kCreateViewDeleteButtonsInset) + ((2*kCreateViewDeleteButtonsInset) + kAddProductsViewHeight + kAddTagsViewHeight)))/2) + (kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset) + (kCreateViewDeleteButtonsHeight + kCreateViewDeleteButtonsInset) + (kAddProductsViewHeight + kCreateViewDeleteButtonsInset))
//                                                        andSize:CGSizeMake(contentView.frame.size.width - (2*kCreateViewDeleteButtonsInset),kAddTagsViewHeight)
//                                                 andBorderWidth:0.0
//                                                 andBorderColor:[UIColor clearColor]
//                                                        andText:NSLocalizedString(@"_ADDGROUPTAGSHERE_", nil)
//                                                        andFont:[UIFont fontWithName:@"Avenir-Light" size:16]
//                                                   andFontColor:[UIColor blackColor]
//                                                 andUppercasing:NO
//                                                   andAlignment:UIControlContentHorizontalAlignmentCenter
//                                                       andImage:nil
//                                                   andImageMode:UIViewContentModeScaleAspectFit
//                                             andBackgroundImage:nil];
//    
//    [addGroupTagButton setTag:tag];
//    
//    [addGroupTagButton addTarget:self action:@selector(addGroupTag:) forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    [self.FashionistaPostView addSubview:addGroupTagButton];
//    [self.FashionistaPostView bringSubviewToFront:addGroupTagButton];
//    
}

-(long) getNumGroupsInContent:(NSString *) idFashionistaContent
{
    long iNumGroups = 0;
    // Añadimos al diccionario de grupos
    NSMutableDictionary *groupKeywordDict = [_kwDict valueForKey: idFashionistaContent];
    if (groupKeywordDict)
    {
        iNumGroups = [[groupKeywordDict allKeys] count];
    }
    
    return iNumGroups;
}

-(NSNumber *) getNumMaxGroupsInContent:(NSString *) idFashionistaContent
{
    NSNumber *iMaxGroups = [NSNumber numberWithInt:0];
    // Añadimos al diccionario de grupos
    NSMutableDictionary *groupKeywordDict = [_kwDict valueForKey: idFashionistaContent];
    if (groupKeywordDict)
    {
        for (NSString * key in groupKeywordDict.allKeys)
        {
            NSNumber * iIdxGroup =  [NSNumber numberWithInt:[key intValue]];
            if (iIdxGroup > iMaxGroups)
            {
                iMaxGroups = iIdxGroup;
            }
        }
    }
    
    return iMaxGroups;
}

- (void)addGroupTag:(UIButton *)sender
{
    FashionistaContent *  fashionistaContent = [self setClickedContentGroup:sender];
    UIView * view = [self getViewFromTag:sender.tag];
    // Get the keywords that were provided
    
    // get the group
    long iNumGroups = [self getNumGroupsInContent:fashionistaContent.idFashionistaContent];
    NSNumber * groupPos = [NSNumber numberWithLong:iNumGroups];
    NSNumber * group = [self getNumMaxGroupsInContent:fashionistaContent.idFashionistaContent];
    [self createKeywordView:view byGroup:group withTag:sender.tag andContent:fashionistaContent andYpos:groupPos isAddGroupButton:YES];
    
    [sender removeFromSuperview];
    
    [self createButtonAddTagGroup:view andTag:sender.tag];
}

#pragma mark - Manage Post Content Wardrobe

// Add Wardrobe action
- (void)addContentWardrobe:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    _selectedContentToAddWardrobe = nil;
    _selectedContentToAddWardrobe = [self setClickedContent:sender];

    [self createWardrobeWithName: NSLocalizedString(@"_DEFAULTWARDROBE_NAME_", nil)];

//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ADDWARDROBE_", nil) message:NSLocalizedString(@"_ADDWARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_ADD_", nil), nil];
//    
//    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    
//    [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
//    
//    [alertView textFieldAtIndex:0].placeholder = NSLocalizedString(@"_ADDWARDROBENAME_LBL_", nil);
//    
//    [alertView show];
}

- (void)addContentWardrobeWithIndex:(NSInteger)index
{
    long iTag = index;
    
    if (iTag >= kMultiplierTagForGroup)
    {
        iTag = index / kMultiplierTagForGroup;
    }
    
    _selectedContentToAddWardrobe = nil;
    _selectedContentToAddWardrobe = [self getContentByTag:iTag];
    
    [self createWardrobeWithName: NSLocalizedString(@"_DEFAULTWARDROBE_NAME_", nil)];
}

//Create new wardrobe
-(void)createWardrobeWithName:(NSString *)wardrobeName
{
    
    wardrobeName = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"_STYLISTPOSTWARDROBE_PREFIX_", nil), wardrobeName];
    
    
    NSLog(@"Adding wardrobe: %@", wardrobeName);
    
    // Check that the name is valid
    
    if (!(wardrobeName == nil))
    {
        // Perform request to get the wardrobe contents
        
        // Provide feedback to user
        if ([self.fashionistaPostDelegate respondsToSelector:@selector(showFeedbackActivity:)]) {
            [self.fashionistaPostDelegate showFeedbackActivity:NSLocalizedString(@"_PREPARINGWARDROBE_MSG_", nil)];
        }

//        [self stopActivityFeedback];
//        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGWARDROBE_MSG_", nil)];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        Wardrobe *newWardrobe = [[Wardrobe alloc] initWithEntity:[NSEntityDescription entityForName:@"Wardrobe" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
        
        [newWardrobe setName:wardrobeName];
        
        [newWardrobe setUserId:appDelegate.currentUser.idUser];
        
        // Encode the wardrobe name string to be used as an URL parameter
        //        wardrobeName = [wardrobeName urlEncodeUsingNSUTF8StringEncoding];
        
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:newWardrobe, nil];
        
        [self performRestPost:ADD_WARDROBE withParamaters:requestParameters];
    }
}

// Add wardrobe to con tent
- (void)addWardrobe:(Wardrobe *)wardrobe ToContentWithID:(NSString *)contentID
{
    if (!(wardrobe == nil))
    {
        NSLog(@"Adding wardrobe to content: %@", contentID);
        
        // Perform request to save the wardrobe into the content
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_ADDINGWARDROBETOCONTENT_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:contentID, wardrobe, nil];
        
        [self performRestPost:ADD_WARDROBE_TO_CONTENT withParamaters:requestParameters];
    }
}

// Delete Wardrobe action
- (void)deleteContentWardrobe:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    FashionistaContent * clickedContent = [self setClickedContent:sender];
    
    _keywordsFetchedResultsController = nil;
    _keywordssFetchRequest = nil;
    _wardrobeSelectedToDelete = nil;
    
    [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"idWardrobe ==[c] %@" withString:[clickedContent.wardrobeId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] sortingWithKey:@"idWardrobe" ascending:YES];
    
    if (!(_keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[_keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Wardrobe * tmpWardrobe = [[_keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpWardrobe == nil))
            {
                if(!(tmpWardrobe.idWardrobe == nil))
                {
                    if(!([tmpWardrobe.idWardrobe isEqualToString:@""]))
                    {
                        _wardrobeSelectedToDelete = tmpWardrobe;
                    }
                }
            }
        }
    }
    
    if(!(_wardrobeSelectedToDelete == nil))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_REMOVEWARDROBE_", nil) message:NSLocalizedString(@"_REMOVEPOSTCONTENTWARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
        
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_REMOVEWARDROBE_", nil) message:NSLocalizedString(@"_CANTREMOVEPOSTCONTENTWARDROBE_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }
}

// Delete Wardrobe with a given ID
- (void)deleteWardrobe:(Wardrobe *)wardrobe
{
    // Check if user is signed in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        NSLog(@"Deleting wardrobe: %@", wardrobe.name);
        
        // Check that the name is valid
        
        if (!(wardrobe == nil))
        {
            if (!(wardrobe.idWardrobe == nil))
            {
                if (!([wardrobe.idWardrobe isEqualToString:@""]))
                {
                    // Perform request to get the wardrobe contents
                    
                    // Provide feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DELETINGWARDROBE_MSG_", nil)];
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobe, nil];
                    
                    _selectedContentToEdit.wardrobeId = nil;

                    [self performRestDelete:DELETE_WARDROBE withParamaters:requestParameters];
                    
                }
            }
        }
    }
}

-(void) getWardrobeToEdit:(NSString *)wardrobeId
{
    _keywordsFetchedResultsController = nil;
    _keywordssFetchRequest = nil;
    _wardrobeSelected = nil;
    
    [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"idWardrobe ==[c] %@" withString:[wardrobeId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] sortingWithKey:@"idWardrobe" ascending:YES];
    
    if (!(_keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[_keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Wardrobe * tmpWardrobe = [[_keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpWardrobe == nil))
            {
                if(!(tmpWardrobe.idWardrobe == nil))
                {
                    if(!([tmpWardrobe.idWardrobe isEqualToString:@""]))
                    {
                        _wardrobeSelected = tmpWardrobe;
                    }
                }
            }
        }
    }
}

// Edit Wardrobe action
- (void)editContentWardrobe:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    FashionistaContent * clickedContent = [self setClickedContent:sender];
    
    _keywordsFetchedResultsController = nil;
    _keywordssFetchRequest = nil;
    _wardrobeSelected = nil;
    
    [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"idWardrobe ==[c] %@" withString:[clickedContent.wardrobeId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] sortingWithKey:@"idWardrobe" ascending:YES];
    
    if (!(_keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[_keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Wardrobe * tmpWardrobe = [[_keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpWardrobe == nil))
            {
                if(!(tmpWardrobe.idWardrobe == nil))
                {
                    if(!([tmpWardrobe.idWardrobe isEqualToString:@""]))
                    {
                        _wardrobeSelected = tmpWardrobe;
                    }
                }
            }
        }
    }
    
    if(!(_wardrobeSelected == nil))
    {
        if(!(_wardrobeSelected.idWardrobe== nil))
        {
            if(!([_wardrobeSelected.idWardrobe isEqualToString:@""]))
            {
                // Initialize the filter terms ribbon
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                appDelegate.addingProductsToWardrobeID = _wardrobeSelected.idWardrobe;
                
                // Instantiate the 'Search' view controller within the container view
                
                if ([UIStoryboard storyboardWithName:@"Search" bundle:nil] != nil)
                {
                    
                    @try {
                        
                        searchBaseVC = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateViewControllerWithIdentifier:[@(SEARCH_VC) stringValue]];
                        
                    }
                    @catch (NSException *exception) {
                        
                        return;
                        
                    }
                    
                    if (searchBaseVC != nil)
                    {
                        [self addChildViewController:searchBaseVC];

                        //[addPostToPageVC willMoveToParentViewController:self];
                        
                        searchBaseVC.view.frame = CGRectMake(0,0,_addToWardrobeVCContainerView.frame.size.width, _addToWardrobeVCContainerView.frame.size.height);
                        
                        [searchBaseVC.view setClipsToBounds:YES];
                        
                        [_addToWardrobeVCContainerView addSubview:searchBaseVC.view];
                        
                        [searchBaseVC didMoveToParentViewController:self];
                        
                        [_addToWardrobeVCContainerView setHidden:NO];
                        
                        [_addToWardrobeBackgroundView setHidden:NO];
                        
                        [self.view bringSubviewToFront:_addToWardrobeBackgroundView];
                        
                        [self.view bringSubviewToFront:_addToWardrobeVCContainerView];
                    }
                }
                
////////////////////////                [self transitionToViewController:SEARCH_VC withParameters:nil];
                
                return;
            }
        }
        
        _wardrobeSelected = nil;
        
        return;
        
        //        // Perform request to get its properties from GS server
        //        [self getContentsForWardrobe:_wardrobeSelected];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_EDITWARDROBE_", nil) message:NSLocalizedString(@"_CANTEDITPOSTCONTENTWARDROBE_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }
}

- (void)ContentWardrobe:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }
    
    long iTag = sender.tag;
    
    if (iTag >= kMultiplierTagForGroup)
    {
        iTag = sender.tag / kMultiplierTagForGroup;
    }
    
    FashionistaContent * clickedContent = [self getContentByTag:iTag];
    
    _keywordsFetchedResultsController = nil;
    _keywordssFetchRequest = nil;
    _wardrobeSelected = nil;
    
    [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"idWardrobe ==[c] %@" withString:[clickedContent.wardrobeId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] sortingWithKey:@"idWardrobe" ascending:YES];
    
    if (!(_keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[_keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Wardrobe * tmpWardrobe = [[_keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpWardrobe == nil))
            {
                if(!(tmpWardrobe.idWardrobe == nil))
                {
                    if(!([tmpWardrobe.idWardrobe isEqualToString:@""]))
                    {
                        _wardrobeSelected = tmpWardrobe;
                    }
                }
            }
        }
    }
    
    if(!(_wardrobeSelected == nil))
    {
        if(!(_wardrobeSelected.idWardrobe== nil))
        {
            if(!([_wardrobeSelected.idWardrobe isEqualToString:@""]))
            {
                // Initialize the filter terms ribbon
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                appDelegate.addingProductsToWardrobeID = _wardrobeSelected.idWardrobe;
                
                // Instantiate the 'Search' view controller within the container view
                
                if ([UIStoryboard storyboardWithName:@"Search" bundle:nil] != nil)
                {
                    
                    @try {
                        
                        searchBaseVC = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateViewControllerWithIdentifier:[@(SEARCH_VC) stringValue]];
                        
                    }
                    @catch (NSException *exception) {
                        
                        return;
                        
                    }
                    
                    if (searchBaseVC != nil)
                    {
                        [self addChildViewController:searchBaseVC];
                        
                        //[addPostToPageVC willMoveToParentViewController:self];
                        
                        searchBaseVC.view.frame = CGRectMake(0,0,_addToWardrobeVCContainerView.frame.size.width, _addToWardrobeVCContainerView.frame.size.height);
                        
                        [searchBaseVC.view setClipsToBounds:YES];
                        
                        [_addToWardrobeVCContainerView addSubview:searchBaseVC.view];
                        
                        [searchBaseVC didMoveToParentViewController:self];
                        
                        [_addToWardrobeVCContainerView setHidden:NO];
                        
                        [_addToWardrobeBackgroundView setHidden:NO];
                        
                        [self.view bringSubviewToFront:_addToWardrobeBackgroundView];
                        
                        [self.view bringSubviewToFront:_addToWardrobeVCContainerView];
                    }
                }
                
                ////////////////////////                [self transitionToViewController:SEARCH_VC withParameters:nil];
                
                return;
            }
        }
        
        _wardrobeSelected = nil;
        
        return;
        
        //        // Perform request to get its properties from GS server
        //        [self getContentsForWardrobe:_wardrobeSelected];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_EDITWARDROBE_", nil) message:NSLocalizedString(@"_CANTEDITPOSTCONTENTWARDROBE_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }
}

- (void)closeAddingProductsToContentWithSuccess:(BOOL)bSuccess
{
    if((!(_selectedContentToAddWardrobe == nil)) || (!(_wardrobeSelected == nil)))
    {
        BOOL bShouldDelete = NO;

        if(!(_wardrobeSelected.idWardrobe == nil))
        {
            if(!([_wardrobeSelected.idWardrobe isEqualToString:@""]))
            {
                if((_wardrobeSelected.itemsId == nil) || ([((NSMutableArray *)(_wardrobeSelected.itemsId)) count] == 0))
                {
                    /*        
                     NSLog(@"QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ\nOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
                    _keywordsFetchedResultsController = nil;
                    _keywordssFetchRequest = nil;
                    
                    
                    [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"idWardrobe matches %@" withString:_wardrobeSelected.idWardrobe sortingWithKey:@"idWardrobe" ascending:YES];
                    
                    
                    if (!(_keywordsFetchedResultsController == nil))
                    {
                        for (int i = 0; i < [[_keywordsFetchedResultsController fetchedObjects] count]; i++)
                        {
                            Wardrobe * tmpKeyword = [[_keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
                            
                            if(!(tmpKeyword == nil))
                            {
                                if(!(tmpKeyword.idWardrobe == nil))
                                {
                                    NSLog(@"____________");
                                }
                            }
                        }
                    }*/
                    
                    
                    _wardrobeSelectedToDelete = _wardrobeSelected;
                    [self deleteWardrobe:_wardrobeSelectedToDelete];
                    bShouldDelete = YES;
                }
            }
        }
        
        if(!(bShouldDelete))
        {
            if(!(_shownPost.idFashionistaPost == nil))
            {
                if(!([_shownPost.idFashionistaPost isEqualToString:@""]))
                {
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownPost.idFashionistaPost, nil];
                    [self performRestGet:GET_POST_CONTENT withParamaters:requestParameters];
                }
            }
        }
        
        _wardrobeSelected = nil;
        _selectedContentToAddWardrobe = nil;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.addingProductsToWardrobeID = nil;

    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    
    [[_addToWardrobeVCContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    //[[self.childViewControllers lastObject] didMoveToParentViewController:nil];
    
    [_addToWardrobeVCContainerView setHidden:YES];
    
    [_addToWardrobeBackgroundView setHidden:YES];
}

// Perform search to retrieve wardrobe content
- (void)getContentsForWardrobe:(NSString *)wardrobeId
{
    NSLog(@"Getting contents for wardrobe: %@", wardrobeId);
    
    // Check that the string to search is valid
    
    if (!(wardrobeId == nil))
    {
        if(![wardrobeId isEqualToString:@""])
        {
            // Perform request to get the wardrobe contents
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobeId, nil];
            
            [self performRestGet:GET_WARDROBE withParamaters:requestParameters];
        }
    }
}


#pragma mark - Add Written Term


// Setup 'Add Term' button
- (void)setupAddTermButton
{
    // Set the delegate to the Add Term text field
    [self.addTermTextField setDelegate:self];
    
    // Setup the Add Term text field appearance
    [self.addTermTextField setValue:[UIFont fontWithName: @"Avenir-Medium" size: 18] forKeyPath:@"_placeholderLabel.font"];
    [self.addTermTextField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.addTermTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [[self.addTermTextField layer] setCornerRadius:5.0];
    [[self.addTermTextField layer] setBorderWidth:0.5];
    [[self.addTermTextField layer] setBorderColor:[UIColor blackColor].CGColor];
    
//    [self.addTermTextField setClipsToBounds:NO];
//    [self.addTermTextField.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
//    [self.addTermTextField.layer setShadowRadius:5];
//    [self.addTermTextField.layer setShadowOpacity:0.7];
    
    // Setup 'Search' button at right side
    
    UIButton * searchButton = [UIButton createButtonWithOrigin:CGPointMake(1,0)
                                                       andSize:CGSizeMake(self.addTermTextField.frame.size.height-1, self.addTermTextField.frame.size.height)
                                                andBorderWidth:0.0
                                                andBorderColor:[UIColor clearColor]
                                                       andText:NSLocalizedString(@"_SEARCH_BTN_", nil)
                                                       andFont:[UIFont fontWithName:@"Avenir-Light" size:10]
                                                  andFontColor:[UIColor blackColor]
                                                andUppercasing:YES
                                                  andAlignment:UIControlContentHorizontalAlignmentCenter
                                                      andImage:[UIImage imageNamed:@"SearchButton.png"]
                                                  andImageMode:UIViewContentModeScaleAspectFit
                                            andBackgroundImage:nil];
    
    // Button action
    [searchButton addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Setup 'Hide' button at right side
    
    UIButton * hideButton = [UIButton createButtonWithOrigin:CGPointMake(0,0)
                                                     andSize:CGSizeMake(self.addTermTextField.frame.size.height, self.addTermTextField.frame.size.height)
                                              andBorderWidth:0.0
                                              andBorderColor:[UIColor clearColor]
                                                     andText:NSLocalizedString(@"_HIDE_BTN_", nil)
                                                     andFont:[UIFont fontWithName:@"Avenir-Light" size:9]
                                                andFontColor:[UIColor lightGrayColor]
                                              andUppercasing:YES
                                                andAlignment:UIControlContentHorizontalAlignmentCenter
                                                    andImage:[UIImage imageNamed:@"close.png"]
                                                andImageMode:UIViewContentModeScaleAspectFit
                                          andBackgroundImage:nil];
    
    // Button action
    [hideButton addTarget:self action:@selector(hideAddSearchTerm) forControlEvents:UIControlEventTouchUpInside];
    
    // Add button to view
    
    [self.addTermTextField setRightViewMode:UITextFieldViewModeAlways];
    
    self.addTermTextField.rightView = searchButton;
    
    //    self.addTermTextField.rightView = hideButton;
    
    // Setup the Suggestion bar for this textField
    [self setupKeyboardSuggestionBarForTextField:self.addTermTextField];
}

// Find the content from the clicked button
- (FashionistaContent *)setClickedContent:(UIButton *)sender
{
    long iTag = sender.tag;
    
    if (iTag >= kMultiplierTagForGroup)
    {
        iTag = sender.tag / kMultiplierTagForGroup;
    }
    
    return [self getContentByTag:iTag];
}

- (FashionistaContent *)setClickedContentGroup:(UIButton *)sender
{
    long iTag = sender.tag;
    
    iTag = sender.tag / kMultiplierTagForGroup;
    
    return [self getContentByTag:iTag];
}

// Find the content from the clicked button
- (FashionistaContent *)getContentByTag:(long) tag
{
    NSArray * sortedFashionistaContent = nil;
    
    if(!(_shownPost == nil))
    {
        if(!(_shownFashionistaPostContent == nil))
        {
            if([_shownFashionistaPostContent count] > 0)
            {
                sortedFashionistaContent = [_shownFashionistaPostContent sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
            }
        }
    }
    
    if(!(sortedFashionistaContent == nil))
    {
        if([sortedFashionistaContent count] > 0)
        {
#ifdef _OLD_POST_
            if(!(tag > ([sortedFashionistaContent count] - 1)))
            {
                return [sortedFashionistaContent objectAtIndex:tag];
            }
#else
                return [sortedFashionistaContent objectAtIndex:0];
#endif
        }
    }
    
    return nil;
}

// Find the content from the clicked button
- (FashionistaContent *)getPostContentById:(NSString *)sIdPostContent
{
    NSArray * sortedFashionistaContent = nil;
    
    if(!(_shownPost == nil))
    {
        if(!(_shownFashionistaPostContent == nil))
        {
            if([_shownFashionistaPostContent count] > 0)
            {
                sortedFashionistaContent = [_shownFashionistaPostContent sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
            }
        }
    }
    
    if(!(sortedFashionistaContent == nil))
    {
        if([sortedFashionistaContent count] > 0)
        {
            for (FashionistaContent *fc in sortedFashionistaContent)
            {
                if ([fc.idFashionistaContent isEqualToString:sIdPostContent])
                {
                    return fc;
                }
            }
        }
    }
    
    return nil;
}


// Add Term action
- (void)addWrittenTag:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    if(!([_containerTagsByFilter isHidden]))
    {
        return;
    }
    
    
    _selectedContentToAddKeyword = nil;
    _selectedContentToAddKeyword = [self setClickedContentGroup:sender];
    
    long iGroup = sender.tag % kMultiplierTagForGroup;
    _selectedGroupToAddKeyword = [NSNumber numberWithLong:iGroup];
    
    if(_selectedContentToAddKeyword != nil)
    {
        [self showMainMenu:nil];
        [self showAddSearchTerm];
        [_addTermTextField becomeFirstResponder];
    }
    
    
}

// OVERRIDEN: Assign the suggested text to the textfield
-(void) updateTextFieldWithText: (NSString *)text inRange:(NSRange)range
{
    if([self.addTermTextField.text isEqualToString:@""])
    {
        range.length = 0;
        range.location = 0;
    }
    
    self.addTermTextField.text = [self.addTermTextField.text stringByReplacingCharactersInRange:range withString:text];
    
    [self textFieldShouldReturn:self.addTermTextField];
}

- (BOOL)addKeywordFromName:(NSString*)name
{
    self.currentScrollPosition = self.FashionistaPostView.contentOffset;
    
    Keyword * pKw = [self getKeywordFromName:name];
    
    if (pKw)
    {
        [self addKeyword:pKw toPostContent:self.selectedContentToAddKeyword withGroup:self.selectedGroupToAddKeyword];
        
        /*
         SlideButtonView * keywordsList = [_kwDict valueForKey:_selectedContentToAddKeyword.idFashionistaContent];
         
         for (UIView *view in [(keywordsList.superview) subviews])
         {
         if([view isKindOfClass:[UILabel class]])
         {
         [view removeFromSuperview];
         }
         }
         
         SlideButtonView * termList = [_kwDict valueForKey:_selectedContentToAddKeyword.idFashionistaContent];
         [termList addButton:name];
         [self hideAddSearchTerm];
         */
        
        return YES;
    }
    else
    {
        // el name no se ha encontrado como keyword, enviamos el string al server para que lo procese, y quedará añadido el nuevo keyword a la base de datos.
        // si el string son varias palabaras lo transformará a keywords que exista, y lo que no encuentra lo deja como un nuevo keyword
        [self getKeywordsFromName:[name urlEncodeUsingNSUTF8StringEncoding]];
    }
    
    return NO;
}

/******* 
 Osama Petran
 add KeywordFashionistaContent to FashionistaContent or update 
 *******/
- (BOOL)addKeywordFromNameWithIndex:(NSString*)name Index:(NSInteger)tag XPos:(CGFloat)xPos YPos: (CGFloat)yPos
{
    if (self.selectedContentToAddKeyword == nil) {
        self.selectedContentToAddKeyword = [self getContentByTag:0];
    }
    
    for (KeywordFashionistaContent *content in _PostedUserTagArry) {
        Keyword *keyword = content.keyword;
        if ([name isEqualToString:keyword.name]) { //update KeywordFashionistaContent
            CGFloat x = content.xPos.floatValue;
            CGFloat y = content.yPos.floatValue;
            
            if (fabs(x - xPos) < 0.01 && fabs(y - yPos) < 0.01) { //not change
                return NO;
            } else {  // update Position of KeywordFahsioistaContent object
                NSArray * requestParameters = [[NSArray alloc] initWithObjects: content, nil];
                content.xPos = [NSNumber numberWithFloat:xPos];
                content.yPos = [NSNumber numberWithFloat:yPos];
                if ([self.fashionistaPostDelegate respondsToSelector:@selector(showFeedbackActivity:)]) {
                    [self.fashionistaPostDelegate showFeedbackActivity:NSLocalizedString(@"_PREPARINGFASHIONISTAPOST_MSG_", nil)];
                }
                
//                [self stopActivityFeedback];
//                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTAPOST_MSG_", nil)];
                 [self.postActionArray addObject:@"UPDATE_KEYWORD_TO_CONTENT"];
                [self performRestPost:UPDATE_KEYWORD_TO_CONTENT withParamaters:requestParameters];
                return NO;
            }
        }
    }
    
    long iGroup = tag % kMultiplierTagForGroup;
    NSNumber *selectedGroup = [NSNumber numberWithLong:iGroup];

    PeopleTagClass *peopleTag = [[PeopleTagClass alloc] init];
    peopleTag.userTagName = name;
    peopleTag.xPos  = xPos;
    peopleTag.yPos = yPos;
    peopleTag.selectedGroupToAddKeyword = selectedGroup;
    [_tempPostingUserTagArry addObject:peopleTag];
    
    
    if ([self.fashionistaPostDelegate respondsToSelector:@selector(showFeedbackActivity:)]) {
        [self.fashionistaPostDelegate showFeedbackActivity:NSLocalizedString(@"_PREPARINGFASHIONISTAPOST_MSG_", nil)];
    }
//    [self stopActivityFeedback];
//    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTAPOST_MSG_", nil)];
    [self getKeywordsFromName:[name urlEncodeUsingNSUTF8StringEncoding]];
    
    [self.postActionArray addObject:@"ADD_KEYWORD_TO_CONTENT"];
    
    return NO;
}


-(Keyword *) getKeywordFromName:(NSString *)name
{
    _keywordsFetchedResultsController = nil;
    _keywordssFetchRequest = nil;
    
    NSString *regexString  = [NSString stringWithFormat:@"%@", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    [self initFetchedResultsControllerWithEntity:@"Keyword" andPredicate:@"name matches[cd] %@" withString:regexString sortingWithKey:@"idKeyword" ascending:YES];
    
    
    if (!(_keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[_keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Keyword * tmpKeyword = [[_keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            NSLog(@"keyword name   %@", tmpKeyword.name);
            if(!(tmpKeyword == nil))
            {
                if(!(tmpKeyword.idKeyword == nil))
                {
                    if(!([tmpKeyword.idKeyword isEqualToString:@""]))
                    {
                        return tmpKeyword;
                    }
                }
            }
        }
    }
    return nil;
}

-(void) getKeywordsFromName:(NSString *) name
{
    // Get the content products
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:name, nil];
    
    [self performOwnRestGet:GET_KEYWORDS_FROM_STRING withParamaters:requestParameters];
    
}

-(KeywordFashionistaContent *) getKeywordFashionistaContentFromKeywordId:(NSString *)keywordId andFashionistaContentId:(NSString *)fashionistaContentId
{
    _keywordsFetchedResultsController = nil;
    _keywordssFetchRequest = nil;
    
    NSString *predicate  = [NSString stringWithFormat:@"(keywordId == \"%@\") AND (fashionistaContentId == \"%@\")", keywordId, fashionistaContentId];
    
    [self initFetchedResultsControllerWithEntity:@"KeywordFashionistaContent" andPredicate:predicate withString:@"-" sortingWithKey:@"idKeywordFashionistaContent" ascending:YES];
    
    
    if (!(_keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[_keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            KeywordFashionistaContent * tmpKeyword = [[_keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpKeyword == nil))
            {
                if(!(tmpKeyword.idKeywordFashionistaContent == nil))
                {
                    if(!([tmpKeyword.idKeywordFashionistaContent isEqualToString:@""]))
                    {
                        return tmpKeyword;
                    }
                }
            }
        }
    }
    return nil;
}

// Perform search when user press 'Search'
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //_keywordsFetchedResultsController = nil;
    //_keywordssFetchRequest = nil;
    
    if (!(self.addTermTextField.text == nil))
    {
        if (!([self.addTermTextField.text isEqualToString:@""]))
        {
            if([self addKeywordFromName:self.addTermTextField.text])
            {
//                [self setupPostViews];
                
//                [self hideAddSearchTerm];
//                
//                return YES;
            }
            
        }
    }
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_NOTVALIDTAG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
//    
//    [alertView show];
    
    [self hideAddSearchTerm];
    
    return YES;
}

- (void)showAddSearchTerm
{
    if(!([_addTermTextField isHidden]))
    {
        return;
    }
    
    CGFloat offset = ((self.view.frame.size.height)*((IS_IPHONE_4_OR_LESS) ? (0.52) : (0.48)));
    
    // Empty Add Terms text field
    [_addTermTextField setText:@""];
    
    // Show Add Terms text field and set the focus
    [self.view bringSubviewToFront:_addTermTextField];
    [_addTermTextField setHidden:NO];
    
    CGFloat constant = self.addTermTextFieldBottomConstraints.constant;
    
    CGFloat newConstant = constant + offset;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.addTermTextFieldBottomConstraints.constant = newConstant;
                         
                         [_addTermTextField setAlpha:1.0];
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                         // [_addTermTextField becomeFirstResponder];
                         
                     }];
}

- (void)hideAddSearchTerm
{
    if([_addTermTextField isHidden])
    {
        return;
    }
    
    if(_addTermTextField.alpha < 1.0)
    {
        return;
    }
    
    CGFloat offset = -((self.view.frame.size.height)*((IS_IPHONE_4_OR_LESS) ? (0.52) : (0.48)));
    
    [self.view endEditing:YES];
    
    CGFloat constant = self.addTermTextFieldBottomConstraints.constant;
    
    CGFloat newConstant = constant + offset;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.addTermTextFieldBottomConstraints.constant = newConstant;
                         
                         [_addTermTextField setAlpha:0.01];
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                         
                         [_addTermTextField setHidden:YES];
                         
                         [_addTermTextField resignFirstResponder];
                         
                     }];
}


#pragma mark - Requests


//Upload edited Fashionista Post
//-(void)uploadFashionistaPost:(FashionistaPost *)editedPost withContents:(NSMutableArray *)fashionistaPostContents
//{
//    if(!(editedPost == nil))
//    {
//        if((!(editedPost.userId == nil)) && (!([editedPost.userId isEqualToString:@""])))
//        {
//            if((!(editedPost.fashionistaPageId == nil)) && (!([editedPost.fashionistaPageId isEqualToString:@""])))
//            {
//                if((!(editedPost.name == nil)) && (!([editedPost.name isEqualToString:@""])))
//                {
//                    if((!(fashionistaPostContents == nil)) && ([fashionistaPostContents count] > 0))
//                    {
//                        NSLog(@"Uploading fashionista post: %@", editedPost.name);
//                        
//                        // Provide feedback to user
//                        [self stopActivityFeedback];
//                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTAPOST_MSG_", nil)];
//                        
//                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:editedPost, [NSNumber numberWithBool:([editedPost.idFashionistaPost isEqualToString:_shownPost.idFashionistaPost])], nil];
//                        
//                        [self performRestPost:UPLOAD_FASHIONISTAPOST withParamaters:requestParameters];
//                    }
//                    else
//                    {
//                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_SHOULDSETSOMECONTENT_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
//                        
//                        [alertView show];
//                        
//                        return;
//                    }
//                }
//                else
//                {
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_SHOULDSETPOSTTITLE_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
//                    
//                    [alertView show];
//                    
//                    return;
//                }
//            }
//        }
//    }
//}

// Delete Post
- (void)deleteContent:(FashionistaContent *)content
{
    // Check if user is signed in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        NSLog(@"Deleting content: %@", content.idFashionistaContent);
        
        // Check that the id is valid
        
        if (!(content == nil))
        {
            if (!(content.idFashionistaContent == nil))
            {
                if (!([content.idFashionistaContent isEqualToString:@""]))
                {
                    // Perform request to delete
                    
                    // Provide feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DELETINGCONTENT_MSG_", nil)];
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:content, nil];
                    
                    [self performRestDelete:DELETE_POST_CONTENT withParamaters:requestParameters];
                    
                    return;
                }
            }
            
            if(!(_shownPost == nil))
            {
                if(!(_shownFashionistaPostContent == nil))
                {
                    if (!(_shownFashionistaPostContent == nil))
                    {
                        if([_shownFashionistaPostContent count] > 0)
                        {
                            if([_shownFashionistaPostContent containsObject:content])
                            {
                                [_shownFashionistaPostContent removeObject:content];
                            }
                        }
                    }
                }
            }
            
            //            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            //
            //            [currentContext deleteObject:content];
            //
            //            if (![currentContext save:nil])
            //            {
            //                NSLog(@"Save did not complete successfully.");
            //            }
            
            _selectedContentToDelete = nil;
            
            [self setupPostViews: YES];
        }
    }
}
/*****
 Osama Petran
 remove keyword from FashionistaContent
 *****/
- (void)removeKyewordFromContent:(NSString *)title
{
    if (self.selectedContentToAddKeyword == nil) {
        self.selectedContentToAddKeyword = [self getContentByTag:0];
    }
    for (KeywordFashionistaContent *content in _PostedUserTagArry) {
        Keyword *keyword = content.keyword;
        if ([keyword.name isEqualToString:title]) {
            [self deleteKeyword:keyword KeywordContent:content];
            break;
        }
    }
}
- (void)deleteKeyword:(Keyword *)keyword KeywordContent:(KeywordFashionistaContent *)keywordFashionistaContent
{
    if(!(keyword == nil))
    {
        if(!(keyword.idKeyword == nil))
        {
            if(!([keyword.idKeyword isEqualToString:@""]))
            {
                if (keywordFashionistaContent != nil)
                {
                    // Provide feedback to user
                    if ([self.fashionistaPostDelegate respondsToSelector:@selector(showFeedbackActivity:)]) {
                        [self.fashionistaPostDelegate showFeedbackActivity:NSLocalizedString(@"_UPLOADING_TERM_MSG_", nil)];
                    }
//                    [self stopActivityFeedback];
//                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADING_TERM_MSG_", nil)];
                    
                    //                            NSArray * requestParameters = [[NSArray alloc] initWithObjects: idPostContent, keyword, nil];
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects: keywordFashionistaContent, nil];
                    
                    [self performRestDelete:REMOVE_KEYWORD_FROM_CONTENT withParamaters:requestParameters];
                    [_PostedUserTagArry removeObject:keywordFashionistaContent];
                    return;
                }
            }
        }
    }
}
//end

- (void)deleteKeyword:(Keyword *)keyword fromPostContent:(NSString *)idPostContent
{
    if(!(keyword == nil))
    {
        if(!(keyword.idKeyword == nil))
        {
            if(!([keyword.idKeyword isEqualToString:@""]))
            {
                if(!(idPostContent == nil))
                {
                    if(!([idPostContent isEqualToString:@""]))
                    {
                        NSLog(@"Removing keyword  %@ to post: %@", keyword.name, idPostContent);
                        
                        // Perform request to add the term to the content
                        
                        // fetch for the id of the KeywordFashionistaContent entity
                        // Fetch keywords to force selecting one of them
                        KeywordFashionistaContent *keywordFashionistaContent =  [self getKeywordFashionistaContentFromKeywordId:keyword.idKeyword andFashionistaContentId:idPostContent];
                        
                        if (keywordFashionistaContent != nil)
                        {
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADING_TERM_MSG_", nil)];
                            
//                            NSArray * requestParameters = [[NSArray alloc] initWithObjects: idPostContent, keyword, nil];
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects: keywordFashionistaContent, nil];
                            
                            [self performRestDelete:REMOVE_KEYWORD_FROM_CONTENT withParamaters:requestParameters];
                            
                            return;
                        }
                    }
                }
            }
        }
    }
}

-(void) addKeyword:(Keyword *)keyword toPostContent:(FashionistaContent *)fashionistaContent withGroup:(NSNumber *) group XPos:(CGFloat)xPos YPos:(CGFloat)yPos
{
    if(!(keyword == nil))
    {
        if(!(keyword.idKeyword == nil))
        {
            if(!([keyword.idKeyword isEqualToString:@""]))
            {
                if(!(fashionistaContent == nil))
                {
                    if(!(fashionistaContent.idFashionistaContent == nil))
                    {
                        if(!([fashionistaContent.idFashionistaContent isEqualToString:@""]))
                        {
                            NSLog(@"Adding keyword to post: %@", fashionistaContent.idFashionistaContent);
                            
                            // Perform request to add the term to the content
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADING_TERM_MSG_", nil)];
                            
                            //                            NSArray * requestParameters = [[NSArray alloc] initWithObjects: fashionistaContent, keyword, nil];
                            
                            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            KeywordFashionistaContent * keywordFashionistaContent = [[KeywordFashionistaContent alloc] initWithEntity:[NSEntityDescription entityForName:@"KeywordFashionistaContent" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                            
                            [keywordFashionistaContent setKeyword:keyword];
                            [keywordFashionistaContent setKeywordId:keyword.idKeyword];
                            [keywordFashionistaContent setXPos:[NSNumber numberWithFloat:xPos]];
                            [keywordFashionistaContent setYPos:[NSNumber numberWithFloat:yPos]];
                            [keywordFashionistaContent setFashionistaContent:fashionistaContent];
                            [keywordFashionistaContent setFashionistaContentId:fashionistaContent.idFashionistaContent];
                            
                            [keywordFashionistaContent setGroup:group];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects: keywordFashionistaContent, nil];
                            
                            [self performRestPost:ADD_KEYWORD_TO_CONTENT withParamaters:requestParameters];
                            
                            return;
                        }
                    }
                }
            }
        }
    }
}


/*******
 Osama Petran
 add, update GSBaseElement to Wardrobe
 *******/
- (void) addWardrobeToContent:(GSBaseElement*)itemToAdd {
    if (!(itemToAdd == nil))
    {
        NSString* wardrobeID = _wardrobeSelected.idWardrobe;
        NSLog(@"Adding item to wardrobe: %@", wardrobeID);
        
        // Perform request to save the item into the wardrobe
        
        // Provide feedback to user
        if ([self.fashionistaPostDelegate respondsToSelector:@selector(showFeedbackActivity:)]) {
            [self.fashionistaPostDelegate showFeedbackActivity:NSLocalizedString(@"_ADDINGITEMTOWARDROBE_MSG_", nil)];
        }
//        [self stopActivityFeedback];
//        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_ADDINGITEMTOWARDROBE_MSG_", nil)];
        
        
        for (GSBaseElement* element in _PostedProductArry) {
            if ([element.idGSBaseElement isEqualToString:itemToAdd.idGSBaseElement]) { //update
               
                NSArray * requestParameters = [[NSArray alloc] initWithObjects: element, nil];
                [self performRestPost:UPDATE_BASEELEMENT withParamaters:requestParameters];

                return;
            }
        }
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobeID, itemToAdd, nil];

        [self.postActionArray addObject:@"ADD_ITEM_TO_WARDROBE"];
        [self performRestPost:ADD_ITEM_TO_WARDROBE withParamaters:requestParameters];
    }
}
/*******
 Osama Petran
 remove GSBaseElement
 *******/
-(void) removeItemfromContent:(GSBaseElement*)removingItem
{
    if ([self.fashionistaPostDelegate respondsToSelector:@selector(showFeedbackActivity:)]) {
        [self.fashionistaPostDelegate showFeedbackActivity:NSLocalizedString(@"_UPLOADING_TERM_MSG_", nil)];
    }
    
    NSString* wardrobeID = _wardrobeSelected.idWardrobe;
    NSArray * requestParameters = [[NSArray alloc] initWithObjects: wardrobeID, removingItem.idGSBaseElement, nil];
    [self performRestDelete:REMOVE_ITEM_FROM_WARDROBE withParamaters:requestParameters];
    [self.PostedProductArry removeObject:removingItem];
}
/*******
 Osama Petran
 add Keyword to Content
 *******/
-(void) addKeyword:(Keyword *)keyword toPostContent:(FashionistaContent *)fashionistaContent withGroup:(NSNumber *) group
{
    if(!(keyword == nil))
    {
        if(!(keyword.idKeyword == nil))
        {
            if(!([keyword.idKeyword isEqualToString:@""]))
            {
                if(!(fashionistaContent == nil))
                {
                    if(!(fashionistaContent.idFashionistaContent == nil))
                    {
                        if(!([fashionistaContent.idFashionistaContent isEqualToString:@""]))
                        {
                            NSLog(@"Adding keyword to post: %@", fashionistaContent.idFashionistaContent);
                            
                            // Perform request to add the term to the content
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADING_TERM_MSG_", nil)];
                            if ([self.fashionistaPostDelegate respondsToSelector:@selector(showFeedbackActivity:)]) {
                                [self.fashionistaPostDelegate showFeedbackActivity:NSLocalizedString(@"_UPLOADING_TERM_MSG_", nil)];
                            }
                            //                            NSArray * requestParameters = [[NSArray alloc] initWithObjects: fashionistaContent, keyword, nil];
                            NSLog(@"addKeyword ---  >   %@", keyword.name);
                            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            KeywordFashionistaContent * keywordFashionistaContent = [[KeywordFashionistaContent alloc] initWithEntity:[NSEntityDescription entityForName:@"KeywordFashionistaContent" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                            
                            [keywordFashionistaContent setKeyword:keyword];
                            [keywordFashionistaContent setKeywordId:keyword.idKeyword];
                            
                            [keywordFashionistaContent setFashionistaContent:fashionistaContent];
                            [keywordFashionistaContent setFashionistaContentId:fashionistaContent.idFashionistaContent];
                            
                            [keywordFashionistaContent setGroup:group];

                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects: keywordFashionistaContent, nil];
                            
                            [self performRestPost:ADD_KEYWORD_TO_CONTENT withParamaters:requestParameters];
                            
                            return;
                        }
                    }
                }
            }
        }
    }
}
/*******
 Osama Petran
 connect to server to add Keyword
 *******/
-(void) addKeyword:(Keyword *)keyword toPostContent:(FashionistaContent *)fashionistaContent
{
    if(!(keyword == nil))
    {
        if(!(keyword.idKeyword == nil))
        {
            if(!([keyword.idKeyword isEqualToString:@""]))
            {
                if(!(fashionistaContent == nil))
                {
                    if(!(fashionistaContent.idFashionistaContent == nil))
                    {
                        if(!([fashionistaContent.idFashionistaContent isEqualToString:@""]))
                        {
                            NSLog(@"Adding keyword to post: %@", fashionistaContent.idFashionistaContent);
                            
                            // Perform request to add the term to the content
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADING_TERM_MSG_", nil)];
                            
                            NSLog(@"Keyword Name --- >   %@", keyword.name);
                            NSNumber *group = nil;
                            CGFloat xPos = 0.0;
                            CGFloat yPos = 0.0;
                            for (PeopleTagClass *pTag in _tempPostingUserTagArry) {
                                if ([pTag.userTagName isEqualToString:keyword.name]) {
                                    pTag.keywordID = keyword.idKeyword;
                                    pTag.fashionistaContentID = fashionistaContent.idFashionistaContent;
                                    group = pTag.selectedGroupToAddKeyword;
                                    xPos = pTag.xPos;
                                    yPos = pTag.yPos;
                                    
                                    break;
                                }
                            }
                            
                            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            KeywordFashionistaContent * keywordFashionistaContent = [[KeywordFashionistaContent alloc] initWithEntity:[NSEntityDescription entityForName:@"KeywordFashionistaContent" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                            
                            [keywordFashionistaContent setKeyword:keyword];
                            [keywordFashionistaContent setKeywordId:keyword.idKeyword];
                            
                            [keywordFashionistaContent setFashionistaContent:fashionistaContent];
                            [keywordFashionistaContent setFashionistaContentId:fashionistaContent.idFashionistaContent];
                            [keywordFashionistaContent setXPos:[NSNumber numberWithFloat:xPos]];
                            [keywordFashionistaContent setXPos:[NSNumber numberWithFloat:yPos]];
                            [keywordFashionistaContent setGroup:group];
                            
                            
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects: keywordFashionistaContent, nil];
                            
                            [self performRestPost:ADD_KEYWORD_TO_CONTENT withParamaters:requestParameters];
                            
                            return;
                        }
                    }
                }
            }
        }
    }
}
/*******
 Osama Petran
 show GSBaseElement Details
 *******/
- (void)showProductDetailsView:(GSBaseElement*)bsElement {
    _selectedProductItem = bsElement;
    
    [self getProductForElement:bsElement];
}
/*******
 Osama Petran
 post Location Tag
 *******/
- (void)postLocation:(NSString*)locationStr
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(([appDelegate.currentUser.isFashionista boolValue]) == YES)
        {
            if(!(appDelegate.currentUser.idUser == nil))
            {
                if(!([appDelegate.currentUser.idUser isEqualToString: @""]))
                {
                    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                    FashionistaPost * newPost;
                    if (self.tagLocationPost.idFashionistaPost != nil) {
                        newPost = self.tagLocationPost;
                    } else {
                        newPost = [[FashionistaPost alloc] initWithEntity:[NSEntityDescription entityForName:@"FashionistaPost" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                    }
                    
                    [newPost setUserId:appDelegate.currentUser.idUser];
                    [newPost setLocation_poi:locationStr];
                    
                    
                    if(!(newPost == nil))
                    {
                        if((!(newPost.userId == nil)) && (!([newPost.userId isEqualToString:@""])))
                        {
                            
                            NSLog(@"Uploading fashionista post...");
                            
                            // Provide feedback to user
                            if ([self.fashionistaPostDelegate respondsToSelector:@selector(showFeedbackActivity:)]) {
                                [self.fashionistaPostDelegate showFeedbackActivity:NSLocalizedString(@"_PREPARINGFASHIONISTAPOST_MSG_", nil)];
                            }
//                            [self stopActivityFeedback];
//                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTAPOST_MSG_", nil)];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPost, [NSNumber numberWithBool:self.tagLocationPost.idFashionistaPost != nil? YES : NO], nil];
                            
                            [self.postActionArray containsObject:@"UPLOAD_FASHIONISTAPOST_LOCATION"];
                            [self performRestPost:UPLOAD_FASHIONISTAPOST_LOCATION withParamaters:requestParameters];
                        }
                    }
                    
                }
            }
            
            return;
        }
    }
}

// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    __block FashionistaContent * uploadedContent;
    __block FashionistaPost * mappedUploadedPost;
    __block User * currentUser;
    NSString * currentFashionistaContentId = nil;
    NSArray * parametersForNextVC;
    NSManagedObjectContext *currentContext;
    
    __block SearchQuery *searchQuery;
    NSMutableArray *foundResults = [[NSMutableArray alloc] init];
    NSMutableArray *foundResultsGroups = [[NSMutableArray alloc] init];
    NSMutableArray *successfulTerms = nil;
    __block NSString * notSuccessfulTerms = @"";


    switch (connection)
    {
            /*****
             Osama Petran
             go to PRODUCTSHEET_VC
             *****/
        case GET_PRODUCT:
        {
            NSMutableArray * resultContent = [[NSMutableArray alloc] init];
            NSMutableArray * resultReviews = [[NSMutableArray alloc] init];
            NSArray * parametersForNextVC = nil;
            __block id selectedSpecificResult;
            
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Product class]]))
                 {
                     selectedSpecificResult = (Product *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Get the list of reviews that were provided
            for (Review *review in mappingResult)
            {
                if([review isKindOfClass:[Review class]])
                {
                    if(!(review.idReview == nil))
                    {
                        if  (!([review.idReview isEqualToString:@""]))
                        {
                            if(!([resultReviews containsObject:review.idReview]))
                            {
                                [resultReviews addObject:review.idReview];
                            }
                        }
                    }
                }
            }
            
            // Get the list of contents that were provided
            for (Content *content in mappingResult)
            {
                if([content isKindOfClass:[Content class]])
                {
                    if(!(content.idContent == nil))
                    {
                        if  (!([content.idContent isEqualToString:@""]))
                        {
                            if(!([resultContent containsObject:content.idContent]))
                            {
                                [resultContent addObject:content.idContent];
                            }
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: _selectedProductItem, selectedSpecificResult, resultContent, resultReviews/*, _currentSearchQuery*/, nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:PRODUCTSHEET_VC withParameters:parametersForNextVC];
            
            break;
        }
            
        case GET_POSTADAPTEDBACKGROUNDAD:
        {
            [self setBackgroundImage];
            
            break;
        }
        case UPLOAD_SHARE:
        {
            // Get the list of comments that were provided
            for (Share *newShare in mappingResult)
            {
                if([newShare isKindOfClass:[Share class]])
                {
                    [self socialShareActionWithShareObject:((Share*) newShare) andPreviewImage:[UIImage cachedImageWithURL:_shownPost.preview_image]];
                    
                    break;
                }
            }
            
            break;
        }
        case GET_FASHIONISTA:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     currentUser = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: /*_selectedResult, */currentUser, [NSNumber numberWithBool:NO], nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            
            break;
        }
        case GET_USER_LIKES_POST:
        {
            // Get the list of comments that were provided
            for (NSMutableDictionary *userLikesPostDict in mappingResult)
            {
                if([userLikesPostDict isKindOfClass:[NSMutableDictionary class]])
                {
                    NSNumber * like = [userLikesPostDict objectForKey:@"like"];
                    
                    _currentUserLikesPost = (like.intValue > 0);
                }
            }
            
            // Change the hanger button image
            UIImage * buttonImage = (_currentUserLikesPost ? ([UIImage imageNamed:@"like_checked.png"]) : ([UIImage imageNamed:@"like_unchecked.png"]));
            
            if (!(buttonImage == nil))
            {
                [self.likePostButton setImage:buttonImage forState:UIControlStateNormal];
                [self.likePostButton setImage:buttonImage forState:UIControlStateHighlighted];
                [[self.likePostButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
            }
            
            break;
        }
        case GET_ONLYPOST_LIKES_NUMBER:
        {
            // Get the list of comments that were provided
            for (NSMutableDictionary *postLikesNumberDict in mappingResult)
            {
                if([postLikesNumberDict isKindOfClass:[NSMutableDictionary class]])
                {
                    _postLikesNumber = [postLikesNumberDict objectForKey:@"likes"];
                }
            }

            [self setupCommentsAndLikes];
            
            break;
        }
        case LIKE_POST:
        case UNLIKE_POST:
        {
            _currentUserLikesPost = ((connection == LIKE_POST) ? (YES) : (NO));

            
            // Change the hanger button image
            UIImage * buttonImage = ((_currentUserLikesPost) ? ([UIImage imageNamed:@"like_checked.png"]) : ([UIImage imageNamed:@"like_unchecked.png"]));
            
            if (!(buttonImage == nil))
            {
                [self.likePostButton setImage:buttonImage forState:UIControlStateNormal];
                [self.likePostButton setImage:buttonImage forState:UIControlStateHighlighted];
                [[self.likePostButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
            }
            
            // Reload Post Likes
            
            if(!(_shownPost.idFashionistaPost == nil))
            {
                if(!([_shownPost.idFashionistaPost isEqualToString:@""]))
                {
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownPost.idFashionistaPost, nil];
                    
                    [self performRestGet:GET_ONLYPOST_LIKES_NUMBER withParamaters:requestParameters];
                }
            }
            
            [self stopActivityFeedback];

            break;
        }
        case GET_USER:
        {
            [self.mainCollectionView reloadData];
            
            [self.mainCollectionView layoutIfNeeded];
            
            _CommentsViewBottomConstraint.constant = self.CommentsShadowView.frame.size.height + self.mainCollectionView.contentSize.height;
            
            float auxPostViewY = postViewY + self.CommentsShadowView.frame.size.height + self.mainCollectionView.contentSize.height + kBottomExtraSpace;
            
            self.FashionistaPostView.contentSize = CGSizeMake(self.FashionistaPostView.contentSize.width, auxPostViewY);
            
            [self.view layoutIfNeeded];

            break;
        }
        case UPLOAD_COMMENT_VIDEO:
        {
            if(![self performFetchForCollectionViewWithCellType:@"CommentCell"])
            {
                if([self initFetchedResultsControllerForCollectionViewWithCellType:@"CommentCell" WithEntity:@"Comment" andPredicate:@"idComment IN %@" inArray:_postComments sortingWithKeys:[NSArray arrayWithObject:@"date"] ascending:NO andSectionWithKeyPath:nil])
                {
                    for(Comment * comment in self.mainFetchedResultsController.fetchedObjects)
                    {
                        if(comment.userId && ![comment.userId isEqualToString:@""])
                        {
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:comment.userId, nil];
                            [self performRestGet:GET_USER withParamaters:requestParameters];
                        }
                    }
                }
            }
            
            // Setup the top 'comments and likes' label
            [self setupCommentsAndLikes];
            
            if((self.mainFetchedResultsController == nil) || (!([[self.mainFetchedResultsController fetchedObjects] count] > 0)))
            {
                [self.mainCollectionView setHidden:YES];
            }
            else
            {
                [self.mainCollectionView setHidden:NO];
            }

            self.CommentsView.hidden = NO;
            
            [self.FashionistaPostView bringSubviewToFront:self.CommentsView];
            
            // Update collection view
            [self.mainCollectionView reloadData];
            
            [self.mainCollectionView layoutIfNeeded];
            
            _CommentsViewBottomConstraint.constant = self.CommentsShadowView.frame.size.height + self.mainCollectionView.contentSize.height;
            
            float auxPostViewY = postViewY + self.CommentsShadowView.frame.size.height + self.mainCollectionView.contentSize.height + kBottomExtraSpace;
            
            self.FashionistaPostView.contentSize = CGSizeMake(self.FashionistaPostView.contentSize.width, auxPostViewY);
            
            [self.view layoutIfNeeded];

            [self stopActivityFeedback];

            [self closeWriteComment];
            
            break;
        }
        case DELETE_COMMENT:
        {
            _postCommentObjs = nil;

//           [self stopActivityFeedback];
            
            break;
        }
        case ADD_COMMENT_TO_POST:
        {
            Comment * uploadedComment = nil;
            
            // Get the Added comment
            for (Comment * content in mappingResult)
            {
                if([content isKindOfClass:[Comment class]])
                {
                    if(!(content.idComment == nil))
                    {
                        if  (!([content.idComment isEqualToString:@""]))
                        {
                            _postCommentObjs = content;
                            if (![_postComments containsObject:content.idComment]) {
                                [_postComments addObject:content.idComment];
                            }
                            
                            uploadedComment = content;
                            break;
                        }
                    }
                }
            }
            
            if(!(uploadedComment == nil))
            {
                //                _uploadedContent = uploadedContent;
                if(!(uploadedComment.video == nil))
                {
                    if(!([uploadedComment.video isEqualToString:@""]))
                    {
                        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:uploadedComment.video]];
                        
                        if(!(data == nil))
                        {
                            // Post header image
                            NSArray * requestParameters = [NSArray arrayWithObjects:data, uploadedComment.idComment, nil];
                            
                            if([requestParameters count] == 2)
                            {
                                // Give feedback to user
//                                [self stopActivityFeedback];
//                                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTACONTENT_MSG_", nil)];
                                
                                [self performRestPost:UPLOAD_COMMENT_VIDEO withParamaters:requestParameters];

                                NSLog(@"Uploading comment video: %@", uploadedComment.text);
                                
                                return;
                            }
                            else
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_NO_COMMENTVIDEO_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                                
                                [alertView show];
                            }
                        }
                    }
                }
            }
            
            if(![self performFetchForCollectionViewWithCellType:@"CommentCell"])
            {
                [self initFetchedResultsControllerForCollectionViewWithCellType:@"CommentCell" WithEntity:@"Comment" andPredicate:@"idComment IN %@" inArray:_postComments sortingWithKeys:[NSArray arrayWithObject:@"date"] ascending:NO andSectionWithKeyPath:nil];
            }
            
            if(!(self.mainFetchedResultsController == nil))
            {
                for(Comment * comment in self.mainFetchedResultsController.fetchedObjects)
                {
                    if((comment.user == nil) && (comment.userId && ![comment.userId isEqualToString:@""]))
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:comment.userId, nil];
                        [self performRestGet:GET_USER withParamaters:requestParameters];
                    }
                }
            }
            
            // Setup the top 'comments and likes' label
            [self setupCommentsAndLikes];
            
            if((self.mainFetchedResultsController == nil) || (!([[self.mainFetchedResultsController fetchedObjects] count] > 0)))
            {
                [self.mainCollectionView setHidden:YES];
            }
            else
            {
                [self.mainCollectionView setHidden:NO];
            }
            
            self.CommentsView.hidden = NO;

            [self.FashionistaPostView bringSubviewToFront:self.CommentsView];
            
            // Update collection view
            [self.mainCollectionView reloadData];
            
            [self.mainCollectionView layoutIfNeeded];
            
            _CommentsViewBottomConstraint.constant = self.CommentsShadowView.frame.size.height + self.mainCollectionView.contentSize.height;
            
            float auxPostViewY = postViewY + self.CommentsShadowView.frame.size.height + self.mainCollectionView.contentSize.height + kBottomExtraSpace;
            
            self.FashionistaPostView.contentSize = CGSizeMake(self.FashionistaPostView.contentSize.width, auxPostViewY);
            
            [self.view layoutIfNeeded];
            
            [self stopActivityFeedback];
            
            if ([self.fashionistaPostDelegate respondsToSelector:@selector(hideFeedbackActivity:)]) {
                [self.fashionistaPostDelegate hideFeedbackActivity:@"ADD_COMMENT_TO_POST"];
            }
            
            [self closeWriteComment];
            
            break;
        }
        case REMOVE_ITEM_FROM_WARDROBE:
        {
            
            // run again getting products
            
            // remove item from itemsId of the wardrobe

            if(!(_wardrobeSelected.itemsId == nil))
            {
                if([_wardrobeSelected.itemsId count] > 0)
                {
                    for (int i = 0; i < [_wardrobeSelected.itemsId count]; i++)
                    {
                        NSString * tmpId = [_wardrobeSelected.itemsId objectAtIndex:i];
                        NSString * itemId = [tmpId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if ([itemId isEqualToString:_idProductToRemoveFromWardrobeSelected])
                        {
                            [_wardrobeSelected.itemsId removeObjectAtIndex:i];
                            
                            if(!([_wardrobeSelected.itemsId count] > 0))
                            {
                                _wardrobeSelected.itemsId = nil;
                            }
                            
                            break;
                        }
                    }
                }
            }
            

            if(_wardrobeSelected.itemsId == nil)
            {
                if(!(_wardrobeSelected.idWardrobe == nil))
                {
                    if(!([_wardrobeSelected.idWardrobe isEqualToString:@""]))
                    {
                        _wardrobeSelectedToDelete = _wardrobeSelected;
                        
                        [self deleteWardrobe:_wardrobeSelectedToDelete];
                    }
                }
            }
            
            _wardrobeSelected = nil;
            _selectedContentToEdit = nil;
            _sProductImagePathToRemove = nil;
            
            break;
        }
        case GET_POST_CONTENT_KEYWORDS:
        {
            int tag = [self getTagFromFashionistaContentId:currentFashionistaContentId];
            UIView * view = [self getViewFromTag:tag];
            // Get the post that was provided
            for (NSString *fashionistaContentId in mappingResult)
            {
                if([fashionistaContentId isKindOfClass:[NSString class]])
                {
                    currentFashionistaContentId = (NSString *)fashionistaContentId;
                    
                    if(!(currentFashionistaContentId == nil))
                    {
                        if(!([currentFashionistaContentId isEqualToString:@""]))
                        {
                            // Get the keywords that were provided
                            for (KeywordFashionistaContent *keywordFashionista in mappingResult)
                            {
                                if([keywordFashionista isKindOfClass:[KeywordFashionistaContent class]])
                                {
                                    if (keywordFashionista.keyword != nil)
                                    {
                                        Keyword * keyword = keywordFashionista.keyword;
                                        if(!(keyword.idKeyword == nil))
                                        {
                                            if  (!([keyword.idKeyword isEqualToString:@""]))
                                            {
                                                /*
                                                SlideButtonView * keywordsList = [_kwDict valueForKey:currentFashionistaContentId];
                                                
                                                for (UIView *view in [(keywordsList.superview) subviews])
                                                {
                                                    if([view isKindOfClass:[UILabel class]])
                                                    {
                                                        [view removeFromSuperview];
                                                    }
                                                }
                                                
                                                SlideButtonView * termList = [_kwDict valueForKey:currentFashionistaContentId];
                                                [termList addButton:keyword.name];
                                                 */
                                                
                                                NSNumber * group = keywordFashionista.group;
                                                
                                                long iNumGroups = [self getNumGroupsInContent:keywordFashionista.fashionistaContentId];
                                                NSNumber * groupPos = [NSNumber numberWithLong:iNumGroups];
                                                
                                                SlideButtonView * keywordsList = [self getKeywordViewForContent:keywordFashionista.fashionistaContentId andGroup:group];
                                                
                                                if (!keywordsList)
                                                {
                                                    [self createKeywordView:view byGroup:group withTag:tag andContent:keywordFashionista.fashionistaContent andYpos:groupPos isAddGroupButton:NO];
                                                    keywordsList = [self getKeywordViewForContent:keywordFashionista.fashionistaContentId andGroup:group];
                                                }
                                                
                                                
                                                // remove the label
                                                for (UIView *view in [(keywordsList.superview) subviews])
                                                {
                                                    if([view isKindOfClass:[UILabel class]])
                                                    {
                                                        [view removeFromSuperview];
                                                    }
                                                }
                                                
                                                if(!_bEditingMode)
                                                {
                                                    [keywordsList addUnclosedButtonWithText:keyword.toStringButtonSlideView];
                                                }

//                                                [keywordsList addButton:keyword.name];
                                                [keywordsList addButtonWithObject:keyword];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(_bEditingMode)
            {
                [self createButtonAddTagGroup:view andTag:tag];
            }
            
            [self updatePosYContent];

            break;
        }
        case GET_POST_CONTENT_WARDROBE:
        {
            // Get the post that was provided
            for (NSString *fashionistaContentId in mappingResult)
            {
                if([fashionistaContentId isKindOfClass:[NSString class]])
                {
                    currentFashionistaContentId = (NSString *)fashionistaContentId;
                    
                    if(!(currentFashionistaContentId == nil))
                    {
                        if(!([currentFashionistaContentId isEqualToString:@""]))
                        {
                            // Get the keywords that were provided
                            for (GSBaseElement *baseElement in mappingResult)
                            {
                                if([baseElement isKindOfClass:[GSBaseElement class]])
                                {
                                    if(!(baseElement.idGSBaseElement == nil))
                                    {
                                        if  (!([baseElement.idGSBaseElement isEqualToString:@""]))
                                        {
                                            SlideButtonView * wardrobeContentList = [_wardrobeDict valueForKey:currentFashionistaContentId];
                                            
                                            for (UIView *view in [(wardrobeContentList.superview) subviews])
                                            {
                                                if([view isKindOfClass:[UILabel class]])
                                                {
                                                    [view removeFromSuperview];
                                                }
                                            }

                                            SlideButtonView * productsList = [_wardrobeDict valueForKey:currentFashionistaContentId];
                                            [productsList addButton:baseElement.preview_image];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            break;
        }
        case ADD_WARDROBE:
        {
            // Get the list of items that were provided to fill the Wardrobe.itemsId property
            for (Wardrobe *wardrobe in mappingResult)
            {
                if([wardrobe isKindOfClass:[Wardrobe class]])
                {
                    if(!(wardrobe.idWardrobe== nil))
                    {
                        if(!([wardrobe.idWardrobe isEqualToString:@""]))
                        {
                            if(!(_selectedContentToAddWardrobe == nil))
                            {
                                if(!(_selectedContentToAddWardrobe.idFashionistaContent == nil))
                                {
                                    if(!([_selectedContentToAddWardrobe.idFashionistaContent isEqualToString:@""]))
                                    {
                                        [self addWardrobe:wardrobe ToContentWithID:_selectedContentToAddWardrobe.idFashionistaContent];
                                    }
                                }
                            }
                            break;
                        }
                    }
                }
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case ADD_WARDROBE_TO_CONTENT:
        {
            bool bPutSelectedContentToAddWardrobeToNil = YES;
            
            // Get the list of items that were provided to fill the Wardrobe.itemsId property
            for (Wardrobe *wardrobe in mappingResult)
            {
                if([wardrobe isKindOfClass:[Wardrobe class]])
                {
                    if(!(wardrobe.idWardrobe== nil))
                    {
                        if(!([wardrobe.idWardrobe isEqualToString:@""]))
                        {
                            // Initialize the filter terms ribbon
                            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            
//                            appDelegate.addingProductsToWardrobeID = wardrobe.idWardrobe;
                            
                            // Instantiate the 'Search' view controller within the container view
                            if ([self.fashionistaPostDelegate respondsToSelector:@selector(showProductSearchViewController:)]) {
                                _wardrobeSelected = wardrobe;
                                [self.fashionistaPostDelegate showProductSearchViewController:self];
                                
                            }

                            
#if 0
                            if ([UIStoryboard storyboardWithName:@"Search" bundle:nil] != nil)
                            {

                                searchBaseVC = nil;

                                @try {
                                    
                                    searchBaseVC = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateViewControllerWithIdentifier:[@(SEARCH_VC) stringValue]];
                                    
                                }
                                @catch (NSException *exception) {
                                    
                                    return;
                                    
                                }
                                
                                if (searchBaseVC != nil)
                                {
                                   _wardrobeSelected = wardrobe;

                                    [self addChildViewController:searchBaseVC];
                                    
                                    //[addPostToPageVC willMoveToParentViewController:self];

                                    searchBaseVC.view.frame = CGRectMake(0,0,_addToWardrobeVCContainerView.frame.size.width, _addToWardrobeVCContainerView.frame.size.height);
                                    
                                    [searchBaseVC.view setClipsToBounds:YES];

                                    [_addToWardrobeVCContainerView addSubview:searchBaseVC.view];
                                    
                                    [searchBaseVC didMoveToParentViewController:self];
                                    
                                    [_addToWardrobeVCContainerView setHidden:NO];

                                    [_addToWardrobeBackgroundView setHidden:NO];
                                    
                                    [self.view bringSubviewToFront:_addToWardrobeBackgroundView];

                                    [self.view bringSubviewToFront:_addToWardrobeVCContainerView];
                                }
                            }
#endif
                            
////////////////////////                [self transitionToViewController:SEARCH_VC withParameters:nil];
                            
                            bPutSelectedContentToAddWardrobeToNil = NO;
                            
                            break;
                        }
                    }
                }
            }
            if(bPutSelectedContentToAddWardrobeToNil)
                _selectedContentToAddWardrobe = nil;
            
//            [self stopActivityFeedback];

            break;
        }
        case GET_WARDROBE:
        case GET_WARDROBE_CONTENT:
        {
            // Get the list of items that were provided to fill the Wardrobe.itemsId property
            for (Wardrobe *item in mappingResult)
            {
                if([item isKindOfClass:[Wardrobe class]])
                {
                    if(!(item.idWardrobe== nil))
                    {
                        if(!([item.idWardrobe isEqualToString:@""]))
                        {
                            _wardrobeSelected = item;
                            break;
                        }
                    }
                }
            }
            
            [_wardrobeSelected.itemsId removeAllObjects];
            
            // Get the list of items that were provided to fill the Wardrobe.itemsId property
            for (GSBaseElement *item in mappingResult)
            {
                if([item isKindOfClass:[GSBaseElement class]])
                {
                    if(!(item.idGSBaseElement== nil))
                    {
                        if(!([item.idGSBaseElement isEqualToString:@""]))
                        {
                            if(_wardrobeSelected.itemsId == nil)
                            {
                                _wardrobeSelected.itemsId = [[NSMutableArray alloc] init];
                            }
                            
                            if(!([_wardrobeSelected.itemsId containsObject:item.idGSBaseElement]))
                            {
                                [_wardrobeSelected.itemsId addObject:item.idGSBaseElement];
                            }
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects:_wardrobeSelected, [NSNumber numberWithBool:_bEditingMode], nil];
            
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:WARDROBECONTENT_VC withParameters:parametersForNextVC];
            
            break;
        }
        case DELETE_WARDROBE:
        {
            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            [currentContext deleteObject:_wardrobeSelectedToDelete];
            NSError * error = nil;
            if (![currentContext save:&error])
            {
                NSLog(@"Error saving context! %@", error);
            }
            
            _wardrobeSelectedToDelete = nil;

            if (!(_shownPost == nil))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownPost.idFashionistaPost, nil];
                
                [self performRestGet:GET_POST withParamaters:requestParameters];
                
                //[self performRestGet:GET_POST_CONTENT withParamaters:requestParameters];
                
                return;
            }
            
            [self stopActivityFeedback];
            
//            [self setupPostViews];
            
            break;
        }
        case UPLOAD_FASHIONISTAPAGE:
        {
//            _bEditingChanges = NO;
//            
//            [self stopActivityFeedback];
            
            /*
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_FASHIONISTAPAGESUCCESSFULLYPOSTED_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
             
             [alertView show];
             */
            break;
        }
        case UPLOAD_FASHIONISTAPOST:
        {
            _bIsNewPost = NO; // the post has been saved in the database so it is not a new post any more
            // Get the post that was provided
            for (FashionistaPost *post in mappingResult)
            {
                if([post isKindOfClass:[FashionistaPost class]])
                {
                    if(!(post.idFashionistaPost == nil))
                    {
                        if  (!([post.idFashionistaPost isEqualToString:@""]))
                        {
                            mappedUploadedPost = (FashionistaPost *)post;
                            
                            break;
                        }
                    }
                }
            }
            
            if(!(mappedUploadedPost == nil))
            {
                if(!(mappedUploadedPost.idFashionistaPost == nil))
                {
                    if(!([mappedUploadedPost.idFashionistaPost isEqualToString:@""]))
                    {
                        if (!(self.fromViewController == nil))
                        {
                            if([self.fromViewController isKindOfClass:[FashionistaMainPageViewController class]])
                            {
                                if(!([((FashionistaMainPageViewController *)self.fromViewController) postsArray] == nil))
                                {
                                    if(!([[((FashionistaMainPageViewController *)self.fromViewController) postsArray] containsObject:mappedUploadedPost.idFashionistaPost]))
                                    {
                                        [[((FashionistaMainPageViewController *)self.fromViewController) postsArray] addObject:mappedUploadedPost.idFashionistaPost];
                                    }
                                }
                            }
                        }
                        
                        _shownPost = mappedUploadedPost;
                        
                        if (!(_shownPost == nil))
                        {
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownPost.idFashionistaPost, nil];
                            
                            [self performRestGet:GET_POST withParamaters:requestParameters];
                            
                            //[self performRestGet:GET_POST_CONTENT withParamaters:requestParameters];
                            
                            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            [currentContext deleteObject:_shownPost];
                            
                            [currentContext processPendingChanges];
                            
                            if (![currentContext save:nil])
                            {
                                NSLog(@"Save did not complete successfully.");
                            }
                            
                            return;
                        }
                    }
                }
            }
            
            _bEditingChanges = NO;
            
            //[self dismissViewController];
            
            [self stopActivityFeedback];
            /*
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_FASHIONISTAPOSTSUCCESSFULLYPOSTED_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
             
             [alertView show];
             */
            
            break;
        }
        case GET_POST:
        {
            // Get the post that was provided
            for (FashionistaPost *post in mappingResult)
            {
                if([post isKindOfClass:[FashionistaPost class]])
                {
                    if(!(post.idFashionistaPost == nil))
                    {
                        if  (!([post.idFashionistaPost isEqualToString:@""]))
                        {
                            mappedUploadedPost = (FashionistaPost *)post;
                            
                            break;
                        }
                    }
                }
            }
            
            if(!(mappedUploadedPost == nil))
            {
                if(!(mappedUploadedPost.idFashionistaPost == nil))
                {
                    if(!([mappedUploadedPost.idFashionistaPost isEqualToString:@""]))
                    {
                        _shownPost = mappedUploadedPost;
                    }
                }
            }
            
            [_shownFashionistaPostContent removeAllObjects];
            
            // Get the list of contents that were provided
            for (FashionistaContent *content in mappingResult)
            {
                if([content isKindOfClass:[FashionistaContent class]])
                {
                    if(!(content.idFashionistaContent == nil))
                    {
                        if  (!([content.idFashionistaContent isEqualToString:@""]))
                        {
                            if(!(_shownPost == nil))
                            {
                                if(_shownFashionistaPostContent == nil)
                                {
                                    _shownFashionistaPostContent = [[NSMutableArray alloc] init];
                                }
                                
                                if(!([_shownFashionistaPostContent containsObject:content]))
                                {
                                    [_shownFashionistaPostContent addObject:content];
                                }
                            }
                        }
                    }
                }
            }
            
            _bEditingChanges = NO;
            
            //[self stopActivityFeedback];
            
            [self setupPostViews: YES];
            
            break;
        }
        case GET_POST_CONTENT:
        {
            [_shownFashionistaPostContent removeAllObjects];
            
            // Get the list of contents that were provided
            for (FashionistaContent *content in mappingResult)
            {
                if([content isKindOfClass:[FashionistaContent class]])
                {
                    if(!(content.idFashionistaContent == nil))
                    {
                        if  (!([content.idFashionistaContent isEqualToString:@""]))
                        {
                            if(!(_shownPost == nil))
                            {
                                if(_shownFashionistaPostContent == nil)
                                {
                                    _shownFashionistaPostContent = [[NSMutableArray alloc] init];
                                }
                                
                                if(!([_shownFashionistaPostContent containsObject:content]))
                                {
                                    [_shownFashionistaPostContent addObject:content];
                                }
                            }
                        }
                    }
                }
            }
            
            _bEditingChanges = NO;
            
            [self stopActivityFeedback];
            
            [self setupPostViews: YES];
            
            break;
        }
        case UPLOAD_FASHIONISTACONTENT:
        {
            // Get the post that was provided
            [self stopActivityFeedback];
            for (FashionistaContent *content in mappingResult)
            {
                if([content isKindOfClass:[FashionistaContent class]])
                {
                    if(!(content.idFashionistaContent == nil))
                    {
                        if  (!([content.idFashionistaContent isEqualToString:@""]))
                        {
                            uploadedContent = (FashionistaContent *)content;
                            
                            if(!(_shownPost == nil))
                            {
                                if(_shownFashionistaPostContent == nil)
                                {
                                    _shownFashionistaPostContent = [[NSMutableArray alloc] init];
                                }
                                
                                if(!([_shownFashionistaPostContent containsObject:content]))
                                {
                                    [_shownFashionistaPostContent addObject:content];
                                }
                            }
                            
                            break;
                        }
                    }
                }
            }
            
            if(!(uploadedContent == nil))
            {
                //                _uploadedContent = uploadedContent;
                if(!(uploadedContent.video == nil))
                {
                    if(!([uploadedContent.video isEqualToString:@""]))
                    {
                        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:uploadedContent.video]];
                        if(!(data == nil))
                        {
                            // Post header image
                            NSArray * requestParameters = [NSArray arrayWithObjects:data, ( ((!(uploadedContent.idFashionistaContent == nil)) & (!([uploadedContent.idFashionistaContent isEqualToString:@""]))) ? (uploadedContent.idFashionistaContent) : (nil) ), nil];
                            
                            if([requestParameters count] == 2)
                            {
                                // Give feedback to user
//                                [self stopActivityFeedback];
//                                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTACONTENT_MSG_", nil)];
                                
                                [self performRestPost:UPLOAD_FASHIONISTACONTENT_VIDEO withParamaters:requestParameters];
                                
                                return;
                            }
                            else
                            {
                                NSLog(@"Uploading fashionista post: %@", _shownPost.name);
                                
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_NO_FASHIONISTACONTENTIMAGEUPLOAD_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                                
                                [alertView show];
                            }
                        }
                    }
                }
                
                if(!(uploadedContent.image == nil))
                {
                    if(!([uploadedContent.image isEqualToString:@""]))
                    {
                        // Checkeamos que la imagen no sea local
                        //NSRange range = [uploadedContent.image rangeOfString:IMAGESBASEURL];
                        //if(range.location != NSNotFound)
                        {
                            //  NSRange needleRange = NSMakeRange(range.length, uploadedContent.image.length - range.length);
                            // NSString *needle = [uploadedContent.image substringWithRange:needleRange];
                            
                            //if([needle hasPrefix:@"file:///"])
                            {
                                //uploadedContent.image = needle;
                                
                                //                        if([uploadedContent.image hasPrefix:@"file:///var/mobile"])
                                //                        {
                                // Get image
                                //UIImage * image = [UIImage cachedImageWithURL:needle];
                                UIImage * image = [UIImage cachedImageWithURL:uploadedContent.image];
                                
                                if(!(image == nil))
                                {
                                    // Post header image
                                    NSArray * requestParameters = [NSArray arrayWithObjects:image, ( ((!(uploadedContent.idFashionistaContent == nil)) & (!([uploadedContent.idFashionistaContent isEqualToString:@""]))) ? (uploadedContent.idFashionistaContent) : (nil) ), nil];
                                    
                                    if([requestParameters count] == 2)
                                    {
                                        // Give feedback to user
//                                        [self stopActivityFeedback];
//                                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTACONTENT_MSG_", nil)];
                                        
//                                        if([uploadedContent.order intValue] == 0)
//                                        {
//                                            _bShouldUpdatePreviewImage = YES;
//                                        }

                                        [self performRestPost:UPLOAD_FASHIONISTACONTENT_IMAGE withParamaters:requestParameters];

                                        return;
                                    }
                                    else
                                    {
                                        NSLog(@"Uploading fashionista post: %@", _shownPost.name);
                                        
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_NO_FASHIONISTACONTENTIMAGEUPLOAD_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                                        
                                        [alertView show];
                                    }
                                }
                            }
                        }
                    }
                }
                
                //                if(_shownFashionistaPostContent == nil)
                //                {
                //                    _shownFashionistaPostContent = [[NSMutableArray alloc] initWithObjects:_uploadedContent, nil];
                //                }
                //                else
                //                {
                //                    BOOL bAlreadyInList = NO;
                //
                //                    for (FashionistaContent * content in _shownFashionistaPostContent)
                //                    {
                //                        if(!(content.idFashionistaContent == nil))
                //                        {
                //                            if(content.idFashionistaContent == _uploadedContent.idFashionistaContent)
                //                            {
                //                                bAlreadyInList = YES;
                //                            }
                //                        }
                //                    }
                //
                //                    if(!(bAlreadyInList))
                //                    {
                //                        [_shownFashionistaPostContent addObject:_uploadedContent];
                //                    }
                //                }
                
                _bEditingChanges = NO;
                //                _uploadedContent = nil;
            }
            
            [self setupPostViews: YES];
            
            [self stopActivityFeedback];
            
            ///////////////////////////////////
            //            if (!(_shownPost == nil))
            //            {
            //                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownPost.idFashionistaPost, nil];
            //
            //                [self performRestGet:GET_POST_CONTENT withParamaters:requestParameters];
            //            }
            ///////////////////////////////////
            
            //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_FASHIONISTAPOSTSUCCESSFULLYPOSTED_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            //
            //            [alertView show];
            
            break;
        }
        case UPLOAD_FASHIONISTACONTENT_VIDEO:
        {
            _bEditingChanges = NO;
            
            [self setupPostViews:YES];
            
            [self stopActivityFeedback];
            break;
        }
        case UPLOAD_FASHIONISTACONTENT_IMAGE:
        {
            //            if(_shownFashionistaPostContent == nil)
            //            {
            //                _shownFashionistaPostContent = [[NSMutableArray alloc] initWithObjects:_uploadedContent, nil];
            //            }
            //            else
            //            {
            //                BOOL bAlreadyInList = NO;
            //
            //                for (FashionistaContent * content in _shownFashionistaPostContent)
            //                {
            //                    if(!(content.idFashionistaContent == nil))
            //                    {
            //                        if(content.idFashionistaContent == _uploadedContent.idFashionistaContent)
            //                        {
            //                            bAlreadyInList = YES;
            //                        }
            //                    }
            //                }
            //
            //                if(!(bAlreadyInList))
            //                {
            //                    [_shownFashionistaPostContent addObject:_uploadedContent];
            //                }
            //            }
            
//            if(_bShouldUpdatePreviewImage)
//            {
//                [_shownPost setPreview_image:[[mappingResult firstObject] valueForKey:@"image"]];
//               
//                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownPost, [NSNumber numberWithBool:YES], nil];
//                
//                [self performRestPost:UPLOAD_FASHIONISTAPOST withParamaters:requestParameters];
//                
//                _bShouldUpdatePreviewImage = NO;
//            }
            
            _bEditingChanges = NO;
            
            [self setupPostViews: YES];
            if ([self.fashionistaPostDelegate respondsToSelector:@selector(postedImage)]) {
                NSLog(@"success post image");
                [self.fashionistaPostDelegate postedImage];
            }
            [self stopActivityFeedback];
            
            //            _uploadedContent = nil;
            
            //            [self stopActivityFeedback];
            //
            //            [self setupPostViews];
            
            ///////////////////////////////////
            //            if (!(_shownPost == nil))
            //            {
            //                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownPost.idFashionistaPost, nil];
            //
            //                [self performRestGet:GET_POST_CONTENT withParamaters:requestParameters];
            //            }
            ///////////////////////////////////
            
            //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_FASHIONISTAPOSTSUCCESSFULLYPOSTED_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            //
            //            [alertView show];
            
            break;
        }
        case DELETE_POST:
        {
            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            [currentContext deleteObject:_shownPost];
            
            [currentContext processPendingChanges];
            
            if (![currentContext save:nil])
            {
                NSLog(@"Save did not complete successfully.");
            }
            
            _shownPost = nil;
            
            [self stopActivityFeedback];
            
            [super swipeRightAction];
            
            break;
        }
        case DELETE_POST_CONTENT:
        {
            if(!(_shownPost == nil))
            {
                if (!(_shownFashionistaPostContent == nil))
                {
                    if([_shownFashionistaPostContent count] > 0)
                    {
                        if([_shownFashionistaPostContent containsObject:_selectedContentToDelete])
                        {
                            [_shownFashionistaPostContent removeObject:_selectedContentToDelete];
                        }
                    }
                }
            }
            
            //            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            //
            //            [currentContext deleteObject:_selectedContentToDelete];
            //
            //            if (![currentContext save:nil])
            //            {
            //                NSLog(@"Save did not complete successfully.");
            //            }
            
            _selectedContentToDelete = nil;
            
            [self setupPostViews: YES];
            
            [self stopActivityFeedback];
            
            break;
        }

        case UPLOAD_FASHIONISTAPOST_LOCATION:
        {
            for (FashionistaPost *post in mappingResult)
            {
                if([post isKindOfClass:[FashionistaPost class]])
                {
                    if(!(post.idFashionistaPost == nil))
                    {
                        if  (!([post.idFashionistaPost isEqualToString:@""])) {
                            _tagLocationPost = post;
                            break;
                        }
                    }
                }
            }
//            [self stopActivityFeedback];
            if ([self.fashionistaPostDelegate respondsToSelector:@selector(hideFeedbackActivity:)]) {
                [self.fashionistaPostDelegate hideFeedbackActivity:@"UPLOAD_FASHIONISTAPOST_LOCATION"];
            }
            break;
        }

        case UPDATE_KEYWORD_TO_CONTENT:
        {
#ifndef _OSAMA_
            /*******
             Osama Petran
             once keywordfashionistacontent object update, replacd it into Posted Array. so after this, we can check if add or update.
             *******/
            for (KeywordFashionistaContent *content in mappingResult)
            {
                if([content isKindOfClass:[KeywordFashionistaContent class]])
                {
                    if(!(content.idKeywordFashionistaContent == nil))
                    {
                        if  (!([content.idKeywordFashionistaContent isEqualToString:@""])) {
                            for (KeywordFashionistaContent *tmp in _PostedUserTagArry) {
                                if (tmp.idKeywordFashionistaContent == content.idKeywordFashionistaContent) {
                                    tmp.xPos = content.xPos;
                                    tmp.yPos = content.yPos;
                                    tmp.keyword = content.keyword;
                                    tmp.fashionistaContent = content.fashionistaContent;
                                    break;
                                }
                            }
                        }
                        break;
                    }
                }
            }
#endif
            
//            [self stopActivityFeedback];
            if ([self.fashionistaPostDelegate respondsToSelector:@selector(hideFeedbackActivity:)]) {
                [self.fashionistaPostDelegate hideFeedbackActivity:@"UPDATE_KEYWORD_TO_CONTENT"];
            }
            break;
        }
            /*******
             Osama Petran
             did add, update GSBaseElement
             *******/
        case UPDATE_BASEELEMENT:
        {
            for (GSBaseElement *element in mappingResult)
            {
                if([element isKindOfClass:[GSBaseElement class]])
                {
                    if(!(element.idGSBaseElement == nil))
                    {
                        if (!([element.idGSBaseElement isEqualToString:@""]))
                        {
                            for (int i = 0; i < _PostedProductArry.count; i++) {
                                GSBaseElement *tmp = [_PostedProductArry objectAtIndex:i];
                                if (tmp.idGSBaseElement == element.idGSBaseElement) {
                                    [_PostedProductArry replaceObjectAtIndex:i withObject:element];
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
            }
            if ([self.fashionistaPostDelegate respondsToSelector:@selector(hideFeedbackActivity:)]) {
                [self.fashionistaPostDelegate hideFeedbackActivity:@"UPDATE_BASEELEMENT"];
            }
            break;
        }
            
        case ADD_ITEM_TO_WARDROBE:
        {
            for (GSBaseElement *element in mappingResult)
            {
                if([element isKindOfClass:[GSBaseElement class]])
                {
                    if(!(element.idGSBaseElement == nil))
                    {
                        if (!([element.idGSBaseElement isEqualToString:@""]))
                        {
                            [_PostedProductArry addObject:element];
                            break;
                        }
                    }
                }
            }
            // Reload User Wardrobes
                
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if(!(appDelegate.currentUser.idUser == nil))
                {
                    if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                        
                        [self performRestGet:GET_USER_WARDROBES withParamaters:requestParameters];
                        
                        break;
                    }
                }
            }
            
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_USER_WARDROBES_CONTENT:
        {
            //Reset the fetched results controller to fetch the current user wardrobes
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSString *_addingProductsToWardrobeID = _wardrobeSelected.idWardrobe;
            if(appDelegate.currentUser)
            {
                if(!(_addingProductsToWardrobeID == nil))
                {
                    if(!([_addingProductsToWardrobeID isEqualToString:@""]))
                    {
                        [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"idWardrobe IN %@" inArray:[NSArray arrayWithObject:_addingProductsToWardrobeID] sortingWithKey:@"idWardrobe" ascending:YES];
                        
                        // Get the list of reviews that were provided
//                        for (Wardrobe *wardrobe in mappingResult)
//                        {
//                            if([wardrobe isKindOfClass:[Wardrobe class]])
//                            {
//                                if(!(wardrobe.idWardrobe == nil))
//                                {
//                                    if (!([wardrobe.idWardrobe isEqualToString:@""]))
//                                    {
//                                        if([wardrobe.idWardrobe isEqualToString:_addingProductsToWardrobeID])
//                                        {
////                                            _bAddingProductsToPostContentWardrobe = NO;
//                                        }
//                                    }
//                                }
//                            }
//                        }
                    }
                    else
                    {
                        [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"userId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idWardrobe" ascending:YES];
                    }
                }
                else
                {
                    [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"userId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idWardrobe" ascending:YES];
                }
                
            }
            if ([self.fashionistaPostDelegate respondsToSelector:@selector(hideFeedbackActivity:)]) {
                [self.fashionistaPostDelegate hideFeedbackActivity:@"ADD_ITEM_TO_WARDROBE"];
            }
            break;
        }
        case ADD_KEYWORD_TO_CONTENT:
        {
#ifndef _OSAMA_
            /*******
             Osama Petran
             once keywordfashionistacontent object posted, add it into Posted Array. so after this, we can check if add or update.
             *******/
            for (KeywordFashionistaContent *content in mappingResult)
            {
                if([content isKindOfClass:[KeywordFashionistaContent class]])
                {
                    if(!(content.idKeywordFashionistaContent == nil))
                    {
                        if  (!([content.idKeywordFashionistaContent isEqualToString:@""])) {
                            [_PostedUserTagArry addObject:content];
                        }
                        break;
                    }
                }
            }
#else
            _selectedContentToAddKeyword = nil;

            _selectedGroupToAddKeyword = nil;
            
            [self setupPostViews: NO];
#endif
            [self stopActivityFeedback];
            if ([self.fashionistaPostDelegate respondsToSelector:@selector(hideFeedbackActivity:)]) {
                [self.fashionistaPostDelegate hideFeedbackActivity:@"ADD_KEYWORD_TO_CONTENT"];
            }
            break;
        }
        case REMOVE_KEYWORD_FROM_CONTENT:
        {
#ifndef _OSAMA_
  
//            _selectedContentToAddKeyword = nil;
//            
//            [self setupPostViews: NO];
#endif
            
            [self stopActivityFeedback];
            
            break;
        }
        case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            [self stopActivityFeedback];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_ALERT_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];

            
            break;
        }
        case FINISHED_SEARCH_WITH_RESULTS:
        {
            // Get the number of total results that were provided
            // and the string of terms that didn't provide any results
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[SearchQuery class]]))
                 {
                     searchQuery = obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            if (searchQuery.numresults > 0)
            {
                // Get the list of results groups that were provided
                for (ResultsGroup *group in mappingResult)
                {
                    if([group isKindOfClass:[ResultsGroup class]])
                    {
                        if(!(group.idResultsGroup == nil))
                        {
                            if (!([group.idResultsGroup isEqualToString:@""]))
                            {
                                if(!([foundResultsGroups containsObject:group]))
                                {
                                    [foundResultsGroups addObject:group];
                                }
                            }
                        }
                    }
                }
                
                // Get the list of results that were provided
                for (GSBaseElement *result in mappingResult)
                {
                    if([result isKindOfClass:[GSBaseElement class]])
                    {
                        if(!(result.idGSBaseElement == nil))
                        {
                            if (!([result.idGSBaseElement isEqualToString:@""]))
                            {
                                if(!([foundResults containsObject:result.idGSBaseElement]))
                                {
                                    [foundResults addObject:result.idGSBaseElement];
                                }
                            }
                        }
                    }
                }
                
                // Get the keywords that provided results
                for (Keyword *keyword in mappingResult)
                {
                    if([keyword isKindOfClass:[Keyword class]])
                    {
                        if (successfulTerms == nil)
                        {
                            successfulTerms = [[NSMutableArray alloc] init];
                        }
                        
                        if(!(keyword.name == nil))
                        {
                            if (!([keyword.name isEqualToString:@""]))
                            {
                                NSString * pene = [[keyword.name lowercaseString] capitalizedString];
                                pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                
                                if (!([successfulTerms containsObject:pene]))
                                {
                                    // Add the term to the set of terms
                                    [successfulTerms addObject:pene];
                                }
                            }
                        }
                        
                    }
                }
                
                
                if(_bComingFromTagsSearch == YES)
                {
                    // Paramters for next VC (ResultsViewController)
                    NSArray * parametersForNextVC = [NSArray arrayWithObjects: searchQuery, foundResults, foundResultsGroups, successfulTerms, notSuccessfulTerms, nil];
                    
                    _bComingFromTagsSearch = NO;
                    
                    [self stopActivityFeedback];
                    
                    if ([foundResults count] > 0)
                    {
                        [self transitionToViewController:SEARCH_VC withParameters:parametersForNextVC];
                    }
                    else
                    {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_ALERT_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                        
                        [alertView show];
                        
                    }
                }
                else
                {
                    // Paramters for next VC (ResultsViewController)
                    NSArray * parametersForNextVC = [NSArray arrayWithObjects: mappingResult, [NSNumber numberWithInt:connection], nil];
                    
                    [self stopActivityFeedback];
                    
                    if ([foundResults count] > 0)
                    {
                        [self transitionToViewController:FASHIONISTAS_VC withParameters:parametersForNextVC];
                    }
                    else
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_FOLLOWERSORFOLLOWING_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                        
                        [alertView show];
                    }
                }
            }
            else
            {
                if(_bComingFromTagsSearch == YES)
                {
                    _bComingFromTagsSearch = NO;
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_ALERT_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_FOLLOWERSORFOLLOWING_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                }
            }
            
            break;
        }

        default:
            break;
    }
}

-(void) mappingKeywordsGroup:(NSArray *)mappingResult
{
    NSString * currentFashionistaContentId = nil;
    
    // Get the post that was provided
    for (NSString *fashionistaContentId in mappingResult)
    {
        if([fashionistaContentId isKindOfClass:[NSString class]])
        {
            currentFashionistaContentId = (NSString *)fashionistaContentId;
            
            if(!(currentFashionistaContentId == nil))
            {
                if(!([currentFashionistaContentId isEqualToString:@""]))
                {
                    // Get the keywords that were provided
                    for (KeywordFashionistaContent *keywordFashionista in mappingResult)
                    {
                        NSNumber * groupKeyword = keywordFashionista.group;
                        if([keywordFashionista isKindOfClass:[KeywordFashionistaContent class]])
                        {
                            if (keywordFashionista.keyword != nil)
                            {
                                Keyword * keyword = keywordFashionista.keyword;
                                if(!(keyword.idKeyword == nil))
                                {
                                    if  (!([keyword.idKeyword isEqualToString:@""]))
                                    {
                                        NSMutableDictionary * dictKeywordGroup = [_kwDict valueForKey:[groupKeyword stringValue]];
                                        if (dictKeywordGroup != nil)
                                        {
                                            SlideButtonView * keywordsList = [dictKeywordGroup valueForKey:currentFashionistaContentId];
                                            
                                            for (UIView *view in [(keywordsList.superview) subviews])
                                            {
                                                if([view isKindOfClass:[UILabel class]])
                                                {
                                                    [view removeFromSuperview];
                                                }
                                            }
                                            
                                            SlideButtonView * termList = [dictKeywordGroup valueForKey:currentFashionistaContentId];
//                                            [termList addButton:keyword.name];
                                            [termList addButtonWithObject:keyword];
                                        }
                                        else{
                                            // TODO: crear diccionario para el grupo que no se ha encontrado ??
                                            dictKeywordGroup = [[NSMutableDictionary alloc]init];
                                            [_kwDict setValue:dictKeywordGroup forKey:[groupKeyword stringValue]];
                                            
//                                            SlideButtonView * pTermsListView = [[SlideButtonView alloc] initWithFrame:CGRectMake(5, 5, contentView.frame.size.width-110, 30)];
                                            SlideButtonView * pTermsListView = [[SlideButtonView alloc] initWithFrame:CGRectMake(5, 5, 440, 30)];
                                            
                                            [dictKeywordGroup setValue:pTermsListView forKey:currentFashionistaContentId];
                                            [kwsView addSubview:pTermsListView];
                                            [self initSearchTermsListView:pTermsListView];
                                            [pTermsListView addButton:keyword.name];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
// Perform Rest Request
- (void) performOwnRestGet:(connectionType)connection withParamaters:(NSArray *)parameters
{
    NSString * requestString;
    NSArray * dataClasses;
    NSArray *failedAnswerErrorMessage;
    NSString * currentFashionistaContentId = nil;
    
    switch (connection)
    {
        case GET_KEYWORDS_FROM_STRING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = String
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/getkeywordsFrom/%@",((NSString *)([parameters objectAtIndex:0]))];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Keyword class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform GET_KEYWORDS_FROM_STRING request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_POST_CONTENT_KEYWORDS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    currentFashionistaContentId = ((NSString *)([parameters objectAtIndex:0]));
                    
                    // 0 = Post
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistaPostContent/%@/keywords?limit=-1",((NSString *)([parameters objectAtIndex:0]))];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[KeywordFashionistaContent class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform GET_POST_CONTENT_KEYWORDS request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_POST_CONTENT_WARDROBE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    
                    currentFashionistaContentId = ((NSString *)([parameters objectAtIndex:0]));
                    
                    // 0 = Post
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistaPostContent/%@/wardrobe",((NSString *)([parameters objectAtIndex:0]))];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Wardrobe class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform GET_POST_CONTENT_WARDROBE request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_POST_CONTENT_WARDROBE_CONTENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    currentFashionistaContentId = ((NSString *)([parameters objectAtIndex:1]));
                    
                    // 0 = Wardrobe Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/wardrobe/%@/resultqueries?limit=-1", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[GSBaseElement class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform GET_POST_CONTENT_WARDROBE_CONTENT request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
            
        default:
            break;
    }
    
    if(!(requestString == nil) && (!(dataClasses == nil)))
    {
        if ((!([requestString isEqualToString:@""])) && ([dataClasses count] > 0))
        {
            NSDate *methodStart = [NSDate date];
            
            [[RKObjectManager sharedManager] getObjectsAtPath:requestString
                                                   parameters:nil
                                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
             {
                 // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                 
                 NSDate *methodFinish = [NSDate date];
                 
                 NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
                 
                 NSLog(@"Operation <%@> succeed!! It took: %f", operation.HTTPRequestOperation.request.URL, executionTime);
                 
                 NSArray *mappedResults = [mappingResult array];
                 
                 
                 switch (connection)
                 {
                     case GET_KEYWORDS_FROM_STRING:
                     {
                         // bucle recorriendo los keywords devueltos por el server
                         for (Keyword * keyword in mappedResults)
                         {
                             if (keyword.idKeyword != nil)
                             {
                                 if (![keyword.idKeyword isEqualToString:@""])
                                 {
                                     NSLog(@"keyword name ---->  %@", keyword.name);
                                     // add the relation between the keyword and the post content
                                     [self addKeyword:keyword toPostContent:self.selectedContentToAddKeyword];
                                 }
                             }
                         }
                         
                         
                         break;
                     }
                     case GET_POST_CONTENT_KEYWORDS:
                     {
                         [self cleantTagSlideViewForPostContent:currentFashionistaContentId];
                         
                         int tag = [self getTagFromFashionistaContentId:currentFashionistaContentId];
                         UIView * view = [self getViewFromTag:tag];
                         // Get the keywords that were provided
                         for (KeywordFashionistaContent *keywordFashionista in mappedResults)
                         {
                             if([keywordFashionista isKindOfClass:[KeywordFashionistaContent class]])
                             {
                                 if (keywordFashionista.keyword != nil)
                                 {
                                     Keyword * keyword = keywordFashionista.keyword;
                                     if(!(keyword.idKeyword == nil))
                                     {
                                         if  (!([keyword.idKeyword isEqualToString:@""]))
                                         {
                                             NSNumber * group = keywordFashionista.group;

                                             long iNumGroups = [self getNumGroupsInContent:keywordFashionista.fashionistaContentId];
                                             NSNumber * groupPos = [NSNumber numberWithLong:iNumGroups];
                                             
                                             SlideButtonView * keywordsList = [self getKeywordViewForContent:keywordFashionista.fashionistaContentId andGroup:group];
                                             
                                             if (!keywordsList)
                                             {
                                                 [self createKeywordView:view byGroup:group withTag:tag andContent:keywordFashionista.fashionistaContent andYpos:groupPos isAddGroupButton:NO];
                                                 keywordsList = [self getKeywordViewForContent:keywordFashionista.fashionistaContentId andGroup:group];
                                             }
                                             

                                             // remove the label
                                             for (UIView *view in [(keywordsList.superview) subviews])
                                             {
                                                 if([view isKindOfClass:[UILabel class]])
                                                 {
                                                     [view removeFromSuperview];
                                                 }
                                             }
                                             
//                                             keywordsList = [self getKeywordViewForContent:keywordFashionista.fashionistaContentId andGroup:group];
                                             if ([keyword.forPostContent boolValue])
                                             {
                                                 SlideButtonProperties * prop = [[SlideButtonProperties alloc] init];
                                                 prop.colorTextButtons = [UIColor blueColor];
                                                 prop.colorSelectedTextButtons = [UIColor blueColor];
//                                                 [keywordsList addButton:keyword.name withProperties:prop];
                                                 
                                                 if(!_bEditingMode)
                                                 {
                                                     [keywordsList addUnclosedButtonWithText:keyword.toStringButtonSlideView];
                                                 }

                                                 [keywordsList addButtonWithObject:keyword withProperties:prop];
                                             }
                                             else
                                             {
                                                 if(!_bEditingMode)
                                                 {
                                                     [keywordsList addUnclosedButtonWithText:keyword.toStringButtonSlideView];
                                                 }
                                                 
                                                 [keywordsList addButtonWithObject:keyword];
//                                                 [keywordsList addButton:keyword.name];
                                             }
                                         }
                                     }
                                 }
                             }
                         }
                         
                         if(_bEditingMode)
                         {
                             [self createButtonAddTagGroup:view andTag:tag];
                         }
                         
                         [self updatePosYContent];
                         
                         break;
                     }
                     case GET_POST_CONTENT_WARDROBE:
                     {
                         // Now, request the products
                         if (!(mappingResult == nil))
                         {
                             if ([mappingResult count] > 0)
                             {
                                 NSString *wardrobe = (NSString *)[((Wardrobe *)([mappedResults objectAtIndex:0])) idWardrobe];
                                 
                                 NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobe, currentFashionistaContentId, nil];
                                 
                                 [self performOwnRestGet:GET_POST_CONTENT_WARDROBE_CONTENT withParamaters:requestParameters];
                                 
                                 NSLog(@"Getting wardrobe succeed!");
                                 
                                 break;
                             }
                         }
                         
                         break;
                     }
                     case GET_POST_CONTENT_WARDROBE_CONTENT:
                     {
                         
                         if (_sProductImagePathToRemove != nil)
                         {
                             if (![_sProductImagePathToRemove isEqualToString:@""])
                             {
                                 // Get the keywords that were provided
                                 for (GSBaseElement *baseElement in mappedResults)
                                 {
                                     if([baseElement isKindOfClass:[GSBaseElement class]])
                                     {
                                         if(!(baseElement.preview_image == nil))
                                         {
                                             if  (!([baseElement.preview_image isEqualToString:@""]))
                                             {
                                                 if ([baseElement.preview_image isEqualToString:_sProductImagePathToRemove])
                                                 {
                                                     // set to _wardrobeSelected the wardrobe from we are going to remove a product
                                                     [self getWardrobeToEdit:_selectedContentToEdit.wardrobeId];
                                                     // store the id of the product to remove from the wardrobe
                                                     _idProductToRemoveFromWardrobeSelected = baseElement.idGSBaseElement;
                                                     
                                                     // call to remove the content in the server
                                                     NSArray * requestParameters = [[NSArray alloc] initWithObjects: _selectedContentToEdit.wardrobeId, baseElement.idGSBaseElement, nil];
                                                     [self performRestDelete:REMOVE_ITEM_FROM_WARDROBE withParamaters:requestParameters];
                                                 }
                                             }
                                         }
                                     }
                                 }
                             }
                             break;
                         }
                         
                         [self cleanWardrobeSlideViewPostContent:currentFashionistaContentId];
                         
                         // Get the keywords that were provided
                         for (GSBaseElement *baseElement in mappedResults)
                         {
                             if([baseElement isKindOfClass:[GSBaseElement class]])
                             {
                                 if(!(baseElement.idGSBaseElement == nil))
                                 {
                                     if  (!([baseElement.idGSBaseElement isEqualToString:@""]))
                                     {
                                         SlideButtonView * wardrobeContentList = [_wardrobeDict valueForKey:currentFashionistaContentId];
                                         
                                         for (UIView *view in [(wardrobeContentList.superview) subviews])
                                         {
                                             if([view isKindOfClass:[UILabel class]])
                                             {
                                                 [view removeFromSuperview];
                                             }
                                         }
                                         
                                         SlideButtonView * productsList = [_wardrobeDict valueForKey:currentFashionistaContentId];
                                         [productsList addButton:baseElement.preview_image];
                                     }
                                 }
                             }
                         }
                         
                         
                         break;
                     }
                         
                     default:
                         break;
                 }
             }
                                                      failure:^(RKObjectRequestOperation *operation, NSError *error)
             {
                 //Message to show if no results were provided
                 NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                 
                 // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                 if(failedAnswerErrorMessage == nil)
                 {
                     errorMessage = nil;
                 }
                 
                 NSLog(@"Operation <%@> failed with error: %ld", operation.HTTPRequestOperation.request.URL, (long)operation.HTTPRequestOperation.response.statusCode);
                 
                 [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
             }];
            
            return;
        }
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    
    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
}



#pragma mark - Statistics


-(void)uploadPostView
{
    // Check that the name is valid
    
    if (!(self.shownPost.idFashionistaPost == nil))
    {
        if(!([self.shownPost.idFashionistaPost isEqualToString:@""]))
        {
            // Post the ProductView object
            
            FashionistaPostView * newPostView = [[FashionistaPostView alloc] init];
            
            [newPostView setPostId:self.shownPost.idFashionistaPost];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newPostView setUserId:appDelegate.currentUser.idUser];
                }
            }
            
            if(!(_searchQuery == nil))
            {
                if(!(_searchQuery.idSearchQuery == nil))
                {
                    if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                    {
                        [newPostView setStatProductQueryId:_searchQuery.idSearchQuery];
                    }
                }
            }
            
            [newPostView setFingerprint:appDelegate.finger.fingerprint];

            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostView, nil];
            
            [self performRestPost:ADD_POSTVIEW withParamaters:requestParameters];
        }
    }
}

-(void)uploadPostSharedIn:(NSString *) sSocialNetwork
{
    // Check that the name is valid
    
    if (!(self.shownPost.idFashionistaPost == nil))
    {
        if(!([self.shownPost.idFashionistaPost isEqualToString:@""]))
        {
            // Post the FashionistaPostShared object
            
            FashionistaPostShared * newPostShared = [[FashionistaPostShared alloc] init];
            
            newPostShared.socialNetwork = sSocialNetwork;
            
            [newPostShared setPostId:self.shownPost.idFashionistaPost];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newPostShared setUserId:appDelegate.currentUser.idUser];
                }
            }
            
            if(!(_searchQuery == nil))
            {
                if(!(_searchQuery.idSearchQuery == nil))
                {
                    if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                    {
                        [newPostShared setStatProductQueryId:_searchQuery.idSearchQuery];
                    }
                }
            }
            
            [newPostShared setFingerprint:appDelegate.finger.fingerprint];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostShared, nil];
            
            [self performRestPost:ADD_POSTSHARED withParamaters:requestParameters];
        }
    }
}

-(void) afterSharedIn:(NSString *) sSocialNetwork
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!([appDelegate.currentUser.idUser isEqualToString:self.shownPost.userId]))
    {
        [self uploadPostSharedIn:sSocialNetwork];
    }
}

-(void)uploadCommentView:(Comment *) comment
{
    // Check that the name is valid
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Post the ProductView object
    
    CommentView * newCommentView = [[CommentView alloc] init];
    [newCommentView setCommentId:comment.idComment];
    
    if (!(appDelegate.currentUser == nil))
    {
        if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
        {
            [newCommentView setUserId:appDelegate.currentUser.idUser];
        }
    }
    
    [newCommentView setFingerprint:appDelegate.finger.fingerprint];
    
    if(!(newCommentView == nil))
    {
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:newCommentView, nil];
        
        [self performRestPost:ADD_COMMENTVIEW withParamaters:requestParameters];
    }
}

-(void) postAnayliticsIntervalTimeBetween:(NSDate *) startTime and:(NSDate *) endTime
{
    if (!(self.shownPost.idFashionistaPost == nil))
    {
        if(!([self.shownPost.idFashionistaPost isEqualToString:@""]))
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            //            if(!([appDelegate.currentUser.idUser isEqualToString:self.shownPost.userId]))
            if ([self.idUserViewing isEqualToString:self.shownPost.userId] == NO)
            {
                // Post the ProductView object
                
                FashionistaPostViewTime * newPostViewTime = [[FashionistaPostViewTime alloc] init];
                
                [newPostViewTime setStartTime:startTime];
                
                [newPostViewTime setEndTime:endTime];
                
                [newPostViewTime setPostId:self.shownPost.idFashionistaPost];
                
                
                if (!(self.idUserViewing == nil))
                {
                    if (!([self.idUserViewing isEqualToString:@""]))
                    {
                        [newPostViewTime setUserId:self.idUserViewing];
                    }
                }
                
                if(!(_searchQuery == nil))
                {
                    if(!(_searchQuery.idSearchQuery == nil))
                    {
                        if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                        {
                            [newPostViewTime setStatProductQueryId:_searchQuery.idSearchQuery];
                        }
                    }
                }
                
                [newPostViewTime setFingerprint:appDelegate.finger.fingerprint];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostViewTime, nil];
                
                [self performRestPost:ADD_POSTVIEWTIME withParamaters:requestParameters];
            }
        }
    }
}


#pragma mark - Add to Wardrobe


// Initialize fetched Results Controller to fetch the current user wardrobes in order to properly show the hanger button
- (BOOL)initFetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate inArray:(NSArray *)arrayForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    BOOL bReturn = FALSE;
    
    if(_wardrobesFetchedResultsController == nil)
    {
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        if (_wardrobesFetchRequest == nil)
        {
            if([arrayForPredicate count] > 0)
            {
                _wardrobesFetchRequest = [[NSFetchRequest alloc] init];
                
                // Entity to look for
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                
                [_wardrobesFetchRequest setEntity:entity];
                
                // Filter results
                
                [_wardrobesFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, arrayForPredicate]];
                
                // Sort results
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                
                [_wardrobesFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                [_wardrobesFetchRequest setFetchBatchSize:20];
            }
        }
        
        if(_wardrobesFetchRequest)
        {
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_wardrobesFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
            
            _wardrobesFetchedResultsController = fetchedResultsController;
            
            _wardrobesFetchedResultsController.delegate = self;
        }
        
        if(_wardrobesFetchedResultsController)
        {
            // Perform fetch
            
            NSError *error = nil;
            
            if (![_wardrobesFetchedResultsController performFetch:&error])
            {
                // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                
                NSLog(@"Couldn't fetched wardrobes. Unresolved error: %@, %@", error, [error userInfo]);
                
                return FALSE;
            }
            
            bReturn = ([_wardrobesFetchedResultsController fetchedObjects].count > 0);
        }
    }
    
    return bReturn;
}


- (BOOL) doesCurrentUserWardrobesContainPostWithId:(NSString *)postId
{
    if (!([postId isEqualToString:@""]))
    {
        if (!(_wardrobesFetchedResultsController == nil))
        {
            if (!((int)[[_wardrobesFetchedResultsController fetchedObjects] count] < 1))
            {
                for (GSBaseElement *tmpGSBaseElement in [_wardrobesFetchedResultsController fetchedObjects])
                {
                    if([tmpGSBaseElement isKindOfClass:[GSBaseElement class]])
                    {
                        // Check that the element to search is valid
                        if (!(tmpGSBaseElement == nil))
                        {
                            if(!(tmpGSBaseElement.fashionistaPostId == nil))
                            {
                                if(!([tmpGSBaseElement.fashionistaPostId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.fashionistaPostId isEqualToString:postId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}

// Setup the hanger button
-(void) setupHangerButton: (BOOL) bSelected
{
    // Setup the hanger button
    
    CGRect buttonFrame = CGRectMake((self.view.frame.size.width - (kHangerButtonWidth + kHangerButtonHorizontalInset)), (self.view.frame.origin.y + kHangerButtonVerticalInset), kHangerButtonWidth, kHangerButtonHeight);
    
    self.hangerButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    [self.hangerButton setFrame:buttonFrame];
    [self.hangerButton setBackgroundColor:[UIColor clearColor]];
    [self.hangerButton setAlpha:1.0];
    [[self.hangerButton titleLabel] setFont:[UIFont fontWithName:@kFontInHangerButton size:kFontSizeInHangerButton]];
    [self.hangerButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.hangerButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.hangerButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    UIImage * buttonImage = [UIImage imageNamed:(bSelected ? (@"hanger_checked.png") : (@"hanger_unchecked.png"))];
    
    if (buttonImage == nil)
    {
        [self.hangerButton setTitle:NSLocalizedString(@"_ADDTOWARDROBE_BTN_", nil) forState:UIControlStateNormal];
    }
    else
    {
        [self.hangerButton setImage:buttonImage forState:UIControlStateNormal];
        [self.hangerButton setImage:buttonImage forState:UIControlStateHighlighted];
        [[self.hangerButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    [self.hangerButton addTarget:self action:@selector(onTapAddToWardrobe:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.hangerButton];
    [self.view bringSubviewToFront:self.hangerButton];
}


- (void)onTapAddToWardrobe:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    if (!([self doesCurrentUserWardrobesContainPostWithId:_shownPost.idFashionistaPost]))
    {
        // Instantiate the 'AddProductToWardrobe' view controller within the container view
        
        if ([UIStoryboard storyboardWithName:@"Wardrobe" bundle:nil] != nil)
        {
            AddItemToWardrobeViewController *addItemToWardrobeVC = nil;
            
            @try {
                
                addItemToWardrobeVC = [[UIStoryboard storyboardWithName:@"Wardrobe" bundle:nil] instantiateViewControllerWithIdentifier:[@(ADDITEMTOWARDROBE_VC) stringValue]];
                
            }
            @catch (NSException *exception) {
                
                return;
                
            }
            
            if (addItemToWardrobeVC != nil)
            {
                [addItemToWardrobeVC setItemToAdd:_shownGSBaseElement];

                [addItemToWardrobeVC setPostToAdd:_shownPost];
                
                [addItemToWardrobeVC setButtonToHighlight:sender];
                
                [self addChildViewController:addItemToWardrobeVC];
                
                //[addProductToWardrobeVC willMoveToParentViewController:self];
                
                addItemToWardrobeVC.view.frame = CGRectMake(0,0,_addToWardrobeVCContainerView.frame.size.width, _addToWardrobeVCContainerView.frame.size.height);
                
                [_addToWardrobeVCContainerView addSubview:addItemToWardrobeVC.view];
                
                [addItemToWardrobeVC didMoveToParentViewController:self];
                
                [_addToWardrobeVCContainerView setHidden:NO];
                
                [_addToWardrobeBackgroundView setHidden:NO];
                
                [self.view bringSubviewToFront:_addToWardrobeBackgroundView];
                
                [self.view bringSubviewToFront:_addToWardrobeVCContainerView];
            }
        }
    }
}

- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL)bSuccess
{
    if((bSuccess) && (!(button == nil)))
    {
        // Change the hanger button imageç
        UIImage * buttonImage = [UIImage imageNamed:@"hanger_checked.png"];
        
        if (!(buttonImage == nil))
        {
            [button setImage:buttonImage forState:UIControlStateNormal];
            [button setImage:buttonImage forState:UIControlStateHighlighted];
            [[button imageView] setContentMode:UIViewContentModeScaleAspectFit];
            //[self.hangerButton setImage:buttonImage forState:UIControlStateNormal];
            //[self.hangerButton setImage:buttonImage forState:UIControlStateHighlighted];
            //[[self.hangerButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
            
        }
    }
    
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    
    [[_addToWardrobeVCContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    //[[self.childViewControllers lastObject] didMoveToParentViewController:nil];
    
    [_addToWardrobeVCContainerView setHidden:YES];
    
    [_addToWardrobeBackgroundView setHidden:YES];
}

-(BOOL) existsWardrobeInContent:(FashionistaContent *) content
{
    BOOL bRes = NO;
    if ((content.wardrobeId != nil) && (![content.wardrobeId isEqualToString:@""]))
    {
        _keywordsFetchedResultsController = nil;
        _keywordssFetchRequest = nil;
        
        [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"idWardrobe ==[c] %@" withString:[content.wardrobeId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] sortingWithKey:@"idWardrobe" ascending:YES];
        
        if (!(_keywordsFetchedResultsController == nil))
        {
            bRes = ([[_keywordsFetchedResultsController fetchedObjects] count] > 0);
        }
    }
    
    if (bRes == NO)
    {
        // no existe el wardrobe ponemos a nil el wardrobreId
        content.wardrobeId = nil;
    }
    
    return bRes;
}

-(void) cleanWardrobeSlideViewPostContent: (NSString *)idFashionistaContent
{
    SlideButtonView * slide = [_wardrobeDict objectForKey:idFashionistaContent];
    
    if (slide)
    {
        [slide removeAllButtons];
    }
}



#pragma mark - Show content wardrobe and tags


- (void)onTapShowContentWardrobe:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    if(![[self activityIndicator] isHidden])
        return;
    
    FashionistaContent * clickedContent = [self setClickedContent:sender];
    
    if(clickedContent != nil)
    {
        if(!(clickedContent.wardrobeId == nil))
        {
            if(!([clickedContent.wardrobeId isEqualToString:@""]))
            {
                // Perform request to get its properties from GS server
                [self getContentsForWardrobe:clickedContent.wardrobeId];
                
                return;
            }
        }
    }

    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_EDITWARDROBE_", nil) message:NSLocalizedString(@"_CANTEDITPOSTCONTENTWARDROBE_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
//    [alertView show];
}

- (void)onTapShowContentTags:(UIButton *)sender
{
    if(_bEditingMode)
    {
        return;
    }
    
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }
    
    if(![[self activityIndicator] isHidden])
        return;
    
    FashionistaContent * clickedContent = [self setClickedContent:sender];
    
    if(clickedContent != nil)
    {
        NSMutableArray * arrayViews = [_viewsDict valueForKey:clickedContent.idFashionistaContent];
        
        UIView * mainView = arrayViews[0];
        
        if (([mainView isKindOfClass:[UIImageView class]]) || ([mainView isKindOfClass:[UIView class]]))
        {
            for(int iIdx = 1 ; iIdx < arrayViews.count; iIdx++)
            {
                UIView * view = [arrayViews objectAtIndex:iIdx];

                if(!([view isKindOfClass:[UIButton class]]))
                {
                    [UIView animateWithDuration:0.5
                                          delay:(0.02 * iIdx)
                                        options:UIViewAnimationOptionAllowUserInteraction
                                     animations:^ {
                                         
                                         [view setTransform:CGAffineTransformMakeTranslation((-1*(!(view.hidden)))*(mainView.frame.size.width), 0)];
                                         view.hidden = (!(view.hidden));
                                         
                                     }
                                     completion:^(BOOL finished) {
                                         
                                     }];
                }
            }
        }
    }
}

- (void) performTagsSearch:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }
    
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    if(!([_containerTagsByFilter isHidden]))
    {
        return;
    }
    
    _selectedContentToAddKeyword = nil;
    FashionistaContent * clickedContent = [self setClickedContentGroup:sender];
    
    long iGroup = sender.tag % kMultiplierTagForGroup;
    NSNumber * contentKeywordsGroup = [NSNumber numberWithLong:iGroup];
    
    SlideButtonView * keywordsList = [self getKeywordViewForContent:clickedContent.idFashionistaContent andGroup:contentKeywordsGroup];
 
    if(!(keywordsList == nil))
    {
        if(!(keywordsList.arrayButtons == nil))
        {
            if([keywordsList.arrayButtons count] > 0)
            {
                NSMutableArray * searchTerms = [[NSMutableArray alloc] init];
                
                for (NSObject * keyword in keywordsList.arrayButtons)
                {
                    if(!(keyword == nil))
                    {
                        if([keyword isKindOfClass:[NSObject class]])
                        {
                            [searchTerms addObject:[keyword toStringButtonSlideView]];
                            
                        }
                    }
                }
                
                if([searchTerms count] > 0)
                {
                    //Setup search string

                    NSString *stringToSearch = [self composeStringhWithTermsOfArray:searchTerms encoding:YES];
                    
                    // Check that the final string to search is valid
                    if (((stringToSearch == nil) || ([stringToSearch isEqualToString:@""])))
                    {
                        /*
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_NO_SEARCH_KEYWORDS_", nil) message:NSLocalizedString(@"_NO_SEARCH_KEYWORDS_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                         
                         [alertView show];
                         */
                        
                        return;
                    }
                    else
                    {
                        NSLog(@"Performing search with terms: %@", stringToSearch);
                        
                        // Provide feedback to user
                        [self stopActivityFeedback];
                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SEARCHING_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [NSArray arrayWithObject:stringToSearch];
                        
                        _bComingFromTagsSearch = YES;
                        
                        [self performRestGet:PERFORM_SEARCH_WITHIN_PRODUCTS withParamaters:requestParameters];
                    }
                }
            }
        }
    }
}


#pragma mark - Report contents abuse

// Check if the current view controller must show the 'Report' button
- (BOOL)shouldCreateReportButton
{
    /*
    if(_bEditingMode == NO)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        if(!([appDelegate.currentUser.idUser isEqualToString:_shownPost.userId]))
        {
            return YES;
        }
    }
    */
    return NO;
}

// Report post content
- (void)reportAction:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }
    
    if(!([self.mainMenuView isHidden]))
    {
        [self showMainMenu:nil];
        return;
    }

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }    
    
    // Here we need to pass a full frame
    CustomAlertView *alertView = [[CustomAlertView alloc] init];
    
    UIView *errorTypesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 220)];
    
    for (int i = 0; i < maxPostContentReportTypes; i++)
    {
        //"_POSTCONTENT_REPORT_TYPE_0_" = "Shows nudity";
        //"_POSTCONTENT_REPORT_TYPE_1_" = "Includes drug use";
        //"_POSTCONTENT_REPORT_TYPE_2_" = "Is sexually explicit";
        //"_POSTCONTENT_REPORT_TYPE_3_" = "Shows violence, criminal activity or accidents";
        //"_POSTCONTENT_REPORT_TYPE_4_" = "Advocates the doing of a terrorist act";
        
        
        NSString *postContentReportType = [NSString stringWithFormat:@"_POSTCONTENT_REPORT_TYPE_%i_", i];
        
        UILabel *reportTypeLabel = [UILabel createLabelWithOrigin:CGPointMake(10, (10 * (i+1)) + (30 * i))
                                                          andSize:CGSizeMake(errorTypesView.frame.size.width - 80, 30)
                                               andBackgroundColor:[UIColor clearColor]
                                                         andAlpha:1.0
                                                          andText:NSLocalizedString(postContentReportType, nil)
                                                     andTextColor:[UIColor blackColor]
                                                          andFont:[UIFont fontWithName:@"Avenir-Light" size:15]
                                                   andUppercasing:NO
                                                       andAligned:NSTextAlignmentLeft];
        
        UISwitch *switchErrorType = [[UISwitch alloc] initWithFrame:CGRectMake(reportTypeLabel.frame.origin.x + reportTypeLabel.frame.size.width + 10, reportTypeLabel.frame.origin.y, 80, 10)];
        [switchErrorType setTag:i];
        [switchErrorType setOn:NO animated:NO];
        
        [errorTypesView addSubview:reportTypeLabel];
        [errorTypesView addSubview:switchErrorType];
    }
    
    // Add some custom content to the alert view
    [alertView setContainerView:errorTypesView];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"_CANCEL_", nil), NSLocalizedString(@"_SEND_", nil), nil]];
    
    [alertView setDelegate:self];
    
    [alertView setUseMotionEffects:true];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        if(buttonIndex == 1)
        {
            // Check that the name is valid
            
            if (!(_shownPost.idFashionistaPost == nil))
            {
                if(!([_shownPost.idFashionistaPost isEqualToString:@""]))
                {
                    // Post the PostContentReport object
                    
                    PostContentReport * newPostContentReport = [[PostContentReport alloc] init];
                    
                    [newPostContentReport setPostId:_shownPost.idFashionistaPost];
                    
                    int reportType = 0;
                    
                    for (UIView * view in alertView.containerView.subviews)
                    {
                        if ([view isKindOfClass:[UISwitch class]])
                        {
                            reportType += ((pow(2,(view.tag))) * ([((UISwitch*) view) isOn]));
                        }
                    }
                    
                    [newPostContentReport setReportType:[NSNumber numberWithInt:reportType]];
                    

                    if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        [newPostContentReport setUserId:appDelegate.currentUser.idUser];
                    }
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostContentReport, nil];
                    
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGPOSTCONTENTREPORT_ACTV_MSG_", nil)];
                    
                    [self performRestPost:ADD_POSTCONTENTREPORT withParamaters:requestParameters];
                }
            }
        }
        
        [alertView close];
        
    }];
    
    // And launch the dialog
    [alertView show];
    
}


- (void)customAlertViewButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
}


#pragma mark - Show full-sized images


- (void)onTapZoomPostImage:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }
    
    if(!([_addTermTextField isHidden]))
    {
        [self hideAddSearchTerm];

        return;
    }
    
    int iIdx = (int)sender.tag;
    NYTExamplePhoto *selectedPhoto = nil;
    
    NSMutableArray * photos = [[NSMutableArray alloc]init];
    NSArray * sortedFashionistaContent = nil;
    
    if(!(_shownPost == nil))
    {
        if(!(_shownFashionistaPostContent == nil))
        {
            if([_shownFashionistaPostContent count] > 0)
            {
                sortedFashionistaContent = [_shownFashionistaPostContent sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
            }
        }
    }
    
    if(!(sortedFashionistaContent == nil))
    {
        if([sortedFashionistaContent count] > 0)
        {
            for (int i = 0; i < [sortedFashionistaContent count]; i++)
            {
                FashionistaContent * fashionistaContent = [sortedFashionistaContent objectAtIndex:i];
                
                if (!(fashionistaContent == nil))
                {
                    if(fashionistaContent.image != nil)
                    {
                        NYTExamplePhoto *photo = [[NYTExamplePhoto alloc] init];
                        photo.image =[UIImage cachedImageWithURL:fashionistaContent.image];
                        
                        if(iIdx == i)
                            selectedPhoto = photo;
                        
                        [photos addObject:photo];
                    }
                }
            }
        }
    }
    
    if(selectedPhoto)
    {
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos initialPhoto:selectedPhoto];
        [self presentViewController:photosViewController animated:YES completion:nil];
    }
    else
    {
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos];
        [self presentViewController:photosViewController animated:YES completion:nil];
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    CGSize contentSize = webView.scrollView.contentSize;
    contentSize.width += 1.0f;
    [webView.scrollView setContentSize:contentSize];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
    self.currentScrollPosition = scrollView.contentOffset;
    NSLog(@"Scroll");
    
    if(bIsAnimating)
        return;
    
    float fOffsetMargin = 30.0;
    NSInteger contentCount = self.postImagesArray.count;
    
    if(scrollView.contentOffset.x >= ((scrollView.contentSize.width - scrollView.frame.size.width)+fOffsetMargin))
    {
        // Current webview
        UIWebView * pCurrentWebView = [self.webViewArray objectAtIndex:self.iSelectedContent];
        
        // Right
        if(self.iSelectedContent < (contentCount-1))
        {
            bIsAnimating = YES;
            self.iSelectedContent = self.iSelectedContent+1;
            UIWebView * pNextWebView = [self.webViewArray objectAtIndex:(self.iSelectedContent)];
            
            CGRect visibleRect = pCurrentWebView.frame;
            CGRect hideRightRect = pCurrentWebView.frame;
            hideRightRect.origin.x = hideRightRect.size.width;
            CGRect hideLefttRect = pCurrentWebView.frame;
            hideLefttRect.origin.x = -hideLefttRect.size.width;
            
            pNextWebView.frame = hideRightRect;
            pNextWebView.hidden = NO;
            
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^ {
                                 
                                 pNextWebView.frame = visibleRect;
                                 pCurrentWebView.frame = hideLefttRect;
                                 [self.view layoutIfNeeded];
                                 
                                 
                             }
                             completion:^(BOOL finished) {
                                 pCurrentWebView.hidden = YES;
                                 pCurrentWebView.frame = visibleRect;
                                 bIsAnimating = NO;
                             }];
        }
        
    }
    else if(scrollView.contentOffset.x <= -fOffsetMargin)
    {
        // Current webview
        UIWebView * pCurrentWebView = [self.webViewArray objectAtIndex:self.iSelectedContent];
        
        // left
        if(self.iSelectedContent > 0)
        {
            bIsAnimating = YES;
            self.iSelectedContent = self.iSelectedContent-1;
            UIWebView * pNextWebView = [self.webViewArray objectAtIndex:(self.iSelectedContent)];
            
            CGRect visibleRect = pCurrentWebView.frame;
            CGRect hideRightRect = pCurrentWebView.frame;
            hideRightRect.origin.x = hideRightRect.size.width;
            CGRect hideLefttRect = pCurrentWebView.frame;
            hideLefttRect.origin.x = -hideLefttRect.size.width;
            
            pNextWebView.frame = hideLefttRect;
            pNextWebView.hidden = NO;
            
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^ {
                                 
                                 pNextWebView.frame = visibleRect;
                                 pCurrentWebView.frame = hideRightRect;
                                 [self.view layoutIfNeeded];
                                 
                                 
                             }
                             completion:^(BOOL finished) {
                                 pCurrentWebView.hidden = YES;
                                 pCurrentWebView.frame = visibleRect;
                                 bIsAnimating = NO;
                             }];
        }
        
    }
    */
}


#pragma mark - Alert views management


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *title = [alertView title];
    
    if( ([title isEqualToString:NSLocalizedString(@"_SETPOSTTITLE_", nil)]) ||
       ([title isEqualToString:NSLocalizedString(@"_EDITPOSTTITLE_", nil)]) ||
       ([title isEqualToString:NSLocalizedString(@"_ADDWARDROBE_", nil)]))
    {
        if(![[[alertView textFieldAtIndex:0] text] length] >= 1)
        {
            return NO;
        }
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( ([alertView.title isEqualToString:NSLocalizedString(@"_SETPOSTTITLE_", nil)]) || ([alertView.title isEqualToString:NSLocalizedString(@"_EDITPOSTTITLE_", nil)]))
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_OK_", nil)])
        {
            // Set top bar title
            
            if(_bEditingMode)
            {
                if(!(_shownPost == nil))
                {
                    [_shownPost setName:[alertView textFieldAtIndex:0].text];
                }
                
                _bEditingChanges = YES;
                
                [self setTopBarTitle:nil andSubtitle:[alertView textFieldAtIndex:0].text];
            }
        }
    }
    else if ([alertView.title isEqualToString:NSLocalizedString(@"_CANCELPOSTEDITING_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
        {
            _bEditingChanges = NO;
            
            [self swipeRightAction];
        }
    }
    else if ([alertView.title isEqualToString:NSLocalizedString(@"_REMOVECONTENT_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_CANCEL_", nil)])
        {
            if(!(_selectedContentToDelete == nil))
            {
                _selectedContentToDelete = nil;
            }
        }
        else if([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
        {
            if (_selectedContentToDelete != nil)
            {
                [self deleteContent:_selectedContentToDelete];
            }
        }
        
    }
    else if ([alertView.title isEqualToString:NSLocalizedString(@"_CANCELTEXTEDITION_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
        {
            _bConfirmingTextEditDiscard = NO;

            [self hideEditTextContentTextView];
            
            _selectedContentToEdit = nil;
        }
        else
        {
            _bConfirmingTextEditDiscard = NO;
            
            [_editTextContentTextView becomeFirstResponder];
        }
    }
    else if([alertView.title isEqualToString:NSLocalizedString(@"_ADDWARDROBE_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_ADD_", nil)])
        {
            [self createWardrobeWithName: [alertView textFieldAtIndex:0].text];
        }
        else if([title isEqualToString:NSLocalizedString(@"_CANCEL_", nil)])
        {
            _selectedContentToAddWardrobe = nil;
        }
    }
    else if ([alertView.title isEqualToString:NSLocalizedString(@"_REMOVEWARDROBE_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_CANCEL_", nil)])
        {
            if (_wardrobeSelectedToDelete != nil)
            {
                _wardrobeSelectedToDelete = nil;
            }
        }
        else if ([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
        {
            if (_wardrobeSelectedToDelete != nil)
            {
                [self deleteWardrobe:_wardrobeSelectedToDelete];
            }
        }
    }
    
}


#pragma mark - Transitions between View Controllers


// OVERRIDE: Just to prevent from being at the 'Add to Wardrobe' view
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        if (searchBaseVC != nil)
        {
            if([searchBaseVC zoomViewVisible])
            {
                [searchBaseVC hideZoomView];
            }
        }
        return;
    }
    
    if (![_containerTagsByFilter isHidden])
    {
        if([_filterTagVC zoomViewVisible])
        {
            [_filterTagVC hideZoomView];
            return;
        }
    }
    
    [super touchesEnded:touches withEvent:event];
    
}

// OVERRIDE: (Just to prevent from being at 'Zoomed Image View' dialog) Action to perform when user swipes to right: go to previous screen
- (void)swipeRightAction
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    if(!([self.hintBackgroundView isHidden]))
    {
        [self hintPrevAction:nil];
        
        return;
    }

    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        if (searchBaseVC != nil)
        {
            if([searchBaseVC zoomViewVisible])
            {
                [searchBaseVC hideZoomView];
                return;
            }
        }
        
        [self closeAddingItemToWardrobeHighlightingButton:nil withSuccess:NO];
        
        return;
    }

    if(!([_containerTagsByFilter isHidden]))
    {
        [_filterTagVC hideZoomView];

//        [self closeFilterForTags];
        
        return;
    }
    else if(!self.writeCommentView.hidden)
    {
        [self closeWriteComment];
        
        return;
    }

    
    if(!(_bEditingMode))
    {
        [super swipeRightAction];
    }
    else if(!(_bEditingChanges))
    {
        if(_shownPost)
        {
            if((!_shownPost.fashionistaPageId || [_shownPost.fashionistaPageId isEqualToString:@""] ) || ((_shownFashionistaPostContent == nil) || ([_shownFashionistaPostContent count] < 1)))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownPost, nil];
                [self performRestDelete:DELETE_POST withParamaters:requestParameters];
                return;
            }
        }
        
        [super swipeRightAction];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELPOSTEDITING_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_BACK_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
        
        [alertView show];
    }
}
/*
// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Left action
- (void)leftAction:(UIButton *)sender
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }

    if (_containerTagsByFilter.hidden == NO)
    {
        // get the ID of keywords selected
        [self closeFilterForTags];
        
        return;
    }
    
    if(!self.writeCommentView.hidden)
    {
        [self closeWriteComment];
        
        return;
    }

    
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    if(!(_bEditingMode))
    {
        [super leftAction:sender];
    }
    else if(!(_bEditingChanges))
    {
        if(_shownPost)
        {
            if((!_shownPost.fashionistaPageId || [_shownPost.fashionistaPageId isEqualToString:@""] ) || ((_shownFashionistaPostContent == nil) || ([_shownFashionistaPostContent count] < 1)))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownPost, nil];
                [self performRestDelete:DELETE_POST withParamaters:requestParameters];
                return;
            } 
        }
        
        [super swipeRightAction];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELPOSTEDITING_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_BACK_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
        
        [alertView show];
    }
}
*/

-(void)uploadFashionistaPost:(FashionistaPost *)editedPost withContents:(NSMutableArray *)fashionistaPostContents
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    // Instantiate the 'AddProductToWardrobe' view controller within the container view
    
    if ([UIStoryboard storyboardWithName:@"FashionistaContents" bundle:nil] != nil)
    {
        AddPostToPageViewController *addPostToPageVC = nil;
        
        @try {
            
            addPostToPageVC = [[UIStoryboard storyboardWithName:@"FashionistaContents" bundle:nil] instantiateViewControllerWithIdentifier:[@(ADDPOSTTOPAGE_VC) stringValue]];
            
        }
        @catch (NSException *exception) {
            
            return;
            
        }
        
        if (addPostToPageVC != nil)
        {
            [addPostToPageVC setPostToAdd:editedPost];
            
            [self addChildViewController:addPostToPageVC];
            
            //[addPostToPageVC willMoveToParentViewController:self];
            
            addPostToPageVC.view.frame = CGRectMake(0,0,_addToWardrobeVCContainerView.frame.size.width, _addToWardrobeVCContainerView.frame.size.height);
            
            [_addToWardrobeVCContainerView addSubview:addPostToPageVC.view];
            
            [addPostToPageVC didMoveToParentViewController:self];
            
            [_addToWardrobeVCContainerView setHidden:NO];
            
            [_addToWardrobeBackgroundView setHidden:NO];
            
            [self.view bringSubviewToFront:_addToWardrobeBackgroundView];
            
            [self.view bringSubviewToFront:_addToWardrobeVCContainerView];
        }
    }
}

- (void)closeAddingPostToPageWithSuccess:(BOOL)bSuccess
{
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    
    [[_addToWardrobeVCContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    //[[self.childViewControllers lastObject] didMoveToParentViewController:nil];
    
    [_addToWardrobeVCContainerView setHidden:YES];
    
    [_addToWardrobeBackgroundView setHidden:YES];
    
    if(bSuccess)
    {
        [self swipeRightAction];
    }
}

- (void)saveData
{
    if(!([_editTextContentSuperView isHidden]))
    {
        return;
    }

    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }

    if (_containerTagsByFilter.hidden == NO)
    {
        // TODO: get the ID of keywords selected
        if(_selectedContentToAddKeyword != nil)
        {
            for (NSString *name in _keywordsSelected)
            {
                [self addKeywordFromName:name];
            }
        }
        
        [self closeFilterForTags];

        NSString * key = [NSString stringWithFormat:@"HIGHLIGHTSAVE_%d", [self.restorationIdentifier intValue]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Save into defaults if doesn't already exists
        if (!([defaults objectForKey:key]))
        {
            [defaults setInteger:1 forKey:key];
            
            [defaults synchronize];
        }
        else
        {
            int iNumHighlights = (int)[defaults integerForKey:key];
            
            [defaults setInteger:(iNumHighlights+1) forKey:key];
            
            [defaults synchronize];
        }

//        [self setupPostViews];
        
        return;
    }
    
    if (!self.writeCommentView.hidden)
    {
        // Check that the review has some text
        if ([self.commentTextView.text length] == 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_POST_COMMENT_", nil) message:NSLocalizedString(@"_POST_COMMENT_ADDSOMETEXT_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
        }
        else
        {
            [self.writeCommentView endEditing:YES];
            
            [self uploadComment];
            
            NSString * key = [NSString stringWithFormat:@"HIGHLIGHTSUBMIT_%d", [self.restorationIdentifier intValue]];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            // Save into defaults if doesn't already exists
            if (!([defaults objectForKey:key]))
            {
                [defaults setInteger:1 forKey:key];
                
                [defaults synchronize];
            }
            else
            {
                int iNumHighlights = (int)[defaults integerForKey:key];
                
                [defaults setInteger:(iNumHighlights+1) forKey:key];
                
                [defaults synchronize];
            }
        }
        
        return;
    }
    
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    if(!(_bEditingMode))
    {
        // Action to perform is 'Share'
        if (!(self.shownPost.idFashionistaPost == nil))
        {
            if(!([self.shownPost.idFashionistaPost isEqualToString:@""]))
            {
                // Post the Share object
                
                NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                
                Share * newShare = [[Share alloc] initWithEntity:[NSEntityDescription entityForName:@"Share" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];

                [newShare setSharedPostId:self.shownPost.idFashionistaPost];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                if (!(appDelegate.currentUser == nil))
                {
                    if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        [newShare setSharingUserId:appDelegate.currentUser.idUser];
                    }
                }
                
                [currentContext processPendingChanges];
                
                [currentContext save:nil];

                NSArray * requestParameters = [[NSArray alloc] initWithObjects:newShare, nil];
                
                [self performRestPost:UPLOAD_SHARE withParamaters:requestParameters];
            }
        }
    }
    else
    {
        if(!(_shownPost == nil))
        {
            if(!(_shownFashionistaPostContent == nil))
            {
                if([_shownFashionistaPostContent count] > 0)
                {
                    [self uploadFashionistaPost:_shownPost withContents:_shownFashionistaPostContent];
                    
                    NSString * key = [NSString stringWithFormat:@"HIGHLIGHTFINISH_%d", [self.restorationIdentifier intValue]];
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    
                    // Save into defaults if doesn't already exists
                    if (!([defaults objectForKey:key]))
                    {
                        [defaults setInteger:1 forKey:key];
                        
                        [defaults synchronize];
                    }
                    else
                    {
                        int iNumHighlights = (int)[defaults integerForKey:key];
                        
                        [defaults setInteger:(iNumHighlights+1) forKey:key];
                        
                        [defaults synchronize];
                    }
                    
                    return;
                }
            }
        }

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_SHOULDSETSOMECONTENT_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }
}

// OVERRIDE: To control the case when the user is adding products to a post content wardrobe
- (void)showMainMenu:(UIButton *)sender
{
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    else
    {
        [super showMainMenu:sender];
    }
}

#pragma mark - Logout
// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    
    if (_bEditingMode)
    {
        return;
        [self dismissViewController];
        
        [self transitionToViewController:SEARCH_VC withParameters:nil fromViewController:self.fromViewController];
    }
    else
    {
        [self closeAddingPostToPageWithSuccess:NO];
        [self closeAddingItemToWardrobeHighlightingButton:nil withSuccess:NO];
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)getCurrentLocation
{
    [commentLocationManager requestWhenInUseAuthorization];
    
    commentLocationManager.delegate = self;
    
    commentLocationManager.pausesLocationUpdatesAutomatically = NO;
    
    commentLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    if ([CLLocationManager locationServicesEnabled])
    {
        [commentLocationManager startUpdatingLocation];
    }
    else
    {
        NSLog(@"Location services is not enabled");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location failed with error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location updated to location: %@", newLocation);
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        
        // Stop Location Manager
        [commentLocationManager stopUpdatingLocation];
        
        // Reverse Geocoding
        NSLog(@"Resolving the address...");
        
        [commentGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error){
            
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            
            if (error == nil && [placemarks count] > 0)
            {
                commentPlacemark = [placemarks lastObject];
                
                // For full address
                /*_detailedReviewUserLocation.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                 placemark.subThoroughfare, placemark.thoroughfare,
                 placemark.postalCode, placemark.locality,
                 placemark.administrativeArea,
                 placemark.country];*/
                
                _currentUserLocation = [NSString stringWithFormat:@"%@ (%@)", commentPlacemark.locality, commentPlacemark.country];
            }
            else
            {
                NSLog(@"%@", error.debugDescription);
            }
        } ];
    }
}


#pragma mark - Social Comments View


- (NSString*) calculatePeriodForDate:(NSDate *)date
{
    NSDate * today = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponents = [calendar components: (NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date toDate:today options:0];
    
    if (dateComponents.year > 0)
    {
        if (dateComponents.year > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_YEARS_AGO_", nil), (long)dateComponents.year];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_YEAR_AGO_", nil);
        }
    }
    else if (dateComponents.month > 0)
    {
        if (dateComponents.month > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_MONTHS_AGO_", nil), (long)dateComponents.month];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_MONTH_AGO_", nil);
        }
    }
    else if (dateComponents.weekOfYear > 0)
    {
        if (dateComponents.weekOfYear > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_WEEKS_AGO_", nil), (long)dateComponents.weekOfYear];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_WEEK_AGO_", nil);
        }
    }
    else if (dateComponents.day > 0)
    {
        if (dateComponents.day > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_DAYS_AGO_", nil), (long)dateComponents.day];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_YESTERDAY_", nil);
        }
    }
    else if (dateComponents.hour > 0)
    {
        if (dateComponents.hour > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_HOURS_AGO_", nil), (long)dateComponents.hour];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_HOUR_AGO_", nil);
        }
    }
    else if (dateComponents.minute > 0)
    {
        if (dateComponents.minute > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_MINUTES_AGO_", nil), (long)dateComponents.minute];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_MINUTE_AGO_", nil);
        }
    }
    else if (dateComponents.second > 0)
    {
        //        if (dateComponents.second > 1)
        //        {
        //            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_SECONDS_AGO_", nil), (long)dateComponents.second];
        //        }
        //        else
        {
            return NSLocalizedString(@"_POSTED_RIGHTNOW_", nil);
        }
    }
    
    //    else
    //    {
    //        return NSLocalizedString(@"_POSTED_TODAY_", nil);
    //    }
    
    return nil;
}

- (void)setupLocationAndDate
{
    NSString *locationAndDate = nil;
    [self.commentsLocDateLabel setText:NSLocalizedString(@"_UNKNOWN_LOCATION_AND_DATE_", nil)];
    
    if (!(_shownPost == nil))
    {
        if(!(_shownPost.date == nil))
        {
            NSString *date = [self calculatePeriodForDate:_shownPost.date];
            
            if(!(date == nil))
            {
                if(!([date isEqualToString:@""]))
                {
                    locationAndDate = [NSString stringWithFormat:NSLocalizedString(@"_POSTDATE_", nil), date];
                }
            }
        }
        
        if(!(_shownPost.location == nil))
        {
            if(!([_shownPost.location isEqualToString:@""]))
            {
                if(!((locationAndDate == nil) || ([locationAndDate isEqualToString:@""])))
                {
                    locationAndDate = [locationAndDate stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"_POSTDATEANDLOCATION_", nil), _shownPost.location]];
                }
                else
                {
                    locationAndDate = [NSString stringWithFormat:NSLocalizedString(@"_POSTLOCATION_", nil), _shownPost.location];
                }
            }
        }
        
        if(!(locationAndDate == nil))
        {
            if(!([locationAndDate isEqualToString:@""]))
            {
                [self.commentsLocDateLabel setText:locationAndDate];
            }
        }
    }
}


- (void)setupCommentsAndLikes
{
    NSString *commentsAndLikes = nil;
    
    [self.commentsComLikesLabel setText:NSLocalizedString(@"_NO_COMMENTS_AND_LIKES_", nil)];
    
    if (!(_postLikesNumber == nil))
    {
        if([_postLikesNumber intValue] > 0)
        {
            if([_postLikesNumber intValue] == 1)
            {
                commentsAndLikes = [NSString stringWithFormat:NSLocalizedString(@"_POSTLIKE_", nil), [_postLikesNumber intValue]];
            }
            else
            {
                commentsAndLikes = [NSString stringWithFormat:NSLocalizedString(@"_POSTLIKES_", nil), [_postLikesNumber intValue]];
            }
        }
    }
    
    if (!(self.mainFetchedResultsController == nil))
    {
        if([[self.mainFetchedResultsController fetchedObjects] count] > 0)
        {
            if(!((commentsAndLikes == nil) || ([commentsAndLikes isEqualToString:@""])))
            {
                if([[self.mainFetchedResultsController fetchedObjects] count] == 1)
                {
                    commentsAndLikes = [commentsAndLikes stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"_POSTLIKESANDCOMMENT_", nil), [[self.mainFetchedResultsController fetchedObjects] count]]];
                }
                else
                {
                    commentsAndLikes = [commentsAndLikes stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"_POSTLIKESANDCOMMENTS_", nil), [[self.mainFetchedResultsController fetchedObjects] count]]];
                }
            }
            else
            {
                if([[self.mainFetchedResultsController fetchedObjects] count] == 1)
                {
                    commentsAndLikes = [NSString stringWithFormat:NSLocalizedString(@"_POSTCOMMENT_", nil), [[self.mainFetchedResultsController fetchedObjects] count]];
                }
                else
                {
                    commentsAndLikes = [NSString stringWithFormat:NSLocalizedString(@"_POSTCOMMENTS_", nil), [[self.mainFetchedResultsController fetchedObjects] count]];
                }
            }
        }
    }
    
    if(!(commentsAndLikes == nil))
    {
        if(!([commentsAndLikes isEqualToString:@""]))
        {
            [self.commentsComLikesLabel setText:commentsAndLikes];
        }
    }
}

-(void)setupCurrentUserLike
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, _shownPost.idFashionistaPost, nil];
                
                [self performRestGet:GET_USER_LIKES_POST withParamaters:requestParameters];
            }
        }
    }
}

-(void) setupCommentsView
{
    [self setupCurrentUserLike];
    
    [self setupCommentsCollection];
    
    // Setup the top 'location and date' label
    [self setupLocationAndDate];
    
    // Setup the top 'comments and likes' label
    [self setupCommentsAndLikes];

    // setup comments view
    self.CommentsViewTopConstraint.constant = postViewY-5;

    self.CommentsViewBottomConstraint.constant = self.CommentsShadowView.frame.size.height + self.mainCollectionView.contentSize.height;
    
    float auxPostViewY = postViewY + self.CommentsShadowView.frame.size.height + self.mainCollectionView.contentSize.height + kBottomExtraSpace;
    
    self.FashionistaPostView.contentSize = CGSizeMake(self.FashionistaPostView.contentSize.width, auxPostViewY);
    
    [self.view layoutIfNeeded];
   
    if((self.mainFetchedResultsController == nil) || (!([[self.mainFetchedResultsController fetchedObjects] count] > 0)))
    {
        [self.mainCollectionView setHidden:YES];
    }
    else
    {
        [self.mainCollectionView setHidden:NO];
    }

    self.CommentsShadowView.layer.shadowOpacity = 0.3;
    self.CommentsShadowView.layer.shadowRadius = 2;
    self.CommentsShadowView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.CommentsShadowView.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.CommentsShadowView.clipsToBounds = NO;
    
    self.commentTextView.layer.borderWidth = 0.5;
    self.commentTextView.layer.borderColor = [UIColor grayColor].CGColor;
    
    _bVideoReviewing = NO;

    _addVideoToCommentButton.titleLabel.text = NSLocalizedString(@"_ADD_COMMENT_VIDEO_", nil);
    [_addVideoToCommentButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [_addVideoToCommentButton.titleLabel setMinimumScaleFactor:0.5];
    
    self.CommentsView.hidden = NO;
    [self.FashionistaPostView bringSubviewToFront:self.CommentsView];
}

-(void)setupCommentsCollection
{
    // Setup Collection View
    [self setupCollectionViewsWithCellTypes:[[NSMutableArray alloc] initWithObjects:@"CommentCell", nil]];
    
    // Check if there are comments
    if([self initFetchedResultsControllerForCollectionViewWithCellType:@"CommentCell" WithEntity:@"Comment" andPredicate:@"idComment IN %@" inArray:_postComments sortingWithKeys:[NSArray arrayWithObject:@"date"] ascending:NO andSectionWithKeyPath:nil])
    {
        for(Comment * comment in self.mainFetchedResultsController.fetchedObjects)
        {
            if(comment.userId && ![comment.userId isEqualToString:@""])
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:comment.userId, nil];
                [self performRestGet:GET_USER withParamaters:requestParameters];
            }
        }
        
    }
    
    [self initCollectionViewsLayout];
}

// OVERRIDE: Number of sections for the given collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfSectionsForCollectionViewWithCellType:(NSString *)cellType
{
    return 1;
}

// OVERRIDE: Return if the first section is empty and it should, therefore, be notified to the user
- (BOOL)shouldShowDecorationViewForCollectionView:(UICollectionView *)collectionView
{
    return NO;
}

// OVERRIDE: Return if the first section is empty and it should, therefore, be notified to the user
- (BOOL)shouldReportResultsforSection:(int)section
{
    return NO;
}

// OVERRIDE: Return the title to be shown in section header for a collection view
- (NSString *)getHeaderTitleForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

// OVERRIDE: Number of items in each section for the main collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfItemsInSection:(NSInteger)section forCollectionViewWithCellType:(NSString *)cellType
{
    if([cellType isEqualToString:@"CommentCell"])
    {
        return self.mainFetchedResultsController.fetchedObjects.count;
    }
    
    return 0;
}

// OVERRIDE: Return the content to be shown in a cell for a collection view
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if([cellType isEqualToString:@"CommentCell"])
    {
        Comment * comment = [self.mainFetchedResultsController objectAtIndexPath:indexPath];
        
        if(!comment.user)
        {
            if(!(comment.userId == nil))
            {
                if(!([comment.userId isEqualToString:@""]))
                {
                    _wardrobesFetchedResultsController = nil;
                    _wardrobesFetchRequest = nil;
                    
                    [self initFetchedResultsControllerWithEntity:@"User" andPredicate:@"idUser IN %@" inArray:[NSArray arrayWithObject:comment.userId] sortingWithKey:@"idUser" ascending:YES];
                    
                    if (!(_wardrobesFetchedResultsController == nil))
                    {
                        //NSMutableArray * userWardrobesElements = [[NSMutableArray alloc] init];
                        
                        for (int i = 0; i < [[_wardrobesFetchedResultsController fetchedObjects] count]; i++)
                        {
                            User * tmpUser = [[_wardrobesFetchedResultsController fetchedObjects] objectAtIndex:i];
                            comment.user = tmpUser;
                        }
                        
                        _wardrobesFetchedResultsController = nil;
                        _wardrobesFetchRequest = nil;
                    }
                }
            }
        }
        
        // Profile image
        // User name
        // User location
        // Comment text
        // Comment video
        return [NSArray arrayWithObjects: comment.user.picture, comment.user.fashionistaName, comment.location, comment.text, comment.video, nil];
    }

    return nil;
}

// OVERRIDE: Action to perform if an item in a collection view is selected
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if ([cellType isEqualToString:@"ContentCell"])
    {
        self.shownContent = [[self getFetchedResultsControllerForCellType:@"ContentCell"] objectAtIndexPath:indexPath];
        
        self.iSelectedContent = [indexPath indexAtPosition:1];
        [self setMainImageWithURLString:self.shownContent.url];
    }
    else if([cellType isEqualToString:@"CommentCell"])
    {
    }
     */
}

- (IBAction)onTapLikeButton:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    if (!(_currentUserLikesPost))
    {
        if (!(_shownPost == nil))
        {
            if (!(_shownPost.idFashionistaPost == nil))
            {
                if(!([_shownPost.idFashionistaPost isEqualToString:@""]))
                {
                    if (!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            NSLog(@"Liking post: %@", _shownPost.name);
                            
                            // Perform request to like post
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LIKING_USER_MSG_", nil)];
                            
                            // Post the PostLike object
                            
                            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            PostLike *newPostLike = [[PostLike alloc] initWithEntity:[NSEntityDescription entityForName:@"PostLike" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                            
                            [newPostLike setUserId:appDelegate.currentUser.idUser];
                            
                            [newPostLike setPostId:_shownPost.idFashionistaPost];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostLike, nil];
                            
                            [self performRestPost:LIKE_POST withParamaters:requestParameters];
                        }
                    }
                }
            }
        }
    }
    else
    {
        if (!(_shownPost == nil))
        {
            if (!(_shownPost.idFashionistaPost == nil))
            {
                if(!([_shownPost.idFashionistaPost isEqualToString:@""]))
                {
                    if (!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            NSLog(@"UNLiking post: %@", _shownPost.name);
                            
                            // Perform request to like post
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UNLIKING_USER_MSG_", nil)];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, _shownPost.idFashionistaPost, nil];
                            
                            [self performRestGet:UNLIKE_POST withParamaters:requestParameters];
                        }
                    }
                }
            }
        }
    }
}

- (void)setCommentScreenTopBottom
{
    [self setTopBarTitle:NSLocalizedString(@"_WRITE_COMMENT_", nil) andSubtitle:_shownPost.name];
}

- (IBAction)onTapAddCommentButton:(UIButton *)sender
{
    // Limipiamos el dialogo
    _temporalCommentURL = @"";
    _commentTextView.text = @"";
    _addVideoToCommentButton.titleLabel.text = NSLocalizedString(@"_ADD_COMMENT_VIDEO_", nil);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    // Initialize objects to get location data
    commentLocationManager = [[CLLocationManager alloc] init];
    commentGeocoder = [[CLGeocoder alloc] init];
    
    self.writeCommentView.hidden = NO;
    [self.view bringSubviewToFront:self.writeCommentView];
    [self bringBottomControlsToFront];
    [self bringTopBarToFront];
    
    [UIView transitionWithView:self.writeCommentView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:^ {
                        
                    }
                    completion:^(BOOL finished){

                        [self setCommentScreenTopBottom];
                        
                        [self getCurrentLocation];
                    }];
    
}

- (void)setPostScreenTopBottom
{
    [self setupPostTopView];
}

- (IBAction)onTapGetUsersLike:(UIButton *)sender {
    if (!(_postLikesNumber == nil))
    {
        if([_postLikesNumber intValue] > 0)
        {
            NSLog(@"Searching user like for Stylist: %@", _shownPost.idFashionistaPost);
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            NSString * currentFashionistaPostId = @"";
            
            if(_shownPost.idFashionistaPost)
            {
                if(!([_shownPost.idFashionistaPost isEqualToString:@""]))
                {
                    currentFashionistaPostId = _shownPost.idFashionistaPost;
                }
            }
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:currentFashionistaPostId, nil];
            
            [self performRestGet:PERFORM_SEARCH_USER_LIKE_POST withParamaters:requestParameters];
        }
    }

}

- (IBAction)onTapAddVideoToComment:(UIButton *)sender
{
    if(_temporalCommentURL && ![_temporalCommentURL isEqualToString:@""])
    {
        _commentTextSpaceConstraint.constant = 125;
        
        [UIView animateWithDuration:0.30
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             self.player.view.alpha = 0.0;
                             self.commentTextSpaceConstraint.constant = 125;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             UIView * pView = self.player.view;
                             [pView removeFromSuperview];
                             self.player = nil;
                         }];
        
        _temporalCommentURL = @"";
        _addVideoToCommentButton.titleLabel.text = NSLocalizedString(@"_ADD_COMMENT_VIDEO_", nil);
    }
    else
    {
        _bVideoReviewing = YES;
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"_SELECT_SOURCE_PHOTO_",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"_TAKE_VIDEO_", nil), NSLocalizedString(@"_CHOOSE_VIDEO_", nil), nil];
        
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

- (IBAction)onTapShowVideoComment:(UIButton *)sender
{
    Comment * comment = [self.mainFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
    
    if(comment)
    {
        NSString * moviePath = comment.video;
        
        if (moviePath)
        {
            [self uploadCommentView:comment];
            
            AVPlayer * player = [AVPlayer playerWithURL:[NSURL URLWithString:moviePath]];
            AVPlayerViewController *playerViewController = [AVPlayerViewController new];
            playerViewController.player = player;
            [playerViewController.player play];
            [self presentViewController:playerViewController animated:YES completion:nil];
        }
    }
}

- (void)uploadComment
{
    NSLog(@"Uploading comment...");
    
    // Check that the name is valid
    
    // Perform request to upload the comment
    
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGCOMMENT_ACTV_MSG_", nil)];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    Comment *newComment = [[Comment alloc] initWithEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];

    [newComment setFashionistaPostId:_shownPost.idFashionistaPost];
    [newComment setUserId:appDelegate.currentUser.idUser];
    [newComment setLocation:(((_currentUserLocation == nil) || ([_currentUserLocation isEqualToString:@""])) ? (NSLocalizedString(@"_COULDNT_RETRIEVE_USERLOCATION_", nil)) : (_currentUserLocation))];
    [newComment setText:self.commentTextView.text];
//    [newComment setDate:[NSDate date]];
    [newComment setVideo:_temporalCommentURL];
    // TODO: Properly manage LikeIt!
    [newComment setLikeIt:[NSNumber numberWithBool:YES]];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects: _shownPost.idFashionistaPost, newComment, nil];
    
    [self performRestPost:ADD_COMMENT_TO_POST withParamaters:requestParameters];
}

- (void)uploadComment:(NSString *)commentString
{
    NSLog(@"Uploading comment...");
    
    // Check that the name is valid
    
    // Perform request to upload the comment
    
    // Provide feedback to user
    if ([self.fashionistaPostDelegate respondsToSelector:@selector(showFeedbackActivity:)]) {
        [self.fashionistaPostDelegate showFeedbackActivity:NSLocalizedString(@"_UPLOADINGCOMMENT_ACTV_MSG_", nil)];
    }
//    [self stopActivityFeedback];
//    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGCOMMENT_ACTV_MSG_", nil)];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    Comment *newComment;
    if (_postCommentObjs != nil) {
        newComment = _postCommentObjs;
        [newComment setFashionistaPostId:_shownPost.idFashionistaPost];
        [newComment setUserId:appDelegate.currentUser.idUser];
        [newComment setLocation:(((_currentUserLocation == nil) || ([_currentUserLocation isEqualToString:@""])) ? (NSLocalizedString(@"_COULDNT_RETRIEVE_USERLOCATION_", nil)) : (_currentUserLocation))];
        [newComment setText:commentString];
        //    [newComment setDate:[NSDate date]];
        [newComment setVideo:_temporalCommentURL];
        // TODO: Properly manage LikeIt!
        [newComment setLikeIt:[NSNumber numberWithBool:YES]];
        NSLog(@"comment id %@", newComment.idComment);
        NSArray * requestParameters = [[NSArray alloc] initWithObjects: _shownPost.idFashionistaPost, newComment, [NSNumber numberWithBool:YES], nil];
        
        [self performRestPost:ADD_COMMENT_TO_POST withParamaters:requestParameters];
        [self.postActionArray addObject:@"ADD_COMMENT_TO_POST"];
    } else {
        newComment = [[Comment alloc] initWithEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
    
        [newComment setFashionistaPostId:_shownPost.idFashionistaPost];
        [newComment setUserId:appDelegate.currentUser.idUser];
        [newComment setLocation:(((_currentUserLocation == nil) || ([_currentUserLocation isEqualToString:@""])) ? (NSLocalizedString(@"_COULDNT_RETRIEVE_USERLOCATION_", nil)) : (_currentUserLocation))];
        [newComment setText:commentString];
        //    [newComment setDate:[NSDate date]];
        [newComment setVideo:_temporalCommentURL];
        // TODO: Properly manage LikeIt!
        [newComment setLikeIt:[NSNumber numberWithBool:YES]];
       
        NSArray * requestParameters = [[NSArray alloc] initWithObjects: _shownPost.idFashionistaPost, newComment, nil];
        
        [self performRestPost:ADD_COMMENT_TO_POST withParamaters:requestParameters];
        [self.postActionArray addObject:@"ADD_COMMENT_TO_POST"];

    }
    
}

- (void)deleteComment
{
    if (_postCommentObjs != nil) {
        Comment *theComment = _postCommentObjs;
        if ([self.fashionistaPostDelegate respondsToSelector:@selector(showFeedbackActivity:)]) {
            [self.fashionistaPostDelegate showFeedbackActivity:NSLocalizedString(@"_UPLOADINGCOMMENT_ACTV_MSG_", nil)];
        }
//        [self stopActivityFeedback];
//        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGCOMMENT_ACTV_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects: _shownPost.idFashionistaPost, theComment, nil];
        [self performRestDelete:DELETE_COMMENT withParamaters:requestParameters];
    }
}

- (void)closeWriteComment
{
    [self setPostScreenTopBottom];
    
    [UIView transitionWithView:self.writeCommentView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:^{
                        [self bringBottomControlsToFront];
                        [self bringTopBarToFront];
                        self.writeCommentView.hidden = YES;
                        _commentTextSpaceConstraint.constant = 125;
                        
                        if(self.player)
                        {
                            self.player.view.alpha = 0.0;
                        }
                    }
                    completion:^(BOOL finished){
                        if(self.player)
                        {
                            [self.player.view removeFromSuperview];
                            self.player = nil;
                        }
                    }];
}

-(BOOL) checkPostEditionBeforeTransition
{
    if(!(_bEditingMode))
    {
        return YES;
    }
    else if(!(_bEditingChanges))
    {
        if(_shownPost)
        {
            if((!_shownPost.fashionistaPageId || [_shownPost.fashionistaPageId isEqualToString:@""] ) || ((_shownFashionistaPostContent == nil) || ([_shownFashionistaPostContent count] < 1)))
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELPOSTEDITINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
                
                [alertView show];

                return NO;
            }
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELPOSTEDITINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

@end

