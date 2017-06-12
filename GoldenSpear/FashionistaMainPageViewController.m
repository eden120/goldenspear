//
//  FashionistaMainPageViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 22/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "FashionistaMainPageViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+CircleMenuManagement.h"
#import "BaseViewController+UserManagement.h"


#import "UIButton+CustomCreation.h"
#import "NSString+ValidateURL.h"

#import "ProductSheetViewController.h"
#import "WardrobeContentViewController.h"
#import "SearchBaseViewController.h"
#import "AddItemToWardrobeViewController.h"

#define kOffsetForBottomScroll 10
#define kDetailsViewShadowXOffset 0
#define kDetailsViewShadowYOffset 2
#define kDetailsViewShadowOpacity 0.5
#define kDetailsViewShadowRadius 4

#define kFontInCreateViewDeleteButton "Avenir-Roman"
#define kFontSizeInCreateViewDeleteButton 18
#define kCreateViewDeleteButtonBorderWidth 0.5
#define kCreateViewDeleteButtonBorderColor lightGrayColor
#define kCreateViewDeleteButtonsInset 10
#define kCreateViewDeleteButtonsHeight 30



@interface FashionistaMainPageViewController ()

@end

@implementation FashionistaMainPageViewController


BOOL _bLoadsMoreContents = NO;
BOOL _bEditedChanges = NO;
BOOL _bHeaderImageDidChange = NO;
BOOL _bContinuesUpdating = YES;
BOOL _bEditPost = NO;
FashionistaPage * _uploadedPage;

UIButton * headerImageButton;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    _selectedPost = nil;
    _selectedPostToDelete = nil;
    
    if((_bEditionMode == YES) & (_shownFashionistaPage == nil))
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (!(appDelegate.currentUser == nil))
        {
            if(!(appDelegate.currentUser.idUser == nil))
            {
                if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                    
                    _creatingFashionistaPage = [[FashionistaPage alloc] initWithEntity:[NSEntityDescription entityForName:@"FashionistaPage" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                    
                    [_creatingFashionistaPage setUser:appDelegate.currentUser];
                    [_creatingFashionistaPage setUserId:appDelegate.currentUser.idUser];
                    [_creatingFashionistaPage setLocation:appDelegate.currentUser.addressCity];
                    [_creatingFashionistaPage setBlogURL:@""];
                    [_creatingFashionistaPage setCategory:@""];
                    [_creatingFashionistaPage setGroup:@""];
                    [_creatingFashionistaPage setSubcategory:@""];
                    [_creatingFashionistaPage setHeader_image:@""];
                    
                    //if (![currentContext save:nil])
                    {
                        NSLog(@"Save did not complete successfully.");
                    }
                }
            }
        }
    }
    else
    {
        _creatingFashionistaPage = nil;
    }
    
    // Setup Fashionista Header Image View
    [self setupFashionistaTopView];
    
    // Setup Fashionista Header Image View
    [self setupFashionistaHeaderImageView];
    
    // Setup Fashionista Details View
    [self setupFashionistaDetailsView];
    
    // Init collection views cell types
    [self setupCollectionViewsWithCellTypes:[[NSMutableArray alloc] initWithObjects:@"PostCell", nil]];
    
    // Setup the Main Collection View background image
//    [self setupBackgroundImage];
    
    // Initialize results array
    if (_postsArray == nil)
    {
        _postsArray = [[NSMutableArray alloc] init];
    }
    
    // Initialize results groups array
    if (_postsGroups == nil)
    {
        _postsGroups = [[NSMutableArray alloc] init];
    }
    
    // Check if there are results
    [self initFetchedResultsControllerForCollectionViewWithCellType:@"PostCell" WithEntity:@"FashionistaPost" andPredicate:@"idFashionistaPost IN %@" inArray:_postsArray sortingWithKeys:[NSArray arrayWithObject:@"order"] ascending:NO andSectionWithKeyPath:nil];
    
    // Setup Collection View
    [self initCollectionViewsLayout];
    
    // Get the Fashionista Page posts
    [self getPagePosts];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
    if ([self getFetchedResultsControllerForCellType:@"PostCell" ] == nil)
    {
        [self initFetchedResultsControllerForCollectionViewWithCellType:@"PostCell" WithEntity:@"FashionistaPost" andPredicate:@"idFashionistaPost IN %@" inArray:_postsArray sortingWithKeys:[NSArray arrayWithObject:@"order"] ascending:NO andSectionWithKeyPath:nil];
    }
    
    // Update Fetched Results Controller
    [self performFetchForCollectionViewWithCellType:@"PostCell"];
    
    // Update collection view
    [self updateCollectionViewWithCellType:@"PostCell" fromItem:0 toItem:-1 deleting:FALSE];
    
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
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void) setupFashionistaTopView
{
    if (_bEditionMode == YES)
    {
        // Top bar title
        NSString * title = NSLocalizedString(@"_ADD_TITLE_", nil);

        if (!(_shownFashionistaPage == nil))
        {
            if(!(_shownFashionistaPage.title == nil))
            {
                if(!([_shownFashionistaPage.title isEqualToString:@""]))
                {
                    // Set top bar title
                    title = _shownFashionistaPage.title;
                }
            }
        }
        
        // Top bar subtitle
        NSString * subtitle = NSLocalizedString(@"_FASHIONISTA_PAGE_", nil);
        
        if(!(_shownFashionistaPage.user.name == nil))
        {
            if(!([_shownFashionistaPage.user.name isEqualToString:@""]))
            {
                subtitle = ([NSString stringWithFormat:NSLocalizedString(@"_FASHIONISTA_PAGE_BY", nil), [_shownFashionistaPage.user fashionistaName]]);
            }
        }
        else if(!(_creatingFashionistaPage.user.name == nil))
        {
            if(!([_creatingFashionistaPage.user.name isEqualToString:@""]))
            {
                subtitle = ([NSString stringWithFormat:NSLocalizedString(@"_FASHIONISTA_PAGE_BY", nil), [_creatingFashionistaPage.user fashionistaName]]);
            }
        }

        // Set top bar title and subtitle
        [self setTopBarTitle:title andSubtitle:subtitle];
    }
    else
    {
        if (!(_shownFashionistaPage == nil))
        {
            if(!(_shownFashionistaPage.title == nil))
            {
                if(!([_shownFashionistaPage.title isEqualToString:@""]))
                {
                    // Set top bar title
                    [self setTopBarTitle:_shownFashionistaPage.title andSubtitle:nil];
                }
            }
            
            // Get Fashionista Name
            [self getFashionistaPageAuthor];
        }
    }
}

- (void) setupFashionistaHeaderImageView
{
    // Header Image button title
    NSString * headerImageButtonText = NSLocalizedString(@"_ADD_HEADER_IMAGE_", nil);

    if (!(_shownFashionistaPage.header_image == nil))
    {
        if (!([_shownFashionistaPage.header_image isEqualToString:@""]))
        {
            headerImageButtonText = NSLocalizedString(@"_EDIT_HEADER_IMAGE_", nil);
            
            // Init the activity indicator
            UIActivityIndicatorView *imgViewActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            // Position and show the activity indicator
            
            [imgViewActivityIndicator setCenter:_fashionistaHeaderImageView.center];
            
            [imgViewActivityIndicator setHidesWhenStopped:YES];
            
            [imgViewActivityIndicator startAnimating];
            
            [_fashionistaHeaderImageView addSubview: imgViewActivityIndicator];

            if ([UIImage isCached:_shownFashionistaPage.header_image])
            {
                UIImage * image = [UIImage cachedImageWithURL:_shownFashionistaPage.header_image];
                
                if(image == nil)
                {
                    image = [UIImage imageNamed:@"no_image.png"];
                }
                
                [_fashionistaHeaderImageView setImage:image];
                
                [imgViewActivityIndicator stopAnimating];
            }
            else
            {
                // Load image in the background
                
                __weak FashionistaMainPageViewController *weakSelf = self;
                
                NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                    
                    UIImage * image = [UIImage cachedImageWithURL:_shownFashionistaPage.header_image];
                    
                    if(image == nil)
                    {
                        image = [UIImage imageNamed:@"no_image.png"];
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // Then set image via the main queue
                        [weakSelf.fashionistaHeaderImageView setImage:image];
                        
                        [weakSelf.fashionistaHeaderImageView setImage:image];
                        
                        [imgViewActivityIndicator stopAnimating];
                    });
                }];
                
                operation.queuePriority = NSOperationQueuePriorityHigh;
                
                [self.imagesQueue addOperation:operation];
            }
        }
    }
    
    // Header Image button
    
    if (_bEditionMode)
    {
         headerImageButton = [UIButton createButtonWithOrigin:CGPointMake(self.fashionistaHeaderImageView.frame.origin.x + kCreateViewDeleteButtonsInset, self.fashionistaHeaderImageView.frame.origin.y + (((self.fashionistaHeaderImageView.frame.size.height - kCreateViewDeleteButtonsHeight) / 2)))
         andSize:CGSizeMake(self.view.frame.size.width - (2 * kCreateViewDeleteButtonsInset), kCreateViewDeleteButtonsHeight)
         andBorderWidth:kCreateViewDeleteButtonBorderWidth
         andBorderColor:[UIColor kCreateViewDeleteButtonBorderColor]
         andText:headerImageButtonText
         andFont:[UIFont fontWithName:@kFontInCreateViewDeleteButton size:kFontSizeInCreateViewDeleteButton]
         andFontColor:[UIColor blackColor]
         andUppercasing:NO
         andAlignment:UIControlContentHorizontalAlignmentCenter
         andImage:nil
         andImageMode:UIViewContentModeScaleAspectFit
         andBackgroundImage:nil];

        [headerImageButton setBackgroundColor:[UIColor whiteColor]];
        [headerImageButton setAlpha:0.7];

        // Button action
        [headerImageButton addTarget:self action:@selector(headerImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // Add button to view
        [self.view addSubview:headerImageButton];
        [self.view bringSubviewToFront:headerImageButton];
    }
}

- (void) setupFashionistaDetailsView
{
    self.fashionistaDetailsView.clipsToBounds = NO;
    self.fashionistaDetailsView.layer.shadowOffset = CGSizeMake(kDetailsViewShadowXOffset, kDetailsViewShadowYOffset);
    self.fashionistaDetailsView.layer.shadowOpacity = kDetailsViewShadowOpacity;
    self.fashionistaDetailsView.layer.shadowRadius = kDetailsViewShadowRadius;

    // Fashionista Location & Blog URL
    
    [_fashionistaDetailsTitle setTitle:@"" forState:UIControlStateNormal];

    if(!(_shownFashionistaPage == nil))
    {
        if(!(_shownFashionistaPage.location == nil))
        {
            if(!([_shownFashionistaPage.location isEqualToString:@""]))
            {
                [_fashionistaDetailsTitle setTitle:_shownFashionistaPage.location forState:UIControlStateNormal];
            }
        }
        
        NSString * url = @"";
        
        if (!(_shownFashionistaPage.blogURL == nil))
        {
            if(!([_shownFashionistaPage.blogURL isEqualToString:@""]))
            {
                url = _shownFashionistaPage.blogURL;
            }
        }
        
        if(!([url isEqualToString:@""]))
        {
            if([[_fashionistaDetailsTitle titleForState:UIControlStateNormal] isEqualToString:@""])
            {
                [_fashionistaDetailsTitle setTitle:url forState:UIControlStateNormal];
            }
            else
            {
                [_fashionistaDetailsTitle setTitle:[_fashionistaDetailsTitle.titleLabel.text stringByAppendingString:[NSString stringWithFormat:@"  -  %@", url]] forState:UIControlStateNormal];
            }
        }
        else if (_bEditionMode)
        {
            if([[_fashionistaDetailsTitle titleForState:UIControlStateNormal] isEqualToString:@""])
            {
                [_fashionistaDetailsTitle setTitle:NSLocalizedString(@"_ADD_URL_", nil) forState:UIControlStateNormal];
            }
            else
            {
                [_fashionistaDetailsTitle setTitle:[_fashionistaDetailsTitle.titleLabel.text stringByAppendingString:[NSString stringWithFormat:@"  -  %@", NSLocalizedString(@"_ADD_URL_", nil)]] forState:UIControlStateNormal];
            }
        }
    }
    else if(!(_creatingFashionistaPage == nil))
    {
        if(!(_creatingFashionistaPage.location == nil))
        {
            if(!([_creatingFashionistaPage.location isEqualToString:@""]))
            {
                [_fashionistaDetailsTitle setTitle:_creatingFashionistaPage.location forState:UIControlStateNormal];
            }
        }
        
        if([[_fashionistaDetailsTitle titleForState:UIControlStateNormal] isEqualToString:@""])
        {
            [_fashionistaDetailsTitle setTitle:NSLocalizedString(@"_ADD_URL_", nil) forState:UIControlStateNormal];
        }
        else
        {
            [_fashionistaDetailsTitle setTitle:[_fashionistaDetailsTitle.titleLabel.text stringByAppendingString:[NSString stringWithFormat:@"  -  %@", NSLocalizedString(@"_ADD_URL_", nil)]] forState:UIControlStateNormal];
        }
    }

    // Fashionista's Title
    
    if(!(_shownFashionistaPage.user == nil))
    {
        if(!(_shownFashionistaPage.user.fashionistaTitle == nil))
        {
            if(!([_shownFashionistaPage.user.fashionistaTitle isEqualToString:@""]))
            {
                _fashionistaDetailsAuthorTitle.text = _shownFashionistaPage.user.fashionistaTitle;
            }
        }
    }
    
    // Post types buttons
    
    if(!(_shownFashionistaPage.wardrobesPostNumber == nil))
    {
        [_fashionistaDetailsWardrobesButton setTitle:[_shownFashionistaPage.wardrobesPostNumber stringValue] forState:UIControlStateNormal];
    }
    
    if(!(_shownFashionistaPage.articlesPostNumber == nil))
    {
        [_fashionistaDetailsArticlesButton setTitle:[_shownFashionistaPage.articlesPostNumber stringValue] forState:UIControlStateNormal];
    }
    
    if(!(_shownFashionistaPage.tutorialsPostNumber == nil))
    {
        [_fashionistaDetailsTutorialsButton setTitle:[_shownFashionistaPage.tutorialsPostNumber stringValue] forState:UIControlStateNormal];
    }
}

- (void)showFashionistaDetailsView
{
    if(!([_fashionistaDetailsView isHidden]))
    {
        return;
    }
    
    CGFloat offset = 187;//((self.view.frame.size.height)*((IS_IPHONE_4_OR_LESS) ? (0.52) : (0.48)));
    
    // Show Add Terms text field and set the focus
    //    [self.view bringSubviewToFront:_TextFieldsUpperView];
    [_fashionistaDetailsView setHidden:NO];
    [headerImageButton setHidden:NO];
    
    CGFloat constant = self.fashionistaDetailsViewTopConstraint.constant;
    
    CGFloat newConstant = constant + offset;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.fashionistaDetailsViewTopConstraint.constant = newConstant;
                         
                         [_fashionistaDetailsView setAlpha:0.98];

                         [headerImageButton setAlpha:0.98];
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)hideFashionistaDetailsView
{
    if([_fashionistaDetailsView isHidden])
    {
        return;
    }
    
    if(_fashionistaDetailsView.alpha < 0.98)
    {
        return;
    }
    
    CGFloat offset = -187;//((self.view.frame.size.height)*((IS_IPHONE_4_OR_LESS) ? (0.52) : (0.48)));
    
    [self.view endEditing:YES];
    
    CGFloat constant = self.fashionistaDetailsViewTopConstraint.constant;
    
    CGFloat newConstant = constant + offset;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.fashionistaDetailsViewTopConstraint.constant = newConstant;
                         
                         [_fashionistaDetailsView setAlpha:0.01];
                         
                         [headerImageButton setAlpha:0.01];
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                         [_fashionistaDetailsView setHidden:YES];
                         [headerImageButton setHidden:YES];
                         
                     }];
}

// OVERRIDE: Action to perform when user swipes to right: go to previous screen
- (void)panGesture:(UIPanGestureRecognizer *)sender
{
    CGPoint velocity = [sender velocityInView:self.view];
    
    CGPoint translation = [sender translationInView:self.view];
    
    CGFloat widthPercentage  = fabs(translation.x / CGRectGetWidth(sender.view.bounds));
    
    CGFloat heightPercentage  = fabs(translation.y / CGRectGetHeight(sender.view.bounds));
    
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        // Perform the transition when swipe right
        if (velocity.x > 0)
        {
            if(widthPercentage > 0.3)
            {
                [self swipeRightAction];
            }
        }
        
        // Perform the transition when swipe left
        if (velocity.x < 0)
        {
            if(widthPercentage > 0.3)
            {
                [self swipeLeftAction];
            }
        }
        
        // Hide the advanced search when swipe up
        if (velocity.y > 0)
        {
            if(heightPercentage > 0.1)
            {
                [self swipeDownAction];
            }
        }
    }
}

// Action to perform when user swipes down
- (void)swipeDownAction
{
    [self showFashionistaDetailsView];
}


#pragma mark - Collection view methods


// Setup Main Collection View background image
- (void) setupBackgroundImage
{
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:nil];
    
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [backgroundImageView setBackgroundColor:[UIColor clearColor]];
    
    [backgroundImageView setAlpha:1.00];
    
    [backgroundImageView setImage:[UIImage imageNamed:@"Splash_Background.png"]];
    
    [backgroundImageView setUserInteractionEnabled:YES];
    
//    [backgroundImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAddSearchTerm)]];
    
    [self.mainCollectionView setBackgroundView:backgroundImageView];
}

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

// Check if the item is in the current user list of wardrobes
- (BOOL) doesCurrentUserWardrobesContainItemWithId:(FashionistaPost *)item
{
    NSString * itemId = @"";
    
    if (!(item == nil))
    {
        if(!(item.idFashionistaPost == nil))
        {
            if(!([item.idFashionistaPost isEqualToString:@""]))
            {
                itemId = item.idFashionistaPost;
            }
        }
    }
    
    if (!([itemId isEqualToString:@""]))
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
                                    if ([tmpGSBaseElement.fashionistaPostId isEqualToString:itemId])
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

// OVERRIDE: Number of sections for the given collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfSectionsForCollectionViewWithCellType:(NSString *)cellType
{
    if ([cellType isEqualToString:@"PostCell"])
    {
        if(_bEditionMode)
        {
            if(_shownFashionistaPage == nil)
            {
                return 0;
            }
            
            return MAX([[[self getFetchedResultsControllerForCellType:cellType] sections] count], 1);
        }

        return [[[self getFetchedResultsControllerForCellType:cellType] sections] count];
    }
    
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

// OVERRIDE: Number of items in each section for the main collection view
- (NSInteger)numberOfItemsInSection:(NSInteger)section forCollectionViewWithCellType:(NSString *)cellType
{
    if ([cellType isEqualToString:@"PostCell"])
    {
        int iNum = (int)[[[self getFetchedResultsControllerForCellType:cellType] sections][section] numberOfObjects];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        return iNum+((_bEditionMode)*(!(appDelegate.currentUser == nil))); // One extra item for "Add post" option
    }
    
    return 0;
}

// OVERRIDE: Return the size of the image to be shown in a cell for a collection view
- (CGSize)getSizeForImageInCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"PostCell"])
    {
        int iNum = (int)[[[self getFetchedResultsControllerForCellType:cellType] fetchedObjects] count];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        iNum += ((_bEditionMode)*(!(appDelegate.currentUser == nil))); // One extra item for "Add post" option
        
        int iLast = iNum-1;
        
        int iIdx = (int)[indexPath indexAtPosition:1];
        
        if((_bEditionMode) & (iIdx == iLast))
        {
            return CGSizeMake(0, 0);
        }
        else
        {
            FashionistaPost *tmpPost = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];
            
            return CGSizeMake([tmpPost.preview_image_width intValue], [tmpPost.preview_image_height intValue]);
        }
    }
    
    return CGSizeMake(0, 0);
}

// OVERRIDE: Return the content to be shown in a cell for a collection view
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"PostCell"])
    {
        int iNum = (int)[[[self getFetchedResultsControllerForCellType:cellType] fetchedObjects] count];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        iNum += ((_bEditionMode)*(!(appDelegate.currentUser == nil))); // One extra item for "Add post" option
        
        int iLast = iNum-1;
        
        int iIdx = (int)[indexPath indexAtPosition:1];
        
        if((_bEditionMode) & (iIdx == iLast))
        {
            NSArray * cellContent = [NSArray arrayWithObjects: [NSNumber numberWithInt:0], @"", [NSNumber numberWithBool:NO], @"", @"", nil];
            return cellContent;
        }
        else
        {
            int iMode = 1;
            
            if(_bEditionMode)
            {
                iMode = 2;
            }
            
            FashionistaPost *tmpPost = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];
            
            NSString * cellTitle = [NSString stringWithFormat:@"%@", tmpPost.name];
            
//            if(!((tmpPost.user.name == nil) || ([tmpPost.user.name  isEqualToString:@""])))
            if(!((_shownFashionistaPage.user.name == nil) || ([_shownFashionistaPage.user.name  isEqualToString:@""])))
            {
                cellTitle = ([NSString stringWithFormat:NSLocalizedString(@"_AUTHOR_AND_TITLE_", nil), _shownFashionistaPage.user.name, ((_shownFashionistaPage.blogURL == nil) ? (@"") : (_shownFashionistaPage.blogURL))]);//tmpPost.mainInformation, tmpPost.name]);
            }

            NSArray * cellContent = [NSArray arrayWithObjects: [NSNumber numberWithInt:iMode], tmpPost.preview_image, [NSNumber numberWithBool:[self doesCurrentUserWardrobesContainItemWithId:tmpPost]], cellTitle, tmpPost.name, nil];
            
            return cellContent;
        }
    }
    
    return nil;
}

// OVERRIDE: Action to perform if an item in a collection view is selected
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if(![[self activityIndicator] isHidden])
        return;
    
    if ([cellType isEqualToString:@"PostCell"])
    {
        int iNum = (int)[[[self getFetchedResultsControllerForCellType:cellType] fetchedObjects] count];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        iNum += ((_bEditionMode)*(!(appDelegate.currentUser == nil))); // One extra item for "Add wardrobe" option
        
        int iLast = iNum-1;
        
        int iIdx = (int)[indexPath indexAtPosition:1];
        
        if((_bEditionMode) & (iIdx == iLast))
        {
            return;
        }
        else
        {
            _selectedPost = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
            
            // Perform request to get its properties from GS server
            if(!(_selectedPost.idFashionistaPost == nil))
            {
                if(!([_selectedPost.idFashionistaPost isEqualToString:@""]))
                {
                    // Perform request to get the result contents
                    NSLog(@"Getting contents for Fashionista post: %@", _selectedPost.name);
                    
                    _bEditPost = NO;

                    // Provide feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:_selectedPost.idFashionistaPost, nil];
                    
                    [self performRestGet:GET_POST withParamaters:requestParameters];
                }
            }
        }
    }
}

- (void)onTapAddToWardrobeButton:(UIButton *)sender
{
//    return;
    
    if(![[self activityIndicator] isHidden])
        return;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    FashionistaPost *selectedResult = [[self getFetchedResultsControllerForCellType:@"PostCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:(sender.tag - (((int)(sender.tag/OFFSET))*OFFSET)) inSection:((int)(sender.tag/OFFSET))]];
    
    if (!([self doesCurrentUserWardrobesContainItemWithId:selectedResult]))
    {
        // Instantiate the 'AddItemToWardrobe' view controller within the container view
        
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
                if ([selectedResult isKindOfClass:[FashionistaPost class]])
                {
                    [addItemToWardrobeVC setPostToAdd:(FashionistaPost *)selectedResult];
                }
//                else
//                {
//                    [addItemToWardrobeVC setItemToAdd:selectedResult];
//                }
                
                
                [addItemToWardrobeVC setButtonToHighlight:sender];
                
                [self addChildViewController:addItemToWardrobeVC];
                
                //[addItemToWardrobeVC willMoveToParentViewController:self];
                
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

- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL) bSuccess
{
    if ((bSuccess) && (!(button == nil)))
    {
        // Change the hanger button imageç
        UIImage * buttonImage = [UIImage imageNamed:@"hanger_checked.png"];
        
        if (!(buttonImage == nil))
        {
            [button setImage:buttonImage forState:UIControlStateNormal];
            [button setImage:buttonImage forState:UIControlStateHighlighted];
            [[button imageView] setContentMode:UIViewContentModeScaleAspectFit];
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
                }
            }
        }
    }
    
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    
    [[_addToWardrobeVCContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    //[[self.childViewControllers lastObject] didMoveToParentViewController:nil];
    
    [_addToWardrobeVCContainerView setHidden:YES];
    
    [_addToWardrobeBackgroundView setHidden:YES];
}

- (IBAction)analyticsPushed:(UIButton*)sender {
}

- (IBAction)continousButtonPushed:(UIButton*)sender {
}

- (IBAction)infoButtonPushed:(UIButton*)sender {
}

- (IBAction)wardrobeButtonPushed:(UIButton *)sender {
}

- (IBAction)mailButtonPushed:(UIButton *)sender {
}

- (IBAction)calendarButtonPushed:(UIButton *)sender {
}

// OVERRIDE: Just to prevent from being at the 'Add to Wardrobe' view
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!([_addToWardrobeVCContainerView isHidden]))
        return;
    
    [super touchesEnded:touches withEvent:event];
    
}

#pragma mark - Requests

// Check if arrived to the end of the collection view and, if so, request more results
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Check if the upper view should be shown
    if (0 < scrollView.contentOffset.y)
    {
        [self hideFashionistaDetailsView];
    }
    
    // Check if the resuts reload should be performed
    if (scrollView.contentOffset.y <= 0)
    {
        [self showFashionistaDetailsView];
    }
    
    // Check if the resuts reload should be performed
    if ((_bContinuesUpdating) && (scrollView.contentOffset.y >= roundf((scrollView.contentSize.height-scrollView.frame.size.height)+kOffsetForBottomScroll)))
    {
        // Do it only if the total number of results is not achieved yet and a search is not already taking place
        if ([[self activityLabel] isHidden])
        {
            _bLoadsMoreContents = YES;
            [self updateSearch];
        }
    }
}

// Get the author of the current page
- (void)getFashionistaPageAuthor
{
    if (!(_shownFashionistaPage.idFashionistaPage == nil))
    {
        if (!([_shownFashionistaPage.idFashionistaPage isEqualToString:@""]))
        {
            NSLog(@"Getting Fashionista Author for the Page titled: %@", _shownFashionistaPage.title);
            
            // Perform request to get the Fashionista Author
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownFashionistaPage.idFashionistaPage, nil];
            
            [self performRestGet:GET_FASHIONISTAPAGE_AUTHOR withParamaters:requestParameters];
        }
    }
}

// Perform search with a new set of search terms
- (void)getPagePosts
{
    if (!(_shownFashionistaPage.idFashionistaPage == nil))
    {
        if (!([_shownFashionistaPage.idFashionistaPage isEqualToString:@""]))
        {
            NSLog(@"Retrieving Page Posts");
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownFashionistaPage.idFashionistaPage, [NSNumber numberWithInteger:0], nil];
            
            [self performRestGet:GET_FASHIONISTAPAGE_POSTS withParamaters:requestParameters];
        }
    }
}

// Update search with more results
- (void)updateSearch
{
    if (!(_shownFashionistaPage.idFashionistaPage == nil))
    {
        if (!([_shownFashionistaPage.idFashionistaPage isEqualToString:@""]))
        {
            NSLog(@"Retrieving More Page Posts");
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownFashionistaPage.idFashionistaPage, [NSNumber numberWithInteger:[_postsArray count]], nil];
            
            [self performRestGet:GET_FASHIONISTAPAGE_POSTS withParamaters:requestParameters];
        }
    }
}

// Delete Post
- (void)deletePost:(FashionistaPost *)post
{
    // Check if user is signed in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        NSLog(@"Deleting post: %@", post.name);
        
        // Check that the id is valid
        
        if (!(post == nil))
        {
            if (!(post.idFashionistaPost == nil))
            {
                if (!([post.idFashionistaPost isEqualToString:@""]))
                {
                    // Perform request to delete
                    
                    // Provide feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DELETINGPOST_MSG_", nil)];
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:post, nil];
                    
                    [self performRestDelete:DELETE_POST withParamaters:requestParameters];
                    
                }
            }
        }
    }
}

// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    NSString * subtitle = NSLocalizedString(@"_FASHIONISTA_PAGE_", nil);
    NSMutableArray * postContent = [[NSMutableArray alloc] init];
    NSArray * parametersForNextVC = nil;
    int postsBeforeUpdate = (int)[[[self getFetchedResultsControllerForCellType:@"PostCell"] fetchedObjects] count];
    __block id selectedSpecificPost;
    NSManagedObjectContext *currentContext;
    __block FashionistaPage * mappedUploadedPage;

    switch (connection)
    {
        case GET_FASHIONISTAPAGE_AUTHOR:
        {
            // Get the list of items that were provided to fill the Wardrobe.itemsId property
            for (User *author in mappingResult)
            {
                if([author isKindOfClass:[User class]])
                {
                    if(!(author.name== nil))
                    {
                        if(!([author.name isEqualToString:@""]))
                        {
                            subtitle = ([NSString stringWithFormat:NSLocalizedString(@"_FASHIONISTA_PAGE_BY", nil), [author fashionistaName]]);
                        }
                    }
                }
            }

            // Set top bar title
            [self setTopBarTitle:_shownFashionistaPage.title andSubtitle:subtitle];

            [self stopActivityFeedback];
            
            break;
        }
        case GET_USER_WARDROBES_CONTENT:
        {
            //Reset the fetched results controller to fetch the current user wardrobes
            
            _wardrobesFetchedResultsController = nil;
            _wardrobesFetchRequest = nil;
            
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
                    
                    [self updateCollectionViewWithCellType:@"PostCell" fromItem:0 toItem:-1 deleting:NO];
                }
            }
            
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
                            selectedSpecificPost = (FashionistaPost *)post;
                            
                            break;
                        }
                    }
                }
            }
            
            // Get the list of contents that were provided
            for (FashionistaContent *content in mappingResult)
            {
                if([content isKindOfClass:[FashionistaContent class]])
                {
                    if(!(content.idFashionistaContent == nil))
                    {
                        if  (!([content.idFashionistaContent isEqualToString:@""]))
                        {
                            if(!([postContent containsObject:content]))
                            {
                                [postContent addObject:content];
                            }
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: _selectedPost, selectedSpecificPost, postContent, [NSNumber numberWithBool:_bEditPost], ((_bEditPost) ? (_shownFashionistaPage) : (nil)), nil];
            
            [self stopActivityFeedback];
            
            
            if((!([parametersForNextVC count] < 2)) && ([postContent count] > 0))
            {
                [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
            }
            
            _bEditPost = NO;
            
            break;
        }
        case UPLOAD_FASHIONISTAPAGE:
        {
            if (_bHeaderImageDidChange)
            {
                // Post header image
                NSArray * requestParameters = [NSArray arrayWithObjects:_fashionistaHeaderImageView.image, (((!(_shownFashionistaPage == nil)) && (!([_shownFashionistaPage.idFashionistaPage isEqualToString:@""]))) ? (_shownFashionistaPage.idFashionistaPage) : (((!(_creatingFashionistaPage == nil)) && (!([_creatingFashionistaPage.idFashionistaPage isEqualToString:@""]))) ? (_creatingFashionistaPage.idFashionistaPage) : (nil))), nil];
                
                if([requestParameters count] == 2)
                {
                    [self performRestPost:UPLOAD_FASHIONISTAPAGE_IMAGE withParamaters:requestParameters];
                    
                    if(!(_creatingFashionistaPage == nil))
                    {
                        // Get the page that was provided
                        for (FashionistaPage *page in mappingResult)
                        {
                            if([page isKindOfClass:[FashionistaPage class]])
                            {
                                if(!(page.idFashionistaPage == nil))
                                {
                                    if  (!([page.idFashionistaPage isEqualToString:@""]))
                                    {
                                        mappedUploadedPage = (FashionistaPage *)page;
                                        
                                        break;
                                    }
                                }
                            }
                        }
                        
                        if(!(mappedUploadedPage == nil))
                        {
                            _uploadedPage = mappedUploadedPage;
                        }
                    }
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_NO_FASHIONISTAPAGEHEADERIMAGEUPLOAD_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                    
                    [self stopActivityFeedback];
                }
            }
            else
            {
                if(!(_creatingFashionistaPage == nil))
                {
                    // Get the page that was provided
                    for (FashionistaPage *page in mappingResult)
                    {
                        if([page isKindOfClass:[FashionistaPage class]])
                        {
                            if(!(page.idFashionistaPage == nil))
                            {
                                if  (!([page.idFashionistaPage isEqualToString:@""]))
                                {
                                    mappedUploadedPage = (FashionistaPage *)page;
                                    
                                    break;
                                }
                            }
                        }
                    }
                    
                    if(!(mappedUploadedPage == nil))
                    {
                        if(_shownFashionistaPage == nil)
                        {
                            _shownFashionistaPage = mappedUploadedPage;
                            _creatingFashionistaPage = nil;
                        }
                    }
                }

                _bEditedChanges = NO;
                
                [self updateCollectionViewWithCellType:@"PostCell" fromItem:0 toItem:-1 deleting:NO];
                
                [self stopActivityFeedback];
                /*
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_FASHIONISTAPAGESUCCESSFULLYPOSTED_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
                 */
            }
            
            break;
        }
        case UPLOAD_FASHIONISTAPAGE_IMAGE:
        {
            if(!(_creatingFashionistaPage == nil))
            {
                if(!(_uploadedPage == nil))
                {
                    if(_shownFashionistaPage == nil)
                    {
                        _shownFashionistaPage = _uploadedPage;
                        _creatingFashionistaPage = nil;
                    }
                }
            }
            
            _bEditedChanges = NO;
            _bHeaderImageDidChange = NO;
            
            [self updateCollectionViewWithCellType:@"PostCell" fromItem:0 toItem:-1 deleting:NO];
            
            [self stopActivityFeedback];
            /*
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_FASHIONISTAPAGESUCCESSFULLYPOSTED_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
            */
            break;
        }
        case GET_WARDROBE:
        {
            // Get the wardrobe that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Wardrobe class]]))
                 {
                     selectedSpecificPost = (Wardrobe *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Get the list of items that were provided to fill the Wardrobe.itemsId property
            for (GSBaseElement *item in mappingResult)
            {
                if([item isKindOfClass:[GSBaseElement class]])
                {
                    if(!(item.idGSBaseElement== nil))
                    {
                        if(!([item.idGSBaseElement isEqualToString:@""]))
                        {
                            if(((Wardrobe*)selectedSpecificPost).itemsId == nil)
                            {
                                ((Wardrobe*)selectedSpecificPost).itemsId = [[NSMutableArray alloc] init];
                            }
                            
                            if(!([((Wardrobe*)selectedSpecificPost).itemsId containsObject:item.idGSBaseElement]))
                            {
                                [((Wardrobe*)selectedSpecificPost).itemsId addObject:item.idGSBaseElement];
                            }
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects:((Wardrobe*)selectedSpecificPost), [NSNumber numberWithBool:YES], nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:WARDROBECONTENT_VC withParameters:parametersForNextVC];
            
            break;
        }
        case GET_FASHIONISTAPAGE_POSTS:
        {
            if([mappingResult count] > 0)
            {
                // Get the list of results that were provided
                for (FashionistaPost *post in mappingResult)
                {
                    if([post isKindOfClass:[FashionistaPost class]])
                    {
                        if(!(post.idFashionistaPost == nil))
                        {
                            if  (!([post.idFashionistaPost isEqualToString:@""]))
                            {
                                if(!([_postsArray containsObject:post.idFashionistaPost]))
                                {
                                    [_postsArray addObject:post.idFashionistaPost];
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                _bContinuesUpdating = NO;
            }

            
            // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
            if ([self getFetchedResultsControllerForCellType:@"PostCell" ] == nil)
            {
                [self initFetchedResultsControllerForCollectionViewWithCellType:@"PostCell" WithEntity:@"FashionistaPost" andPredicate:@"idFashionistaPost IN %@" inArray:_postsArray sortingWithKeys:[NSArray arrayWithObjects:@"order", nil]  ascending:YES andSectionWithKeyPath:nil];
            }
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:@"PostCell"];
            
            //int i = (int)[[[self getFetchedResultsControllerForCellType:@"PostCell"] fetchedObjects] count];;
            
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"PostCell" fromItem:postsBeforeUpdate toItem:(int)[[[self getFetchedResultsControllerForCellType:@"PostCell"] fetchedObjects] count] deleting:FALSE];
            
            [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
            
            
            //Update top bar with number of results and terms
            
//            [self setTopBarTitle:nil andSubtitle:( ([_currentSearchQuery.numresults intValue] > 0) ? (([_currentSearchQuery.numresults intValue] > 1) ? ([NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULTS_", nil), [_currentSearchQuery.numresults intValue]]) : ([NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULT_", nil), [_currentSearchQuery.numresults intValue]])) : (NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil)))];
            
            [self stopActivityFeedback];
            
            break;
        }
        case DELETE_POST:
        {
            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            [currentContext deleteObject:_selectedPostToDelete];
            
            if (![currentContext save:nil])
            {
                NSLog(@"Save did not complete successfully.");
            }
            
            _selectedPostToDelete = nil;
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:@"PostCell"];
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"PostCell" fromItem:0 toItem:-1 deleting:FALSE];
            
            [self stopActivityFeedback];
            
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - Fashionista Webpage


- (IBAction)onTapVisitFashionistaWebSite:(UIButton *)sender
{
    if(_bEditionMode)
    {
        NSString * title = NSLocalizedString(@"_SETPAGEURL_", nil);
        NSString * message = NSLocalizedString(@"_SETPAGEURL_MSG_", nil);
        NSString * placeholder = NSLocalizedString(@"_SETPAGEURL_LBL_", nil);
        NSString * currentBlogURL = @"";
        
        if(!(_shownFashionistaPage == nil))
        {
            if(!(_shownFashionistaPage.blogURL == nil))
            {
                if(!([_shownFashionistaPage.blogURL isEqualToString:@""]))
                {
                    title = NSLocalizedString(@"_EDITPAGEURL_", nil);
                    message = NSLocalizedString(@"_EDITPAGEURL_MSG_", nil);
                    placeholder = NSLocalizedString(@"_EDITPAGEURL_LBL_", nil);
                    currentBlogURL = _shownFashionistaPage.blogURL;
                }
            }
        }
        else if(!(_creatingFashionistaPage == nil))
        {
            if(!(_creatingFashionistaPage.blogURL == nil))
            {
                if(!([_creatingFashionistaPage.blogURL isEqualToString:@""]))
                {
                    title = NSLocalizedString(@"_EDITPAGEURL_", nil);
                    message = NSLocalizedString(@"_EDITPAGEURL_MSG_", nil);
                    placeholder = NSLocalizedString(@"_EDITPAGEURL_LBL_", nil);
                    currentBlogURL = _creatingFashionistaPage.blogURL;
                }
            }
        }

        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_OK_", nil), nil];
        
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
        
        [alertView textFieldAtIndex:0].placeholder = placeholder;
        
        [alertView textFieldAtIndex:0].text = currentBlogURL;
        
        [alertView show];
    }
    else
    {
        if(!(_shownFashionistaPage == nil))
        {
            if (!(_shownFashionistaPage.blogURL == nil))
            {
                if(!([_shownFashionistaPage.blogURL isEqualToString:@""]))
                {
                    [self.fashionistaWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_shownFashionistaPage.blogURL]]];
                    
                    self.fashionistaWebView.hidden = NO;
                    [self.view bringSubviewToFront:self.fashionistaWebView];
                    [self bringBottomControlsToFront];
                    [self bringTopBarToFront];
                    
                    [UIView transitionWithView:self.fashionistaWebView
                                      duration:0.5
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:nil
                                    completion:^(BOOL finished){
                                    }];
                }
            }
            
        }
    }
}

- (void)closeFashionistaWebSite
{
    [UIView transitionWithView:self.fashionistaWebView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self bringBottomControlsToFront];
                        [self bringTopBarToFront];
                        self.fashionistaWebView.hidden = YES;
                    }
                    completion:^(BOOL finished){
                        [self.fashionistaWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
                    }];
    
}


#pragma mark - Fashionista Main Page EDIT


// OVERRIDE: Title button action
- (void)titleButtonAction:(UIButton *)sender
{
    NSString * title = NSLocalizedString(@"_SETPAGETITLE_", nil);
    NSString * message = NSLocalizedString(@"_SETPAGETITLE_MSG_", nil);
    NSString * placeholder = NSLocalizedString(@"_SETPAGETITLE_LBL_", nil);
    NSString * currenttitle = @"";
    
    if(_bEditionMode)
    {
        if(!(_shownFashionistaPage == nil))
        {
            if(!(_shownFashionistaPage.title == nil))
            {
                if(!([_shownFashionistaPage.title isEqualToString:@""]))
                {
                    title = NSLocalizedString(@"_EDITPAGETITLE_", nil);
                    message = NSLocalizedString(@"_EDITPAGETITLE_MSG_", nil);
                    placeholder = NSLocalizedString(@"_EDITPAGETITLE_LBL_", nil);
                    currenttitle = _shownFashionistaPage.title;
                }
            }
        }
        else if(!(_creatingFashionistaPage == nil))
        {
            if(!(_creatingFashionistaPage.title == nil))
            {
                if(!([_creatingFashionistaPage.title isEqualToString:@""]))
                {
                    title = NSLocalizedString(@"_EDITPAGETITLE_", nil);
                    message = NSLocalizedString(@"_EDITPAGETITLE_MSG_", nil);
                    placeholder = NSLocalizedString(@"_EDITPAGETITLE_LBL_", nil);
                    currenttitle = _creatingFashionistaPage.title;
                }
            }
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_OK_", nil), nil];
        
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
        
        [alertView textFieldAtIndex:0].placeholder = placeholder;

        [alertView textFieldAtIndex:0].text = currenttitle;

        [alertView show];
    }
}

- (void)headerImageButtonAction:(UIButton *)sender
{
    // Let user opt between take a photo or select from camera roll
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"_SELECT_SOURCE_PHOTO_",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"_TAKE_PHOTO_", nil), NSLocalizedString(@"_CHOOSE_PHOTO_", nil), nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

// Perform action to change user profile picture
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Prepare Image Picker
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;

    
//    imagePicker.allowsEditing = YES;
    
    switch (buttonIndex)
    {
        case 0: //Take photo
            
            // Ensure that device has camera
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_NO_CAMERA_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
                
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

// Image selected, now edit it
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];

    if(!(chosenImage == nil))
    {
//        ImageCropViewController *imageCropper = [[ImageCropViewController alloc] initWithImage:chosenImage];
//        
//        imageCropper.delegate = self;
//        imageCropper.blurredBackground = YES;
//        imageCropper.allowResizing = NO;
//        imageCropper.initialClearAreaSize = CGSizeMake(_fashionistaHeaderImageView.frame.size.width, _fashionistaHeaderImageView.frame.size.height);
//        [picker presentViewController:imageCropper animated:YES completion:nil];
    }
}

// In case user cancels changing image
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// The user finishes editing the image
//- (void)ImageCropViewController:(ImageCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
//{
//    if(!(_shownFashionistaPage == nil))
//    {
//        //_shownFashionistaPage.preview_image  = chosenImage;
//        _shownFashionistaPage.header_image_height = [NSNumber numberWithFloat:croppedImage.size.height];
//        _shownFashionistaPage.header_image_width = [NSNumber numberWithFloat:croppedImage.size.width];
//    }
//    else if(!(_creatingFashionistaPage == nil))
//    {
//        //    _creatingFashionistaPage.header_image = chosenImage;
//        _creatingFashionistaPage.header_image_height = [NSNumber numberWithFloat:_fashionistaHeaderImageView.frame.size.height];
//        _creatingFashionistaPage.header_image_width = [NSNumber numberWithFloat:_fashionistaHeaderImageView.frame.size.width];
//    }
//    
//    [_fashionistaHeaderImageView setImage:croppedImage];
//    
//    _bEditedChanges = YES;
//    _bHeaderImageDidChange = YES;
//
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//// In case user cancels editing image
//- (void)ImageCropViewControllerDidCancel:(ImageCropViewController *)controller
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

//Upload edited Fashionista Page
-(void)uploadFashionistaPage:(FashionistaPage *)editedPage
{
    if(!(editedPage == nil))
    {
        if((!(editedPage.userId == nil)) && (!([editedPage.userId isEqualToString:@""])))
        {
            if((!(editedPage.title == nil)) && (!([editedPage.title isEqualToString:@""])))
            {
                if(!(_fashionistaHeaderImageView.image == nil))
                {
//                    if( (!(editedPage.blogURL == nil)) && (!([editedPage.blogURL isEqualToString:@""])) )
//                    {
                        NSLog(@"Uploading fashionista page: %@", editedPage.title);
                        
                        // Provide feedback to user
                        [self stopActivityFeedback];
                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTAPAGE_MSG_", nil)];

                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:editedPage, [NSNumber numberWithBool:([editedPage.idFashionistaPage isEqualToString:_shownFashionistaPage.idFashionistaPage])], nil];
                        
                        [self performRestPost:UPLOAD_FASHIONISTAPAGE withParamaters:requestParameters];
//                    }
//                    else
//                    {
//                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_SHOULDSETBLOGURL_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
//                        
//                        [alertView show];
//                        
//                        return;
//                    }
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_SHOULDSETHEADERIMAGE_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
                    
                    [alertView show];
                    
                    return;
                }
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_SHOULDSETPAGETITLE_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
                
                [alertView show];
                
                return;
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_SHOULDSETUSERID_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
            
            [alertView show];
            
            return;
        }
    }
}

- (void)onTapCreateNewElement:(UIButton *)sender
{
    // Paramters for next VC (ResultsViewController)
    NSArray * parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], _shownFashionistaPage, nil];
    
    if(!([parametersForNextVC count] < 2))
    {
        [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
    }
}

- (void)onTapView:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
        return;

    _selectedPost = [[self getFetchedResultsControllerForCellType:@"PostCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
    
    // Perform request to get its properties from GS server
    if(!(_selectedPost.idFashionistaPost == nil))
    {
        if(!([_selectedPost.idFashionistaPost isEqualToString:@""]))
        {
            // Perform request to get the result contents
            NSLog(@"Getting contents for Fashionista post: %@", _selectedPost.name);
            
            _bEditPost = NO;

            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_selectedPost.idFashionistaPost, nil];
            
            [self performRestGet:GET_POST withParamaters:requestParameters];
        }
    }
}

// OVERRIDE: Action to perform if the user press the 'Edit' button on a PostCell
- (void)onTapEditElement:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
        return;
    
    _selectedPost = [[self getFetchedResultsControllerForCellType:@"PostCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
    
    // Perform request to get its properties from GS server
    if(!(_selectedPost.idFashionistaPost == nil))
    {
        if(!([_selectedPost.idFashionistaPost isEqualToString:@""]))
        {
            // Perform request to get the result contents
            NSLog(@"Getting contents for Fashionista post: %@", _selectedPost.name);

            _bEditPost = YES;
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_selectedPost.idFashionistaPost, nil];
            
            [self performRestGet:GET_POST withParamaters:requestParameters];
        }
    }
}

- (void)onTapDelete:(UIButton *)sender
{
    _selectedPostToDelete = [[self getFetchedResultsControllerForCellType:@"PostCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_REMOVEPOST_", nil) message:NSLocalizedString(@"_REMOVEPOST_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
    
    [alertView show];
}


#pragma mark - Alert views management


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *title = [alertView title];
    
    if( ([title isEqualToString:NSLocalizedString(@"_SETPAGETITLE_", nil)]) || ([title isEqualToString:NSLocalizedString(@"_EDITPAGETITLE_", nil)]))
    {
        if(![[[alertView textFieldAtIndex:0] text] length] >= 1)
        {
            return NO;
        }
    }

    if( ([title isEqualToString:NSLocalizedString(@"_SETPAGEURL_", nil)]) || ([title isEqualToString:NSLocalizedString(@"_EDITPAGEURL_", nil)]))
    {
        if(![[[alertView textFieldAtIndex:0] text] length] >= 1)
        {
            return NO;
        }
        
        // Check if URL has a correct format
        if(![NSString validateURL:[[alertView textFieldAtIndex:0] text]])
        {
            return NO;
        }
            
    }

    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( ([alertView.title isEqualToString:NSLocalizedString(@"_SETPAGETITLE_", nil)]) || ([alertView.title isEqualToString:NSLocalizedString(@"_EDITPAGETITLE_", nil)]))
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_OK_", nil)])
        {
            // Set top bar title
            
            if(_bEditionMode)
            {
                if(!(_shownFashionistaPage == nil))
                {
                    [_shownFashionistaPage setTitle:[alertView textFieldAtIndex:0].text];
                }
                else if (!(_creatingFashionistaPage == nil))
                {
                    [_creatingFashionistaPage setTitle:[alertView textFieldAtIndex:0].text];
                }
                
                _bEditedChanges = YES;
                
                [self setTopBarTitle:[alertView textFieldAtIndex:0].text andSubtitle:nil];
            }
        }
    }
    else if ( ([alertView.title isEqualToString:NSLocalizedString(@"_SETPAGEURL_", nil)]) || ([alertView.title isEqualToString:NSLocalizedString(@"_EDITPAGEURL_", nil)]))
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_OK_", nil)])
        {
            // Set blog url
            
            if(_bEditionMode)
            {
                [_fashionistaDetailsTitle setTitle:@"" forState:UIControlStateNormal];
                
                if(!(_shownFashionistaPage == nil))
                {
                    [_shownFashionistaPage setBlogURL:[alertView textFieldAtIndex:0].text];

                    if(!(_shownFashionistaPage.location == nil))
                    {
                        if(!([_shownFashionistaPage.location isEqualToString:@""]))
                        {
                            [_fashionistaDetailsTitle setTitle:_shownFashionistaPage.location forState:UIControlStateNormal];
                        }
                    }
                    
                    if (!(_shownFashionistaPage.blogURL == nil))
                    {
                        if(!([_shownFashionistaPage.blogURL isEqualToString:@""]))
                        {
                            if([[_fashionistaDetailsTitle titleForState:UIControlStateNormal] isEqualToString:@""])
                            {
                                [_fashionistaDetailsTitle setTitle:_shownFashionistaPage.blogURL forState:UIControlStateNormal];
                            }
                            else
                            {
                                [_fashionistaDetailsTitle setTitle:[_fashionistaDetailsTitle.titleLabel.text stringByAppendingString:[NSString stringWithFormat:@"  -  %@", _shownFashionistaPage.blogURL]] forState:UIControlStateNormal];
                            }
                        }
                    }
                }
                else if(!(_creatingFashionistaPage == nil))
                {
                    [_creatingFashionistaPage setBlogURL:[alertView textFieldAtIndex:0].text];

                    if(!(_creatingFashionistaPage.location == nil))
                    {
                        if(!([_creatingFashionistaPage.location isEqualToString:@""]))
                        {
                            [_fashionistaDetailsTitle setTitle:_creatingFashionistaPage.location forState:UIControlStateNormal];
                        }
                    }
                    
                    if([[_fashionistaDetailsTitle titleForState:UIControlStateNormal] isEqualToString:@""])
                    {
                        [_fashionistaDetailsTitle setTitle:_creatingFashionistaPage.blogURL forState:UIControlStateNormal];
                    }
                    else
                    {
                        [_fashionistaDetailsTitle setTitle:[_fashionistaDetailsTitle.titleLabel.text stringByAppendingString:[NSString stringWithFormat:@"  -  %@", _creatingFashionistaPage.blogURL]] forState:UIControlStateNormal];
                    }
                }
                
                _bEditedChanges = YES;
            }
        }
    }
    else if ([alertView.title isEqualToString:NSLocalizedString(@"_CANCELPAGEDITING_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
        {
            _bEditedChanges = NO;
            
            [self swipeRightAction];
        }
    }
    else if ([alertView.title isEqualToString:NSLocalizedString(@"_REMOVEPOST_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_CANCEL_", nil)])
        {
            if(!(_selectedPostToDelete == nil))
            {
                _selectedPostToDelete = nil;
            }
        }
        else if([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
        {
            if (_selectedPostToDelete != nil)
            {
                [self deletePost:_selectedPostToDelete];
            }
        }
        
    }
}


#pragma mark - Transitions between View Controllers


// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Action to perform when user swipes to right: go to previous screen
- (void)swipeRightAction
{
    if(!([self.hintBackgroundView isHidden]))
    {
        [self hintPrevAction:nil];
    }
    else if(!([_addToWardrobeVCContainerView isHidden]))
    {
        [self closeAddingItemToWardrobeHighlightingButton:nil withSuccess:NO];
    }
    else if(![self.fashionistaWebView isHidden])
    {
        [self closeFashionistaWebSite];
    }
    else if(!(_bEditionMode))
    {
        [super swipeRightAction];
    }
    else if(!(_bEditedChanges))
    {
        if(!(_creatingFashionistaPage == nil))
        {
            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            [currentContext deleteObject:_creatingFashionistaPage];
            
            if (![currentContext save:nil])
            {
                NSLog(@"Save did not complete successfully.");
            }
            
            _creatingFashionistaPage = nil;
        }
        
        [super swipeRightAction];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPAGEDITING_", nil) message:NSLocalizedString(@"_CANCELPAGEDITING_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_BACK_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
        
        [alertView show];
    }
}

// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Left action
/*
- (void)leftAction:(UIButton *)sender
{
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    if(!(_bEditionMode))
    {
        [super leftAction:sender];
    }
    else if(!(_bEditedChanges))
    {
        [super swipeRightAction];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPAGEDITING_", nil) message:NSLocalizedString(@"_CANCELPAGEDITING_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_BACK_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
        
        [alertView show];
    }
}

// OVERRIDE: Right action
- (void)rightAction:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
    {
        return;
    }

    if(!(_bEditionMode))
    {
        [super rightAction:sender];
    }
    else if(!(_bEditedChanges))
    {
 
    }
    else
    {
        if(!(_shownFashionistaPage == nil))
        {
            [self uploadFashionistaPage:_shownFashionistaPage];
        }
        else if(!(_creatingFashionistaPage == nil))
        {
            [self uploadFashionistaPage:_creatingFashionistaPage];
        }
    }
}
*/
#pragma mark - Logout
// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    
    if (_bEditionMode)
    {
        return;
    }
    else
    {
        [self closeAddingItemToWardrobeHighlightingButton:nil withSuccess:NO];
    }

}


@end

