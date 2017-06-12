//
//  SearchBaseViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//
#import <SystemConfiguration/SystemConfiguration.h>

#import "SearchBaseViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+CircleMenuManagement.h"
#import "BaseViewController+KeyboardSuggestionBarManagement.h"
#import "BaseViewController+UserManagement.h"

#import "FashionistaPostViewController.h"
#import "ProductSheetViewController.h"
#import "WardrobeContentViewController.h"
#import "AddItemToWardrobeViewController.h"
#import "FilterSearchViewController.h"
#import "FilterSearchBrandViewController.h"
#import "UIButton+CustomCreation.h"
#import "NSObject+ButtonSlideView.h"
#import "UIImage+GrayScale.h"
#import "UIImageView+WebCache.h"

#import "BDKCollectionIndexView.h"

#import "NSString+stringBetweenStrings.h"

#import "CoreDataQuery.h"

#import "FilterManager.h"
#import "Ad.h"

#define kSuggestedFiltersRibbonHeight 20
#define kMinWidthButton 50
#define kOffsetForBottomScroll 10

#define kConstraintTopSearchFeatureViewVisible 0
#define kConstraintTopSearchFeatureViewVisibleStylist 25
#define kConstraintTopSearchFeatureViewHidden -0-35
#define kConstraintTopSearchFeatureViewVisibleWhenEmbedded -30
#define kConstraintTopSearchFeatureViewHiddenWhenEmbedded -30-35

#define kScreenPortionForActivityIndicatorVerticalCenter 0.35
#define kActivityLabelBackgroundColor grayColor
#define kActivityLabelAlpha 0.6
#define kFontInActivityLabel "Avenir-Light"
#define kFontSizeInActivityLabel 16

#define kAlphabetWidth 20
#define kConstraintBottomAddSearchTerm 10;

#define kOffsetToRefreshSearch -(self.view.frame.size.height*0.42)

#define kDefaultFontSuggestedSize 16

#define kInspireViewHeight ((IS_IPHONE_5_OR_LESS) ? (250) : (300))

#define ADNUM   5

@interface BaseViewController (Protected)

- (void)rightAction:(UIButton *)sender;

@end


@implementation IdxAlphabet
@end


@implementation SectionProductType
@end


@implementation SearchBaseViewController
{
    // variables for the suggested bar management
    int iGenderSelected;
    ProductGroup * selectedProductCategory;
    NSMutableArray * arSelectedProductCategories;
    int iNumSubProductCategories;
    NSMutableArray * arSelectedSubProductCategory;
    NSMutableArray * arExpandedSubProductCategory;
    NSMutableArray * arSelectedBrandsProductCategory;
    
    // array that will store the features of prices
    NSMutableArray * arrayFeaturesPrices;
    
    NSMutableArray * _productGroupsParentForSuggestedKeywords;
    
    BOOL bChangingBackgroundAd;
    BOOL bComingFromSwipeSearchNavigation;
    BOOL bUpdatingSelectionColor;
    
    NSDate * timingShowCollection;
    
    __block BOOL bLoadingLocalDatabase;
    __block NSMutableDictionary * dictBrandsById;
    __block NSMutableDictionary * dictBrandsByName;
    __block BOOL bLoadedBrands;
    __block NSMutableDictionary * dictFeaturesById;
    __block NSMutableDictionary * dictFeaturesByName;
    __block BOOL bLoadedFeatures;
    __block NSMutableDictionary * dictProductCategoriesById;
    __block NSMutableDictionary * dictProductCategoriesByName;
    __block NSMutableDictionary * dictProductCategoriesByAppName;
    __block BOOL bLoadedProductCategories;
    __block NSMutableDictionary * dictFeatureGroupsById;
    __block NSMutableDictionary * dictFeatureGroupsByName;
    __block BOOL bLoadedFeaturesGroups;
    
    
    __block BOOL bLocationQuery;
    __block BOOL bStyleStylistQuery;
    
    BDKCollectionIndexView *scrollBrandAlphabetBDK;
    //    UIView * scrollBrandAlphabet;
    NSMutableDictionary * dictAlphabet;
    
    //    NSString * _entityForSuggestedKeyword;
    //NSString * _predicateForSuggestedKeyword;
    //NSString * _sortOrderForSuggestedKeyword;
    BOOL bRestartingSearch;
    BOOL bGettingInitialDataPosts;
    BOOL bGettingDataOfElement;
    
    BOOL bAfterDidLoad;
    
    CGFloat originalContraintAddSearchTerm;
    
    NSMutableArray * arSectionsProductType;
    
    BOOL scrollByAlphabet;
    
    UIView * viewBottomFilterShadow;
    
    FilterManager * filterManager;
    
    UISwipeGestureRecognizer *rightSwipe;
    UISwipeGestureRecognizer *leftSwipe;
    
    NSMutableArray *adList;
    NSMutableArray *adCells;
    
    CGFloat INSPIREVIEW_WIDTH;
}

BOOL bFiltersNew = YES;

// variable que indica si los suggestedkeywords son los product categories o provienen del resultado de una búsqueda
BOOL _bSuggestedKeywordsFromSearch = YES;

// Control whether search is new or just asking for more results
BOOL _bLoadingMoreResults = NO;

// Control whether search is reloading results
BOOL _bRefreshingSearch = NO;

// Control whether search is loading posts or stylists
BOOL _bLoadingStylistsOrPosts = NO;

// Save controller in charge of filter search
FilterSearchViewController *_filterSearchVC = nil;

// Save search terms before changing them, so we can go back to the previous results
NSMutableArray *_searchTermsBeforeUpdate = nil;

// Save the already downloades brands to avoid repeated downloads
NSMutableArray * _downloadedBrands = nil;

// When adding products to a known wardrobe (directly within this ViewController, when coming from StylistPost edition) or adding a Stylis follow, we need to keep track of the button to highlight
UIButton * buttonToHighlight = nil;

int iLastSelectedSlide = 0;
NSString * sLastSelectedSlide = @"";

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        _searchContext = maxSearchContexts;
    }
    
    return self;
}

- (int)iGetSearchNumResults
{
    int iNumResults = [_currentSearchQuery.numresults intValue];
    if([self.resultsGroups count] > 0)
    {
        ResultsGroup * rg = [self.resultsGroups objectAtIndex:0];
        iNumResults = [rg.last_order intValue] - [rg.first_order intValue] + 1;
    }
    return iNumResults;
}

- (BOOL)shouldCreateHintButton{
    return NO;
}

- (void)addExtraButtons{
    if(self.searchContext == PRODUCT_SEARCH){
        [self addExtraButton:@"VisualSearch" withHandler:@selector(actionForMainSecondCircleMenuEntry)];
    }
}

- (void)selectAButton{
    if(self.searchContext == PRODUCT_SEARCH){
        [self selectTheButton:self.rightButton];
    }
}

- (void)viewDidLoad
{
    filterManager = [FilterManager new];
    
    bAfterDidLoad = YES;
    bGettingInitialDataPosts = NO;
    bGettingDataOfElement = NO;
    arSelectedProductCategories = nil;
    scrollByAlphabet = NO;
    adCells = [NSMutableArray new];
    _fashionistaSearch = NO;
    
    [super viewDidLoad];
    
    // force to hide the add search term, before the next instruction of saving originalContraintAddSearchTerm
    [self resetAddSearchTerm];

    
    originalContraintAddSearchTerm = kConstraintBottomAddSearchTerm;
    
    bRestartingSearch = NO;
    filterManager.bRestartingSearch = NO;
    
    bLoadingLocalDatabase = NO;
    
    bComingFromSwipeSearchNavigation = NO;
    
    bUpdatingSelectionColor = NO;
    
    INSPIREVIEW_WIDTH = _inspireView.frame.size.width;
    
    if (_bFromTagSearch) {
        self.inspireView.hidden = NO;
        self.inspireButton.alpha = 0;
        NSString *inspireImage = (NSString*)[_inspireParams objectAtIndex:0];
        NSInteger width = [[_inspireParams objectAtIndex:1] integerValue];
        NSInteger height = [[_inspireParams objectAtIndex:2] integerValue];
        
        CGFloat ratioX = width / INSPIREVIEW_WIDTH;
        CGFloat ratioY = height / kInspireViewHeight;
        
        CGRect frame = _inspireView.frame;
        if (ratioX > ratioY) {
            frame.size.height = height / ratioX;
        }
        if (ratioX < ratioY) {
            frame.size.width = width / ratioY;
        }
        
        _inspireView.frame = frame;
        self.inspireViewHeightConstraint.constant = frame.size.height;
        [self.inspireImageView sd_setImageWithURL:[NSURL URLWithString:inspireImage]];
        
        if ([_categoryTerms count] > 0) {
            NSLog(@"Category Term Count :%li", [_categoryTerms count]);
        }
        _inspireTerms = _successfulTerms;
        
        
    }
    else {
        self.inspireView.hidden = YES;
    }
    // Do any additional setup after loading the view.
    
    _filterSearchVC = nil;
    _searchQueue = [[NSMutableArray alloc]init];
    _forwardSearchQueue = [[NSMutableArray alloc]init];
    bChangingBackgroundAd = NO;
    _bAddingProductsToPostContentWardrobe = NO;
    
    // If no specific search context is already set, PRODUCT_SEARCH will be the default
    if (_searchContext == maxSearchContexts)
    {
        _searchContext = PRODUCT_SEARCH;
    }
    
    if(_searchContext == FASHIONISTAS_SEARCH)
    {
        [self.stylistsSearch setBackgroundImage:[UIImage imageNamed:@"PostAndStylistButtonBackground.png"] forState:UIControlStateNormal];
        [self.stylistsSearch setBackgroundImage:[UIImage imageNamed:@"PostAndStylistButtonBackground.png"] forState:UIControlStateHighlighted];
        [self.stylistsSearch setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.postsSearch setBackgroundImage:nil forState:UIControlStateNormal];
        [self.postsSearch setBackgroundImage:nil forState:UIControlStateHighlighted];
        [self.postsSearch setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    else if (_searchContext == FASHIONISTAPOSTS_SEARCH)
    {
        [self.postsSearch setBackgroundImage:[UIImage imageNamed:@"PostAndStylistButtonBackground.png"] forState:UIControlStateNormal];
        [self.postsSearch setBackgroundImage:[UIImage imageNamed:@"PostAndStylistButtonBackground.png"] forState:UIControlStateHighlighted];
        [self.postsSearch setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.stylistsSearch setBackgroundImage:nil forState:UIControlStateNormal];
        [self.stylistsSearch setBackgroundImage:nil forState:UIControlStateHighlighted];
        [self.stylistsSearch setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    // Initialize results array
    if (_resultsArray == nil)
    {
        _resultsArray = [[NSMutableArray alloc] init];
    }
    
    // Initialize results groups array
    if (_resultsGroups == nil)
    {
        _resultsGroups = [[NSMutableArray alloc] init];
    }
    
    // Initialize the filter terms ribbon
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //    if (!appDelegate.bAutoLogin)
    //    {
    [self initSuggestedFilters];
    //    }
    
    if(!(appDelegate.addingProductsToWardrobeID == nil))
    {
        if(!([appDelegate.addingProductsToWardrobeID isEqualToString:@""]))
        {
            _addingProductsToWardrobeID = appDelegate.addingProductsToWardrobeID;
        }
    }
    
    if(_searchContext == STYLES_SEARCH)
    {
        if(!(_getTheLookReferenceProduct == nil))
        {
            if(!(_getTheLookReferenceProduct.name == nil))
            {
                [self setTopBarTitle:[self stringForBarTitle] andSubtitle:[NSString stringWithFormat:NSLocalizedString(@"_GET_THE_LOOK_FOR_PRODUCT_", nil), (((_getTheLookReferenceProduct.mainInformation == nil) || ([_getTheLookReferenceProduct.mainInformation isEqualToString:@""])) ? ([_getTheLookReferenceProduct.name capitalizedString]) : ([NSString stringWithFormat:@"%@ %@", [_getTheLookReferenceProduct.mainInformation uppercaseString], [_getTheLookReferenceProduct.name capitalizedString]]))]];
            }
        }
    }
    else if (!(_currentSearchQuery == nil))
    {
        int iNumResults = [self iGetSearchNumResults];
        
        NSString * subTitle = nil;
        
        //if(!(_searchContext == FASHIONISTAS_SEARCH || _searchContext == FASHIONISTAPOSTS_SEARCH))
        {
            if(iNumResults > 0)
            {
                if(iNumResults >= 1000)
                {
                    subTitle = [NSString stringWithFormat:NSLocalizedString(@"_MORETHAN1000_RESULTS_", nil), iNumResults];
                }
                else
                {
                    if(iNumResults > 1)
                    {
                        subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULTS_", nil), iNumResults];
                    }
                    else
                    {
                        subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULT_", nil), iNumResults];
                    }
                }
            }
            else
            {
                subTitle = NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil);
            }
        }
        
        [self setTopBarTitle:nil andSubtitle:subTitle];
        
        [self setNotSuccessfulTerms:([_notSuccessfulTerms isEqualToString:@""] ? @"" : [NSString stringWithFormat:NSLocalizedString(@"_NOTSUCCESFULTERMS_", nil), _notSuccessfulTerms])];
    }
    else
    {
        NSString * subTitle = nil;
        
        //if(!(_searchContext == FASHIONISTAS_SEARCH || _searchContext == FASHIONISTAPOSTS_SEARCH))
        {
            subTitle = NSLocalizedString(@"_NO_SEARCH_KEYWORDS_MSG_", nil);
        }
        
        // Show specific title depending on the Search Context
        NSString* barTitle = [self stringForBarTitle];
        [self setTopBarTitle:barTitle andSubtitle:subTitle];
    }
    
    // Init collection views cell types
    [self setupCollectionViewsWithCellTypes:[[NSMutableArray alloc] initWithObjects:@"ResultCell", @"SearchFeatureCell", nil]];
    
    // Setup the Main Collection View background image
    [self setupBackgroundImage];
    
    // Quit background image if there are already some results
    if (([_resultsArray count] > 0))
    {
        [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
        [self hideBackgroundAddButton];
    }
    
    // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
    if ([self getFetchedResultsControllerForCellType:@"ResultCell" ] == nil)
    {
        [self initFetchedResultsController];
    }
    
    // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
    if ([self getFetchedResultsControllerForCellType:@"SearchFeatureCell" ] == nil)
    {
        [self initFetchedResultsControllerForKeywordsForEntity:@"Brand" withPredicate:@"name IN %@" anOrderBy:@"name"];
    }
    
    // Setup Collection View
    [self initCollectionViewsLayout];
    
    // Set TODAY as the default selected history period
    _searchPeriod = TODAY;
    
    // Set 'Any' as the default selected type of post to retrieve
    _searchPostType = ALLPOSTS;
    
    // Set ALL as the default relationships filter for stylists search
    _searchStylistRelationships = ALLSTYLISTS;
    
    [self initDataFromLocalDatabase];
    
    // Setup the search terms list
    [self initSearchTermsList];
    
    // Setup the 'Add term' button
    [self setupAddTermButton];
    
    [self getAds];
    // doanloading infor from server
//    if (!appDelegate.bAutoLogin)
//    {
//        if (appDelegate.splashScreen == YES)
//            [self startLoadingInfoFilterFromServer];
//        iNumMaxMessage--;
//    }
    
    if (bFiltersNew)
    {
        [filterManager initZoomView];
    }
    else
    {
        [self initZoomView];
    }
    [self updateBottomBarSearch];
    
    [self initDataFromLocalDatabase];
    
    arSelectedSubProductCategory = [[NSMutableArray alloc] init];
    
    arExpandedSubProductCategory = [[NSMutableArray alloc ] init];
    
    arSectionsProductType = nil;
    
    if (bFiltersNew)
    {
        [filterManager initBottomShadow];
    }
    else
    {
        viewBottomFilterShadow = [[UIView alloc] initWithFrame:CGRectMake(0,self.selectFeaturesView.frame.size.height - 1, self.selectFeaturesView.frame.size.width, 10.0)];
        viewBottomFilterShadow.hidden = YES;
        viewBottomFilterShadow.alpha = 0.0;
        viewBottomFilterShadow.backgroundColor = [UIColor whiteColor];
        viewBottomFilterShadow.layer.shadowColor = [[UIColor blackColor] CGColor];
        viewBottomFilterShadow.layer.shadowOffset = CGSizeMake(0,-5);
        viewBottomFilterShadow.layer.shadowRadius = 5.0;
        viewBottomFilterShadow.layer.shadowOpacity = 0.5;
        
        [self.selectFeaturesView addSubview:viewBottomFilterShadow];
    }
    
    // test  VERIFY FOLLOWER
//    NSArray * requestParameters = [[NSArray alloc] initWithObjects:@"5574d5c8b235539e57d9d9c1",@"55cdd16ed13624a81dca6925", nil];
//    
//    [self performRestGet:VERIFY_FOLLOWER withParamaters:requestParameters];
    
//    // test GET NEAREST POIS
//    NSArray * requestParameters = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:40.714], [NSNumber numberWithFloat:-74.00], nil];
//    
//    [self performRestGet:GET_NEAREST_POI withParamaters:requestParameters];
    
//    // test get GET_USERS_FOR_AUTOFILL
//        NSArray * requestParameters = [[NSArray alloc] initWithObjects:@"5574d5c8b235539e57d9d9c1",nil];
//    
//        [self performRestGet:GET_USERS_FOR_AUTOFILL withParamaters:requestParameters];
    
    
}

-(void)initGestureRecognizer {
    [self.inspireView setUserInteractionEnabled:YES];
    rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(inspireGesture:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.inspireView addGestureRecognizer:rightSwipe];
    
    leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(inspireGesture:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.inspireView addGestureRecognizer:leftSwipe];

    UISwipeGestureRecognizer * rightswipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    rightswipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer * leftswipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    leftswipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.mainCollectionView addGestureRecognizer:leftswipeRecognizer];
    [self.mainCollectionView addGestureRecognizer:rightswipeRecognizer];
}

-(void)inspireGesture:(UIPanGestureRecognizer *)sender {
    UISwipeGestureRecognizer *swipeGesture = (UISwipeGestureRecognizer*)sender;
    
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Swipe Left");
        [self hideInspireView];
    }
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Swipe Right");
        [self showInspireView];
    }
}

-(void)hideInspireView {
    CGRect frame = self.inspireView.frame;
    frame.origin.x = -self.inspireView.frame.size.width + self.inspireButton.frame.size.width;
    
    CGRect toFrame = self.inspireButton.frame;
    toFrame.origin.x = self.inspireView.frame.size.width - self.inspireButton.frame.size.width;
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.inspireView setFrame:frame];
                         self.inspireImageContainer.alpha = 0;
                         self.inspireButton.alpha = 1;
                         self.inspireButton.frame = toFrame;
                     }
                     completion:^(BOOL finished){
                         self.inspireImageContainer.hidden = YES;
                     }];
}

-(void)showInspireView {
    CGRect frame = self.inspireView.frame;
    frame.origin.x = 4;
    CGRect toFrame = self.inspireButton.frame;
    toFrame.origin.x = 0;
    self.inspireImageContainer.hidden = NO;
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.inspireView setFrame:frame];
                         self.inspireImageContainer.alpha = 1;
                         self.inspireButton.alpha = 0;
                         self.inspireButton.frame = toFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)showInspire {
    if (_bFromTagSearch) {
        if ([_categoryTerms count] > 0) {
            _inspireView.hidden = NO;
        }
    }
    _inspireView.hidden = YES;
}
-(void)panGesture:(UIPanGestureRecognizer*)sender {
    UISwipeGestureRecognizer *swipeGesture = (UISwipeGestureRecognizer*)sender;
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Swipe Right");
        [self swipeRightAction];
    }
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Swipe Left");
        [self swipeLeftAction];
    }
}
- (IBAction)showInspireAction:(id)sender {
    [self showInspireView];
}

- (NSString*)stringForBarTitle{
    //NSString* barTitle = NSLocalizedString(([NSString stringWithFormat:@"_VCTITLE_%i_",_searchContext]), nil);
    NSString* barTitle = NSLocalizedString(@"_VCTITLE_22_", nil);
    if (_searchContext==HISTORY_SEARCH) {
        barTitle = NSLocalizedString(@"_VCTITLE_9_", nil);
    }
    return barTitle;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect frame = self.inspireView.frame;
    CGRect frame1 = self.mainCollectionView.frame;
    
    if (_searchContext == PRODUCT_SEARCH)
    {
        [self getBackgroundAdForCurrentUser];
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.splashScreen == YES) || appDelegate.bLoadingFilterInfo)
    {
        [self getSuggestedFilters];
        
//        [self startLoadingInfoFilterFromServer];
        
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SPLASH_MESSAGE_",nil)];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeSplashView:) name:@"finishLoadingTask" object:nil];
    }
    
    // If not in global seach context, retrieve the initial results
    if ((!(_searchContext == PRODUCT_SEARCH)) && (!(_searchContext == STYLES_SEARCH)))
    {
        if((_searchContext == FASHIONISTAS_SEARCH) && ((_fashionistasMappingResult) && ([_fashionistasMappingResult count] > 0)) && ((_fashionistasOperation) && (_fashionistasOperation >= 0)))
        {
            [self actionAfterSuccessfulAnswerToRestConnection:[_fashionistasOperation intValue] WithResult:_fashionistasMappingResult];
        }
        else
        {
            if (bAfterDidLoad)
            {
                bGettingInitialDataPosts = YES;
                NSLog(@"bGettingInitialData = YES");
                // Perform the first search
                bGettingInitialDataPosts = [self updateSearchForTermsChanges];
            }
        }
    }
    
    
    
    // Reload User Wardrobes & Follows

    if (!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
//                                return;// TO REGENERATE LAST COREDATA FILES!!!
                // ALSO SET RETURN IN 'getCurrentUserInitialData'
                // ALSO SET DATA = NIL IN 'getInitialDB'
                // ALSO SET RETURN IN SearchBaseViewController::'actionAfterLogIn'
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                
                if ((_searchContext == PRODUCT_SEARCH) || (_searchContext == TRENDING_SEARCH) || (_searchContext == FASHIONISTAPOSTS_SEARCH) || (_searchContext == HISTORY_SEARCH) || (_searchContext == STYLES_SEARCH))
                {
                    [self performRestGet:GET_USER_WARDROBES withParamaters:requestParameters];
                }
                
                if ((_searchContext == TRENDING_SEARCH) || (_searchContext == FASHIONISTAS_SEARCH) || (_searchContext == NOTIFICATIONS_SEARCH) || (_searchContext == HISTORY_SEARCH))
                {
                    [self performRestGet:GET_USER_FOLLOWS withParamaters:requestParameters];
                }
                
                //[self performRestGet:GET_USER_NOTIFICATIONS withParamaters:requestParameters];
            }
        }
    }
    
    if(!(_addingProductsToWardrobeID == nil))
    {
        if(!([_addingProductsToWardrobeID isEqualToString:@""]))
        {
            [self.topBarView removeFromSuperview];
            [self.bottomControlsView removeFromSuperview];
            
            [self viewDidLoad];
        }
    }
    
    bAfterDidLoad = NO;
    if(self.vcName > 0){
        NSString* theString = [NSString stringWithFormat:@"_VCTITLE_%i_",self.vcName];
        [self setTopBarTitle:NSLocalizedString(theString,nil) andSubtitle:nil];
    }
}


-(void) viewDidLayoutSubviews
{
    if(!(_addingProductsToWardrobeID == nil))
    {
        if(!([_addingProductsToWardrobeID isEqualToString:@""]))
        {
            self.constraintMainCollectionViewLeading.constant = 0.0;
            self.constraintMainCollectionViewTrailing.constant = 0.0;
            self.constraintSecondCollectionViewLeading.constant = 0.0;
            self.constraintSecondCollectionViewTrailing.constant = 0.0;
            
            UIEdgeInsets edgeInsets = self.mainCollectionView.contentInset;
            edgeInsets.top = 92;
            [self.mainCollectionView setContentInset:edgeInsets];
        }
    }
    
    /*
     if (self.SuggestedFiltersRibbonView != nil)
     {
     //        self.SuggestedFiltersRibbonView = [[SlideButtonView alloc] initWithFrame:CGRectMake(self.topBarView.frame.origin.x, self.topBarView.frame.origin.y+(self.topBarView.frame.size.height-kSuggestedFiltersRibbonHeight), self.topBarView.frame.size.width, kSuggestedFiltersRibbonHeight)];
     CGRect frame = self.SuggestedFiltersRibbonView.frame;
     frame.size.width = self.topBarView.frame.size.width;
     self.SuggestedFiltersRibbonView.frame = frame;
     [self.SuggestedFiltersRibbonView updateButtons];
     }
     */
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Update and re-position search terms list
    [self.searchTermsListView updateContentSize];
    
    [self.searchTermsListView scrollToTheEnd];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(addObserverForKeyboardChange) userInfo:nil repeats:NO];
    if(self.searchContext == PRODUCT_SEARCH){
        [self performSelector:@selector(moveScrollBar) withObject:nil afterDelay:0.5];
    }
}

- (void) addObserverForKeyboardChange
{
    
    // Observe the notification for keyboard appearing/dissappearing in order to properly animate Add Terms text field
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameWithNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishLoadingTask" object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(void) stopActivityFeedback
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //if (appDelegate.splashScreen == NO)
        [super stopActivityFeedback];
    
}

-(void) startActivityFeedbackWithMessage:(NSString*)message {
    [super startActivityFeedbackWithMessage:message];

}

-(void) initDataFromLocalDatabase
{
    [[CoreDataQuery sharedCoreDataQuery] initDataFromLocalDatabase];

    if ((bLoadingLocalDatabase == NO) && (bLoadedFeaturesGroups == NO))
    {
        NSLog(@"initDataFromLocalDatabase");
        bLoadingLocalDatabase = YES;
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        bLoadedBrands = NO;
        bLoadedFeatures = NO;
        bLoadedFeaturesGroups = NO;
        bLoadedProductCategories = NO;
        
        if (dictBrandsById != nil)
            [ dictBrandsById removeAllObjects];
        if (dictBrandsByName != nil)
            [ dictBrandsByName removeAllObjects];
        dictBrandsById = [[NSMutableDictionary alloc] init];
        dictBrandsByName = [[NSMutableDictionary alloc] init];
        [self getAllBrandsToDict];
        bLoadedBrands = YES;
        
        if (dictProductCategoriesById != nil)
            [ dictProductCategoriesById removeAllObjects];
        if (dictProductCategoriesByName != nil)
            [ dictProductCategoriesByName removeAllObjects];
        if (dictProductCategoriesByAppName != nil)
            [ dictProductCategoriesByAppName removeAllObjects];
        dictProductCategoriesById = [[NSMutableDictionary alloc] init];
        dictProductCategoriesByName = [[NSMutableDictionary alloc] init];
        dictProductCategoriesByAppName = [[NSMutableDictionary alloc] init];
        [self getAllProductGroupsToDict];
        bLoadedProductCategories = YES;
        
        if (dictFeaturesById != nil)
            [ dictFeaturesById removeAllObjects];
        if (dictFeaturesByName != nil)
            [ dictFeaturesByName removeAllObjects];
        dictFeaturesById = [[NSMutableDictionary alloc] init];
        dictFeaturesByName = [[NSMutableDictionary alloc] init];
        [self getAllFeaturesToDict];
        bLoadedFeatures = YES;
        
        if (dictFeatureGroupsById != nil)
            [ dictFeatureGroupsById removeAllObjects];
        if (dictFeatureGroupsByName != nil)
            [ dictFeatureGroupsByName removeAllObjects];
        dictFeatureGroupsById = [[NSMutableDictionary alloc] init];
        dictFeatureGroupsByName = [[NSMutableDictionary alloc] init];
        [self getAllFeatureGroupsToDict];
        bLoadedFeaturesGroups = YES;
        
        bLoadingLocalDatabase = NO;
        //});
    }
}

-(void) showAlertBrandNoProducts:(NSArray *)mappingResult
{
    NSString * brandName = @"";
    NSString * alertString;
    
    if (mappingResult != nil)
    {
        if (mappingResult.count > 0)
        {
            if ([[mappingResult objectAtIndex:0] isKindOfClass:[SearchQuery class]])
            {
                SearchQuery * search = (SearchQuery *) [mappingResult objectAtIndex:0];
                
                brandName = [search.searchQuery stringBetweenString:@"#" andString:@"#"];
                
                if (brandName == nil)
                    brandName = @"";
            }
        }
    }
    if ([brandName isEqualToString:@""])
    {
        alertString = NSLocalizedString(@"_NO_BRANDPRODUCTS_ERROR_MSG_", nil);
    }
    else
    {
        alertString = [NSString stringWithFormat:NSLocalizedString(@"_NO_BRANDPRODUCTS_COMMING_SOON_MSG_", nil), brandName];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:alertString delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
}

-(NSString *) getSearchContextString
{
    NSArray *array = [NSArray arrayWithObjects:@"PRODUCT_SEARCH",
                      @"TRENDING_SEARCH",
                      @"BRANDS_SEARCH",
                      @"FASHIONISTAS_SEARCH",
                      @"FASHIONISTAPOSTS_SEARCH",
                      @"NOTIFICATIONS_SEARCH",
                      @"HISTORY_SEARCH",
                      @"STYLES_SEARCH",
                      @"maxSearchContexts",nil];
    
    NSString *result = @"Unexpected FormatType";
    if (_searchContext < [ array count])
    {
        result = array[_searchContext];
    }
    
    return result;
}

#pragma mark - Brands alphabet

#define kDefaultFontSizeAlphabet 10
#define kHeightLetterAlphabet 20
#define kWidthAlphabet 20

-(void) initAlphabetwithArray:(NSMutableArray *)arrayElements  withSections:(BOOL) bSections
{
    if (arrayElements.count<= 0)
    {
        [self hideAlphabet];
        return;
    }
    
    if (scrollBrandAlphabetBDK != nil)
    {
        [scrollBrandAlphabetBDK removeFromSuperview];
    }
    
    if (dictAlphabet != nil)
    {
        [dictAlphabet removeAllObjects];
    }
    else
    {
        dictAlphabet = [[NSMutableDictionary alloc] init];
    }
    
    // initi dictionary will all indexes to -1
    int iIdx = 1;
    IdxAlphabet * idxAlphabet= [IdxAlphabet new];
    idxAlphabet.iIndex = -1;
    idxAlphabet.iSection = -1;
    [dictAlphabet setObject:idxAlphabet forKey:@"#"];
    for(int i = 65; i <= 90; i++)
    {
        NSString *stringChar = [NSString stringWithFormat:@"%c", i];
        IdxAlphabet * idxAlphabet= [IdxAlphabet new];
        idxAlphabet.iIndex = -1;
        idxAlphabet.iSection = -1;
        [dictAlphabet setObject:idxAlphabet forKey:stringChar];
    }
    
    NSMutableArray * finalArrayAlphabet = [[NSMutableArray alloc] initWithArray:arrayElements];;
    if (bSections)
    {
        [finalArrayAlphabet removeAllObjects];
        
        int iSection = 0;
        for(SectionProductType * section in arrayElements)
        {
            if (section.iLevel == 0)
            {
                for (ProductGroup * pg in section.arElements)
                {
                    [finalArrayAlphabet addObject:[pg getNameForApp]];
                }
            }
            iSection++;
        }
    }
    
    // set dictionary of letter with the index
    int iNumLettersInAlphabet = 0;
    int iIdxElementFiltered = 0;
    for (int iIdxElement = 0; iIdxElement < [finalArrayAlphabet count]; iIdxElement++)
    {
        NSString * tmpElement = [finalArrayAlphabet objectAtIndex:iIdxElement];
        
        if(!(tmpElement == nil))
        {
            if(!([tmpElement isEqualToString:@""]))
            {
                NSString * initialCharacter =[tmpElement.uppercaseString substringToIndex:1];
                int iChar = [initialCharacter characterAtIndex:0];
                NSString * key = @"";
                if ((iChar >= 65) && (iChar <= 90))
                {
                    key = initialCharacter;
                }
                else
                {
                    key = @"#";
                }
                IdxAlphabet * iIdx = [dictAlphabet objectForKey:key];
                if (iIdx.iSection == -1)
                {
                    iIdx.iSection = 0;
                    iIdx.iIndex = iIdxElementFiltered;
                    //                    iIdx = [NSNumber numberWithInt:iIdxElementFiltered];
                    if (bSections)
                    {
                        int iSection = 0;
                        BOOL bTrobat = NO;
                        // buscar la seccion y index dentro de la seccion
                        for(SectionProductType * section in arrayElements)
                        {
                            if (section.iLevel == 0)
                            {
                                int iIndex = 0;
                                for (ProductGroup * pg in section.arElements)
                                {
                                    if ([[pg getNameForApp] isEqualToString:tmpElement])
                                    {
                                        iIdx.iSection = iSection;
                                        iIdx.iIndex = iIndex;
                                        //                                        [dictAlphabet setObject:idxNew forKey:key];
                                        bTrobat = YES;
                                        break;
                                    }
                                    iIndex++;
                                    
                                }
                            }
                            if (bTrobat)
                            {
                                break;
                            }
                            iSection++;
                        }
                    }
                    //                    else
                    //                    {
                    //                        [dictAlphabet setObject:iIdx forKey:key];
                    //                    }
                    iNumLettersInAlphabet++;
                }
                iIdxElementFiltered ++;
            }
        }
    }
    
    
    UIFont * fontDefault = [UIFont fontWithName:@"AvenirNext-Regular" size:kDefaultFontSizeAlphabet];
    UIFont * fontZoom = [UIFont fontWithName:@"AvenirNext-Bold" size:(kDefaultFontSizeAlphabet*2.5)];
    
    
    float fTotalHeight = self.selectFeaturesView.frame.size.height - 60 - self.topBarHeight- self.SuggestedFiltersRibbonView.frame.size.height - 4;
    if ([self shouldCreateSlideLabel])
        fTotalHeight = self.selectFeaturesView.frame.size.height - 85 - self.topBarHeight - self.SuggestedFiltersRibbonView.frame.size.height - 4;
    
    //    float fHeightButton = fTotalHeight / (90-65 + 1 + 1);
    //    float fHeightButton = fTotalHeight / iNumLettersInAlphabet;
    float fHeightButton = kHeightLetterAlphabet;
    
    //    scrollBrandAlphabet = [[UIView alloc] initWithFrame:CGRectMake(self.selectFeaturesView.frame.size.width-fHeightButton, self.SuggestedFiltersRibbonView.frame.size.height + self.selectFeaturesView.frame.origin.y + 4, kWidthAlphabet, fTotalHeight)];
    
    scrollBrandAlphabetBDK = [BDKCollectionIndexView indexViewWithFrame:CGRectMake(self.selectFeaturesView.frame.size.width-fHeightButton, self.SuggestedFiltersRibbonView.frame.size.height + self.selectFeaturesView.frame.origin.y + self.topBarHeight + 4, kWidthAlphabet, fTotalHeight) indexTitles:@[]];
    
    [scrollBrandAlphabetBDK.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [scrollBrandAlphabetBDK.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [scrollBrandAlphabetBDK.layer setShadowRadius:0.5];
    [scrollBrandAlphabetBDK.layer setShadowOpacity:0.5];
    //    [scrollBrandAlphabetBDK setClipsToBounds:NO];
    
    scrollBrandAlphabetBDK.touchStatusBackgroundColor = [UIColor grayColor];
    scrollBrandAlphabetBDK.touchStatusViewAlpha = 0.8;
    scrollBrandAlphabetBDK.font = fontDefault;
    scrollBrandAlphabetBDK.fontZoom = fontZoom;
    scrollBrandAlphabetBDK.fontZoomColor = [UIColor whiteColor];
    scrollBrandAlphabetBDK.tintColor = [UIColor whiteColor];
    
    [scrollBrandAlphabetBDK addTarget:self action:@selector(indexViewValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    //    float yPos = 0.0;
    
    //    iIdx = 0;
    NSMutableArray * sortedKeyArray = [[NSMutableArray alloc] initWithArray:[[dictAlphabet allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    NSMutableArray * arIdxBDK = [NSMutableArray new];
    
    for(NSString * key in sortedKeyArray)
    {
        IdxAlphabet * idx = [dictAlphabet objectForKey:key];
        if (idx.iSection != -1)
        {
            //            yPos = iIdx * fHeightButton;
            //            UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, yPos,fHeightButton, fHeightButton)];
            //            view.tag = [idx longValue];
            //
            //            [view setBackgroundImage:[UIImage imageNamed:@"Alphabet.png"] forState:UIControlStateNormal];
            //            [view setTitle:key forState:UIControlStateNormal];
            //            [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [view.titleLabel setFont:fontDefault];
            [arIdxBDK addObject:key];
            //            [view addTarget:self action:@selector(btnBrandAlphabet:) forControlEvents:UIControlEventTouchUpInside];
            //
            //            [scrollBrandAlphabet addSubview:view];
            iIdx++;
        }
    }
    
    scrollBrandAlphabetBDK.indexTitles = arIdxBDK;
    ////    scrollBrandAlphabet.contentSize = CGSizeMake(scrollBrandAlphabet.frame.size.width-5, fHeightButton *iIdx);
    //    scrollBrandAlphabet.hidden = YES;
    //    [self.view addSubview:scrollBrandAlphabet];
    //    [self.view bringSubviewToFront:scrollBrandAlphabet];
    [self.view addSubview:scrollBrandAlphabetBDK];
    [self.view bringSubviewToFront:scrollBrandAlphabetBDK];
    
    //    NSLog(@"Init brands Rect Alphabet Origin (%f, %f) Size(%f, %f)", scrollBrandAlphabetBDK.frame.origin.x, scrollBrandAlphabetBDK.frame.origin.y, scrollBrandAlphabetBDK.frame.size.width, scrollBrandAlphabetBDK.frame.size.height);
    
    //    self.constraintTrailingAlphabet.constant = fHeightButton+5;
    //    self.constraintTrailingAlphabet.constant = kWidthAlphabet;
    
    [self.view layoutIfNeeded];
    
}

-(void) initBrandsAlphabet
{
    NSMutableArray * arElements = [[NSMutableArray alloc] init];
    
    for (int iIdxBrand = 0; iIdxBrand < [[self.secondFetchedResultsController fetchedObjects] count]; iIdxBrand++)
    {
        Brand * tmpBrand = [[self.secondFetchedResultsController fetchedObjects] objectAtIndex:iIdxBrand];
        
        if(!(tmpBrand == nil))
        {
            if(!(tmpBrand.idBrand == nil))
            {
                if(!([tmpBrand.idBrand isEqualToString:@""]))
                {
                    if([_foundSuggestions count] == 0 || [_foundSuggestions objectForKey:tmpBrand.idBrand])
                    {
                        [arElements addObject:tmpBrand.name];
                    }
                }
            }
        }
    }
    
    [self initAlphabetwithArray:arElements withSections:NO];
}

-(void) initProductCategoryAlphabet
{
    NSMutableArray * arElements = [[NSMutableArray alloc] init];
    
    for (int iIdxPG = 0; iIdxPG < [[self.secondFetchedResultsController fetchedObjects] count]; iIdxPG++)
    {
        ProductGroup * tmpPG = [[self.secondFetchedResultsController fetchedObjects] objectAtIndex:iIdxPG];
        
        if(!(tmpPG == nil))
        {
            if(!(tmpPG.idProductGroup == nil))
            {
                if(!([tmpPG.idProductGroup isEqualToString:@""]))
                {
                    if([_foundSuggestions count] == 0 || [_foundSuggestions objectForKey:tmpPG.idProductGroup])
                    {
                        [arElements addObject:[tmpPG getNameForApp]];
                    }
                }
            }
        }
    }
    
    if (arSectionsProductType.count > 0)
    {
        [self initAlphabetwithArray:arSectionsProductType withSections:(arSectionsProductType.count > 0)];
    }
    else
    {
        [self initAlphabetwithArray:arElements withSections:(arSectionsProductType.count > 0)];
    }
}

-(void) initFeaturesAlphabet
{
    NSMutableArray * arElements = [[NSMutableArray alloc] init];
    
    for (int iIdxFeat = 0; iIdxFeat < [[self.secondFetchedResultsController fetchedObjects] count]; iIdxFeat++)
    {
        Feature * tmpFeat = [[self.secondFetchedResultsController fetchedObjects] objectAtIndex:iIdxFeat];
        
        if(!(tmpFeat == nil))
        {
            if(!(tmpFeat.idFeature == nil))
            {
                if(!([tmpFeat.idFeature isEqualToString:@""]))
                {
                    if([_foundSuggestions count] == 0 || [_foundSuggestions objectForKey:tmpFeat.idFeature])
                    {
                        [arElements addObject:tmpFeat.name];
                    }
                }
            }
        }
    }
    
    [self initAlphabetwithArray:arElements withSections:NO];
}

-(void) hideAlphabet
{
    //    if (scrollBrandAlphabet != nil)
    //    {
    //        [scrollBrandAlphabet removeFromSuperview];
    //    }
    if (scrollBrandAlphabetBDK != nil)
    {
        scrollBrandAlphabetBDK.hidden = YES;
        [scrollBrandAlphabetBDK removeFromSuperview];
    }
    //    self.constraintTrailingAlphabet.constant = 5;
    [self.view layoutIfNeeded];
}

/*
 - (IBAction)btnBrandAlphabet: (id)sender
 {
 UIButton *button = (UIButton*)sender;
 // highlight the button
 long iIdxBrand = (long)button.tag;
 NSLog(@"Alphabet %ld", iIdxBrand);
 
 if (iIdxBrand > -1)
 {
 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:iIdxBrand inSection:0];
 // scrolling here does work
 [self.secondCollectionView scrollToItemAtIndexPath:indexPath
 atScrollPosition:UICollectionViewScrollPositionTop
 animated:YES];
 }
 }
 */
- (void)indexViewValueChanged:(BDKCollectionIndexView *)sender
{
    IdxAlphabet * idx = [dictAlphabet objectForKey:sender.currentIndexTitle];
    //    NSLog(@"Alphabet %i %i", idx.iSection, idx.iIndex);
    if ((idx.iSection > -1) && (idx.iIndex > -1))
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx.iIndex inSection:idx.iSection];
        // scrolling here does work
        scrollByAlphabet = YES;
        [self.secondCollectionView scrollToItemAtIndexPath:indexPath
                                          atScrollPosition:UICollectionViewScrollPositionTop
                                                  animated:YES];
    }
    
    //    NSLog(@"Fin Alphabet %i %i", idx.iSection, idx.iIndex);
    
    /*
     NSIndexPath *path = [NSIndexPath indexPathForItem:sender.currentIndex inSection:0];
     if (![self collectionView:self.secondCollectionView cellForItemAtIndexPath:path])
     return;
     
     [self.secondCollectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
     CGFloat yOffset = self.secondCollectionView.contentOffset.y;
     
     self.secondCollectionView.contentOffset = CGPointMake(self.secondCollectionView.contentOffset.x, yOffset);
     */
}



#pragma mark - Collection view methods


// Setup Main Collection View background image
- (void) setupBackgroundImage
{
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:nil];
    
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [backgroundImageView setBackgroundColor:[UIColor clearColor]];
    
    [backgroundImageView setAlpha:1.00];
    
    [backgroundImageView setUserInteractionEnabled:YES];
    
    [backgroundImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBackgroundImage)]];
    
    [backgroundImageView setImage:[UIImage imageNamed:@"Splash_Background.png"]];
    
    [self.mainCollectionView setBackgroundView:backgroundImageView];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.view.frame;
    
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0] CGColor],
                       (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0] CGColor],
                       (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2] CGColor],
                       (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7] CGColor],
                       (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor],
                       nil];
    
    [self.mainCollectionView.backgroundView.layer insertSublayer:gradient atIndex:0];
}

// Set a specific image as background
-(void) setBackgroundImage
{
    if(_searchContext == PRODUCT_SEARCH)
    {
        if(bChangingBackgroundAd)
        {
            return;
        }
        
        if (([_resultsArray count] > 0))
        {
            [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
            [self hideBackgroundAddButton];
            
            return;
        }
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if(!(appDelegate.nextSearchAdaptedBackgroundAd == nil))
        {
            if(!([appDelegate.nextSearchAdaptedBackgroundAd imageURL ] == nil))
            {
                if(!([[appDelegate.nextSearchAdaptedBackgroundAd imageURL] isEqualToString:@""]))
                {
                    if(!([((UIImageView *)([self.mainCollectionView backgroundView])) image] == nil))
                    {
                        if(!(_currentBackgroundAd == nil))
                        {
                            if(!(_currentBackgroundAd.imageURL == nil))
                            {
                                if(!([_currentBackgroundAd.imageURL isEqualToString:@""]))
                                {
                                    if([[appDelegate.nextSearchAdaptedBackgroundAd imageURL] isEqualToString:_currentBackgroundAd.imageURL])
                                    {
                                        return;
                                    }
                                }
                            }
                        }
                    }
                    
                    bChangingBackgroundAd = YES;
                    
                    _currentBackgroundAd = appDelegate.nextSearchAdaptedBackgroundAd;
                    
                    NSString *backgroundImageURL = [_currentBackgroundAd imageURL];
                    
                    if ([UIImage isCached:backgroundImageURL])
                    {
                        UIImage * image = [UIImage cachedImageWithURL:backgroundImageURL];
                        
                        if(image == nil)
                        {
                            image = [UIImage imageNamed:@"Splash_Background.png"];
                        }
                        
                        [UIView animateWithDuration:1.0
                                              delay:0
                                            options:UIViewAnimationOptionCurveEaseOut
                                         animations:^ {
                                             
                                             [((UIImageView *)([self.mainCollectionView backgroundView])) setAlpha:0.01];
                                             
                                             [self.mainCollectionView setBackgroundColor:[UIColor whiteColor]];
                                         }
                                         completion:^(BOOL finished) {
                                             
                                             [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:[UIImage convertImageToGrayScale:image]];
                                             
                                             [UIView animateWithDuration:1.0
                                                                   delay:0
                                                                 options:UIViewAnimationOptionCurveEaseOut
                                                              animations:^ {
                                                                  
                                                                  [((UIImageView *)([self.mainCollectionView backgroundView])) setAlpha:1.0];
                                                                  
                                                                  [self.mainCollectionView setBackgroundColor:[UIColor colorWithRed:(0.9) green:(0.9) blue:(0.9) alpha:1.0]];
                                                                  
                                                                  [self showBackgroundAddButton];
                                                                  
                                                                  if (([_resultsArray count] > 0))
                                                                  {
                                                                      [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
                                                                      [self hideBackgroundAddButton];
                                                                  }
                                                                  
                                                                  if (!([self.selectFeaturesView isHidden]))
                                                                  {
                                                                      [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
                                                                      [self hideBackgroundAddButton];
                                                                  }
                                                              }
                                                              completion:^(BOOL finished) {
                                                                  
                                                                  bChangingBackgroundAd = NO;
                                                                  
                                                                  if (([_resultsArray count] > 0))
                                                                  {
                                                                      [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
                                                                      [self hideBackgroundAddButton];
                                                                  }
                                                                  
                                                                  if (!([self.selectFeaturesView isHidden]))
                                                                  {
                                                                      [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
                                                                      [self hideBackgroundAddButton];
                                                                  }
                                                              }];
                                         }];
                    }
                    else
                    {
                        // Load image in the background
                        
                        __weak SearchBaseViewController *weakSelf = self;
                        
                        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                            
                            UIImage * image = [UIImage cachedImageWithURL:backgroundImageURL];
                            
                            if(image == nil)
                            {
                                image = [UIImage imageNamed:@"Splash_Background.png"];
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                // Then set them via the main queue if the cell is still visible.
                                UICollectionView *collectionView = [weakSelf mainCollectionView];
                                
                                [UIView animateWithDuration:1.0
                                                      delay:0
                                                    options:UIViewAnimationOptionCurveEaseOut
                                                 animations:^ {
                                                     
                                                     [((UIImageView *)([collectionView backgroundView])) setAlpha:0.01];
                                                     
                                                     [self.mainCollectionView setBackgroundColor:[UIColor whiteColor]];
                                                 }
                                                 completion:^(BOOL finished) {
                                                     
                                                     [((UIImageView *)([collectionView backgroundView])) setImage:[UIImage convertImageToGrayScale:image]];
                                                     
                                                     [UIView animateWithDuration:1.0
                                                                           delay:0
                                                                         options:UIViewAnimationOptionCurveEaseOut
                                                                      animations:^ {
                                                                          
                                                                          [((UIImageView *)([collectionView backgroundView])) setAlpha:1.0];
                                                                          
                                                                          [self.mainCollectionView setBackgroundColor:[UIColor colorWithRed:(0.9) green:(0.9) blue:(0.9) alpha:1.0]];
                                                                          
                                                                          [self showBackgroundAddButton];
                                                                          
                                                                          if (([_resultsArray count] > 0))
                                                                          {
                                                                              [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
                                                                              [self hideBackgroundAddButton];
                                                                          }
                                                                          
                                                                          if (!([self.selectFeaturesView isHidden]))
                                                                          {
                                                                              [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
                                                                              [self hideBackgroundAddButton];
                                                                          }
                                                                      }
                                                                      completion:^(BOOL finished) {
                                                                          
                                                                          bChangingBackgroundAd = NO;
                                                                          
                                                                          if (([_resultsArray count] > 0))
                                                                          {
                                                                              [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
                                                                              [self hideBackgroundAddButton];
                                                                          }
                                                                          
                                                                          if (!([self.selectFeaturesView isHidden]))
                                                                          {
                                                                              [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
                                                                              [self hideBackgroundAddButton];
                                                                          }
                                                                      }];
                                                 }];
                            });
                        }];
                        
                        operation.queuePriority = NSOperationQueuePriorityHigh;
                        
                        [self.preloadImagesQueue addOperation:operation];
                    }
                    
                    return;
                }
            }
        }
    }
    else
    {
        [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];//[UIImage imageNamed:@"Splash_Background.png"]];
        [self hideBackgroundAddButton];
        return;
    }
    
    [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:[UIImage imageNamed:@"Splash_Background.png"]];
    [self hideBackgroundAddButton];
}

// Set the proper title to the background ad button
-(NSString *)getBackgroundAdTitle
{
    if(!(_currentBackgroundAd == nil))
    {
        //        if(!(_currentBackgroundAd.userId == nil))
        //        {
        //            if(!([_currentBackgroundAd.userId isEqualToString:@""]))
        //            {
        NSString * backgroundAdText = nil;
        
        if(!(_currentBackgroundAd.secondaryInformation == nil))
        {
            if(!([_currentBackgroundAd.secondaryInformation isEqualToString:@""]))
            {
                backgroundAdText = _currentBackgroundAd.secondaryInformation;
            }
        }
        
        if(!(_currentBackgroundAd.mainInformation == nil))
        {
            if(!([_currentBackgroundAd.mainInformation isEqualToString:@""]))
            {
                if(!(backgroundAdText == nil))
                {
                    backgroundAdText = [backgroundAdText stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"_BACKGROUNDAD_SEPARATOR_", nil), _currentBackgroundAd.mainInformation]];
                }
                else
                {
                    backgroundAdText = _currentBackgroundAd.mainInformation;
                }
            }
        }
        
        if(!(_currentBackgroundAd.userId == nil))
        {
            if(!([_currentBackgroundAd.userId isEqualToString:@""]))
            {
                if(!(backgroundAdText == nil))
                {
                    backgroundAdText = [backgroundAdText stringByAppendingString:[NSString stringWithFormat:@"  |  %@", NSLocalizedString(@"_BACKGROUNDAD_ACTION_MODEL_", nil)]];
                }
                else
                {
                    backgroundAdText = NSLocalizedString(@"_BACKGROUNDAD_ACTION_MODEL_", nil);
                }
            }
        }
        
        return backgroundAdText;
        //            }
        //
        //        }
        // CHECK OTHER AD TYPES...
        //        else if(...)
        //        {
        //
        //        }
    }
    
    return nil;
}

// Setup and show the background Ad button
-(void) showBackgroundAddButton
{
    if(!(self.parentViewController == nil))
    {
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!(appDelegate.addingProductsToWardrobeID == nil))
    {
        if(!([appDelegate.addingProductsToWardrobeID isEqualToString:@""]))
        {
            [self.searchBackgroundAdButton setHidden:YES];
            
            return;
        }
    }
    
    if(!(_currentBackgroundAd == nil))
    {
        NSString * backgroundAdTitle = [self getBackgroundAdTitle];
        
        if(!(backgroundAdTitle == nil))
        {
            if(!([backgroundAdTitle isEqualToString:@""]))
            {
                [self.searchBackgroundAdButton setTitle:[backgroundAdTitle uppercaseString] forState:UIControlStateNormal];
                
                [self.searchBackgroundAdButton setHidden:NO];
                
                return;
            }
        }
    }
    
    [self.searchBackgroundAdButton setHidden:YES];
}

// Reset and hide the background Ad buttton
-(void)hideBackgroundAddButton
{
    [self.searchBackgroundAdButton setTitle:[NSLocalizedString(@"_BACKGROUNDAD_TEXT_DEFAULT_", nil) uppercaseString] forState:UIControlStateNormal];
    
    [self.searchBackgroundAdButton setHidden:YES];
}

// OVERRIDE: Background Ad action
- (void)onTapBackgroundAdButton:(UIButton *)sender
{
    if(!(_currentBackgroundAd == nil))
    {
        if(!(_currentBackgroundAd.userId == nil))
        {
            if(!([_currentBackgroundAd.userId isEqualToString:@""]))
            {
                // Perform request to get the result contents
                NSLog(@"Getting contents for Fashionista: %@", _currentBackgroundAd.userId);
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_currentBackgroundAd.userId, nil];
                
                [self performRestGet:GET_FASHIONISTA withParamaters:requestParameters];
            }
        }
        // CHECK OTHER AD TYPES...
        //        else if(...)
        //        {
        //
        //        }
    }
}

// Initialize the Fetched Results Controller to manage search results
- (void) initFetchedResultsController
{
    NSArray * sortingKeys = nil;
    NSString * sectionKey = nil;
    
    //    if(_searchContext == TRENDING_SEARCH)
    //    {
    //        sortingKeys = [NSArray arrayWithObject:@"order"];
    //        sectionKey = @"group";
    //    }
    //    else
    {
        sortingKeys = [NSArray arrayWithObject:@"order"];
        sectionKey = @"group";
    }
    
    [self initFetchedResultsControllerForCollectionViewWithCellType:@"ResultCell" WithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:_resultsArray sortingWithKeys:sortingKeys ascending:YES andSectionWithKeyPath:sectionKey];
}

// Initialize the Fetched Results Controller to manage search results
- (BOOL) initFetchedResultsControllerForKeywordsForEntity:(NSString *)sEntity withPredicate:(NSString *)sPredicate anOrderBy:(NSString *)sOrder
{
    NSArray * sortingKeys = nil;
    NSString * sectionKey = nil;
    
    sortingKeys = [NSArray arrayWithObject:sOrder];
    
    self.secondFetchedResultsController = nil;
    self.secondFetchRequest = nil;
    
    return [self initFetchedResultsControllerForCollectionViewWithCellType:@"SearchFeatureCell" WithEntity:sEntity andPredicate:sPredicate inArray:_suggestedFilters sortingWithKeys:sortingKeys ascending:YES andSectionWithKeyPath:sectionKey];
}

- (BOOL) initFetchedResultsControllerForKeywordsForEntity:(NSString *)sEntity withPredicateObject:(NSPredicate *)objPredicate anOrderBy:(NSString *)sOrder
{
    NSArray * sortingKeys = nil;
    NSString * sectionKey = nil;
    
    sortingKeys = [NSArray arrayWithObject:sOrder];
    
    self.secondFetchedResultsController = nil;
    self.secondFetchRequest = nil;
    
    return [self initFetchedResultsControllerForCollectionViewWithCellType:@"SearchFeatureCell" WithEntity:sEntity andPredicate:objPredicate sortingWithKeys:sortingKeys ascending:YES andSectionWithKeyPath:sectionKey];
}

- (BOOL) initFetchedResultsControllerForKeywordsForEntity:(NSString *)sEntity withPredicateObject:(NSPredicate *)objPredicate anOrderByArray:(NSArray *)sOrder ascendingArray:(NSArray *)ascendingArray
{
    NSString * sectionKey = nil;
    
    self.secondFetchedResultsController = nil;
    self.secondFetchRequest = nil;
    
    return [self initFetchedResultsControllerForCollectionViewWithCellType:@"SearchFeatureCell" WithEntity:sEntity andPredicate:objPredicate sortingWithKeys:sOrder ascendingArray:ascendingArray andSectionWithKeyPath:sectionKey];
}

// Initialize a specific Fetched Results Controller to fetch the current user wardrobes in order to properly show the hanger button
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
- (BOOL) doesCurrentUserWardrobesContainItemWithId:(GSBaseElement *)item
{
    NSString * itemId = @"";
    
    _wardrobesFetchedResultsController = nil;
    _wardrobesFetchRequest = nil;
    
    [self initFetchedResultsControllerWithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:_userWardrobesElements sortingWithKey:@"idGSBaseElement" ascending:YES];
    
    if (!(item == nil))
    {
        if(!(item.productId == nil))
        {
            if(!([item.productId isEqualToString:@""]))
            {
                itemId = item.productId;
            }
        }
        else if(!(item.fashionistaPostId == nil))
        {
            if(!([item.fashionistaPostId isEqualToString:@""]))
            {
                itemId = item.fashionistaPostId;
            }
        }
        else if(!(item.fashionistaPageId == nil))
        {
            if(!([item.fashionistaPageId isEqualToString:@""]))
            {
                itemId = item.fashionistaPageId;
            }
        }
        else if(!(item.wardrobeId == nil))
        {
            if(!([item.wardrobeId isEqualToString:@""]))
            {
                itemId = item.wardrobeId;
            }
        }
        else if(!(item.wardrobeQueryId == nil))
        {
            if(!([item.wardrobeQueryId isEqualToString:@""]))
            {
                itemId = item.wardrobeQueryId;
            }
        }
        else if(!(item.styleId == nil))
        {
            if(!([item.styleId isEqualToString:@""]))
            {
                itemId = item.styleId;
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
                            if(!(tmpGSBaseElement.productId == nil))
                            {
                                if(!([tmpGSBaseElement.productId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.productId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.fashionistaPostId == nil))
                            {
                                if(!([tmpGSBaseElement.fashionistaPostId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.fashionistaPostId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.fashionistaPageId == nil))
                            {
                                if(!([tmpGSBaseElement.fashionistaPageId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.fashionistaPageId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.wardrobeId == nil))
                            {
                                if(!([tmpGSBaseElement.wardrobeId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.wardrobeId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.wardrobeQueryId == nil))
                            {
                                if(!([tmpGSBaseElement.wardrobeQueryId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.wardrobeQueryId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.styleId == nil))
                            {
                                if(!([tmpGSBaseElement.styleId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.styleId isEqualToString:itemId])
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

// Check if the item is in the current user list of wardrobes
- (BOOL) isThisWardrobeMine:(GSBaseElement *)item
{
    NSString * itemId = @"";
    
    _wardrobesFetchedResultsController = nil;
    _wardrobesFetchRequest = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
                [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"userId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idWardrobe" ascending:YES];
                
                if (!(item == nil))
                {
                    if ((item.brandId == nil) && (item.fashionistaId == nil) && (item.fashionistaPageId == nil) && (item.fashionistaPostId == nil) && (item.productId == nil))
                    {
                        if(item.wardrobeId != nil)
                        {
                            if(!([item.wardrobeId isEqualToString:@""]))
                            {
                                itemId = item.wardrobeId;
                            }
                        }
                        else if(item.wardrobeQueryId != nil)
                        {
                            if(!([item.wardrobeQueryId isEqualToString:@""]))
                            {
                                itemId = item.wardrobeQueryId;
                            }
                        }
                    }
                }
                
                if (!([itemId isEqualToString:@""]))
                {
                    if (!(_wardrobesFetchedResultsController == nil))
                    {
                        if (!((int)[[_wardrobesFetchedResultsController fetchedObjects] count] < 1))
                        {
                            for (Wardrobe *tmpGSBaseElement in [_wardrobesFetchedResultsController fetchedObjects])
                            {
                                if([tmpGSBaseElement isKindOfClass:[Wardrobe class]])
                                {
                                    // Check that the element to search is valid
                                    if (!(tmpGSBaseElement == nil))
                                    {
                                        if(tmpGSBaseElement.idWardrobe != nil)
                                        {
                                            if(!([tmpGSBaseElement.idWardrobe isEqualToString:@""]))
                                            {
                                                if ([tmpGSBaseElement.idWardrobe isEqualToString:itemId])
                                                {
                                                    return YES;
                                                }
                                            }
                                        }
                                        //                            else if(tmpGSBaseElement.wardrobeQueryId != nil)
                                        //                            {
                                        //                                if(!([tmpGSBaseElement.wardrobeQueryId isEqualToString:@""]))
                                        //                                {
                                        //                                    if ([tmpGSBaseElement.wardrobeQueryId isEqualToString:itemId])
                                        //                                    {
                                        //                                        return YES;
                                        //                                    }
                                        //                                }
                                        //                            }
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

// Initialize a specific Fetched Results Controller to fetch the current user follows in order to properly show the heart button
- (BOOL)initFollowsFetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate inArray:(NSArray *)arrayForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    BOOL bReturn = FALSE;
    
    if(_followsFetchedResultsController == nil)
    {
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        if (_followsFetchRequest == nil)
        {
            if([arrayForPredicate count] > 0)
            {
                _followsFetchRequest = [[NSFetchRequest alloc] init];
                
                // Entity to look for
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                
                [_followsFetchRequest setEntity:entity];
                
                // Filter results
                
                [_followsFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, arrayForPredicate]];
                
                // Sort results
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                
                [_followsFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                [_followsFetchRequest setFetchBatchSize:20];
            }
        }
        
        if(_followsFetchRequest)
        {
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_followsFetchRequest sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_followsFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
            
            _followsFetchedResultsController = fetchedResultsController;
            
            _followsFetchedResultsController.delegate = self;
        }
        
        if(_followsFetchedResultsController)
        {
            // Perform fetch
            
            NSError *error = nil;
            
            if (![_followsFetchedResultsController performFetch:&error])
            {
                // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                
                NSLog(@"Couldn't fetched wardrobes. Unresolved error: %@, %@", error, [error userInfo]);
                
                return FALSE;
            }
            
            bReturn = ([_followsFetchedResultsController fetchedObjects].count > 0);
        }
    }
    
    return bReturn;
}

// Check if the user is in the current user list of follows
- (BOOL) doesCurrentUserFollowsStylistWithId:(NSString *)stylistId
{
    _followsFetchedResultsController = nil;
    _followsFetchRequest = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
                if(!(stylistId == nil))
                {
                    if (!([stylistId isEqualToString:@""]))
                    {
                        [self initFollowsFetchedResultsControllerWithEntity:@"Follow" andPredicate:@"followingId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idFollow" ascending:YES];
                        
                        if (!(_followsFetchedResultsController == nil))
                        {
                            if (!((int)[[_followsFetchedResultsController fetchedObjects] count] < 1))
                            {
                                for (Follow *tmpFollow in [_followsFetchedResultsController fetchedObjects])
                                {
                                    if([tmpFollow isKindOfClass:[Follow class]])
                                    {
                                        // Check that the follow is valid
                                        if (!(tmpFollow == nil))
                                        {
                                            if(!(tmpFollow.followedId == nil))
                                            {
                                                if(!([tmpFollow.followedId isEqualToString:@""]))
                                                {
                                                    if ([tmpFollow.followedId isEqualToString:stylistId])
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
                }
            }
        }
    }
    
    return NO;
}

// Check if the item is in the current user list of wardrobes
- (BOOL) isThisUserMe:(GSBaseElement *)item
{
    if (!(item == nil))
    {
        if (!(item.fashionistaId == nil))
        {
            if(![item.fashionistaId isEqualToString:@""])
            {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                if (!(appDelegate.currentUser == nil))
                {
                    if(!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            if([appDelegate.currentUser.idUser isEqualToString:item.fashionistaId])
                            {
                                return YES;
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
    if ([cellType isEqualToString:@"ResultCell"])
    {
        return [_resultsGroups count];
        
        //return [[[self getFetchedResultsControllerForCellType:cellType] sections] count];
    }
    
    if (bUpdatingSelectionColor)
    {
        return 1;
    }
    
    if (bFiltersNew)
    {
        return [filterManager numberOfSectionsFilterForCelltype:cellType];
    }

    
    if (arSectionsProductType != nil)
    {
        [arSectionsProductType removeAllObjects];
    }
    else
    {
        arSectionsProductType = [[NSMutableArray alloc] init];
    }
    
    BOOL bOrderByProductGroup = NO;
    NSMutableArray * arrayProductType = [[NSMutableArray alloc] init];
    for(NSObject * obj in [[self getFetchedResultsControllerForCellType:cellType] fetchedObjects])
    {
        if([obj isKindOfClass:[ProductGroup class]])
        {
            ProductGroup *pg = (ProductGroup *)obj;
            BOOL bAdd = YES;
            if (selectedProductCategory != nil)
            {
                bAdd = NO;
                //                for (ProductGroup * pgSelected in arSelectedSubProductCategory)
                //                {
                //                    if ([pgSelected isChild:pg])
                //                    {
                //                        bAdd = YES;
                //                        break;
                //                    }
                //                }
                
                if (bAdd == NO)
                {
                    for (ProductGroup * pgSelected in arExpandedSubProductCategory)
                    {
                        if ([pgSelected isChild:pg])
                        {
                            bAdd = YES;
                            break;
                        }
                    }
                    
                    if (bAdd == NO)
                    {
                        if (_searchContext == PRODUCT_SEARCH)
                        {
                            bAdd = ([selectedProductCategory isChild:pg]);
                        }
                        else
                        {
                            for(ProductGroup * pgSelected in arSelectedProductCategories)
                            {
                                if ([pgSelected isChild:pg])
                                {
                                    bAdd = YES;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            
            if (bAdd)
            {
                if(_foundSuggestions.count == 0 || [_foundSuggestions objectForKey:pg.idProductGroup])
                    [arrayProductType addObject:obj];
            }
            bOrderByProductGroup = YES;
        }
    }
    
    if ((selectedProductCategory != nil) && (bOrderByProductGroup))
    {
        NSMutableArray * arrayToOrder = [[NSMutableArray alloc] initWithArray:arrayProductType];
        [arrayProductType removeAllObjects];
        if (_searchContext == PRODUCT_SEARCH)
        {
            arrayProductType = [self orderProductGroup:selectedProductCategory usingArray:arrayToOrder level:0];
        }
        else
        {
            for(ProductGroup * pgSelected in arSelectedProductCategories)
            {
                NSMutableArray * arrayTemp = [self orderProductGroup:pgSelected usingArray:arrayToOrder level:0];
                [arrayProductType addObjectsFromArray:arrayTemp];
            }
        }
        
        
        //        if (scrollByAlphabet == NO)
        //        {
        //            [self initAlphabetwithArray:arSectionsProductType withSections:YES];
        //        }
        //        scrollByAlphabet = NO;
        //
        //        if ((self.secondCollectionView.alpha < 1.0) || (self.secondCollectionView.isHidden)) // si la vista esta en alpha a 1 es que esta visible, si tiene otro valor es que se debe estar cerrando.
        //        {
        //            [self hideAlphabet];
        //        }
        
        
        return arSectionsProductType.count;
    }
    
    return 1;
}

// OVERRIDE: Calculate the actual section in FetchedResultsController based on the Result Groups
- (int) getFetchedResultsControllerSectionForSection:(int) section
{
    int frcSection = section;
    
    if (!(_resultsGroups == nil))
    {
        if(!(([_resultsGroups count]) == 0))
        {
            if(!(section > ([_resultsGroups count] - 1)))
            {
                for (int i = 0; i < section; i++)
                {
                    ResultsGroup * resultGroup = [_resultsGroups objectAtIndex:i];
                    
                    //if (([resultGroup.last_order intValue] - [resultGroup.first_order intValue]) == 0)
                    if([resultGroup.last_order intValue] == -1)
                    {
                        frcSection--;
                    }
                }
                
                return frcSection;
            }
        }
    }
    
    if (arSectionsProductType != nil)
    {
        
    }
    
    return -1;
}

// OVERRIDE: Number of items in each section for the main collection view
- (NSInteger)numberOfItemsInSection:(NSInteger)section forCollectionViewWithCellType:(NSString *)cellType
{
    
    if ([cellType isEqualToString:@"ResultCell"])
    {
        if (!(_resultsGroups == nil))
        {
            if(!(([_resultsGroups count]) == 0))
            {
                if(!(section > ([_resultsGroups count] - 1)))
                {
                    //if(([[([_resultsGroups objectAtIndex:section]) last_order] intValue]) - ([[([_resultsGroups objectAtIndex:section]) first_order] intValue]) == 0)
                    if(([[([_resultsGroups objectAtIndex:section]) last_order] intValue]) == -1)
                    {
                        return 0;
                    }
                    else
                    {
                        //Calculate the actual section in FetchedResultsController
                        int frcSection = [self getFetchedResultsControllerSectionForSection:(int)section];
                        
                        if(frcSection >= 0)
                        {
                            if (!([[self getFetchedResultsControllerForCellType:cellType] sections] == nil))
                            {
                                if(!(([[[self getFetchedResultsControllerForCellType:cellType] sections] count]) == 0))
                                {
                                    if(!(frcSection > ([[[self getFetchedResultsControllerForCellType:cellType] sections] count] - 1)))
                                    {
                                        if (frcSection == 0) {
                                            int n = [[[self getFetchedResultsControllerForCellType:cellType] sections][frcSection] numberOfObjects] + [adList count];
                                            int m = n / ADNUM;
                                            if (m < [adList count]) {
                                                if (n % ADNUM == ADNUM - 1) {
                                                    return [[[self getFetchedResultsControllerForCellType:cellType] sections][frcSection] numberOfObjects] + m + 1;
                                                }
                                                else {
                                                    return [[[self getFetchedResultsControllerForCellType:cellType] sections][frcSection] numberOfObjects] + m;
                                                }
                                            }
                                            else {
                                                return [[[self getFetchedResultsControllerForCellType:cellType] sections][frcSection] numberOfObjects] + [adList count];
                                            }

                                        }
                                        return [[[self getFetchedResultsControllerForCellType:cellType] sections][frcSection] numberOfObjects];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    else if ([cellType isEqualToString:@"SearchFeatureCell"])
    {
        if (bFiltersNew)
        {
            return [filterManager numberOfItemsInSectionFilter:section forCollectionViewWithCellType:cellType];
        }
        
        if(!_filteredFilters)
        {
            _filteredFilters = [[NSMutableArray alloc]init];
        }
        
        [_filteredFilters removeAllObjects];
        
        if (bLocationQuery)
        {
            for(NSString * sobj in _foundSuggestionsLocations)
            {
                [_filteredFilters addObject:sobj];
            }
        }
        else if (bStyleStylistQuery)
        {
            for(NSString * sobj in _foundSuggestionsStyleStylist)
            {
                [_filteredFilters addObject:sobj];
            }
        }
        else
        {
            BOOL bOrderByProductGroup = NO;
            for(NSObject * obj in [[self getFetchedResultsControllerForCellType:cellType] fetchedObjects])
            {
                if([obj isKindOfClass:[ProductGroup class]])
                {
                    ProductGroup *pg = (ProductGroup *)obj;
                    BOOL bAdd = YES;
                    if ((selectedProductCategory != nil) && (!(bUpdatingSelectionColor)))
                    {
                        bAdd = NO;
                        for (ProductGroup * pgSelected in arExpandedSubProductCategory)
                        {
                            if ([pgSelected isChild:pg])
                            {
                                bAdd = YES;
                                break;
                            }
                        }
                        
                        if (bAdd == NO)
                        {
                            if (_searchContext == PRODUCT_SEARCH)
                            {
                                bAdd = ([selectedProductCategory isChild:pg]);
                            }
                            else
                            {
                                for(ProductGroup * pgSelected in arSelectedProductCategories)
                                {
                                    if ([pgSelected isChild:pg])
                                    {
                                        bAdd = YES;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    
                    if (bAdd)
                    {
                        if(_foundSuggestions.count == 0 || [_foundSuggestions objectForKey:pg.idProductGroup])
                            [_filteredFilters addObject:obj];
                    }
                    bOrderByProductGroup = YES;
                }
                else if([obj isKindOfClass:[Feature class]])
                {
                    Feature * cs = (Feature*)obj;
                    int iGender = [self getGenderFromName:cs.name];
                    if(iGender != 0 || [_foundSuggestions count] == 0 || [_foundSuggestions objectForKey:cs.idFeature])
                    {
                        if ([cs isVisibleForGender:iGenderSelected andProductCategory:selectedProductCategory andSubProductCategories:arSelectedSubProductCategory])
                        {
                            [_filteredFilters addObject:obj];
                        }
                    }
                }
                else if([obj isKindOfClass:[Brand class]])
                {
                    Brand * cs = (Brand*)obj;
                    if([_foundSuggestions count] == 0 || [_foundSuggestions objectForKey:cs.idBrand])
                        [_filteredFilters addObject:obj];
                }
                
            }
            
            if ((bOrderByProductGroup) && (selectedProductCategory != nil) && (!(bUpdatingSelectionColor)))
            {
                SectionProductType * objSection = [arSectionsProductType objectAtIndex:section];
                NSArray * arObjects = objSection.arElements;
                unsigned long iNum = [arObjects count];//[[[self getFetchedResultsControllerForCellType:cellType] sections][0] numberOfObjects];
                NSLog(@" ------- > %lu", iNum);
                
                return iNum;
            }
        }
        
        unsigned long iNum = [_filteredFilters count];//[[[self getFetchedResultsControllerForCellType:cellType] sections][0] numberOfObjects];
        NSLog(@" ------- > %lu", iNum);
        //        return [[[self getFetchedResultsControllerForCellType:cellType] sections][0] numberOfObjects];
        return iNum;
    }
    
    return 0;
}


-(NSMutableArray *) orderProductGroup:(ProductGroup *) pgParam usingArray:(NSMutableArray *)arrayToOrder level:(int) iLevel
{
    NSMutableArray * arrayRest = [[NSMutableArray alloc] init];
    NSMutableArray * arrayThisChild = [[NSMutableArray alloc] init];
    NSMutableArray  * arChildren = [pgParam getChildren];
    for(ProductGroup * pg in arChildren)
    {
        if ([arrayToOrder containsObject:pg])
        {
            [arrayThisChild addObject:pg];
            [arrayRest addObject:pg];
            NSMutableArray * temp = [self orderProductGroup:pg usingArray:arrayToOrder level:iLevel+1];
            
            if (temp.count > 0)
            {
                // new array for the sections
                NSArray * arObjects = [[NSArray alloc] initWithArray:arrayThisChild copyItems:NO];
                SectionProductType * newSection = [SectionProductType new];
                newSection.iLevel = iLevel;
                NSSortDescriptor *sortDescriptorOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
                NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"app_name" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil];
                NSArray *sortedArray = [arObjects sortedArrayUsingDescriptors:sortDescriptors];
                newSection.arElements = sortedArray;
                [arSectionsProductType insertObject:newSection atIndex:arSectionsProductType.count-1];
                [arrayThisChild removeAllObjects];
            }
            
            [arrayRest addObjectsFromArray:temp];
        }
    }
    if (arrayThisChild.count > 0 )
    {
        NSArray * arObjects = [[NSArray alloc] initWithArray:arrayThisChild copyItems:NO];
        SectionProductType * newSection = [SectionProductType new];
        newSection.iLevel = iLevel;
        
        NSSortDescriptor *sortDescriptorOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
        NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"app_name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil];
        NSArray *sortedArray = [arObjects sortedArrayUsingDescriptors:sortDescriptors];
        
        newSection.arElements = sortedArray;
        
        [arSectionsProductType addObject:newSection];
    }
    
    return arrayRest;
    
}


// OVERRIDE: Return the layout to be shown in a cell for a collection view
- (resultCellLayout)getLayoutTypeForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"ResultCell"])
    {
        GSBaseElement *tmpResult = nil;
        int index = indexPath.item / ADNUM;
        //Calculate the actual section in FetchedResultsController
        int frcSection = [self getFetchedResultsControllerSectionForSection:(int)indexPath.section];
        
        if(frcSection >= 0)
        {
            if (!([[self getFetchedResultsControllerForCellType:cellType] sections] == nil))
            {
                if(!(([[[self getFetchedResultsControllerForCellType:cellType] sections] count]) == 0))
                {
                    if(!(frcSection > ([[[self getFetchedResultsControllerForCellType:cellType] sections] count] - 1)))
                    {
                        
                        if (frcSection == 0) {
                            
                            if (index < [adList count]) {
                                int n = indexPath.item - index;
                                NSLog(@"@@@@@@ Index @@@@@@@ : %i", n);
                                tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item - index inSection:frcSection]];
                            }
                            else {
                                int n = indexPath.item - [adList count];
                                NSLog(@"@@@@@@ Index @@@@@@@ : %i", n);
                                tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:(indexPath.item - [adList count]) inSection:frcSection]];
                            }
                        }
                        else {
                            tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:frcSection]];
                        }
                    
                    }
                }
            }
        }
        
        // Check that the element to search is valid
        
        if (!(tmpResult == nil))
        {
            if(!(tmpResult.productId == nil))
            {
                if(!([tmpResult.productId isEqualToString:@""]))
                {
                    return PRODUCTLAYOUT;
                }
            }
            //            else if(!(tmpResult.articleId == nil))
            //            {
            //                if(!([tmpResult.articleId isEqualToString:@""]))
            //                {
            //                    return ARTICLELAYOUT;
            //                }
            //            }
            //            else if(!(tmpResult.tutorialId == nil))
            //            {
            //                if(!([tmpResult.tutorialId isEqualToString:@""]))
            //                {
            //                    return TUTORIALLAYOUT;
            //                }
            //            }
            //            else if(!(tmpResult.reviewId == nil))
            //            {
            //                if(!([tmpResult.reviewId isEqualToString:@""]))
            //                {
            //                    return REVIEWLAYOUT;
            //                }
            //            }
            else if(!(tmpResult.fashionistaPostId == nil))
            {
                if(!([tmpResult.fashionistaPostId isEqualToString:@""]))
                {
                    return POSTLAYOUT;
                }
            }
            else if(!(tmpResult.fashionistaPageId == nil))
            {
                if(!([tmpResult.fashionistaPageId isEqualToString:@""]))
                {
                    return PAGELAYOUT;
                }
            }
            else if(!(tmpResult.wardrobeId == nil))
            {
                if(!([tmpResult.wardrobeId isEqualToString:@""]))
                {
                    return WARDROBELAYOUT;
                }
            }
            else if(!(tmpResult.wardrobeQueryId == nil))
            {
                if(!([tmpResult.wardrobeQueryId isEqualToString:@""]))
                {
                    return WARDROBELAYOUT;
                }
            }
            else if(!(tmpResult.fashionistaId == nil))
            {
                if(!([tmpResult.fashionistaId isEqualToString:@""]))
                {
                    return STYLISTLAYOUT;
                }
            }
            else if(!(tmpResult.brandId == nil))
            {
                if(!([tmpResult.brandId isEqualToString:@""]))
                {
                    return BRANDLAYOUT;
                }
            }
        }
    }
    
    return PRODUCTLAYOUT;
}

// OVERRIDE: Return the size of the image to be shown in a cell for a collection view
- (CGSize)getSizeForImageInCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"ResultCell"])
    {
        int index = indexPath.item / ADNUM;
        //Calculate the actual section in FetchedResultsController
        int frcSection = [self getFetchedResultsControllerSectionForSection:(int)indexPath.section];
        
        if(frcSection >= 0)
        {
            if (!([[self getFetchedResultsControllerForCellType:cellType] sections] == nil))
            {
                if(!(([[[self getFetchedResultsControllerForCellType:cellType] sections] count]) == 0))
                {
                    if(!(frcSection > ([[[self getFetchedResultsControllerForCellType:cellType] sections] count] - 1)))
                    {
                        if (frcSection == 0) {
                            if (index < [adList count]) {
                                if (indexPath.item % ADNUM == ADNUM - 1) {
                                    Ad *tmpResult = [adList objectAtIndex:index];
                                    return CGSizeMake([tmpResult.width intValue], [tmpResult.height intValue]);
                                }
                                GSBaseElement *tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item - index inSection:frcSection]];
                                
                                return CGSizeMake([tmpResult.preview_image_width intValue], [tmpResult.preview_image_height intValue]);
                            }
                            else {
                                GSBaseElement *tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:(indexPath.item - [adList count]) inSection:frcSection]];
                                
                                return CGSizeMake([tmpResult.preview_image_width intValue], [tmpResult.preview_image_height intValue]);
                            }
                        }
                        else {
                            GSBaseElement *tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:frcSection]];
                            
                            return CGSizeMake([tmpResult.preview_image_width intValue], [tmpResult.preview_image_height intValue]);
                        }
                    }
                }
            }
            
        }
    }
    
    return CGSizeMake(0, 0);
}

// Get number of images from the codificated string
- (NSNumber *) getImagesNumFromString:(NSString*)infoString
{
    // infoString: "XX XX XX"
    
    NSArray* values = [[infoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString: @" "];
    
    if(!(values == nil))
    {
        if([values count] > 0)
        {
            if(!([values objectAtIndex:0] == nil))
            {
                if([[values objectAtIndex:0] isKindOfClass:[NSString class]])
                {
                    if(!([[values objectAtIndex:0] isEqualToString:@""]))
                    {
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        
                        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                        
                        NSNumber *imagesNum = [numberFormatter numberFromString:[values objectAtIndex:0]];
                        
                        return ((imagesNum > 0) ? (imagesNum) : ([NSNumber numberWithInt:0]));
                    }
                }
            }
        }
    }
    
    return nil;
}

// Get number of likes from the codificated string
- (NSNumber *) getLikesNumFromString:(NSString*)infoString
{
    // infoString: "XX XX XX"
    
    NSArray* values = [[infoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString: @" "];
    
    if(!(values == nil))
    {
        if([values count] > 1)
        {
            if(!([values objectAtIndex:1] == nil))
            {
                if([[values objectAtIndex:1] isKindOfClass:[NSString class]])
                {
                    if(!([[values objectAtIndex:1] isEqualToString:@""]))
                    {
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        
                        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                        
                        NSNumber *likesNum = [numberFormatter numberFromString:[values objectAtIndex:1]];
                        
                        return ((likesNum > 0) ? (likesNum) : ([NSNumber numberWithInt:0]));
                    }
                }
            }
        }
    }
    
    return nil;
}

// Get number of comments from the codificated string
- (NSNumber *) getCommentsNumFromString:(NSString*)infoString
{
    // infoString: "XX XX XX"
    
    NSArray* values = [[infoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString: @" "];
    
    if(!(values == nil))
    {
        if([values count] > 2)
        {
            if(!([values objectAtIndex:2] == nil))
            {
                if([[values objectAtIndex:2] isKindOfClass:[NSString class]])
                {
                    if(!([[values objectAtIndex:2] isEqualToString:@""]))
                    {
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        
                        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                        
                        NSNumber *commentsNum = [numberFormatter numberFromString:[values objectAtIndex:2]];
                        
                        return ((commentsNum > 0) ? (commentsNum) : ([NSNumber numberWithInt:0]));
                    }
                }
            }
        }
    }
    
    return nil;
}

-(NSInteger)getADcount {
    return [adList count];
}

// OVERRIDE: Return the content to be shown in a cell for a collection view
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"ResultCell"])
    {
        int index = indexPath.item / ADNUM;
        GSBaseElement *tmpResult = nil;
        
        //Calculate the actual section in FetchedResultsController
        int frcSection = [self getFetchedResultsControllerSectionForSection:(int)indexPath.section];
        
        if(frcSection >= 0)
        {
            if (!([[self getFetchedResultsControllerForCellType:cellType] sections] == nil))
            {
                if(!(([[[self getFetchedResultsControllerForCellType:cellType] sections] count]) == 0))
                {
                    if(!(frcSection > ([[[self getFetchedResultsControllerForCellType:cellType] sections] count] - 1)))
                    {
                        if (_fashionistaSearch) {
                            tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:frcSection]];
                        }
                        else {
                            if (frcSection == 0) {
                                if (index < [adList count] && indexPath.item % ADNUM == ADNUM - 1) {
                                    tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item - index inSection:frcSection]];
                                }
                                else {
                                    if (index > [adList count]) {
                                        tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:(indexPath.item - [adList count]) inSection:frcSection]];
                                    }
                                    else {
                                        tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item - index inSection:frcSection]];
                                    }
                                }
                            }
                            else {
                                tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:frcSection]];
                            }
                        }
                    }
                }
            }
        }
        
        if(!(tmpResult == nil))
        {
            NSNumber * imagesNum = nil;
            NSNumber * likesNum = nil;
            NSNumber * commentsNum = nil;
            
            NSString * cellTitle = [NSString stringWithFormat:@"%@", tmpResult.name];
            
            resultCellLayout layout = [self getLayoutTypeForCellWithType:cellType AtIndexPath:indexPath];
            
            NSArray * cellContent;
            if (layout == BRANDLAYOUT)
            {
                cellTitle = tmpResult.mainInformation;
                if (tmpResult.preview_image != nil)
                    cellContent = [NSArray arrayWithObjects: tmpResult.preview_image,[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO], cellTitle,nil];
                else
                    cellContent = [NSArray arrayWithObjects: @"",[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO], cellTitle,nil];
            }
            else
            {
                if (!_fashionistaSearch && frcSection == 0 && index < [adList count]) {
                    if (indexPath.item % ADNUM == ADNUM - 1) {
                        
                        
                        {
                            Ad *ad = [adList objectAtIndex:index];
                            NSString *imageURL = [NSString stringWithFormat:@"%@%@", IMAGESBASEURL, ad.image];
                            cellContent = [NSArray arrayWithObjects:imageURL, nil];
                            [adCells addObject:cellContent];
                            return cellContent;
                        }
                    }
                }
                if(!((layout == WARDROBELAYOUT) || (layout == STYLISTLAYOUT)))
                {
                    if(!((tmpResult.mainInformation == nil) || ([tmpResult.mainInformation isEqualToString:@""])))
                    {
                        cellTitle = (((layout == PRODUCTLAYOUT)) ? ([NSString stringWithFormat:@"%@\n%@", tmpResult.mainInformation, tmpResult.name]) : ([NSString stringWithFormat:NSLocalizedString(@"_AUTHOR_AND_TITLE_", nil), tmpResult.mainInformation, ((tmpResult.name == nil) ? (@"") : (tmpResult.name))]));;
                    }
                }
                
                if(layout == STYLISTLAYOUT)
                {
                    if(!((tmpResult.mainInformation == nil) || ([tmpResult.mainInformation isEqualToString:@""])))
                    {
                        cellTitle = tmpResult.mainInformation;
                    }
                }
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                BOOL bShowAddToWardrobe = NO;
                if (appDelegate.currentUser != nil)
                {
                    if(layout == STYLISTLAYOUT)
                    {
                        bShowAddToWardrobe = ![self isThisUserMe:tmpResult];
                    }
                    else
                    {
                        bShowAddToWardrobe = ![self isThisWardrobeMine:tmpResult];
                    }
                }
                
                if(layout == POSTLAYOUT)
                {
                    imagesNum = [self getImagesNumFromString:tmpResult.name];
                    likesNum = [self getLikesNumFromString:tmpResult.name];
                    commentsNum = [self getCommentsNumFromString:tmpResult.name];
                }
                
                NSLog(@"Image: %@", tmpResult.preview_image);
                
                cellContent = [NSArray arrayWithObjects: tmpResult.preview_image,
                               [NSNumber numberWithBool:bShowAddToWardrobe],// variable to show or not the button to add item to wardrobe
                               ((layout == STYLISTLAYOUT) ? ([NSNumber numberWithBool:[self doesCurrentUserFollowsStylistWithId:tmpResult.fashionistaId]]) : ([NSNumber numberWithBool:[self doesCurrentUserWardrobesContainItemWithId:tmpResult]])),
                               cellTitle,
                               ((!(layout == PRODUCTLAYOUT)) ? ((layout == WARDROBELAYOUT) ? (tmpResult.mainInformation) : (tmpResult.additionalInformation)) : (((tmpResult.additionalInformation == nil) || ([tmpResult.additionalInformation isEqualToString:@""])) ? (NSLocalizedString(@"_PASTCOLLECTIONPRODUCT_", nil)) : (([tmpResult.recommendedPrice floatValue] > 0) ? ([NSString stringWithFormat:@"$%.2f", [tmpResult.recommendedPrice floatValue]]) : (NSLocalizedString(@"_PRICE_NOT_AVAILABLE_", nil))))),
                               [NSNumber numberWithBool:tmpResult.additionalInformation.boolValue],
                               imagesNum,
                               likesNum,
                               commentsNum,
                               nil];
                if(layout == STYLISTLAYOUT)
                {
                    NSMutableArray* moreContent = [NSMutableArray arrayWithArray:cellContent];
                    [moreContent addObject:tmpResult.fashionistaId];
                    if(!(tmpResult.name==nil)){
                        [moreContent addObject:tmpResult.name];
                    }
                    cellContent = moreContent;
                }
            }
            
            return cellContent;
        }
    }
    else if ([cellType isEqualToString:@"SearchFeatureCell"])
    {
        if (bFiltersNew)
        {
            return [filterManager getContentFilterForCellWithType:cellType AtIndexPath:indexPath];
        }
        
        UIColor *backLabelColor = [UIColor whiteColor];
        long iIdxSelected = -1;
        //        NSObject * tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
        NSObject * tmpResult = [_filteredFilters objectAtIndex:indexPath.item];
        SectionProductType * objSection = nil;
        if ((arSectionsProductType.count > indexPath.section) && (!(bUpdatingSelectionColor)))
        {
            objSection = [arSectionsProductType objectAtIndex:indexPath.section];
            NSArray * arElements = objSection.arElements;
            tmpResult = [arElements objectAtIndex:indexPath.item];
        }
        
        NSString * image = @"no_image.png";
        NSString * sName = @"";
        NSString * sNameCheck = @"";
        
        // comprobamos el tamaño de la celda, si es por defecto mostramos el zoom in, sino no.
        NSNumber * numberShowZoom = [NSNumber numberWithBool:YES];
        NSNumber * numberShowExpand = [NSNumber numberWithBool:NO];
        
        if ([tmpResult isKindOfClass:[ Brand class]])
        {
            Brand * brand = (Brand *)tmpResult;
            sNameCheck = sName = brand.name;
            if(brand.logo)
                image = brand.logo;
        }
        else if ([tmpResult isKindOfClass:[ Feature class]])
        {
            Feature * feature = (Feature *)tmpResult;
            sName = [feature getNameForApp];
            sNameCheck = feature.name;
            ProductGroup * subProductCategory = nil;
            if ((arSelectedSubProductCategory.count > 0) && (arSelectedSubProductCategory.count <= 1))
            {
                subProductCategory = [arSelectedSubProductCategory objectAtIndex:0];
            }
            //            image = [feature getIconForGender:iGenderSelected andProductCategoryParent:selectedProductCategory andProductCategoryChild:subProductCategory byDefault:@"no_image.png"];
            image = [feature getIconForGender:iGenderSelected andProductCategoryParent:selectedProductCategory andSubProductCategories:arSelectedSubProductCategory byDefault:@"no_image.png"];
            //            if (feature.icon)
            //                image = feature.icon;
        }
        else if ([tmpResult isKindOfClass:[ ProductGroup class]])
        {
            ProductGroup * productCategory = (ProductGroup *)tmpResult;
            
            sName = [productCategory getNameForApp];
            sNameCheck = productCategory.name;
            image = [productCategory getIconForGender:iGenderSelected byDefault:@"no_image.png"];
            
            if (productCategory == selectedProductCategory)
            {
                backLabelColor = [UIColor colorWithRed:(244/255.0) green:(206/255.0) blue:(118/255.0) alpha:1.0f];
                iIdxSelected = 0;
            }
            
            if ((selectedProductCategory != nil) && (!(bUpdatingSelectionColor)))
            {
                // check if some of the children are in found suggestions
                
                if ([productCategory getChildrenInFoundSuggestions:_foundSuggestions forGender:iGenderSelected].count > 0)
                {
                    numberShowExpand = [NSNumber numberWithInt:1];
                    if ([arExpandedSubProductCategory containsObject:productCategory])
                    {
                        numberShowExpand = [NSNumber numberWithInt:2];
                    }
                }
            }
            
        }
        else
        {
            NSLog(@"%@", NSStringFromClass([tmpResult class]));
        }
        
        NSString * sNameTrimmed = [sName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString * sNameCheckTrimmed = [sNameCheck stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (iIdxSelected == -1)
        {
            iIdxSelected =[self iIdxFilterSelected:sNameCheckTrimmed];
            
            if (iIdxSelected != -1)
            {
                backLabelColor = [UIColor colorWithRed:(244/255.0) green:(206/255.0) blue:(118/255.0) alpha:1.0f];
            }
            else
            {
                if ([tmpResult isKindOfClass:[ ProductGroup class]])
                {
                    ProductGroup * productCategory = (ProductGroup *)tmpResult;
                    if (objSection != nil)
                    {
                        if (objSection.iLevel == 0)
                        {
                            // check, buscando si el objeto tiene algun hijo seleccionado. Bucle recorrriendo el array de subcategorias selecionadas irando si alguno es hijo
                            // si tiene algun hijo seleccionado lo marcamos con color mas atenuado
                            for(ProductGroup  * pg in arSelectedSubProductCategory)
                            {
                                if ([productCategory isChild:pg])
                                {
                                    backLabelColor = [UIColor colorWithRed:(254/255.0) green:(230/255.0) blue:(190/255.0) alpha:1.0f];
                                    break;
                                }
                            }
                        }
                        else
                        {
                            ProductGroup * pgParent = productCategory.parent;
                            
                            // comprobamos que el padre está seleccionado
                            BOOL bParentSelected = NO;
                            for (ProductGroup * pgSelected in arSelectedSubProductCategory)
                            {
                                if ([pgSelected.idProductGroup isEqualToString:pgParent.idProductGroup])
                                {
                                    bParentSelected = YES;
                                    break;
                                }
                            }
                            
                            if (bParentSelected)
                            {
                                BOOL bSiblingSelected = NO;
                                for (ProductGroup * pg in pgParent.getChildren)
                                {
                                    for (ProductGroup * pgSelected in arSelectedSubProductCategory)
                                    {
                                        if ([pgSelected.idProductGroup isEqualToString:pg.idProductGroup])
                                        {
                                            bSiblingSelected = YES;
                                            break;
                                        }
                                    }
                                    
                                    if (bSiblingSelected)
                                        break;
                                }
                                
                                if (bSiblingSelected == NO)
                                {
                                    backLabelColor = [UIColor colorWithRed:(254/255.0) green:(230/255.0) blue:(190/255.0) alpha:1.0f];
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return [NSArray arrayWithObjects: image, sNameTrimmed.uppercaseString, backLabelColor, numberShowZoom, numberShowExpand, nil];
        //        return [NSArray arrayWithObjects: image, sNameTrimmed, backLabelColor, nil];
        
    }
    
    return nil;
}

// OVERRIDE: Return if the first section is empty and it should, therefore, be notified to the user
- (BOOL)shouldShowDecorationViewForCollectionView:(UICollectionView *)collectionView
{
    if (collectionView != self.secondCollectionView)
        return YES;
    
    return NO;
}

// OVERRIDE: Return if the first section is empty and it should, therefore, be notified to the user
- (BOOL)shouldReportResultsforSection:(int)section
{
    if (!(_resultsGroups == nil))
    {
        if([_resultsGroups count] > 0)
        {
            if(!(section > ([_resultsGroups count] - 1)))
            {
                ResultsGroup * resultGroup = [_resultsGroups objectAtIndex:section];

                // CHANGED TO ONLY RETURN ONE SECTION (THE SECOND).
                
                if(section == 0)
                {
                    return NO;
                    //                    if([resultGroup.last_order intValue] == -1)
                    //                    {
                    //                        return YES;
                    //                    }
                    //                    else
                    //                    {
                    //                        return NO;
                    //                    }
                }
                else if (section == 1)
                {
                    return YES;
                }
                else
                {
                    return NO;
                    //                    if([resultGroup.last_order intValue] == -1)
                    //                    {
                    //                        return NO;
                    //                    }
                    //                    else
                    //                    {
                    //                        return YES;
                    //                    }
                }
            }
        }
    }
    
    if (bFiltersNew)
    {
        return [filterManager shouldReportResultsforSection:section];
    }
    
    if (arSectionsProductType != nil)
    {
        if (arSectionsProductType.count > 1)
        {
            if (section > 0)
            {
                return YES;
            }
        }
    }
    
    return NO;
}

// OVERRIDE: Return the title to be shown in section header for a collection view
- (NSString *)getHeaderTitleForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"ResultCell"])
    {
        if(!([self numberOfSectionsForCollectionViewWithCellType:cellType] > 1))
        {
            return nil;
        }
        
        NSMutableArray * sectionKeywords = [[NSMutableArray  alloc] init];
        
        if (!(_resultsGroups == nil))
        {
            if(!([indexPath section] > [_resultsGroups count]))
            {
                ResultsGroup * resultGroup = [_resultsGroups objectAtIndex:[indexPath section]];
                
                if (!([resultGroup keywords] == nil))
                {
                    if([[resultGroup keywords] count] > 0)
                    {
                        // Get the keywords that provided results
                        for (Keyword *keyword in [resultGroup keywords])
                        {
                            if([keyword isKindOfClass:[Keyword class]])
                            {
                                if(!(keyword.name == nil))
                                {
                                    if (!([keyword.name isEqualToString:@""]))
                                    {
                                        if (!([sectionKeywords containsObject:keyword.name]))
                                        {
                                            // Add the term to the set of terms
                                            [sectionKeywords addObject:keyword.name];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if (!([sectionKeywords count] > 0))
        {
            return  nil;
        }
        
        NSString * sectionTitle = [[[self composeStringhWithTermsOfArray:sectionKeywords encoding:NO] lowercaseString] capitalizedString];
        
        
        BOOL bIsFirstResult = YES;
        
        for (int i = 0; i < [indexPath section]; i++)
        {
            //        if (!(([((ResultsGroup *)[_resultsGroups objectAtIndex:i]).first_order intValue] - [((ResultsGroup *)[_resultsGroups objectAtIndex:i]).last_order intValue]) == 0))
            if (!(([((ResultsGroup *)[_resultsGroups objectAtIndex:i]).last_order intValue]) == -1))
            {
                bIsFirstResult = NO;
            }
        }
        
        if ([indexPath section] == 0)
        {
            //        if (([((ResultsGroup *)[_resultsGroups objectAtIndex:0]).first_order intValue] - [((ResultsGroup *)[_resultsGroups objectAtIndex:0]).last_order intValue]) == 0)
            if ((([((ResultsGroup *)[_resultsGroups objectAtIndex:0]).last_order intValue]) == -1))
            {
                //return NSLocalizedString(@"_NO_MAIN_SEARCH_RESULTS_", nil);
                return nil;
            }
            
            //return [NSString stringWithFormat:NSLocalizedString(@"_MAIN_SEARCH_RESULTS_", nil), sectionTitle];
            return nil;
        }
        else
        {
            if (bIsFirstResult)
            {
                return [NSString stringWithFormat:NSLocalizedString(@"_BUT_ADDITIONAL_SEARCH_RESULTS_", nil), sectionTitle];
            }
            
            return [NSString stringWithFormat:NSLocalizedString(@"_ADDITIONAL_SEARCH_RESULTS_", nil), sectionTitle];
        }
    }
    else if ([cellType isEqualToString:@"SearchFeatureCell"])
    {
        if (bFiltersNew)
        {
            return [filterManager getHeaderTitleForFilterCellWithType:cellType AtIndexPath:indexPath];
        }
        
        if(!([self numberOfSectionsForCollectionViewWithCellType:cellType] > 1))
        {
            return nil;
        }
        
        if (_searchContext == PRODUCT_SEARCH)
        {
            if (indexPath.section == 1)
            {
                if (arExpandedSubProductCategory != nil)
                {
                    if (arExpandedSubProductCategory.count > 0)
                    {
                        ProductGroup * pg = (ProductGroup *)([arExpandedSubProductCategory objectAtIndex:0]);
                        NSString * sTitleSecion = [NSString stringWithFormat:NSLocalizedString(@"_SUBSTYLE_HEADER_SECTION",nil), [pg getNameForApp]];
                        return sTitleSecion;
                    }
                }
            }
        }
        
    }
    
    return nil;
    //    else if ([indexPath section] == 1)
    //    {
    //        if (bIsFirstResult)
    //        {
    //            return [NSString stringWithFormat:NSLocalizedString(@"_BUT_ADDITIONAL_SEARCH_RESULTS_", nil), sectionTitle];
    //        }
    //
    //        return [NSString stringWithFormat:NSLocalizedString(@"_ADDITIONAL_SEARCH_RESULTS_", nil), sectionTitle];
    //    }
    //    else if ([indexPath section] == 2)
    //    {
    //        if (bIsFirstResult)
    //        {
    //            return [NSString stringWithFormat:NSLocalizedString(@"_BUT_MORE_SEARCH_RESULTS_", nil), sectionTitle];
    //        }
    //
    //        return [NSString stringWithFormat:NSLocalizedString(@"_MORE_SEARCH_RESULTS_", nil), sectionTitle];
    //    }
    //    else if ([indexPath section] == ([_resultsGroups count]-1))
    //    {
    //        if (bIsFirstResult)
    //        {
    //            return [NSString stringWithFormat:NSLocalizedString(@"_BUT_FINAL_SEARCH_RESULTS_", nil), sectionTitle];
    //        }
    //
    //        return [NSString stringWithFormat:NSLocalizedString(@"_FINAL_SEARCH_RESULTS_", nil), sectionTitle];
    //    }
    //    else
    //    {
    //        if (bIsFirstResult)
    //        {
    //            return [NSString stringWithFormat:NSLocalizedString(@"_BUT_REST_OF_SEARCH_RESULTS_", nil), sectionTitle];
    //        }
    //
    //        return [NSString stringWithFormat:NSLocalizedString(@"_REST_OF_SEARCH_RESULTS_", nil), sectionTitle];
    //    }
}

// OVERRIDE: Action to perform if an item in a collection view is selected
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if(![[self activityIndicator] isHidden])
    {
        [self hideFiltersView:YES];
        return;
    }
    
    if(!([_addTermTextField isHidden]))
    {
        [self hideFiltersView:YES];
        // Hide Add Terms text field
        [self hideAddSearchTerm];
        
        return;
    }
    
    
    if ([cellType isEqualToString:@"ResultCell"])
    {
        [self hideFiltersView:YES];
        _selectedResult = nil;
        
        // Hide Add Terms text field
        [self hideAddSearchTerm];
        
        if (indexPath.item % ADNUM == ADNUM - 1) {
            int index = indexPath.item / ADNUM;
            if (index < [adList count]) {
                Ad *result = [adList objectAtIndex:index];
                if (result.website != nil && ![result.website isEqualToString:@""]) {
                    [self showAvailabilityDetailViewWithURLString:result.website];
                }
                else if (result.productId != nil && ![result.productId isEqualToString:@""]) {
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:result.productId, nil];
                    
                    [self performRestGet:GET_PRODUCT withParamaters:requestParameters];
                }
                else if (result.profileId != nil && ![result.profileId isEqualToString:@""]) {
                    [self openFashionistaWithId:result.profileId];
                }
                else if (result.postId != nil && ![result.postId isEqualToString:@""]) {
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:result.postId, [NSNumber numberWithBool:NO], nil];
                    
                    [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
                }
                return;
            }
        }
        //Calculate the actual section in FetchedResultsController
        int frcSection = [self getFetchedResultsControllerSectionForSection:(int)indexPath.section];
        
        if(frcSection >= 0)
        {
            if (!([[self getFetchedResultsControllerForCellType:cellType] sections] == nil))
            {
                if(!(([[[self getFetchedResultsControllerForCellType:cellType] sections] count]) == 0))
                {
                    if(!(frcSection > ([[[self getFetchedResultsControllerForCellType:cellType] sections] count] - 1)))
                    {
                        int index = indexPath.item / ADNUM;
                        if (index > [adList count]) {
                            _selectedResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:(indexPath.item - [adList count]) inSection:frcSection]];
                        }
                        else {
                            _selectedResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item - index inSection:frcSection]];
                        }
                    }
                }
            }
        }
        
        if(!(_selectedResult == nil))
        {
            if ((_searchContext == PRODUCT_SEARCH) && (!(_addingProductsToWardrobe == nil)))
            {
                for (NSString *itemId in _addingProductsToWardrobe.itemsId)
                {
                    if([itemId isEqualToString:_selectedResult.idGSBaseElement])
                    {
                        return;
                    }
                }
                
                GSBaseElementCell *currentCell = (GSBaseElementCell *)[self collectionView:self.mainCollectionView cellForItemAtIndexPath:indexPath];
                
                _productTagItem = _selectedResult;
                buttonToHighlight = currentCell.hangerButton;

                [self addItem:_selectedResult toWardrobeWithID:_addingProductsToWardrobe.idWardrobe];

                _selectedResult = nil;
                
            } else if ((_searchContext == PRODUCT_SEARCH) && ([self.searchBaseDelegate respondsToSelector:@selector(finishItemToWardrobe:Item:WardrobeID:)])) {
                GSBaseElementCell *currentCell = (GSBaseElementCell *)[self collectionView:self.mainCollectionView cellForItemAtIndexPath:indexPath];
                
                _productTagItem = _selectedResult;
                

                NSLog(@"GSElement name: %@,    id: %@", [_productTagItem name],[_productTagItem additionalInformation]);
                NSLog(@"GSElement name: %@,    id: %@", [_productTagItem mainInformation],[_productTagItem brandId]);
                if ([self.searchBaseDelegate respondsToSelector:@selector(finishItemToWardrobe:Item:WardrobeID:)]) {
                    [self.searchBaseDelegate finishItemToWardrobe:self Item:_productTagItem WardrobeID:_addingProductsToWardrobe.idWardrobe];
                }
                
                _selectedResult = nil;
                if (buttonToHighlight != nil) {
                    UIImage * buttonImage = [UIImage imageNamed:@"hanger_unchecked.png"];
                    if (!(buttonImage == nil))
                    {
                        [buttonToHighlight setImage:buttonImage forState:UIControlStateNormal];
                        [buttonToHighlight setImage:buttonImage forState:UIControlStateHighlighted];
                        [[buttonToHighlight imageView] setContentMode:UIViewContentModeScaleAspectFit];
                    }
                }
                UIImage * buttonImage = [UIImage imageNamed:@"hanger_checked.png"];
                buttonToHighlight = currentCell.hangerButton;
                if (!(buttonImage == nil))
                {
                    [buttonToHighlight setImage:buttonImage forState:UIControlStateNormal];
                    [buttonToHighlight setImage:buttonImage forState:UIControlStateHighlighted];
                    [[buttonToHighlight imageView] setContentMode:UIViewContentModeScaleAspectFit];
                }
            }
            else
            {
                bGettingDataOfElement = YES;
                [self getContentsForElement:_selectedResult];
            }
        }
    }
    else if ([cellType isEqualToString:@"SearchFeatureCell"])
    {
        if (bFiltersNew)
        {
            if ([filterManager actionForFilterSelectionOfCellWithType:cellType AtIndexPath:indexPath])
                [self updateBottomBarSearch]; // solo cuando sea necesario el FilterManagaer ha de indicar cuando es necesario
            return;
        }
        
        // making the serching for the initial
        //Calculate the actual section in FetchedResultsController
        //NSObject * obj = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
        NSObject * obj = [_filteredFilters objectAtIndex:indexPath.item];
        if (arSectionsProductType.count > 0)
        {
            SectionProductType * objSection = [arSectionsProductType objectAtIndex:indexPath.section];
            NSArray * arObjects = objSection.arElements;
            obj = [arObjects objectAtIndex:indexPath.item];
        }
        
        if ([obj isKindOfClass:[NSString class]])
        {
            BOOL bCheckSearchTerms = (_searchContext == PRODUCT_SEARCH);
            //            [self addSearchTermWithName:(NSString *)obj animated:YES];
            if ([self.searchTermsListView.arrayButtons containsObject:obj] == NO)
            {
                [self addSearchTermWithObject:obj animated:YES performSearch:NO checkSearchTerms:bCheckSearchTerms];
            }
            else
            {
                int iIdx = (int)[self iIdxFilterSelected:(NSString *)obj];
                [self removeSearchTermAtIndex:iIdx checkSuggestions:YES];
            }
            //            [self.secondCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            [self.secondCollectionView reloadData];
            
        }
        else if ([obj isKindOfClass:[ProductGroup class]])
        {
            ProductGroup *pg = (ProductGroup *)obj;
            
            //            if ((_searchContext == FASHIONISTAPOSTS_SEARCH) || (_searchContext == FASHIONISTAS_SEARCH))
            if (_searchContext != PRODUCT_SEARCH)
            {
                if ([self.searchTermsListView.arrayButtons containsObject:pg] == NO)
                {
                    // add the product category
                    [self addSearchTermWithObject:pg animated:YES performSearch:NO checkSearchTerms:NO];
                }
                else
                {
                    // the product category already exists
                    int iIdx = (int)[self iIdxFilterSelected:pg.app_name];
                    if (iIdx > -1)
                    {
                        [self removeSearchTermAtIndex:iIdx checkSuggestions:YES];
                    }
                    else
                    {
                        int iIdx = (int)[self iIdxFilterSelected:pg.name];
                        if (iIdx > -1)
                        {
                            [self removeSearchTermAtIndex:iIdx checkSuggestions:YES];
                        }
                    }
                }
                //            [self.secondCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                [self.secondCollectionView reloadData];
            }
            else
            {
                if (selectedProductCategory == nil)
                {
                    selectedProductCategory = pg;
                    
                    [self addSearchTermWithObject:selectedProductCategory animated:YES performSearch:NO checkSearchTerms:YES];
                    [self getSuggestedFiltersForProductGroup:selectedProductCategory];
                    iLastSelectedSlide = 0;
                    //        [self setupSuggestedFiltersRibbonView];
                    sLastSelectedSlide = @"";
                    //            [self.secondCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                    
                    // check if there are any child with the expanded property to true, if there is one, we need to expand it
                    NSMutableArray *pgChildren = [pg getChildrenInFoundSuggestions:_foundSuggestions forGender:iGenderSelected];
                    for(ProductGroup *pgchild in pgChildren)
                    {
                        if ([pgchild checkExpandedForGender:iGenderSelected])
                        {
                            [arExpandedSubProductCategory removeAllObjects];
                            [arExpandedSubProductCategory addObject:pgchild];
                            break;
                        }
                    }
                    
                    bUpdatingSelectionColor = YES;
                    
                    [self.secondCollectionView reloadData];
                    
                    return;
                }
                else
                {
                    ProductGroup * pgParent = [pg getTopParent];
                    if ([pgParent.idProductGroup isEqualToString:selectedProductCategory.idProductGroup])
                    {
                        [self manageProductGroup:pg];
                    }
                }
            }
        }
        else if ([obj isKindOfClass:[Brand class]])
        {
            Brand *brand = (Brand *)obj;
            BOOL bCheckSearchTerms = (_searchContext == PRODUCT_SEARCH);
            //            if (selectedProductCategory != nil)
            {
                //            [self addSearchTermWithName:brand.name animated:YES];
                if ([self.searchTermsListView.arrayButtons containsObject:brand] == NO)
                {
                    [self addSearchTermWithObject:brand animated:YES performSearch:NO checkSearchTerms:bCheckSearchTerms];
                }
                else
                {
                    int iIdx = (int)[self iIdxFilterSelected:brand.name];
                    [self removeSearchTermAtIndex:iIdx checkSuggestions:YES];
                }
                //            [self.secondCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                [self.secondCollectionView reloadData];
            }
            //            else
            //            {
            //                if ([self.searchTermsListView.arrayButtons containsObject:brand] == NO)
            //                {
            //                    [self addSearchTermWithObject:brand animated:YES performSearch:NO];
            //                    [self getSuggestedFiltersProductGroupForGender:iGenderSelected];
            //                    [self setupSuggestedFiltersRibbonView];
            //                    iLastSelectedSlide = 0;
            //                    sLastSelectedSlide = @"";
            //                    return;
            //                }
            //            }
        }
        else if ([obj isKindOfClass:[Feature class]])
        {
            Feature *feature = (Feature *)obj;
            BOOL bCheckSearchTerms = (_searchContext == PRODUCT_SEARCH);
            if ([self.searchTermsListView.arrayButtons containsObject:feature] == NO)
            {
                [self addSearchTermWithObject:feature animated:YES performSearch:NO checkSearchTerms:bCheckSearchTerms];
            }
            else
            {
                int iIdx = (int)[self iIdxFilterSelected:feature.name];
                [self removeSearchTermAtIndex:iIdx checkSuggestions:YES];
            }
            
            if (bCheckSearchTerms)
            {
                NSString * sFeatureGroupName = [[feature.featureGroup.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([sFeatureGroupName isEqualToString:@"gender"])
                {
                    if (selectedProductCategory != nil)
                    {
                        [self getGenderSelected];
                        [self getSuggestedFiltersForProductGroup:selectedProductCategory];
                        [self initOperationsLoadingImages];
                        [self.imagesQueue cancelAllOperations];
                        [self.secondCollectionView reloadData];
                        
                        [self updateSuccessulTermsForGender];
                    }
                }
            }
            //            [self.secondCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            [self.secondCollectionView reloadData];
        }
        else
        {
            NSLog(@"Search, Element not recognized %@", NSStringFromClass([obj class]));
        }
        
        //        [self hideFiltersView:YES];
    }
    
    [self updateBottomBarSearch];
}

- (void)onTapAddToWardrobeButton:(UIButton *)sender
{
    [self hideFiltersView:YES];
    if(!([_filterSearchVCContainerView isHidden]))
    {
        return;
    }
    
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
    
    if (!appDelegate.completeUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                        message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    GSBaseElement *selectedResult = nil;
    
    //Calculate the actual section in FetchedResultsController
    int frcSection = [self getFetchedResultsControllerSectionForSection:((int)(sender.tag/OFFSET))];
    
    if(frcSection >= 0)
    {
        if (!([[self getFetchedResultsControllerForCellType:@"ResultCell"] sections] == nil))
        {
            if(!(([[[self getFetchedResultsControllerForCellType:@"ResultCell"] sections] count]) == 0))
            {
                if(!(frcSection > ([[[self getFetchedResultsControllerForCellType:@"ResultCell"] sections] count] - 1)))
                {
                    selectedResult = [[self getFetchedResultsControllerForCellType:@"ResultCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:(sender.tag - (((int)(sender.tag/OFFSET))*OFFSET))inSection:frcSection]];
                }
            }
        }
    }
    
    if(!(selectedResult == nil))
    {
        if ((_searchContext == PRODUCT_SEARCH) && (!(_addingProductsToWardrobe == nil)))
        {
            for (NSString *itemId in _addingProductsToWardrobe.itemsId)
            {
                if([itemId isEqualToString:selectedResult.idGSBaseElement])
                {
                    /*
                     // Item already in wardrobe!
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_ITEMALREADYINWARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                     
                     [alertView show];
                     */
                    return;
                }
            }
            
            buttonToHighlight = sender;
            
            [self addItem:selectedResult toWardrobeWithID:_addingProductsToWardrobe.idWardrobe];
        }
        else if (!([self doesCurrentUserWardrobesContainItemWithId:selectedResult]))
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
                    [addItemToWardrobeVC setItemToAdd:selectedResult];
                    
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

- (void)openFashionistaWithId:(NSString *)userId{
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:userId, nil];
    
    [self performRestGet:GET_FASHIONISTA withParamaters:requestParameters];
}

- (void)showAvailabilityDetailViewWithURLString:(NSString*)sURL
{
    NSString *url = [NSString stringWithFormat:@"http://%@", sURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    [self setTopBarTitle:[NSURL URLWithString:url].host andSubtitle:nil];
    self.webViewContrainer.hidden = NO;
    [self.view bringSubviewToFront:self.webViewContrainer];
    [self bringBottomControlsToFront];
    //[self bringTopBarToFront];
}

- (void)closeAvailiabilityDetailView
{
    [self setTopBarTitle:NSLocalizedString(@"_VCTITLE_105_", nil) andSubtitle:nil];
    [UIView transitionWithView:self.webViewContrainer
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:^{
                        [self.view bringSubviewToFront:self.mainCollectionView];
                        [self.view bringSubviewToFront:self.addTermTextField];
                        
                        [self bringBottomControlsToFront];
                        [self bringTopBarToFront];
                        self.webViewContrainer.hidden = YES;
                    }
                    completion:^(BOOL finished){
                        
                    }];
    
}


// Action to perform if the user press the 'Heart' button on a ResultsCell (STYLISTSLAYOUT)
- (void)onTapFollowButton:(UIButton *)sender
{
    [self hideFiltersView:YES];
    if(!([_filterSearchVCContainerView isHidden]))
    {
        return;
    }
    
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
    
    GSBaseElement *selectedResult = nil;
    
    //Calculate the actual section in FetchedResultsController
    int frcSection = [self getFetchedResultsControllerSectionForSection:((int)(sender.tag/OFFSET))];
    
    if(frcSection >= 0)
    {
        if (!([[self getFetchedResultsControllerForCellType:@"ResultCell"] sections] == nil))
        {
            if(!(([[[self getFetchedResultsControllerForCellType:@"ResultCell"] sections] count]) == 0))
            {
                if(!(frcSection > ([[[self getFetchedResultsControllerForCellType:@"ResultCell"] sections] count] - 1)))
                {
                    selectedResult = [[self getFetchedResultsControllerForCellType:@"ResultCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:(sender.tag - (((int)(sender.tag/OFFSET))*OFFSET))inSection:frcSection]];
                }
            }
        }
    }
    
    if(!(selectedResult == nil))
    {
        if (!([self doesCurrentUserFollowsStylistWithId:selectedResult.fashionistaId]))
        {
            if (!(selectedResult == nil))
            {
                if (!(selectedResult.fashionistaId == nil))
                {
                    if(!([selectedResult.fashionistaId isEqualToString:@""]))
                    {
                        if (!(appDelegate.currentUser.idUser == nil))
                        {
                            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                            {
                                NSLog(@"Following user: %@", selectedResult.fashionistaId);
                                
                                // Perform request to follow user
                                
                                // Provide feedback to user
                                [self stopActivityFeedback];
                                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_FOLLOWING_USER_MSG_", nil)];
                                
                                // Post the setFollow object
                                
                                setFollow * newFollow = [[setFollow alloc] init];
                                
                                [newFollow setFollow:selectedResult.fashionistaId];
                                
                                //                                NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                                //
                                //                                Follow *newFollow = [[Follow alloc] initWithEntity:[NSEntityDescription entityForName:@"Follow" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                                //
                                //                                [newFollow setFollowingId:appDelegate.currentUser.idUser];
                                //
                                //                                [newFollow setFollowedId:selectedResult.fashionistaId];
                                
                                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newFollow, nil];
                                
                                buttonToHighlight = sender;
                                
                                [self performRestPost:FOLLOW_USER withParamaters:requestParameters];
                            }
                        }
                    }
                }
            }
        }
        else
        {
            if (!(selectedResult.fashionistaId == nil))
            {
                if(!([selectedResult.fashionistaId isEqualToString:@""]))
                {
                    if (!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            NSLog(@"UNfollowing user: %@", selectedResult.fashionistaId);
                            
                            // Perform request to follow user
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UNFOLLOWING_USER_MSG_", nil)];
                            
                            // Post the unsetFollow object
                            
                            unsetFollow * newUnsetFollow = [[unsetFollow alloc] init];
                            
                            [newUnsetFollow setUnfollow:selectedResult.fashionistaId];
                            
                            //                                NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            //
                            //                                Follow *newFollow = [[Follow alloc] initWithEntity:[NSEntityDescription entityForName:@"Follow" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                            //
                            //                                [newFollow setFollowingId:appDelegate.currentUser.idUser];
                            //
                            //                                [newFollow setFollowedId:selectedResult.fashionistaId];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newUnsetFollow, nil];
                            
                            buttonToHighlight = sender;
                            
                            [self performRestPost:UNFOLLOW_USER withParamaters:requestParameters];
                        }
                    }
                }
            }
        }
    }
}

// OVERRIDE: Just to prevent from being at the 'Add to Wardrobe' view
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!([_addToWardrobeVCContainerView isHidden]))
        return;
    
    if (![_filterSearchVCContainerView isHidden])
    {
        if([_filterSearchVC zoomViewVisible])
        {
            [_filterSearchVC hideZoomView];
            return;
        }
    }
    
    if ([self zoomViewVisible])
    {
        [self hideZoomView];
        return;
    }
    
    if ([self.selectFeaturesView isHidden] == NO)
    {
        return;
    }
    
    [super touchesEnded:touches withEvent:event];
    
}

#pragma mark - Requests


// Also find "Get suggested filters" in #pragma mark - Search Terms & Suggested filters


// Request the BackgroundAd to be shown to the user
-(void)getAds {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSArray *requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, @"discover", nil];
    
    [self performRestGet:GET_AD withParamaters:requestParameters];
}

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
                
                [self performRestGet:GET_SEARCHADAPTEDBACKGROUNDAD withParamaters:requestParameters];
                
                return;
            }
        }
    }
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:@"", nil];
    
    [self performRestGet:GET_SEARCHADAPTEDBACKGROUNDAD withParamaters:requestParameters];
}

- (NSString*) calculateDateForPeriod:(historyPeriod) historyPeriod
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    
    [dateFormatter setLocale:enUSPOSIXLocale];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *selectedDate = nil;
    
    NSDateComponents *dateComponents = [calendar components: ( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[NSDate date]];
    
    switch (historyPeriod)
    {
        case TODAY:
            
            [dateComponents setHour:0];
            [dateComponents setMinute:0];
            [dateComponents setSecond:5];
            selectedDate = [calendar dateFromComponents:dateComponents];
            
            break;
            
        case PASTWEEK:
            
            [dateComponents setDay:([dateComponents day] - 7)];
            selectedDate = [calendar dateFromComponents:dateComponents];
            
            break;
            
        case PASTMONTH:
            
            [dateComponents setMonth:([dateComponents month] - 1)];
            selectedDate = [calendar dateFromComponents:dateComponents];
            
            
            break;
            
        case SIXMONTHS:
            
            [dateComponents setMonth:([dateComponents month] - 6)];
            selectedDate = [calendar dateFromComponents:dateComponents];
            
            break;
            
        case ONEYEAR:
            
            [dateComponents setYear:([dateComponents year] - 1)];
            selectedDate = [calendar dateFromComponents:dateComponents];
            
            break;
            
        default:
            break;
    }
    
    NSLog(@"Selected date:%@", selectedDate);
    
    return [dateFormatter stringFromDate:selectedDate];
}

-(NSString *) stringForPostType:(fashionistaPostType)postType
{
    switch (postType)
    {
        case ALLPOSTS:
            
            return @"";
            
            break;
            
        case ARTICLE:
            
            return @"article";
            
            break;
            
        case TUTORIAL:
            
            return @"tutorial";
            
            break;
            
        case REVIEW:
            
            return @"review";
            
            break;
            
            //        case WARDROBE:
            
        default:
            
            return @"";
            
            break;
    }
}

-(NSString *) stringForStylistRelationship:(followingRelationships)stylistRelationShip
{
    switch (stylistRelationShip)
    {
        case ALLSTYLISTS:
            
            return @"all";
            
            break;
            
        case FOLLOWED:
            
            return @"followed";
            
            break;
            
        case FOLLOWERS:
            
            return @"followers";
            
            break;
            
        case SUGGESTED:
            
            return @"suggested";
            
            break;
        case SOCIAL_NETWORK:
            return @"social_network";
            break;
            //        case FOLLOWEDBYMYFOLLOWED:
            //
            //            return @"followedbyfollowed";
            //
            //            break;
            
        default:
            
            return @"";
            
            break;
    }
}

// Update search when the list of search terms changes
- (BOOL)updateSearchForTermsChanges
{
    BOOL bPerformSearch = NO;
    
    //    if ((_searchContext != BRANDS_SEARCH) && ([self.searchTermsListView sameFromLastState]))
    //        return NO;
    
    int resultsBeforeUpdate = (int) [_resultsArray count];
    
    // Empty old results array
    [_resultsArray removeAllObjects];
    
    // Empty old results groups array
    [_resultsGroups removeAllObjects];
    
    _currentSearchQuery = nil;
    
    // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
    if ([self getFetchedResultsControllerForCellType:@"ResultCell" ] == nil)
    {
        [self initFetchedResultsController];
    }
    
    // Update Fetched Results Controller
    [self performFetchForCollectionViewWithCellType:@"ResultCell"];
    
    // Update collection view
    [self updateCollectionViewWithCellType:@"ResultCell" fromItem:0 toItem:resultsBeforeUpdate deleting:TRUE];
    
    [self setBackgroundImage];
    
    [self setNotSuccessfulTermsText:([_notSuccessfulTerms isEqualToString:@""] ? @"" : [NSString stringWithFormat:NSLocalizedString(@"_NOTSUCCESFULTERMS_", nil), _notSuccessfulTerms])];
    
    [self.noFilterTermsLabel setHidden:YES];
    
    if ((self.successfulTerms == nil) || (!([self.successfulTerms count] > 0)))
    {
        if(!(_searchContext == STYLES_SEARCH))
        {
            //Update top bar with number of results and terms and no successul terms
            int iNumResults = [self iGetSearchNumResults];
            
            NSString * subTitle = nil;
            
            //if(!(_searchContext == FASHIONISTAS_SEARCH || _searchContext == FASHIONISTAPOSTS_SEARCH))
            {
                if(iNumResults > 0)
                {
                    if(iNumResults >= 1000)
                    {
                        subTitle = [NSString stringWithFormat:NSLocalizedString(@"_MORETHAN1000_RESULTS_", nil), iNumResults];
                    }
                    else
                    {
                        if(iNumResults > 1)
                        {
                            subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULTS_", nil), iNumResults];
                        }
                        else
                        {
                            subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULT_", nil), iNumResults];
                        }
                    }
                }
                else
                {
                    subTitle = NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil);
                }
            }
            
            [self setTopBarTitle:nil andSubtitle:subTitle];
        }
        
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_NO_SEARCH_KEYWORDS_", nil) message:NSLocalizedString(@"_NO_SEARCH_KEYWORDS_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        //
        //        [alertView show];
        
        [_searchTermsBeforeUpdate removeAllObjects];
        
        _searchTermsBeforeUpdate = nil;
        
        if (_searchContext == PRODUCT_SEARCH)
        {
            [self getSuggestedFilters];
            
            [self showAddSearchTerm];
        }
    }
    else
    {
        if(!(_searchContext == STYLES_SEARCH))
        {
            //Update top bar with number of results and terms and no successul terms
            int iNumResults = [self iGetSearchNumResults];
            
            NSString * subTitle = nil;
            
            //if(!(_searchContext == FASHIONISTAS_SEARCH || _searchContext == FASHIONISTAPOSTS_SEARCH))
            {
                if(iNumResults > 0)
                {
                    if(iNumResults >= 1000)
                    {
                        subTitle = [NSString stringWithFormat:NSLocalizedString(@"_MORETHAN1000_RESULTS_", nil), iNumResults];
                    }
                    else
                    {
                        if(iNumResults > 1)
                        {
                            subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULTS_", nil), iNumResults];
                        }
                        else
                        {
                            subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULT_", nil), iNumResults];
                        }
                    }
                }
                else
                {
                    subTitle = NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil);
                }
            }
            
            [self setTopBarTitle:nil andSubtitle:subTitle];
        }
        
        //Hide the filter terms ribbon only if not just loading more results of the same search
        [self hideSuggestedFiltersRibbonAnimated:YES];
        
        if (_searchContext == PRODUCT_SEARCH)
        {
            // Perform request to get the search results
            [self performSearch];
            bPerformSearch = YES;
        }
    }
    
    if (!(_searchContext == PRODUCT_SEARCH))
    {
        // Perform request to get the search results
        [self performSearch];
        bPerformSearch = YES;
    }
    
    return bPerformSearch;
}

// Check if arrived to the end of the collection view and, if so, request more results
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!([self.mainMenuView isHidden]))
    {
        return;
    }
    
    if([_resultsArray count]> 0)
    {
        [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
        // Hide Add Terms text field
        [self hideAddSearchTerm];
    }
    
    if (scrollView == self.mainCollectionView)
    {
        [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
        // Hide Add Terms text field
        [self hideAddSearchTerm];
        
        
        // Check if the resuts reload should be performed
        if ((scrollView.contentOffset.y <= kOffsetToRefreshSearch) && (scrollView.isDragging))
        {
            if(!_bRefreshingSearch)
            {
                _inspireView.hidden = YES;
                _bRefreshingSearch = YES;
                [self updateSearchForTermsChanges];
            }
        }
        
        // Check if the resuts reload should be performed
        if (([_currentSearchQuery.numresults intValue] > [_resultsArray count]) && (scrollView.contentOffset.y >= roundf((scrollView.contentSize.height-scrollView.frame.size.height)+kOffsetForBottomScroll)))
        {
            // Do it only if the total number of results is not achieved yet and a search is not already taking place
            if ([[self activityLabel] isHidden])
            {
                _bLoadingMoreResults = YES;
                [self updateSearch];
            }
        }
        
        //[self hideFiltersView:YES];
    }
    
    
}

// Perform search with a new set of search terms
- (void)performSearch
{
    NSString *stringToSearch = [self composeStringhWithTermsOfArray:_successfulTerms encoding:YES];
    
    if(stringToSearch == nil)
    {
        stringToSearch = @"";
        
    }
    
    [self performSearchWithString:stringToSearch];
}


- (void)performSearchWithString:(NSString*)stringToSearch
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [_searchQueue addObject:stringToSearch];
    
    if(!(bComingFromSwipeSearchNavigation))
    {
        [_forwardSearchQueue removeAllObjects];
        [appDelegate.tmpVCQueue removeAllObjects];
        [appDelegate.tmpParametersQueue removeAllObjects];
        [appDelegate.lastDismissedVCQueue removeAllObjects];
        [appDelegate.lastDismissedParametersQueue removeAllObjects];
    }
    
    bComingFromSwipeSearchNavigation = NO;
    
    NSArray * requestParameters = nil;
    
    switch (_searchContext)
    {
        case HISTORY_SEARCH:
            
            if (!(appDelegate.currentUser == nil))
            {
                if(!(appDelegate.currentUser.idUser == nil))
                {
                    if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        NSLog(@"Performing search within history with terms: %@", stringToSearch);
                        
                        // Perform request to get the search results
                        
                        // Provide feedback to user
                        [self stopActivityFeedback];
                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                        
                        requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, [self calculateDateForPeriod:_searchPeriod], stringToSearch, nil];
                        
                        [self performRestGet:PERFORM_SEARCH_WITHIN_HISTORY withParamaters:requestParameters];
                    }
                }
            }
            
            break;
            
        case TRENDING_SEARCH:
            
            NSLog(@"Performing search within trending with terms: %@", stringToSearch);
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            requestParameters = [[NSArray alloc] initWithObjects:stringToSearch, nil];
            
            [self performRestGet:PERFORM_SEARCH_WITHIN_TRENDING withParamaters:requestParameters];
            
            break;
            
        case FASHIONISTAPOSTS_SEARCH:
            
            NSLog(@"Performing search within fashionista posts with terms: %@", stringToSearch);
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            // TODO: Add post type filtering!
            
            requestParameters = [[NSArray alloc] initWithObjects:stringToSearch, [self stringForPostType:_searchPostType], [self stringForStylistRelationship:_searchStylistRelationships], nil];
            
            [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAPOSTS withParamaters:requestParameters];
            
            _bLoadingStylistsOrPosts = YES;
            
            break;
            
        case FASHIONISTAS_SEARCH:
        {
            NSLog(@"Performing search within fashionistas with terms: %@", stringToSearch);
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            // TODO: Add post type filtering!
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSString * currentUserId = @"";
            
            if(appDelegate.currentUser)
            {
                if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    currentUserId = appDelegate.currentUser.idUser;
                }
            }
            
            requestParameters = [[NSArray alloc] initWithObjects:[self composeStringhWithTermsOfArray:[NSArray arrayWithObject:stringToSearch] encoding:YES], [self stringForStylistRelationship:_searchStylistRelationships], currentUserId, nil];
            
            [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAS withParamaters:requestParameters];
            
            _bLoadingStylistsOrPosts = YES;
            
            break;
        }
        case PRODUCT_SEARCH:
            
            // Check that the string to search is valid
            if (!((stringToSearch == nil) || ([stringToSearch isEqualToString:@""])))
            {
                NSLog(@"Performing search with terms: %@", stringToSearch);
                
                // Perform request to get the search results
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                
                requestParameters = [[NSArray alloc] initWithObjects:stringToSearch, nil];
                
                [self performRestGet:PERFORM_SEARCH_WITHIN_PRODUCTS withParamaters:requestParameters];
                
                // TODO: new call to get suggestions in a search
                [self cancelCheckSearchOperations];
                
                //                [self performRestGet:CHECK_SEARCH_STRING_AFTER_SEARCH withParamaters:requestParameters];
                //                [self performRestGet:CHECK_SEARCH_STRING_SUGGESTIONS_AFTER_SEARCH withParamaters:requestParameters];
            }
            
            break;
            
        case BRANDS_SEARCH:
            
            NSLog(@"Performing search within brands with terms: %@", stringToSearch);
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            requestParameters = [[NSArray alloc] initWithObjects:stringToSearch, nil];
            
            [self performRestGet:PERFORM_SEARCH_WITHIN_BRANDS withParamaters:requestParameters];
            
            break;
            
        case STYLES_SEARCH:
            
            NSLog(@"Performing search within style looks with terms: %@", stringToSearch);
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            // TODO: Add post type filtering!
            
            requestParameters = [[NSArray alloc] initWithObjects: _getTheLookReferenceProduct, stringToSearch, nil];
            
            [self performRestGet:PERFORM_SEARCH_WITHIN_STYLES withParamaters:requestParameters];
            
            break;
            
        default:
            break;
    }
}

-(void) cancelCheckSearchOperations
{
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:[self getPatternForConnectionType:CHECK_SEARCH_STRING intendedForStringFormat:NO]];
    
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:[self getPatternForConnectionType:CHECK_SEARCH_STRING_SUGGESTIONS intendedForStringFormat:NO]];
    
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:[self getPatternForConnectionType:CHECK_SEARCH_STRING_AFTER_SEARCH intendedForStringFormat:NO]];
    
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:[self getPatternForConnectionType:CHECK_SEARCH_STRING_SUGGESTIONS_AFTER_SEARCH intendedForStringFormat:NO]];
    
}

// Update search with more results
- (void)updateSearch
{
    // Check that the string to search is valid
    if (!((_currentSearchQuery == nil) || ([_currentSearchQuery.idSearchQuery isEqualToString:@""])))
    {
        NSLog(@"Performing search with terms: %@", _currentSearchQuery.searchQuery);
        
        // Perform request to get the search results
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_currentSearchQuery, [NSNumber numberWithInteger:[_resultsArray count]], nil];
        
        switch (_searchContext)
        {
            case PRODUCT_SEARCH:
                
                [self performRestGet:GET_SEARCH_RESULTS_WITHIN_PRODUCTS withParamaters:requestParameters];
                
                break;
                
            case TRENDING_SEARCH:
                
                [self performRestGet:GET_SEARCH_RESULTS_WITHIN_TRENDING withParamaters:requestParameters];
                
                break;
                
            case FASHIONISTAS_SEARCH:
                
                [self performRestGet:GET_SEARCH_RESULTS_WITHIN_FASHIONISTAS withParamaters:requestParameters];
                
                break;
                
            case FASHIONISTAPOSTS_SEARCH:
                
                [self performRestGet:GET_SEARCH_RESULTS_WITHIN_FASHIONISTAPOSTS withParamaters:requestParameters];
                
                break;
                
            case STYLES_SEARCH:
                
                [self performRestGet:GET_SEARCH_RESULTS_WITHIN_STYLES withParamaters:requestParameters];
                
                break;
                
            case BRANDS_SEARCH:
                
                [self performRestGet:GET_SEARCH_RESULTS_WITHIN_BRANDS withParamaters:requestParameters];
                
                break;
                
            case HISTORY_SEARCH:
                
                [self performRestGet:GET_SEARCH_RESULTS_WITHIN_HISTORY withParamaters:requestParameters];
                
                break;
                
            default:
                break;
        }
    }
}

// Add items to wardrobe
- (void)addItem:(GSBaseElement *)itemToAdd toWardrobeWithID:(NSString *)wardrobeID
{
    if (!(itemToAdd == nil))
    {
        if(!(_addingProductsToWardrobeID == nil))
        {
            if(!([_addingProductsToWardrobeID isEqualToString:@""]))
            {
                _bAddingProductsToPostContentWardrobe = YES;
            }
        }
        
        NSLog(@"Adding item to wardrobe: %@", wardrobeID);
        
        // Perform request to save the item into the wardrobe
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_ADDINGITEMTOWARDROBE_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobeID, itemToAdd, nil];
        
        [self performRestPost:ADD_ITEM_TO_WARDROBE withParamaters:requestParameters];
    }
}

// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    NSMutableArray * resultContent = [[NSMutableArray alloc] init];
    NSMutableArray * resultReviews = [[NSMutableArray alloc] init];
    NSMutableArray * resultComments = [[NSMutableArray alloc] init];
    NSMutableArray * resultAvailabilities = [[NSMutableArray alloc] init];
    NSMutableArray *review_array = [[NSMutableArray alloc] init];
    
    NSArray * parametersForNextVC = nil;
    int resultsBeforeUpdate =  (int)[[[self getFetchedResultsControllerForCellType:@"ResultCell"] fetchedObjects] count];
    __block NSString * notSuccessfulTerms = @"";
    __block SearchQuery * searchQuery;
    __block id selectedSpecificResult;
    __block NSNumber * postLikesNumber = [NSNumber numberWithInt:0];
    __block User * postAuthor = nil;
    
    NSMutableArray *foundResults = [[NSMutableArray alloc] init];
    NSMutableArray *foundResultsGroups = [[NSMutableArray alloc] init];
    NSMutableArray *successfulTerms = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (connection)
    {
            /*        case GET_SEARCHPRODUCTS_BRAND:
             {
             // Check if the Fetched Results Controller is already initialized; if so, update it
             if (!([self getFetchedResultsControllerForCellType:@"ResultCell" ] == nil))
             {
             // Check if the Fetched Results Controller is already initialized; if so, update it
             if ([[[self getFetchedResultsControllerForCellType:@"ResultCell"] fetchedObjects] count] > 0)
             {
             NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
             
             for (int i = 0; i < [[[self getFetchedResultsControllerForCellType:@"ResultCell"] fetchedObjects] count]; i++)
             {
             if(!([([[self getFetchedResultsControllerForCellType:@"ResultCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]) brand] == nil))
             {
             continue;
             }
             
             for (Brand *brand in mappingResult)
             {
             if([brand isKindOfClass:[Brand class]])
             {
             if(!(brand.idBrand == nil))
             {
             if(!([brand.idBrand isEqualToString:@""]))
             {
             if(!([([[self getFetchedResultsControllerForCellType:@"ResultCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]) brandId] == nil))
             {
             if(!([[([[self getFetchedResultsControllerForCellType:@"ResultCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]) brandId] isEqualToString:@""]))
             {
             if ([[([[self getFetchedResultsControllerForCellType:@"ResultCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]) brandId] isEqualToString: brand.idBrand])
             {
             [((Result *)([[self getFetchedResultsControllerForCellType:@"ResultCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]])) setBrandName:brand.name];
             }
             }
             }
             }
             }
             }
             }
             
             [currentContext refreshObject:[[self getFetchedResultsControllerForCellType:@"ResultCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]] mergeChanges:YES];
             }
             
             [currentContext save:nil];
             }
             }
             
             // Check if the Fetched Results Controller is already initialized; if so, update it
             if (!([self getFetchedResultsControllerForCellType:@"ResultCell" ] == nil))
             {
             // Update Fetched Results Controller
             [self performFetchForCollectionViewWithCellType:@"ResultCell"];
             }
             
             // Update collection view
             [self updateCollectionViewWithCellType:@"ResultCell" fromItem:0 toItem:-1 deleting:FALSE];
             
             break;
             }
             */
        case GET_SEARCHADAPTEDBACKGROUNDAD:
        {
            if(self.currentSearchQuery == nil)
            {
                [self setBackgroundImage];
            }
            
            break;
        }
        case GET_AD:
        {
            [adList removeAllObjects];
            adList = [NSMutableArray new];
            for (Ad *ad in mappingResult) {
                if ([ad isKindOfClass:[Ad class]]) {
                    [adList addObject:ad];
                }
            }
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
                if(!(_addingProductsToWardrobeID == nil))
                {
                    if(!([_addingProductsToWardrobeID isEqualToString:@""]))
                    {
                        [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"idWardrobe IN %@" inArray:[NSArray arrayWithObject:_addingProductsToWardrobeID] sortingWithKey:@"idWardrobe" ascending:YES];
                        
                        // Get the list of reviews that were provided
                        for (Wardrobe *wardrobe in mappingResult)
                        {
                            if([wardrobe isKindOfClass:[Wardrobe class]])
                            {
                                if(!(wardrobe.idWardrobe == nil))
                                {
                                    if (!([wardrobe.idWardrobe isEqualToString:@""]))
                                    {
                                        if([wardrobe.idWardrobe isEqualToString:_addingProductsToWardrobeID])
                                        {
                                            _bAddingProductsToPostContentWardrobe = NO;
                                        }
                                    }
                                }
                            }
                        }
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
                
                if (!(_wardrobesFetchedResultsController == nil))
                {
                    if (_userWardrobesElements == nil)
                        _userWardrobesElements = [[NSMutableArray alloc] init];
                    else
                        [_userWardrobesElements removeAllObjects];
                    
                    for (int i = 0; i < [[_wardrobesFetchedResultsController fetchedObjects] count]; i++)
                    {
                        Wardrobe * tmpWardrobe = [[_wardrobesFetchedResultsController fetchedObjects] objectAtIndex:i];
                        
                        if([tmpWardrobe.idWardrobe isEqualToString:_addingProductsToWardrobeID])
                        {
                            _addingProductsToWardrobe = tmpWardrobe;
                        }
                        
                        [_userWardrobesElements addObjectsFromArray:tmpWardrobe.itemsId];
                    }
                    
                    _wardrobesFetchedResultsController = nil;
                    _wardrobesFetchRequest = nil;
                    
                    [self initFetchedResultsControllerWithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:_userWardrobesElements sortingWithKey:@"idGSBaseElement" ascending:YES];
                    
                    [self updateCollectionViewWithCellType:@"ResultCell" fromItem:0 toItem:-1 deleting:NO];
                }
            }
            
            if ((bGettingInitialDataPosts == NO) && (_bAddingProductsToPostContentWardrobe == NO))
                [self stopActivityFeedback];
            
            break;
        }
        case GET_SEARCH_SUGGESTEDFILTERKEYWORDS:
        {
            if (bFiltersNew)
            {
                [filterManager setupFiltersFromSearchSuggested:mappingResult];
            }
            else
            {
                // Empty old terms array
                [_suggestedFilters removeAllObjects];
                [_suggestedFiltersObject removeAllObjects];
                
                if (arSelectedProductCategories == nil)
                {
                    arSelectedProductCategories = [[NSMutableArray alloc] init];
                }
                else
                {
                    [arSelectedProductCategories removeAllObjects];
                }
                
                // Add the list of terms that were provided
                
                for (SuggestedKeyword *suggestedKeyword in mappingResult)
                {
                    if([suggestedKeyword isKindOfClass:[SuggestedKeyword class]])
                    {
                        if(!(suggestedKeyword.name == nil))
                        {
                            if(!([suggestedKeyword.name isEqualToString:@""]))
                            {
                                //                            NSString * pene = [[suggestedKeyword.name lowercaseString] capitalizedString];
                                //                            pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                //                            if (!([_suggestedFilters containsObject:pene]))
                                //                            {
                                //                                [_suggestedFilters addObject:pene];
                                //                            }
                                if (!([_suggestedFiltersObject containsObject:suggestedKeyword]))
                                {
                                    // get the keyword
                                    Keyword * keySuggested = [self getKeywordFromId:suggestedKeyword.idSuggestedKeyword];
                                    if (keySuggested != nil)
                                    {
                                        NSString * sObjectId = [keySuggested getIdElement];
                                        if (sObjectId != nil)
                                        {
                                            ProductGroup *pg = [self getProductGroupFromId:sObjectId];
                                            Feature *feat = [self getFeatureFromId:sObjectId];
                                            Brand * brand = [self getBrandFromId:sObjectId];
                                            
                                            if (pg != nil)
                                            {
                                                [_suggestedFiltersObject addObject:pg];
                                                [_suggestedFilters addObject:pg.idProductGroup];
                                                
                                                selectedProductCategory = [pg getTopParent];
                                                
                                                if (![arSelectedProductCategories containsObject:selectedProductCategory])
                                                {
                                                    [arSelectedProductCategories addObject:selectedProductCategory];
                                                }
                                            }
                                            else if (feat != nil)
                                            {
                                                [_suggestedFiltersObject addObject:feat];
                                                [_suggestedFilters addObject:feat.idFeature];
                                            }
                                            else if (brand != nil)
                                            {
                                                [_suggestedFiltersObject addObject:brand];
                                                [_suggestedFilters addObject:brand.idBrand];
                                            }
                                            else
                                            {
                                                [_suggestedFiltersObject addObject:keySuggested];
                                                [_suggestedFilters addObject:sObjectId];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                [self setupSuggestedFiltersRibbonView];
            }

            if ((bGettingDataOfElement == NO) && (bGettingInitialDataPosts == NO))
            {
                [self stopActivityFeedback];
            }
            
            break;
        }
        case GET_PRODUCTCATEGORIES:
        {
            // Empty old terms array
            [_suggestedFilters removeAllObjects];
            [_suggestedFiltersObject removeAllObjects];
            
            // Add the list of terms that were provided
            
            for (ProductGroup *productGroup in mappingResult)
            {
                if([productGroup isKindOfClass:[ProductGroup class]])
                {
                    if(!(productGroup.name == nil))
                    {
                        if(!([productGroup.name isEqualToString:@""]))
                        {
                            //                            NSString * pene = [[productGroup.name lowercaseString] capitalizedString];
                            //                            pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            //
                            //                            if (!([_suggestedFilters containsObject:pene]))
                            //                            {
                            //                                [_suggestedFilters addObject:pene];
                            //                            }
                            if (!([_suggestedFiltersObject containsObject:productGroup]))
                            {
                                [_suggestedFiltersObject addObject:productGroup];
                                [_suggestedFilters addObject:productGroup.idProductGroup];
                            }
                        }
                    }
                }
            }
            
            [self setupSuggestedFiltersRibbonView];
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_PRODUCT:
        {
            bGettingDataOfElement = NO;
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
                                [review_array addObject:review];
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
                                [self preLoadImage:content.url];    
                            }
                        }
                    }
                }
            }
            
            for (ProductAvailability *availability in mappingResult)
            {
                if ([availability isKindOfClass:[ProductAvailability class]])
                {
                    NSLog(@"Getting product availability succeed!");
                    
                    BOOL bOnline = NO;
                    if ([availability.online boolValue])
                    {
                        NSLog(@"Online: YES");
                        bOnline = YES;
                    }
                    else
                    {
                        NSLog(@"Online: NO");
                        bOnline = NO;
                    }
    
                    if (bOnline)
                    {
                        NSLog(@"Website %@", availability.website);
                    }
                    
                    NSLog(@"storename %@", availability.storename);
                    NSLog(@"address %@", availability.address);
                    NSLog(@"zipcode %@", availability.zipcode);
                    NSLog(@"state %@", availability.state);
                    NSLog(@"city %@", availability.city);
                    NSLog(@"country %@", availability.country);
                    NSLog(@"telephone %@", availability.telephone);
                    NSLog(@"latitude %f", [availability.latitude floatValue]);
                    NSLog(@"longitude %f", [availability.longitude floatValue]);
                    
                    [resultAvailabilities addObject:availability];
                }
            }
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: @"ProductAdd", selectedSpecificResult, resultContent, resultReviews, resultAvailabilities, review_array, _currentSearchQuery, nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:PRODUCTSHEET_VC withParameters:parametersForNextVC];
            
            break;
        }
        case GET_FULL_POST:
        {
            User* postUser = nil;
            FashionistaPost* selectedSpecificPost = nil;
            
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
            
            postLikesNumber = selectedSpecificPost.likesNum;
            
            resultComments = [NSMutableArray arrayWithArray:[selectedSpecificPost.comments allObjects]];
            
            NSMutableArray* postContent = [NSMutableArray arrayWithArray:[selectedSpecificPost.contents allObjects]];
            // Get the list of contents that were provided
            for (FashionistaContent *content in postContent)
            {
                [self preLoadImage:content.image];
                //[UIImage cachedImageWithURL:content.image];
            }
            
            postUser = selectedSpecificPost.author;
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], selectedSpecificPost, postContent, resultComments, [NSNumber numberWithBool:NO], postLikesNumber, postUser, nil];
            
                if((!([parametersForNextVC count] < 2)) && ([postContent count] > 0))
                {
                    [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
                }
            [self stopActivityFeedback];
            break;
        }
        case GET_POST:
        {
            bGettingDataOfElement = NO;
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[FashionistaPost class]]))
                 {
                     selectedSpecificResult = (FashionistaPost *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Get the number of likes of that post
            for (NSMutableDictionary *postLikesNumberDict in mappingResult)
            {
                if([postLikesNumberDict isKindOfClass:[NSMutableDictionary class]])
                {
                    postLikesNumber = [postLikesNumberDict objectForKey:@"likes"];
                }
            }
            
            // Get the list of comments that were provided
            for (Comment *comment in mappingResult)
            {
                if([comment isKindOfClass:[Comment class]])
                {
                    if(!(comment.idComment == nil))
                    {
                        if  (!([comment.idComment isEqualToString:@""]))
                        {
                            if(!([resultComments containsObject:comment.idComment]))
                            {
                                [resultComments addObject:comment.idComment];
                            }
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
                            if(!([resultContent containsObject:content]))
                            {
                                [resultContent addObject:content];
                                [self preLoadImage:content.image];
                            }
                        }
                    }
                }
            }
            
            // Get the user who authored the Post
            for (User *user in mappingResult)
            {
                if([user isKindOfClass:[User class]])
                {
                    if(!(user.idUser == nil))
                    {
                        if  (!([user.idUser isEqualToString:@""]))
                        {
                            postAuthor = user;
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: _selectedResult, selectedSpecificResult, resultContent, resultComments, _currentSearchQuery, postLikesNumber, postAuthor, nil];
            
            [self stopActivityFeedback];
            
            
            if((!([parametersForNextVC count] < 2)) && ([resultContent count] > 0))
            {
                [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
            }
            
            break;
        }
        case GET_FASHIONISTA:
        {
            bGettingDataOfElement = NO;
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     selectedSpecificResult = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: /*_selectedResult, */selectedSpecificResult, [NSNumber numberWithBool:NO], _currentSearchQuery, nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            
            break;
        }
        case GET_PAGE:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[FashionistaPage class]]))
                 {
                     selectedSpecificResult = (FashionistaPage *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: /*_selectedResult, */selectedSpecificResult, _currentSearchQuery, nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:FASHIONISTAMAINPAGE_VC withParameters:parametersForNextVC];
            
            break;
        }
        case GET_WARDROBE:
        {
            bGettingDataOfElement = NO;
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Wardrobe class]]))
                 {
                     selectedSpecificResult = (Wardrobe *)obj;
                     
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
                            if(((Wardrobe*)selectedSpecificResult).itemsId == nil)
                            {
                                ((Wardrobe*)selectedSpecificResult).itemsId = [[NSMutableArray alloc] init];
                            }
                            
                            if(!([((Wardrobe*)selectedSpecificResult).itemsId containsObject:item.idGSBaseElement]))
                            {
                                [((Wardrobe*)selectedSpecificResult).itemsId addObject:item.idGSBaseElement];
                                [self preLoadImage:item.preview_image];
                            }
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects:((Wardrobe*)selectedSpecificResult), [NSNumber numberWithBool:NO], _currentSearchQuery, nil];
            
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:WARDROBECONTENT_VC withParameters:parametersForNextVC];
            
            break;
        }
        case FINISHED_SEARCH_WITHOUT_RESULTS_ONLY_BRAND:
        case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            bGettingInitialDataPosts = NO;
            bGettingDataOfElement = NO;
            
            _bSuggestedKeywordsFromSearch = NO;
            filterManager.bSuggestedKeywordsFromSearch = NO;
            int previousSuccesfulTerms = (int)[_successfulTerms count];
            
            _currentSearchQuery = nil;
            _notSuccessfulTerms = @"";
            
            //Setup the filter terms ribbon only if not just loading more results of the same search
            if (!_bLoadingMoreResults)
            {
                // Empty old terms array
                [_successfulTerms removeAllObjects];
                selectedProductCategory = nil;
                iNumSubProductCategories = 0;
                [arSelectedSubProductCategory removeAllObjects];
                [arExpandedSubProductCategory removeAllObjects];
                
                NSMutableArray * completeSearchTermsList = [[NSMutableArray alloc] init];
                
                if (_searchContext != BRANDS_SEARCH)
                {
                    if(_searchContext == HISTORY_SEARCH)
                    {
                        if((!(_successfulTerms == nil)) && ([_successfulTerms count] > 0))
                        {
                            [completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",_searchPeriod]), nil)]];
                        }
                        else
                        {
                            [completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",_searchPeriod]), nil)];
                        }
                    }
                    else if(_searchContext == FASHIONISTAPOSTS_SEARCH)
                    {
                        //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTA_POSTS_", nil)]];
                        
                        if(!(appDelegate.currentUser == nil))
                        {
                            //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",_searchPostType]), nil)]];
                            
                            if((!(_successfulTerms == nil)) && ([_successfulTerms count] > 0))
                            {
                                [completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)]];
                            }
                            else
                            {
                                [completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)];
                            }
                        }
                        //else
                        {
                            //if((!(_successfulTerms == nil)) && ([_successfulTerms count] > 0))
                            {
                                //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",_searchPostType]), nil)]];
                            }
                            //else
                            {
                                //[completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",_searchPostType]), nil)];
                            }
                        }
                    }
                    else if(_searchContext == FASHIONISTAS_SEARCH)
                    {
                        //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTAS_", nil)]];
                        
                        if(!(appDelegate.currentUser == nil))
                        {
                            if((!(_successfulTerms == nil)) && ([_successfulTerms count] > 0))
                            {
                                [completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)]];
                            }
                            else
                            {
                                [completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)];
                            }
                        }
                    }
                    
                    [completeSearchTermsList addObjectsFromArray:_successfulTerms];
                    
                    [self.searchTermsListView initSlideButtonWithButtons:[[[NSOrderedSet orderedSetWithArray:completeSearchTermsList] array] mutableCopy] andDelegate:self];
                    
                    [self getSuggestedFilters];
                }
                else
                {
                    [self stopActivityFeedback];
                    
                    [self setupSuggestedFiltersRibbonView];
                }
            }
            else
            {
                _bLoadingMoreResults = NO;
            }
            
            if(!(_searchTermsBeforeUpdate == nil))
            {
                if([_searchTermsBeforeUpdate count] > 0)
                {
                    // show message that the brand has not products, it will be come soon
                    if (connection == FINISHED_SEARCH_WITHOUT_RESULTS_ONLY_BRAND)
                    {
                        [self showAlertBrandNoProducts:mappingResult];
                    }
                    else
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_ALERT_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                        
                        [alertView show];
                    }
                    
                    [_successfulTerms removeAllObjects];
                    [self.searchTermsListView removeAllButtons];
                    
                    [_successfulTerms addObjectsFromArray:_searchTermsBeforeUpdate];
                    [self initSearchTermsList];
                    [self updateSearchForTermsChanges];
                    
                    [_searchTermsBeforeUpdate removeAllObjects];
                    _searchTermsBeforeUpdate = nil;
                    
                    if((_searchContext == PRODUCT_SEARCH) && (self.fromViewController == nil))
                    {
                        [self createBottomControls];
                    }
                    
                    [self updateBottomBarSearch];
                    
                    _bRefreshingSearch = NO;
                    
                    _bLoadingStylistsOrPosts = NO;
                    
                    return;
                }
            }
            //
            //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            //
            //            [alertView show];
            
            [_searchTermsBeforeUpdate removeAllObjects];
            
            _searchTermsBeforeUpdate = nil;
            
            _filterSearchVC = nil;
            
            switch (_searchContext)
            {
                case HISTORY_SEARCH:
                case BRANDS_SEARCH:
                case TRENDING_SEARCH:
                case FASHIONISTAPOSTS_SEARCH:
                case FASHIONISTAS_SEARCH:
                case STYLES_SEARCH:
                    
                    if(!(previousSuccesfulTerms > 0))
                    {
                        break;
                    }
                    
                    // Then, continue to performSearch:
                    
                    [self performSearch];
                    
                    break;
                    
                case PRODUCT_SEARCH:
                    
                    // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
                    if ([self getFetchedResultsControllerForCellType:@"ResultCell" ] == nil)
                    {
                        [self initFetchedResultsController];
                    }
                    
                    // Update Fetched Results Controller
                    [self performFetchForCollectionViewWithCellType:@"ResultCell"];
                    
                    // Update collection view
                    [self updateCollectionViewWithCellType:@"ResultCell" fromItem:resultsBeforeUpdate toItem:(int)[_resultsArray count] deleting:FALSE];
                    
                    [self setBackgroundImage];
                    
                    //Update top bar with number of results and terms
                    
                    if(!(_searchContext == STYLES_SEARCH))
                    {
                        int iNumResults = [self iGetSearchNumResults];
                        
                        NSString * subTitle = nil;
                        
                        //if(!(_searchContext == FASHIONISTAS_SEARCH || _searchContext == FASHIONISTAPOSTS_SEARCH))
                        {
                            if(iNumResults > 0)
                            {
                                if(iNumResults >= 1000)
                                {
                                    subTitle = [NSString stringWithFormat:NSLocalizedString(@"_MORETHAN1000_RESULTS_", nil), iNumResults];
                                }
                                else
                                {
                                    if(iNumResults > 1)
                                    {
                                        subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULTS_", nil), iNumResults];
                                    }
                                    else
                                    {
                                        subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULT_", nil), iNumResults];
                                    }
                                }
                            }
                            else
                            {
                                subTitle = NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil);
                            }
                        }
                        
                        [self setTopBarTitle:nil andSubtitle:subTitle];
                    }
                    
                    // TODO: get
                    
                    [self setNotSuccessfulTerms:([_notSuccessfulTerms isEqualToString:@""] ? @"" : [NSString stringWithFormat:NSLocalizedString(@"_NOTSUCCESFULTERMS_", nil), _notSuccessfulTerms])];
                    
                    [self stopActivityFeedback];
                    
                    [self showAddSearchTerm];
                    
                    // show message that the brand has not products, it will be come soon
                    if (connection == FINISHED_SEARCH_WITHOUT_RESULTS_ONLY_BRAND)
                    {
                        [self showAlertBrandNoProducts:mappingResult];
                    }
                    
                    break;
                    
                default:
                    break;
            }
            
            if((_searchContext == PRODUCT_SEARCH) && (self.fromViewController == nil))
            {
                [self createBottomControls];
            }
            
            _bRefreshingSearch = NO;
            
            _bLoadingStylistsOrPosts = NO;
            
            break;
        }
        case FINISHED_BRANDPRODUCTSSEARCH_WITHOUT_RESULTS:
        {
            [self stopActivityFeedback];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_BRANDPRODUCTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
            
            if((_searchContext == PRODUCT_SEARCH) && (self.fromViewController == nil))
            {
                [self createBottomControls];
            }
            
            break;
        }
        case FINISHED_SEARCH_WITH_RESULTS:
        case FINISHED_STYLESSEARCH_WITH_RESULTS:
        {
            bGettingInitialDataPosts = NO;
            bGettingDataOfElement = NO;
            
            _bSuggestedKeywordsFromSearch = YES;
            filterManager.bSuggestedKeywordsFromSearch = YES;
            
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
            
            _currentSearchQuery = searchQuery;
            
            [self stopActivityFeedback];
            
            if (searchQuery.numresults > 0)
            {
                _notSuccessfulTerms = notSuccessfulTerms;
                
                // Get the list of results groups that were provided
                for (ResultsGroup *group in mappingResult)
                {
                    if([group isKindOfClass:[ResultsGroup class]])
                    {
                        if(!(group.idResultsGroup == nil))
                        {
                            if  (!([group.idResultsGroup  isEqualToString:@""]))
                            {
                                if(!([_resultsGroups containsObject:group]))
                                {
                                    [_resultsGroups addObject:group];
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
                            if  (!([result.idGSBaseElement isEqualToString:@""]))
                            {
                                if(!([_resultsArray containsObject:result.idGSBaseElement]))
                                {
                                    [_resultsArray addObject:result.idGSBaseElement];
                                    [self preLoadImage:result.preview_image];
                                    
                                    //                                    if(!(result.brandName == nil))
                                    //                                    {
                                    //                                        if(!([result.brandName isEqualToString:@""]))
                                    //                                        {
                                    //                                            if(_downloadedBrands == nil)
                                    //                                            {
                                    //                                                _downloadedBrands = [[NSMutableArray alloc] init];
                                    //                                            }
                                    //
                                    //                                            if(!([_downloadedBrands containsObject:result.brandName]))
                                    //                                            {
                                    //                                                [self performRestGet:GET_SEARCHPRODUCTS_BRAND withParamaters:[NSArray arrayWithObject:result.idGSBaseElement]];
                                    //                                                [_downloadedBrands addObject:result.brandName];
                                    //                                            }
                                    //                                        }
                                    //                                    }
                                }
                            }
                        }
                    }
                }
                
                //Setup the filter terms ribbon only if not just loading more results of the same search
                if (!_bLoadingMoreResults&&_searchContext != FASHIONISTAS_SEARCH)
                {
                    // Empty old terms array
                    [_successfulTerms removeAllObjects];
                    
                    // Get the keywords that provided results
                    NSMutableArray * successfulTermsObject = [[NSMutableArray alloc] init];
                    
                    [self getKeywordFromMapping:mappingResult inSuccesfulTerms:_successfulTerms andInSuccessfulObjects:successfulTermsObject];

                    NSMutableArray * completeSearchTermsList = [[NSMutableArray alloc] init];
                    
                    if (_searchContext != BRANDS_SEARCH)
                    {
                        if(_searchContext == HISTORY_SEARCH)
                        {
                            if((!(successfulTermsObject == nil)) && ([successfulTermsObject count] > 0))
                            {
                                [completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",_searchPeriod]), nil)]];
                            }
                            else
                            {
                                [completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",_searchPeriod]), nil)];
                            }
                        }
                        else if(_searchContext == FASHIONISTAPOSTS_SEARCH)
                        {
                            //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTA_POSTS_", nil)]];
                            
                            if(!(appDelegate.currentUser == nil))
                            {
                                //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",_searchPostType]), nil)]];
                                
                                if((!(successfulTermsObject == nil)) && ([successfulTermsObject count] > 0))
                                {
                                    [completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)]];
                                }
                                else
                                {
                                    [completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)];
                                }
                            }
                            //else
                            {
                                //if((!(successfulTermsObject == nil)) && ([successfulTermsObject count] > 0))
                                {
                                    //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",_searchPostType]), nil)]];
                                }
                                //else
                                {
                                    //[completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",_searchPostType]), nil)];
                                }
                            }
                        }
                        else if(_searchContext == FASHIONISTAS_SEARCH)
                        {
                            //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTAS_", nil)]];
                            
                            if(!(appDelegate.currentUser == nil))
                            {
                                if((!(successfulTermsObject == nil)) && ([successfulTermsObject count] > 0))
                                {
                                    [completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)]];
                                }
                                else
                                {
                                    [completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)];
                                }
                            }
                        }
                        
                        [completeSearchTermsList addObjectsFromArray:successfulTermsObject];
                        
                        [self.searchTermsListView initSlideButtonWithButtons:[[[NSOrderedSet orderedSetWithArray:completeSearchTermsList] array] mutableCopy] andDelegate:self];
                        [self.searchTermsListView setLastState];
                        
                        [self getSuggestedFilters];
                        
                        [successfulTermsObject removeAllObjects];
                    }
                    else
                    {
                        [self setupSuggestedFiltersRibbonView];
                    }
                    
                }
                else
                {
                    _bLoadingMoreResults = NO;
                }
                
                [self hideAddSearchTerm];
            }
            
            // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
            if ([self getFetchedResultsControllerForCellType:@"ResultCell" ] == nil)
            {
                [self initFetchedResultsController];
            }
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:@"ResultCell"];
            
            //int i = (int)[[[self getFetchedResultsControllerForCellType:@"ResultCell"] fetchedObjects] count];
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"ResultCell" fromItem:resultsBeforeUpdate toItem:(int)[[[self getFetchedResultsControllerForCellType:@"ResultCell"] fetchedObjects] count] deleting:FALSE];
            
            //Update top bar with number of results and terms
            
            if(!(_searchContext == STYLES_SEARCH))
            {
                int iNumResults = [self iGetSearchNumResults];
                
                NSString * subTitle = nil;
                
                //if(!(_searchContext == FASHIONISTAS_SEARCH || _searchContext == FASHIONISTAPOSTS_SEARCH))
                {
                    if(iNumResults > 0)
                    {
                        if(iNumResults >= 1000)
                        {
                            subTitle = [NSString stringWithFormat:NSLocalizedString(@"_MORETHAN1000_RESULTS_", nil), iNumResults];
                        }
                        else
                        {
                            if(iNumResults > 1)
                            {
                                subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULTS_", nil), iNumResults];
                            }
                            else
                            {
                                subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULT_", nil), iNumResults];
                            }
                        }
                    }
                    else
                    {
                        subTitle = NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil);
                    }
                }
                
                [self setTopBarTitle:nil andSubtitle:subTitle];
            }
            
            [self setNotSuccessfulTerms:([_notSuccessfulTerms isEqualToString:@""] ? @"" : [NSString stringWithFormat:NSLocalizedString(@"_NOTSUCCESFULTERMS_", nil), _notSuccessfulTerms])];
            
            [_searchTermsBeforeUpdate removeAllObjects];
            _searchTermsBeforeUpdate = nil;
            
            [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
            [self hideBackgroundAddButton];
            
            _bRefreshingSearch = NO;
            
            _bLoadingStylistsOrPosts = NO;
            
            break;
        }
        case FINISHED_BRANDPRODUCTSSEARCH_WITH_RESULTS:
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
                                    [self preLoadImage:result.preview_image];
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
                
                // Paramters for next VC (ResultsViewController)
                NSArray * parametersForNextVC = [NSArray arrayWithObjects: searchQuery, foundResults, foundResultsGroups, successfulTerms, notSuccessfulTerms, nil];
                
                [self stopActivityFeedback];
                
                if ([foundResults count] > 0)
                {
                    [self transitionToViewController:SEARCH_VC withParameters:parametersForNextVC];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_BRANDPRODUCTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                }
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_BRANDPRODUCTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
            }
            
            if((_searchContext == PRODUCT_SEARCH) && (self.fromViewController == nil))
            {
                [self createBottomControls];
            }
            
            break;
        }
        case ADD_ITEM_TO_WARDROBE:
        {
            if ((!(buttonToHighlight == nil)))
            {
                // Change the hanger button image
                UIImage * buttonImage = [UIImage imageNamed:@"hanger_checked.png"];
                
                if (!(buttonImage == nil))
                {
                    [buttonToHighlight setImage:buttonImage forState:UIControlStateNormal];
                    [buttonToHighlight setImage:buttonImage forState:UIControlStateHighlighted];
                    [[buttonToHighlight imageView] setContentMode:UIViewContentModeScaleAspectFit];
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
                
                buttonToHighlight = nil;
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_USER:
        {
            [self stopActivityFeedback];
            break;
        }
        case UNFOLLOW_USER:
        case FOLLOW_USER:
        {
            if ((!(buttonToHighlight == nil)))
            {
                // Change the hanger button image
                UIImage * buttonImage = ((connection == FOLLOW_USER) ? ([UIImage imageNamed:@"heart_checked.png"]) : ([UIImage imageNamed:@"heart_unchecked.png"]));
                
                if (!(buttonImage == nil))
                {
                    [buttonToHighlight setImage:buttonImage forState:UIControlStateNormal];
                    [buttonToHighlight setImage:buttonImage forState:UIControlStateHighlighted];
                    [[buttonToHighlight imageView] setContentMode:UIViewContentModeScaleAspectFit];
                }
                
                // Reload User Follows
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                if (!(appDelegate.currentUser == nil))
                {
                    if(!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                            
                            [self performRestGet:GET_USER_FOLLOWS withParamaters:requestParameters];
                        }
                    }
                }
                
                buttonToHighlight = nil;
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_USER_FOLLOWS:
        {
            //Reset the fetched results controller to fetch the current user follows
            
            [_followsFetchedResultsController performFetch:nil];
            
            [self updateCollectionViewWithCellType:@"ResultCell" fromItem:0 toItem:-1 deleting:NO];
            
            [self stopActivityFeedback];
            
            break;
        }
        case CHECK_SEARCH_STRING:
        case CHECK_SEARCH_STRING_AFTER_SEARCH:
        {
            NSMutableArray * arCheckSearch = [[NSMutableArray alloc] init];
            for (CheckSearch *checkSearch in mappingResult)
            {
                if([checkSearch isKindOfClass:[CheckSearch class]])
                {
                    [arCheckSearch addObject:checkSearch];
                }
            }
            
            [self checkSearchTermsWithResults: arCheckSearch updtaingSubTitle:(connection == CHECK_SEARCH_STRING)];
            
            
            
            break;
        }
        case CHECK_SEARCH_STRING_SUGGESTIONS:
        {
            
            NSMutableArray * arCheckSearch = [[NSMutableArray alloc] init];
            for (CheckSearch *checkSearch in mappingResult)
            {
                if([checkSearch isKindOfClass:[CheckSearch class]])
                {
                    [arCheckSearch addObject:checkSearch];
                }
            }
            [self checkSearchSuggestionsWithResults: arCheckSearch];
            
            break;
        }
        case CHECK_SEARCH_STRING_SUGGESTIONS_AFTER_SEARCH:
        {
            
            NSMutableArray * arCheckSearch = [[NSMutableArray alloc] init];
            for (CheckSearch *checkSearch in mappingResult)
            {
                if([checkSearch isKindOfClass:[CheckSearch class]])
                {
                    [arCheckSearch addObject:checkSearch];
                }
            }
            [self checkSearchSuggestionsWithResults: arCheckSearch];
            
            if((_searchContext == PRODUCT_SEARCH) && (self.fromViewController == nil))
            {
                [self createBottomControls];
            }
            
            if ([self includeInspireTerm]) {
                _inspireView.hidden = NO;
            }
            else {
                _inspireView.hidden = YES;
            }
            
            break;
        }
            
        default:
            break;
    }
    
    [self updateBottomBarSearch];
}

- (void)processRestConnection:(connectionType)connection WithErrorMessage:(NSArray *)errorMessage forOperation:(RKObjectRequestOperation *)operation
{
    [super processRestConnection:connection WithErrorMessage:errorMessage forOperation:operation];
    
    
    //    BOOL bReachable = ([[[RKObjectManager sharedManager] HTTPClient] networkReachabilityStatus] != AFNetworkReachabilityStatusNotReachable) &&
    //                      ([[[RKObjectManager sharedManager] HTTPClient] networkReachabilityStatus] != AFNetworkReachabilityStatusUnknown) ;
    
    
    //if (bReachable == NO)
    {
        switch (connection) {
            case GET_ALLPRODUCTCATEGORIES:
            {
                break;
            }
            case GET_PRIORITYBRANDS:
            {
                NSDictionary* userInfo = @{@"total": @"ErrorConnection"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
                
                break;
            }
            case GET_ALLBRANDS:
            {
                NSDictionary* userInfo = @{@"total": @"ErrorConnection"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
                
                break;
            }
            case GET_ALLFEATURES:
            {
                NSDictionary* userInfo = @{@"total": @"ErrorConnection"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
                
                break;
            }
            case GET_ALLFEATUREGROUPS:
            {
                NSDictionary* userInfo = @{@"total": @"ErrorConnection"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
                
                break;
            }
            case CHECK_SEARCH_STRING:
            case CHECK_SEARCH_STRING_AFTER_SEARCH:
            {
                [self stopActivityCheckSearch];
                break;
            }
            case CHECK_SEARCH_STRING_SUGGESTIONS:
            case CHECK_SEARCH_STRING_SUGGESTIONS_AFTER_SEARCH:
            {
                // TODO: Actualizar la colleciton?
                [self stopActivityCheckSuggestions];
                break;
            }
                
            default:
                
//                [self stopActivityFeedback];
                
                break;
        }
        
    }
}

-(BOOL)includeInspireTerm {
    if (_categoryTerms == nil) {
        return NO;
    }
    for (NSString *term in _categoryTerms) {
        int n = 0;
        NSLog(@"SuccessFul Term Count : %li", [self.searchTermsListView.arrayButtons count]);
        for (NSObject *tempTerm in self.searchTermsListView.arrayButtons) {
            if ([tempTerm isKindOfClass:[ProductGroup class]]) {
                NSString *productGroupId = ((ProductGroup*)tempTerm).idProductGroup;
                if ([[term lowercaseString] isEqualToString:[productGroupId lowercaseString]]) {
                    n ++;
                    break;
                }
            }
            else if ([tempTerm isKindOfClass:[NSString class]]) {
                NSString * sSuccesfulTerm = (NSString *)tempTerm;
                // la funcion getKeywordElementForName, si el elemento es un product category este se añade al array de product catgeories donde se comprueba que existan los feature groups
                NSObject * object = [[CoreDataQuery sharedCoreDataQuery] getKeywordElementForName: sSuccesfulTerm];
                if ([object isKindOfClass:[ProductGroup class]]) {
                    NSString *productGroupId = ((ProductGroup*)object).idProductGroup;
                    if ([[term lowercaseString] isEqualToString:[productGroupId lowercaseString]]) {
                        n ++;
                        break;
                    }
                }
            }
        }
        if (n == 0)
        {
            [_categoryTerms removeAllObjects];
            
            _categoryTerms = nil;

            return NO;
        }
    }
    return YES;
}
-(void) checkSearchTerms:(BOOL) afterSearch
{
    _inspireView.hidden = YES;
    NSString *stringToSearch = [self composeStringhWithTermsOfArray:_successfulTerms encoding:YES];
    
    if(stringToSearch == nil)
    {
        stringToSearch = @"";
        
    }
    NSArray * requestParameters = nil;
    
    switch (_searchContext)
    {
        case PRODUCT_SEARCH:
            
            // Check that the string to search is valid
            if (!((stringToSearch == nil) || ([stringToSearch isEqualToString:@""])))
            {
                NSLog(@"Performing check search with terms: %@", stringToSearch);
                
                // Perform request to get the search results
                
                // Provide feedback to user
                [self initActivityCheckSearch];
                [self stopActivityCheckSearch];
                [self startActivityCheckSearch];
                
                //                [self stopActivityFeedback];
                //                [self startActivityFeedbackWithMessage:@""];
                [self initActivityCheckSuggestions];
                [self stopActivityCheckSuggestions];
                [self startActivityCheckSuggestions];
                
                requestParameters = [[NSArray alloc] initWithObjects:stringToSearch, nil];
                
                [self cancelCheckSearchOperations];
                if (afterSearch)
                {
                    [self performRestGet:CHECK_SEARCH_STRING_AFTER_SEARCH withParamaters:requestParameters];
                    [self performRestGet:CHECK_SEARCH_STRING_SUGGESTIONS_AFTER_SEARCH withParamaters:requestParameters];
                }
                else
                {
                    [self performRestGet:CHECK_SEARCH_STRING withParamaters:requestParameters];
                    [self performRestGet:CHECK_SEARCH_STRING_SUGGESTIONS withParamaters:requestParameters];
                }
            }
            else
            {
                
                [self cancelCheckSearchOperations];
                
                if (bFiltersNew)
                {
                    [filterManager initFoundSuggestions];
                }
                else
                {
                    if(_foundSuggestions)
                        [_foundSuggestions removeAllObjects];
                }
                
            }
            
            break;
            
            
        default:
            break;
    }
}

-(void) initActivityCheckSearch
{
    if (self.activityIndicatorCheckSearch == nil)
    {
        self.activityIndicatorCheckSearch = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        // right in the slide view
        //        [self.activityIndicatorCheckSearch setCenter:CGPointMake(self.searchTermsListView.frame.origin.x + self.searchTermsListView.frame.size.width - 10, self.searchTermsListView.frame.origin.y + (self.searchTermsListView.frame.size.height / 2.0))];
        // in the top label
        [self.activityIndicatorCheckSearch setCenter:CGPointMake(self.subtitleLabel.frame.origin.x + 40/*(self.subtitleLabel.frame.size.width / 2.0)*/, self.subtitleLabel.frame.origin.y + (self.subtitleLabel.frame.size.height / 2.0))];
        [self.activityIndicatorCheckSearch setHidesWhenStopped:YES];
        [self.activityIndicatorCheckSearch stopAnimating];
        [self.activityIndicatorCheckSearch setHidden:YES];
        
        [self.view addSubview:self.activityIndicatorCheckSearch];
    }
}

-(void) initActivityCheckSuggestions
{
    if (self.activityIndicatorCheckSuggestions == nil)
    {
        self.activityIndicatorCheckSuggestions = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        // right in the slide view
        //        [self.activityIndicatorCheckSearch setCenter:CGPointMake(self.searchTermsListView.frame.origin.x + self.searchTermsListView.frame.size.width - 10, self.searchTermsListView.frame.origin.y + (self.searchTermsListView.frame.size.height / 2.0))];
        // in the top label
        [self.activityIndicatorCheckSuggestions setCenter:CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height * kScreenPortionForActivityIndicatorVerticalCenter)];
        [self.activityIndicatorCheckSuggestions setHidesWhenStopped:YES];
        [self.activityIndicatorCheckSuggestions stopAnimating];
        [self.activityIndicatorCheckSuggestions setHidden:YES];
        
        [self.view addSubview:self.activityIndicatorCheckSuggestions];
        
        // Init, position and hide the activity label
        self.activityIndicatorCheckSuggestionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        //[[self.activityLabel layer] setCornerRadius:5];
        [self.activityIndicatorCheckSuggestionsLabel setBackgroundColor:[UIColor kActivityLabelBackgroundColor]];
        [self.activityIndicatorCheckSuggestionsLabel setAlpha:kActivityLabelAlpha];
        [self.activityIndicatorCheckSuggestionsLabel setCenter:CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0)];
        [self.activityIndicatorCheckSuggestionsLabel setText:NSLocalizedString(@"_SETTING_SUGGESTIONS_", nil)];
        [self.activityIndicatorCheckSuggestionsLabel setFont:[UIFont fontWithName:@kFontInActivityLabel size:kFontSizeInActivityLabel]];
        [self.activityIndicatorCheckSuggestionsLabel setTextAlignment:NSTextAlignmentCenter];
        [self.activityIndicatorCheckSuggestionsLabel setHidden:YES];
        [self.view addSubview: self.activityIndicatorCheckSuggestionsLabel];
    }
}

-(void) startActivityCheckSearch
{
    if (self.activityIndicatorCheckSearch != nil)
    {
        [self.activityIndicatorCheckSearch startAnimating];
        [self.activityIndicatorCheckSearch setHidden:NO];
        
        [self.view bringSubviewToFront:self.activityIndicatorCheckSearch];
        [self.subtitleLabel setHidden:YES];
    }
}

-(void) startActivityCheckSuggestions
{
    if (self.activityIndicatorCheckSuggestions != nil)
    {
        [self.activityIndicatorCheckSuggestions startAnimating];
        [self.activityIndicatorCheckSuggestions setHidden:NO];
        [self.view setUserInteractionEnabled:NO];
        
        [self.activityIndicatorCheckSuggestionsLabel setHidden:NO];
        
        [self.view bringSubviewToFront: self.activityIndicatorCheckSuggestionsLabel];
        
        [self.view bringSubviewToFront:self.activityIndicatorCheckSuggestions];
    }
}

-(void) stopActivityCheckSearch
{
    if (self.activityIndicatorCheckSearch != nil)
    {
        [self.activityIndicatorCheckSearch setHidden:YES];
        [self.activityIndicatorCheckSearch stopAnimating];
        [self.subtitleLabel setHidden:NO];
        
    }
}

-(void) stopActivityCheckSuggestions
{
    if (self.activityIndicatorCheckSuggestions != nil)
    {
        [self.activityIndicatorCheckSuggestions setHidden:YES];
        [self.activityIndicatorCheckSuggestions stopAnimating];
        [self.activityIndicatorCheckSuggestionsLabel setHidden:YES];
        [self.view setUserInteractionEnabled:YES];
    }
    
}

#pragma mark - Search Terms & Suggested Filters


// Setup the search terms list
- (void) initSearchTermsList
{
    [self.searchTermsListView setColorBackgroundButtons:[UIColor clearColor]];
    
    [self.searchTermsListView setMinWidthButton:kMinWidthButton];
    [self.searchTermsListView setSpaceBetweenButtons:0];
    [self.searchTermsListView setBShowShadowsSides:YES];
    [self.searchTermsListView setBShowPointRight:YES];
    [self.searchTermsListView setBButtonsCentered:NO];
    [self.searchTermsListView setColorTextButtons:[UIColor lightGrayColor]];
    [self.searchTermsListView setColorSelectedTextButtons:[UIColor lightGrayColor]];
    [self.searchTermsListView setFont:[UIFont fontWithName:@"AvantGarde-Book" size:16]];
    
    //[self.searchTermsListView setSNameButtonImage:@"TermsListButtonBackground.png"];
    //[self.searchTermsListView setSNameButtonImageHighlighted:@"TermsListButtonBackground.png"];
    
    NSMutableArray *unclosedButtons = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < maxHistoryPeriods; i++)
    {
        [unclosedButtons addObject:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)];
        [unclosedButtons addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)]];
    }
    
    //for (int i = 0; i < maxFashionistaPostTypes; i++)
    {
        //[unclosedButtons addObject:NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",i]), nil)];
        //[unclosedButtons addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",i]), nil)]];
    }
    
    for (int i = 0; i < maxFollowingRelationships; i++)
    {
        [unclosedButtons addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)];
        [unclosedButtons addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)]];
    }
    
    // Buttons to swap between Stylists contexts
    //[unclosedButtons addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTAS_", nil)]];
    //[unclosedButtons addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTA_POSTS_", nil)]];
    
    
    [self.searchTermsListView initUnclosedButtonsWithArray: unclosedButtons];
    
    NSMutableArray * completeSearchTermsList = [[NSMutableArray alloc] init];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (_searchContext != BRANDS_SEARCH)
    {
        if(_searchContext == HISTORY_SEARCH)
        {
            if((!(_successfulTerms == nil)) && ([_successfulTerms count] > 0))
            {
                [completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",_searchPeriod]), nil)]];
            }
            else
            {
                [completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",_searchPeriod]), nil)];
            }
        }
        else if(_searchContext == FASHIONISTAPOSTS_SEARCH)
        {
            //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTA_POSTS_", nil)]];
            
            if(!(appDelegate.currentUser == nil))
            {
                //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",_searchPostType]), nil)]];
                
                if((!(_successfulTerms == nil)) && ([_successfulTerms count] > 0))
                {
                    [completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)]];
                }
                else
                {
                    [completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)];
                }
            }
            //else
            {
                //if((!(_successfulTerms == nil)) && ([_successfulTerms count] > 0))
                {
                    //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",_searchPostType]), nil)]];
                }
                //else
                {
                    //[completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",_searchPostType]), nil)];
                }
            }
        }
        else if(_searchContext == FASHIONISTAS_SEARCH)
        {
            //[completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTAS_", nil)]];
            
            if(!(appDelegate.currentUser == nil))
            {
                if((!(_successfulTerms == nil)) && ([_successfulTerms count] > 0))
                {
                    [completeSearchTermsList addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)]];
                }
                else
                {
                    [completeSearchTermsList addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)];
                }
            }
        }
        
        
        if (_successfulTerms.count != _successfulTermsObject.count)
            [completeSearchTermsList addObjectsFromArray:_successfulTerms];
        else
            [completeSearchTermsList addObjectsFromArray:_successfulTermsObject];
//        [completeSearchTermsList addObjectsFromArray:_successfulTerms];
        
        //        [self.searchTermsListView initSlideButtonWithButtons:[[[NSOrderedSet orderedSetWithArray:completeSearchTermsList] array] mutableCopy] andDelegate:self];
        //
        //        [self getSuggestedFilters];
    }
    
    [self.searchTermsListView initSlideButtonWithButtons:[[[NSOrderedSet orderedSetWithArray:completeSearchTermsList] array] mutableCopy] andDelegate:self];
    
    [self getSuggestedFilters];
    
}

// Initialize the filter terms ribbon
- (void) initSuggestedFilters
{
    filterManager.searchBaseVC = self;
    filterManager.suggestedFiltersRibbonView = self.SuggestedFiltersRibbonView;
    filterManager.filtersCollectionView = self.secondCollectionView;
    filterManager.filtersView = self.selectFeaturesView;
    filterManager.constraintTopSearchFilterView = self.constraintTopSearchFeatureView;
    
    [filterManager initAllStructures];
    
    
    if (bFiltersNew == NO)
    {
        if(self.suggestedFilters == nil)
        {
            self.suggestedFilters = [[NSMutableArray alloc] init];
        }
        if(self.suggestedFiltersObject == nil)
        {
            self.suggestedFiltersObject = [[NSMutableArray alloc] init];
        }
    }
    
    [self.SuggestedFiltersRibbonView setFont:[UIFont fontWithName:@"Avenir-Heavy" size:kDefaultFontSuggestedSize]];
    
    
    [self.SuggestedFiltersRibbonView setMinWidthButton:kMinWidthButton];
    [self.SuggestedFiltersRibbonView setSpaceBetweenButtons:0];
    
    [self.SuggestedFiltersRibbonView setBSeparator:YES];
    [self.SuggestedFiltersRibbonView setColorSeparator:[UIColor darkGrayColor]];
    [self.SuggestedFiltersRibbonView setFHeightSeparator:self.SuggestedFiltersRibbonView.frame.size.height-7];
    
    [self.SuggestedFiltersRibbonView setFHeightSeparator:self.SuggestedFiltersRibbonView.frame.size.height-20];
    
    [self.SuggestedFiltersRibbonView setFWidthSeparator:2.0];
    
    //    [self.SuggestedFiltersRibbonView setSNameButtonImage:@"FiltersRibbonButtonBackground.png"];
    //    [self.SuggestedFiltersRibbonView setSNameButtonImageHighlighted:@"FiltersRibbonButtonBackground.png"];
    
    [self.SuggestedFiltersRibbonView setBMultiselect:NO];
    [self.SuggestedFiltersRibbonView setTypeSelection:TAB_TYPE];
    
    [self.SuggestedFiltersRibbonView setTypeSelection:UNDERLINE_TYPE];
    UIColor * goldenColor = [UIColor colorWithRed:178.0/255.0 green:145.0/255.0 blue:68.0/255.0 alpha:0.95];
    [self.SuggestedFiltersRibbonView setColorUnderlineSelected:goldenColor];
    
    [self.SuggestedFiltersRibbonView setBUnselectWithClick:YES];
    
    //    [self.SuggestedFiltersRibbonView setFTabHeight:0.9];
    
    [self.SuggestedFiltersRibbonView setColorBackgroundButtons:[UIColor clearColor]];
    
    [self.SuggestedFiltersRibbonView setColorBackgroundButtons:[UIColor clearColor]];
    
    [self.SuggestedFiltersRibbonView setColorShadowButtons:[UIColor clearColor]];
    [self.SuggestedFiltersRibbonView setBButtonsDistributed:YES];
    
    [self.SuggestedFiltersRibbonView setColorBackground:[UIColor colorWithWhite:1.0 alpha:0.98]];
    
    self.constraintTopSearchFeatureView.constant = kConstraintTopSearchFeatureViewHidden;
    
    //    [self.SuggestedFiltersRibbonView setMinWidthButton:kMinWidthButton];
    //    [self.SuggestedFiltersRibbonView setSpaceBetweenButtons:0];
    //    [self.SuggestedFiltersRibbonView setSNameButtonImage:@"FiltersRibbonButtonBackground.png"];
    //    [self.SuggestedFiltersRibbonView setSNameButtonImageHighlighted:@"FiltersRibbonButtonBackground.png"];
    //    [self.SuggestedFiltersRibbonView setBMultiselect:YES];
    //    [self.SuggestedFiltersRibbonView setColorBackgroundButtons:[UIColor clearColor]];
    //    [self.SuggestedFiltersRibbonView setColorShadowButtons:[UIColor clearColor]];
    
    //[self getSuggestedFilters];
}

// Get suggested filters
- (void)getSuggestedFilters
{
    //Hide the filter terms ribbon
    if(!([self.SuggestedFiltersRibbonView isHidden]))
        [self hideSuggestedFiltersRibbonAnimated:YES];
    
    [self.noFilterTermsLabel setText:NSLocalizedString(@"", nil)];
    [self.noFilterTermsLabel setHidden:NO];
    
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:[self getPatternForConnectionType:GET_SEARCH_SUGGESTEDFILTERKEYWORDS intendedForStringFormat:NO]];
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:[self getPatternForConnectionType:GET_PRODUCTCATEGORIES intendedForStringFormat:NO]];
    
    // Check that the string to search is valid
    if (!((_currentSearchQuery == nil) || ([_currentSearchQuery.idSearchQuery isEqualToString:@""])))
    {
        if (_searchContext != PRODUCT_SEARCH)
        {
            NSLog(@"Getting suggested filters for search terms: %@", _currentSearchQuery.searchQuery);
            
            // Perform request to get the suggested filters
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGFILTERTERMS_LBL_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_currentSearchQuery.idSearchQuery, nil];
            
            [self performRestGet:GET_SEARCH_SUGGESTEDFILTERKEYWORDS withParamaters:requestParameters];
            
            _bSuggestedKeywordsFromSearch = YES;
            filterManager.bSuggestedKeywordsFromSearch = YES;
            
        }
        else
        {
            if (bFiltersNew == NO)
            {
                [self adaptSuggestedFilterToSearch: YES];
            }
            else
            {
                [filterManager getFiltersForProductSearch];
                
                [self checkSearchTerms:YES];
            }
        }
    }
    else
    {
        NSLog(@"Getting basic suggested filters for an empty search");
        
        _bSuggestedKeywordsFromSearch = NO;
        filterManager.bSuggestedKeywordsFromSearch = NO;
        
        if (bFiltersNew)
        {
            [filterManager getFiltersWithoutSearch];
        }
        else
        {
            if (iGenderSelected < 1)
            {
                [self getSuggestedFiltersGenders];
            }
            else
            {
                Feature * feat = [self getGenderFeatureFromIndex:iGenderSelected];
                if (feat != nil)
                {
                    [self addSearchTermWithObject:feat animated:YES performSearch:NO checkSearchTerms:YES];
                    //        [self getSuggestedFiltersProductGroupForGender:iGenderSelected];
                    if (selectedProductCategory == nil)
                    {
                        [self getSuggestedFiltersProductGroupForGender:iGenderSelected];
                    }
                    else
                    {
                        [self getSuggestedFiltersForProductGroup:selectedProductCategory];
                    }
                }
                else
                {
                    iGenderSelected = 0;
                }
            }
            //        else if (selectedProductCategory != nil)
            //        {
            //
            //        }
            //        else{
            //
            //        }
            
            // Perform request to get the suggested filters
            [self setupSuggestedFiltersRibbonView];
        }
        
        // Provide feedback to user
        [self stopActivityFeedback];
        
        //        // Perform request to get the suggested filters
        //
        //        // Provide feedback to user
        //        [self stopActivityFeedback];
        //        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGFILTERTERMS_LBL_", nil)];
        //
        //        [self performRestGet:GET_PRODUCTCATEGORIES withParamaters:nil];
        //
        //        _bSuggestedKeywordsFromSearch = NO;
    }
}

-(void) getSuggestedFiltersGenders
{
    NSMutableArray * arFeatures = [self getFeaturesOfFeatureGroupByName:@"gender"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [arFeatures sortedArrayUsingDescriptors:sortDescriptors];
    
    [_suggestedFilters removeAllObjects];
    [_suggestedFiltersObject removeAllObjects];
    for(Feature *feat in sortedArray)
    {
        [_suggestedFiltersObject addObject:feat];
        [_suggestedFilters addObject:feat.idFeature];
    }
    
    NSString * subTitle = nil;
    
    //if(!(_searchContext == FASHIONISTAS_SEARCH || _searchContext == FASHIONISTAPOSTS_SEARCH))
    {
        subTitle = NSLocalizedString(@"_NO_SEARCH_KEYWORDS_MSG_", nil);
    }
    
    // Show specific title depending on the Search Context
    [self setTopBarTitle:[self stringForBarTitle] andSubtitle:subTitle];
}

-(void) getSuggestedFiltersProductGroupForGender:(int) iGender
{
    [_suggestedFilters removeAllObjects];
    [_suggestedFiltersObject removeAllObjects];
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"parent = null"];
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicateObject:predicate sortingWithKey:@"app_name" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProductGroup == nil))
            {
                if(!(tmpProductGroup.idProductGroup == nil))
                {
                    if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
                    {
                        if ([tmpProductGroup.visible boolValue])
                        {
                            if ([tmpProductGroup checkGender:iGender])
                            {
                                [_suggestedFiltersObject addObject:tmpProductGroup];
                                [_suggestedFilters addObject:tmpProductGroup.idProductGroup];
                            }
                            
                        }
                    }
                }
            }
        }
        
        // add the brands
        NSMutableArray * allBrands = [self getAllBrands];
        for(Brand * b in allBrands)
        {
            [_suggestedFiltersObject addObject:b];
            [_suggestedFilters addObject:b.idBrand];
        }
    }
}

-(void) getSuggestedFiltersForProductGroup:(ProductGroup *) productGroup
{
    if (productGroup != nil)
    {
        [_suggestedFilters removeAllObjects];
        [_suggestedFiltersObject removeAllObjects];
        
        
        NSMutableArray * arFeatureGroupsOfProductCategory = [productGroup getFeturesGroupExcept:@""];
        for (FeatureGroup * fg in arFeatureGroupsOfProductCategory)
        {
            if ([fg.name isEqualToString:@"Gender"])
            {
                NSLog(@"FeatureGroup gander");
            }
            for (Feature *feat in fg.features)
            {
                if (![_suggestedFilters containsObject:feat.idFeature])
                {
                    [_suggestedFilters addObject:feat.idFeature];
                    [_suggestedFiltersObject addObject:feat];
                }
            }
            
            NSMutableArray * arFGDescendatns = [fg getAllChildren];
            for (FeatureGroup *fgDescendant in arFGDescendatns)
            {
                for (Feature *feat in fgDescendant.features)
                {
                    if (![_suggestedFilters containsObject:feat.idFeature])
                    {
                        [_suggestedFilters addObject:feat.idFeature];
                        [_suggestedFiltersObject addObject:feat];
                    }
                }
            }
            
            
        }
        
        // get all the style
        if (![_suggestedFilters containsObject:productGroup.idProductGroup])
        {
            [_suggestedFilters addObject:productGroup.idProductGroup];
            [_suggestedFiltersObject addObject:productGroup];
        }
        NSMutableArray * children = [productGroup getAllDescendants];
        // check that there is at least one child visible
        for(ProductGroup * child in children)
        {
            if ([child.visible boolValue])
            {
                if ([child checkGender:iGenderSelected])
                {
                    if (![_suggestedFilters containsObject:child.idProductGroup])
                    {
                        [_suggestedFilters addObject:child.idProductGroup];
                        [_suggestedFiltersObject addObject:child];
                    }
                    
                    NSMutableArray * arFeatureGroupsOfDescendant = [child getFeturesGroupExcept:@""];
                    for(FeatureGroup * fg in arFeatureGroupsOfDescendant)
                    {
                        NSMutableArray * arFGDescendatns = [fg getAllChildren];
                        for (FeatureGroup *fgDescendant in arFGDescendatns)
                        {
                            for (Feature *feat in fgDescendant.features)
                            {
                                if (![_suggestedFilters containsObject:feat.idFeature])
                                {
                                    [_suggestedFilters addObject:feat.idFeature];
                                    [_suggestedFiltersObject addObject:feat];
                                }
                            }
                        }
                    }
                }
                
                //            NSString * sStyle = NSLocalizedString(@"_STYLE_",nil);
            }
        }
        
        
        NSMutableArray * allbrands = [self getAllBrands];
        for(Brand * brand in allbrands)
        {
            if (![_suggestedFilters containsObject:brand.idBrand])
            {
                [_suggestedFilters addObject:brand.idBrand];
                [_suggestedFiltersObject addObject:brand];
            }
        }
        /*
         if ([productGroup.brands count] > 0)
         {
         for (Brand * b in productGroup.brands)
         {
         if (![_suggestedFilters containsObject:b.idBrand])
         {
         [_suggestedFilters addObject:b.idBrand];
         [_suggestedFiltersObject addObject:b];
         }
         }
         }
         */
        
        FeatureGroup *fgPrice = [self getFeatureGroupFromName:@"Price"];
        for (Feature *feat in fgPrice.features)
        {
            [_suggestedFilters addObject:feat.idFeature];
            [_suggestedFiltersObject addObject:feat];
            [arrayFeaturesPrices addObject:feat.idFeature];
        }
    }
    
}

- (void) initFoundSuggestionPC
{
}


- (void) setupSuggestedFiltersRibbonView
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray * completeSuggestedFiltersList = [[NSMutableArray alloc] init];
    
    BOOL isSelectStyleTab = NO;
    BOOL forceSelectNextStep = NO;
    
    if (_searchContext != BRANDS_SEARCH)
    {
        if (_searchContext == PRODUCT_SEARCH)
        {
            NSArray * objs = [appDelegate.config valueForKey:@"order_filter_products"];
            [self setupSuggestedFiltersRibbonView:completeSuggestedFiltersList withOrder:objs andForceSelectNextStep:&forceSelectNextStep andIsSelectStyleTab:&isSelectStyleTab];
        }
        else if (_searchContext == FASHIONISTAS_SEARCH)
        {
            NSArray * objs = [appDelegate.config valueForKey:@"order_filter_fashionistas"];
            [self setupSuggestedFiltersRibbonView:completeSuggestedFiltersList withOrder:objs andForceSelectNextStep:&forceSelectNextStep andIsSelectStyleTab:&isSelectStyleTab];
        }
        else if (_searchContext == FASHIONISTAPOSTS_SEARCH)
        {
            NSArray * objs = [appDelegate.config valueForKey:@"order_filter_post"];
            [self setupSuggestedFiltersRibbonView:completeSuggestedFiltersList withOrder:objs andForceSelectNextStep:&forceSelectNextStep andIsSelectStyleTab:&isSelectStyleTab];
        }
        else if (_searchContext == HISTORY_SEARCH)
        {
            NSArray * objs = [appDelegate.config valueForKey:@"order_filter_history"];
            [self setupSuggestedFiltersRibbonView:completeSuggestedFiltersList withOrder:objs andForceSelectNextStep:&forceSelectNextStep andIsSelectStyleTab:&isSelectStyleTab];
        }
        else
        {
            NSArray * objs = [appDelegate.config valueForKey:@"order_filter_default"];
            [self setupSuggestedFiltersRibbonView:completeSuggestedFiltersList withOrder:objs andForceSelectNextStep:&forceSelectNextStep andIsSelectStyleTab:&isSelectStyleTab];
        }
    }
    else
    {
        [self getLettersTo:completeSuggestedFiltersList];
    }
    
    [self.SuggestedFiltersRibbonView initSlideButtonWithButtons:[[[NSOrderedSet orderedSetWithArray:completeSuggestedFiltersList] array] mutableCopy] andDelegate:self];
    
    [self.SuggestedFiltersRibbonView scrollToTheBeginning];
    //    [self.SuggestedFiltersRibbonView scrollToButtonByIndex:0];
    
    if ([[self.SuggestedFiltersRibbonView arrayButtons] count] > 0)
    {
        [self.noFilterTermsLabel setHidden:YES];
        
        //Show the filter terms ribbon
        [self showSuggestedFiltersRibbonAnimated:YES];
    }
    else
    {
        //Hide the filter terms ribbon
        [self hideSuggestedFiltersRibbonAnimated:NO];
        
        if(!(_currentSearchQuery == nil))
        {
            [self.noFilterTermsLabel setText:NSLocalizedString(@"_NOFILTERTERMS_LBL_", nil)];
            [self.noFilterTermsLabel setHidden:NO];
        }
    }
    
    if (forceSelectNextStep && !_bSuggestedKeywordsFromSearch && !bRestartingSearch)
    {
        //        if (/*isSelectStyleTab &&*/ !_bSuggestedKeywordsFromSearch && !bRestartingSearch)
        {
            // Check si solo hay style y brand en los filters
            BOOL bOnlyStyleAndBrands = YES;
            for(NSObject * objSuggested in self.SuggestedFiltersRibbonView.arrayButtons )
            {
                if ([objSuggested isKindOfClass:[FeatureGroup class]])
                {
                    bOnlyStyleAndBrands = NO;
                    break;
                }
                
                if ([objSuggested isKindOfClass:[NSString class]])
                {
                    NSString * sName = (NSString *)objSuggested;
                    if (![sName isEqualToString:NSLocalizedString(@"_BRANDS_",nil)] &&
                        ![sName isEqualToString:NSLocalizedString(@"_STYLE_",nil)] &&
                        ![sName isEqualToString:NSLocalizedString(@"_PRODUCT_TYPE_",nil)])
                    {
                        bOnlyStyleAndBrands = NO;
                        break;
                    }
                }
                else
                {
                    bOnlyStyleAndBrands = NO;
                    break;
                }
            }
            
            
            if (bOnlyStyleAndBrands)
            {
                // si solo está style y brand, mostramos siempre el style (que será el primero) si brand no estaba seleccionada
                if ([sLastSelectedSlide isEqualToString:@"Brand"] == NO)
                {
                    if (self.SuggestedFiltersRibbonView.arrayButtons.count > 0)
                    {
                        [self.SuggestedFiltersRibbonView forceSelectButton:0];
                        [self slideButtonView:self.SuggestedFiltersRibbonView btnClick:0];
                    }
                }
            }
            else
            {
                // hay feature groups mostrandose o falta style o brand
                
                // obtenemos el indice de la pestaña seleccionada que se guarda su nombre en sLastSelectedSlide
                int iIdx = [self.SuggestedFiltersRibbonView iGetIndexButtonByName: sLastSelectedSlide];
                
                unsigned long iCount = [self.SuggestedFiltersRibbonView.arrayButtons count];
                if ((iIdx < 0) || (iIdx >= iCount))
                {
                    // el indice está fuera de los limites de los elementos de la suggested bar, miramos si podemos asignarle el iLastSelectedSlide
                    if (iLastSelectedSlide >= iCount)
                    {
                        if (iCount > 0)
                            iIdx = (int)iCount -1;
                        else
                            iIdx = 0;
                    }
                    else if (iLastSelectedSlide < 0)
                    {
                        iIdx = 0;
                    }
                    else
                    {
                        iIdx = iLastSelectedSlide;
                    }
                }
                //
                //                // comprobamos de nuevo que el indice esté en los limite, por si el iLastSelectedSlide
                //                if (iIdx < 0)
                //                {
                //                    iIdx = 0;
                //                }
                //                else if (iIdx > iCount)
                //                {
                //                    if (iCount > 0)
                //                        iIdx = (int)iCount -1;
                //                    else
                //                        iIdx = 0;
                //                }
                if (self.SuggestedFiltersRibbonView.arrayButtons.count > 0)
                {
                    [self.SuggestedFiltersRibbonView forceSelectButton:iIdx];
                    [self slideButtonView:self.SuggestedFiltersRibbonView btnClick:iIdx];
                }
                else
                {
                    [self hideFiltersView:NO];
                }
            }
            
        }
        //        else
        //        {
        //            if (self.SuggestedFiltersRibbonView.arrayButtons.count > 0)
        //            {
        //                [self.SuggestedFiltersRibbonView forceSelectButton:0];
        //                [self slideButtonView:self.SuggestedFiltersRibbonView btnClick:0];
        //            }
        //            else
        //            {
        //                [self hideFiltersView:NO];
        //            }
        //        }
    }
    else if (forceSelectNextStep && _bSuggestedKeywordsFromSearch && !bRestartingSearch)
    {
        // obtenemos el indice de la pestaña seleccionada que se guarda su nombre en sLastSelectedSlide
        int iIdx = [self.SuggestedFiltersRibbonView iGetIndexButtonByName: sLastSelectedSlide];
        
        unsigned long iCount = [self.SuggestedFiltersRibbonView.arrayButtons count];
        if ((iIdx < 0) || (iIdx >= iCount))
        {
            // el indice está fuera de los limites de los elementos de la suggested bar, miramos si podemos asignarle el iLastSelectedSlide
            if (iLastSelectedSlide >= iCount)
            {
                if (iCount > 0)
                    iIdx = (int)iCount -1;
                else
                    iIdx = 0;
            }
            else if (iLastSelectedSlide < 0)
            {
                iIdx = 0;
            }
            else
            {
                iIdx = iLastSelectedSlide;
            }
        }
        if (self.SuggestedFiltersRibbonView.arrayButtons.count > 0)
        {
            [self.SuggestedFiltersRibbonView scrollToButtonByIndex:iIdx];
        }
    }
    
}

-(void) setupSuggestedFiltersRibbonView:(NSMutableArray *) completeSuggestedFiltersList withOrder:(NSArray *) arOrder andForceSelectNextStep:(BOOL *) bNextStep andIsSelectStyleTab: (BOOL *) bStyleTab
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self initStructuresForSuggestedKeywords];
    
    if ([self allSuggestedProductGroup])
    {
        // convertimos los string a objetos product group si es posible, si no dejamos el valor original
        NSMutableArray * arObjectsRibbon = [[NSMutableArray alloc] init];
        for (NSString * sFilter in self.suggestedFilters)
        {
            
            //                ProductGroup * pg = [self getProductGroupFromName:sFilter];
            ProductGroup * pg = [self getProductGroupParentFromId:sFilter];
            if (pg != nil)
            {
                if ([pg.visible boolValue])
                    [arObjectsRibbon addObject:pg];
            }
        }
        
        [completeSuggestedFiltersList addObjectsFromArray:arObjectsRibbon];
    }
    else
    {
        [self initFoundSuggestionPC];
        
        NSDate *methodstart = [NSDate date];
        //                NSLog(@"################### After initFoundSuggestions 1: %f", [[NSDate date] timeIntervalSinceDate:methodstart]);
        methodstart = [NSDate date];
        
        
        self.suggestedFiltersFound = [[NSMutableArray alloc]initWithArray:self.suggestedFilters];
        NSMutableArray * filteredSuggestedFilters = self.suggestedFilters;
        
        if([_foundSuggestions count] > 0)
        {
            [self.suggestedFiltersFound removeAllObjects];
            
            for(NSString * objid in self.suggestedFilters)
            {
                if([_foundSuggestions objectForKey:objid])
                {
                    [self.suggestedFiltersFound addObject:objid];
                }
                else
                {
                    // Caso PC, los añadiremos también al ser una búsqueda OR de PC
                    if([self getProductGroupFromId:objid])
                    {
                        if((_foundSuggestions.count == 0) || ([_foundSuggestions objectForKey:objid]))
                        {
                            [self.suggestedFiltersFound addObject:objid];
                        }
                    }
                    if([self getBrandFromId:objid])
                    {
                        if((_foundSuggestions.count == 0) || ([_foundSuggestions objectForKey:objid]))
                        {
                            [self.suggestedFiltersFound addObject:objid];
                        }
                    }
                }
            }
            
            filteredSuggestedFilters = self.suggestedFiltersFound;
        }
        
        //                NSLog(@"################### After initFoundSuggestions 2: %f", [[NSDate date] timeIntervalSinceDate:methodstart]);
        methodstart = [NSDate date];
        
        FeatureGroup * featureGroup = [self allSuggestedFromSameFeatureGroup];
        //                NSLog(@"################### After initFoundSuggestions 3: %f", [[NSDate date] timeIntervalSinceDate:methodstart]);
        methodstart = [NSDate date];
        if (featureGroup != nil)
        {
            NSMutableArray * arObjectsRibbon = [[NSMutableArray alloc] init];
            for (NSString * sFilter in filteredSuggestedFilters)
            {
                //                ProductGroup * pg = [self getProductGroupFromName:sFilter];
                Feature * feat = [self getFeatureFromId:sFilter];
                if (feat != nil)
                {
                    [arObjectsRibbon addObject:feat];
                }
            }
            [completeSuggestedFiltersList addObjectsFromArray:arObjectsRibbon];
        }
        else
        {
            *bNextStep = YES;
            NSDate *methodstart = [NSDate date];
            
            int iIdx = 0;
            for(NSString * sObj in arOrder)
            {
                unsigned long  iNumTabs = completeSuggestedFiltersList.count;
                if ([sObj isEqualToString:@"gender"])
                {
                    if (iGenderSelected <= 0)
                    {
                        [self addFeatureGroupWithName:@"gender" from:filteredSuggestedFilters to:completeSuggestedFiltersList];
                    }
                }
                else if ([sObj isEqualToString:@"style"])
                {
                    [self addProductGroupFrom:filteredSuggestedFilters to: completeSuggestedFiltersList];
                    if (completeSuggestedFiltersList.count == (iNumTabs + 1))
                    {
                        // the style tab is added
                        *bStyleTab = YES;
                    }
                }
                else if ([sObj isEqualToString:@"brands"])
                {
                    [self addBrandsFrom:filteredSuggestedFilters to: completeSuggestedFiltersList];
                }
                else if ([sObj isEqualToString:@"color"])
                {
                    [self addFeatureGroupWithName:@"color" from:filteredSuggestedFilters to:completeSuggestedFiltersList];
                }
                else if ([sObj isEqualToString:@"prices"])
                {
                    [self addPricesGroupFrom:filteredSuggestedFilters to: completeSuggestedFiltersList];
                }
                else if ([sObj isEqualToString:@"features"])
                {
                    NSMutableArray * arFeatureGroupsOfProductCategory = [self getFeaturesOfProductGroupSelectedExcept:@"gender"];
                    
                    [self addFeatureGroupFrom:filteredSuggestedFilters to: completeSuggestedFiltersList orderBy:arFeatureGroupsOfProductCategory];
                }
                else if ([sObj isEqualToString:@"history"])
                {
                    for (int i = 0; i < maxHistoryPeriods; i++)
                    {
                        if (!(i == _searchPeriod))
                        {
                            [completeSuggestedFiltersList addObject:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)];
                        }
                    }
                }
                /*
                 else if ([sObj isEqualToString:@"stylestylist"])
                 {
                 if (_foundSuggestionsStyleStylist.count > 0)
                 {
                 NSString * sStyleStylist = NSLocalizedString(@"_STYLE_STYLIST_",nil);
                 if (![completeSuggestedFiltersList containsObject:sStyleStylist])
                 {
                 [completeSuggestedFiltersList addObject:sStyleStylist];
                 break;
                 }
                 }
                 }
                 else if ([sObj isEqualToString:@"location"])
                 {
                 if (_foundSuggestionsLocations.count > 0)
                 {
                 NSString * sLocation = NSLocalizedString(@"_LOCATION_",nil);
                 if (![completeSuggestedFiltersList containsObject:sLocation])
                 {
                 [completeSuggestedFiltersList addObject:sLocation];
                 break;
                 }
                 }
                 }
                 */
                else if ([sObj isEqualToString:@"follower"])
                {
                    if (!(appDelegate.currentUser == nil))
                    {
                        for (int i = 0; i < maxFollowingRelationships; i++)
                        {
                            if (!(i == _searchStylistRelationships))
                            {
                                [completeSuggestedFiltersList addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)];
                            }
                        }
                    }
                }
                else if ([sObj isEqualToString:@"posttype"])
                {
                    //for (int i = 0; i < maxFashionistaPostTypes; i++)
                    {
                        //if (!(i == _searchPostType))
                        {
                            //[completeSuggestedFiltersList addObject:NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",i]), nil)];
                        }
                    }
                }
                else
                {
                    NSString * sKey = [NSString stringWithFormat:@"%i", iIdx ];
                    NSMutableArray *arrObjects = [_foundSuggestionsDirectly objectForKey:sKey];
                    if (arrObjects != nil)
                    {
                        if (arrObjects.count > 0)
                        {
                            NSString * sName = NSLocalizedString(sObj,nil);
                            if (![completeSuggestedFiltersList containsObject:sName])
                            {
                                [completeSuggestedFiltersList addObject:sName];
                                break;
                            }
                        }
                    }
                }
                iIdx++;
            }
            
            
            NSLog(@"################### Process SuggestedKeywords: %f", [[NSDate date] timeIntervalSinceDate:methodstart]);
        }
    }
}

-(NSMutableArray *) getFeaturesOfProductGroupSelectedExcept:(NSString *)sFeatureGroupToIgnore
{
    NSMutableArray * arFeatureGrups = [[NSMutableArray alloc] init];
    NSMutableArray * arFeatureGroupOrder;
    
    if (selectedProductCategory != nil)
    {
        
        arFeatureGroupOrder = [NSMutableArray arrayWithArray:[selectedProductCategory.featuresGroupOrder allObjects]];// sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
        NSMutableArray * arPGParents = [selectedProductCategory getAllParents];
        for (ProductGroup * pgParent in arPGParents)
        {
            
            NSMutableArray * arFeatureGroupOrderTmp = [NSMutableArray arrayWithArray:[pgParent.featuresGroupOrder allObjects]] ;//] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
            
            for (FeatureGroupOrderProductGroup * fgOrder in arFeatureGroupOrderTmp)
            {
                if ([arFeatureGroupOrder containsObject:fgOrder] == NO)
                {
                    [arFeatureGroupOrder addObject:fgOrder];
                }
            }
        }
        
        // si no hay subproduct ctagoery seleccionado seleccionamos los descendiente de la selected product category
        if (arSelectedSubProductCategory.count == 0)
        {
            NSMutableArray * arPGDescendatns = [selectedProductCategory getAllDescendants];
            for (ProductGroup * pgDescendant in arPGDescendatns)
            {
                
                NSMutableArray * arFeatureGroupOrderTmp = [NSMutableArray arrayWithArray:[pgDescendant.featuresGroupOrder allObjects]] ;//] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
                
                for (FeatureGroupOrderProductGroup * fgOrder in arFeatureGroupOrderTmp)
                {
                    if ([arFeatureGroupOrder containsObject:fgOrder] == NO)
                    {
                        [arFeatureGroupOrder addObject:fgOrder];
                    }
                }
            }
        }
        
        
        //looping through all the sub product categories selected
        for(ProductGroup * pgSelected in arSelectedSubProductCategory)
        {
            NSMutableArray * arPGParents = [pgSelected getAllParents];
            for (ProductGroup * pgParent in arPGParents)
            {
                
                NSMutableArray * arFeatureGroupOrderTmp = [NSMutableArray arrayWithArray:[pgParent.featuresGroupOrder allObjects]] ;//] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
                
                for (FeatureGroupOrderProductGroup * fgOrder in arFeatureGroupOrderTmp)
                {
                    if ([arFeatureGroupOrder containsObject:fgOrder] == NO)
                    {
                        [arFeatureGroupOrder addObject:fgOrder];
                    }
                }
            }
            NSMutableArray * arPGDescendatns = [pgSelected getAllDescendants];
            for (ProductGroup * pgDescendant in arPGDescendatns)
            {
                
                NSMutableArray * arFeatureGroupOrderTmp = [NSMutableArray arrayWithArray:[pgDescendant.featuresGroupOrder allObjects]] ;//] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
                
                for (FeatureGroupOrderProductGroup * fgOrder in arFeatureGroupOrderTmp)
                {
                    if ([arFeatureGroupOrder containsObject:fgOrder] == NO)
                    {
                        [arFeatureGroupOrder addObject:fgOrder];
                    }
                }
            }
        }
        
    }
    
    // sort the mutable array
    NSSortDescriptor *sortDescriptorOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"featureGroup.name" ascending:YES];
    
    arFeatureGroupOrder = [NSMutableArray arrayWithArray:[arFeatureGroupOrder sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
    NSString * sFeatureGroupToIgnoreTrimmed = [sFeatureGroupToIgnore stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // looping all product categories filtering the product ctagoeries withour featuregroup
    for(FeatureGroupOrderProductGroup * fgOrder in arFeatureGroupOrder)
    {
        if (fgOrder.order > 0)
        {
            FeatureGroup * fg = [fgOrder.featureGroup getTopParent];
            // check the num features for each featuregroup
            int iNumFeatures = [fg getNumTotalFeatures];
            if (iNumFeatures > 0)
            {
                // check the name of the featuregroup, if is equal to the parameter
                NSString *sFeatureGroupNameTrimmed = [fg.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (![sFeatureGroupToIgnoreTrimmed.lowercaseString isEqualToString:sFeatureGroupNameTrimmed.lowercaseString])
                {
                    if (![arFeatureGrups containsObject:fg])
                    {
                        [arFeatureGrups addObject:fg];
                    }
                }
            }
        }
    }
    
    
    return arFeatureGrups;
}

-(void) adaptSuggestedFilterToSearch:(BOOL) checkSearch
{
    ProductGroup * pgSuccess;
    ProductGroup * pgSuccessParent;
    selectedProductCategory = nil;
    iNumSubProductCategories = 0;
    [arSelectedSubProductCategory removeAllObjects];
    //    [arExpandedSubProductCategory removeAllObjects];
    [self initStructuresForSuggestedKeywords];
    
    iGenderSelected = 0;
    
    for (NSObject *obj in self.searchTermsListView.arrayButtons)
    {
        if ([obj isKindOfClass:[NSString class]])
        {
            NSString * sSuccesfulTerm = (NSString *)obj;
            // la funcion getKeywordElementForName, si el elemento es un product category este se añade al array de product catgeories donde se comprueba que existan los feature groups
            NSObject * object = [self getKeywordElementForName: sSuccesfulTerm];
            if ([object isKindOfClass:[FeatureGroup class]])
            {
                object = [self getFeatureFromName:sSuccesfulTerm];
            }
            
            if ([object isKindOfClass:[ProductGroup class]])
            {
                pgSuccess = (ProductGroup *)object;
                if ([_successfulTermProductCategory containsObject:pgSuccess] == NO)
                {
                    [_successfulTermProductCategory addObject:pgSuccess];
                }
                if (pgSuccess.parent != nil)
                {
                    if ([arSelectedSubProductCategory containsObject:pgSuccess] == NO)
                    {
                        iNumSubProductCategories++;
                        [arSelectedSubProductCategory addObject:pgSuccess];
                    }
                }
                
                pgSuccessParent = [pgSuccess getTopParent];
            }
            else if ([object isKindOfClass:[Feature class]])
            {
                Feature * feat = (Feature *)object;
                NSString * sNameFeatureGroup = [[feat.featureGroup.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([sNameFeatureGroup isEqualToString:@"gender"])
                {
                    int iGender = [self getGenderFromName:feat.name];
                    iGenderSelected += iGender;
                }
            }
        }
        else if ([obj isKindOfClass:[ProductGroup class]])
        {
            pgSuccess = (ProductGroup *)obj;
            if ([_successfulTermProductCategory containsObject:pgSuccess] == NO)
            {
                [_successfulTermProductCategory addObject:pgSuccess];
            }
            if (pgSuccess.parent != nil)
            {
                if ([arSelectedSubProductCategory containsObject:pgSuccess] == NO)
                {
                    iNumSubProductCategories++;
                    [arSelectedSubProductCategory addObject:pgSuccess];
                }
            }
            
            pgSuccessParent = [pgSuccess getTopParent];
        }
        else if ([obj isKindOfClass:[Feature class]])
        {
            Feature * feat = (Feature *)obj;
            NSString * sNameFeatureGroup = [[feat.featureGroup.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([sNameFeatureGroup isEqualToString:@"gender"])
            {
                int iGender = [self getGenderFromName:feat.name];
                iGenderSelected += iGender;
            }
        }
        else if ([obj isKindOfClass:[Brand class]])
        {
            
        }
    }
    
    // get all the id of the descendatns of the successful terms
    if (_successfulTermIdProductCategory != nil)
    {
        [_successfulTermIdProductCategory removeAllObjects];
        _successfulTermIdProductCategory = nil;
    }
    
    _successfulTermIdProductCategory = [[NSMutableArray alloc] init];
    for(ProductGroup *succesPG in _successfulTermProductCategory)
    {
        //                if ([_successfulTermIdProductCategory containsObject:succesPG.idProductGroup] == NO)
        //                    [_successfulTermIdProductCategory addObject:succesPG.idProductGroup];
        NSMutableArray * temp = [succesPG getAllDescendants];
        for(ProductGroup * descendant in temp)
        {
            if ([_successfulTermIdProductCategory containsObject:descendant.idProductGroup] == NO)
                [_successfulTermIdProductCategory addObject:descendant.idProductGroup];
        }
    }
    
    
    if (pgSuccessParent != nil)
    {
        selectedProductCategory = pgSuccessParent;
    }
    
    //if there are more than 1 product category then the selectedproduct ctagoery does not appear in the search terms view
    //    if ([_successfulTermProductCategory count] > 1)
    //    {
    //        [self.searchTermsListView removeButtonByObject:selectedProductCategory];
    //    }
    
    if ((iGenderSelected == 0) && (selectedProductCategory == nil))
    {
        [self getSuggestedFiltersGenders];
        [self hideFiltersView:YES];
    }
    else if ((iGenderSelected == 0) && (selectedProductCategory != nil))
    {
        [self getSuggestedFiltersGenders];
        [self hideFiltersView:YES];
    }
    else if ((iGenderSelected > 0) && (selectedProductCategory == nil))
    {
        [self getSuggestedFiltersProductGroupForGender:iGenderSelected];
        [self hideFiltersView:YES];
    }
    else if ((iGenderSelected > 0) && (selectedProductCategory != nil))
    {
        [self getSuggestedFiltersForProductGroup:selectedProductCategory];
        [self hideFiltersView:YES];
    }
    
    if ([self.successfulTerms count] <= 0)
    {
        [self getSuggestedFiltersGenders];
        [self hideFiltersView:YES];
    }
    
    [self setupSuggestedFiltersRibbonView];
    
    [self initOperationsLoadingImages];
    [self.imagesQueue cancelAllOperations];
    [self.secondCollectionView reloadData];
    
    if (checkSearch)
        [self checkSearchTerms:YES];
    
}


-(void) getLettersTo:(NSMutableArray *) arrLetter
{
    if (arrLetter != nil)
        [arrLetter removeAllObjects];
    else
        arrLetter = [[NSMutableArray alloc] init];
    
    [arrLetter addObject:@"#"];
    for(int i = 65; i <= 90; i++)
    {
        NSString *stringChar = [NSString stringWithFormat:@"%c", i];
        [arrLetter addObject:stringChar];
    }
    
}

-(BOOL) isGenderInProductCategorySuccess:(NSString *)sGender
{
    int iGender = [self getGenderFromName:sGender];
    for(ProductGroup * pgSuccess in _successfulTermProductCategory)
    {
        if ([pgSuccess checkGender:iGender])
        {
            return YES;
        }
    }
    
    if ([selectedProductCategory checkGender:iGender])
    {
        return YES;
    }
    
    return NO;
}

-(int)getGenderFromName:(NSString *)sGender
{
    int iGender = 0;
    
    NSString * sGenderTrimmer = [[sGender lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([sGenderTrimmer isEqualToString:@"men"])
    {
        iGender = pow(2,0); // 1
    }
    else if ([sGenderTrimmer isEqualToString:@"women"])
    {
        iGender = pow(2,1); // 2
    }
    else if ([sGenderTrimmer isEqualToString:@"boy"])
    {
        iGender = pow(2,2); // 4
    }
    else if ([sGenderTrimmer isEqualToString:@"girl"])
    {
        iGender = pow(2,3); // 8
    }
    else if ([sGenderTrimmer isEqualToString:@"unisex"])
    {
        iGender = pow(2,4); // 16
    }
    else if ([sGenderTrimmer isEqualToString:@"kids"])
    {
        iGender = pow(2,5); // 32
    }
    
    return iGender;
    
}

-(Feature *)getGenderFeatureFromIndex:(int) iIdxGender
{
    NSString * sTextGender = @"";
    if (iIdxGender == pow(2,0))
    {
        sTextGender = @"Men";
    }
    else if (iIdxGender == pow(2,1))
    {
        sTextGender = @"Women";
    }
    else if (iIdxGender == pow(2,2))
    {
        sTextGender = @"Boy";
    }
    else if (iIdxGender == pow(2,3))
    {
        sTextGender = @"Girl";
    }
    else if (iIdxGender == pow(2,4))
    {
        sTextGender = @"Unisex";
    }
    else if (iIdxGender == pow(2,5))
    {
        sTextGender = @"Kids";
    }
    
    return [self getFeatureFromName:sTextGender];
}

-(void) getGenderSelected
{
    iGenderSelected = 0;
    for (NSObject *obj in self.searchTermsListView.arrayButtons)
    {
        if ([obj isKindOfClass:[Feature class]])
        {
            Feature * feat = (Feature *)obj;
            NSString * sNameFeatureGroup = [[feat.featureGroup.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([sNameFeatureGroup isEqualToString:@"gender"])
            {
                int iGender = [self getGenderFromName:feat.name];
                iGenderSelected += iGender;
            }
        }
    }
}

-(void) updateSuccessulTermsForGender
{
    int iFixedButtons = 0;
    
    if(_searchContext == HISTORY_SEARCH)
        iFixedButtons = 1;
    else if(_searchContext == FASHIONISTAS_SEARCH)
        iFixedButtons = 1;
    else if(_searchContext == FASHIONISTAPOSTS_SEARCH)
        iFixedButtons = 1;
    
    NSMutableIndexSet *mutableIndexSetSuccessfulTerms = [[NSMutableIndexSet alloc] init];
    
    NSMutableArray *copy = [[NSMutableArray alloc] initWithArray:self.searchTermsListView.arrayButtons copyItems:NO];
    
    int iIdx = 0;
    for (NSObject *obj in copy)
    {
        if ([obj isKindOfClass:[ProductGroup class]])
        {
            ProductGroup * pg = (ProductGroup *)obj;
            if (selectedProductCategory == nil)
            {
                // the selectedproduct ctagoery parent is null, so we muste remove all the product catgoeries from the successul terms
                [self.searchTermsListView removeButtonByObject:obj];
                [mutableIndexSetSuccessfulTerms addIndex:iIdx-iFixedButtons];
            }
            else if (selectedProductCategory != nil)
            {
                if (_searchContext == PRODUCT_SEARCH)
                {
                    if ([pg.idProductGroup isEqualToString:selectedProductCategory.idProductGroup] == NO)
                    {
                        if ([pg checkGender:iGenderSelected] == NO)
                        {
                            [self.searchTermsListView removeButtonByObject:obj];
                            [mutableIndexSetSuccessfulTerms addIndex:iIdx-iFixedButtons];
                        }
                    }
                }
                else
                {
                    for (ProductGroup * pgParent in arSelectedProductCategories)
                    {
                        if ([pg.idProductGroup isEqualToString:pgParent.idProductGroup] == NO)
                        {
                            if ([pg checkGender:iGenderSelected] == NO)
                            {
                                [self.searchTermsListView removeButtonByObject:obj];
                                [mutableIndexSetSuccessfulTerms addIndex:iIdx-iFixedButtons];
                            }
                        }
                    }
                }
            }
        }
        
        iIdx ++;
    }
    
    [self.successfulTerms removeObjectsAtIndexes:mutableIndexSetSuccessfulTerms];
    
    [self checkSearchTerms:NO];
}

// SlideButtonViewDelegate function
- (void)slideButtonView:(SlideButtonView *)slideButtonView btnClick:(int)buttonEntry
{
    _inspireView.hidden = YES;
    if (bFiltersNew)
    {
        [filterManager hideAlphabet];
    }
    else
    {
        [self hideAlphabet];
    }
    
    _bSuggestedKeywordsFromSearch = NO;
    filterManager.bSuggestedKeywordsFromSearch = NO;
    
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if(![[self activityIndicator] isHidden])
        return;
    
    if (slideButtonView == self.searchTermsListView)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (!(self.successfulTerms == nil))
        {
            int iFixedButtons = 0;
            
            if(_searchContext == HISTORY_SEARCH)
                iFixedButtons = 1;
            else if(_searchContext == FASHIONISTAS_SEARCH)
                iFixedButtons = 1;
            else if(_searchContext == FASHIONISTAPOSTS_SEARCH)
                iFixedButtons = 1;
            
            //[self hideFiltersView:NO];
            
            if (_searchContext == BRANDS_SEARCH)
            {
                [self.searchTermsListView removeButton:buttonEntry];
                // Update search
                [self updateSearchForTermsChanges];
                
                [self hideAddSearchTerm];
            }
            else if (!(buttonEntry >= ([self.successfulTerms count]+iFixedButtons)))
            {
                NSString * sButtonToDelete = [self.searchTermsListView sGetNameButtonByIdx:buttonEntry];
                NSObject * objButtonToDelete = [self.searchTermsListView getObjectByIndex:buttonEntry];
                if (objButtonToDelete == nil)
                {
                    objButtonToDelete = [ self getKeywordElementForName:sButtonToDelete];
                    if ([objButtonToDelete isKindOfClass:[FeatureGroup class]])
                    {
                        objButtonToDelete = [self getFeatureFromName:sButtonToDelete];
                    }
                }
                
                if(_searchContext == HISTORY_SEARCH)
                {
                    for (int i = 0; i < maxHistoryPeriods; i++)
                    {
                        if (([sButtonToDelete isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)]) || ([sButtonToDelete isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)]]))
                        {
                            return;
                        }
                    }
                }
                else if(_searchContext == FASHIONISTAPOSTS_SEARCH)
                {
                    //                    if (([sButtonToDelete isEqualToString:NSLocalizedString(@"_FASHIONISTA_POSTS_", nil)]) || ([sButtonToDelete isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTA_POSTS_", nil)]]))
                    //                    {
                    //                        return;
                    //                    }
                    
                    //for (int i = 0; i < maxFashionistaPostTypes; i++)
                    {
                        //if (([sButtonToDelete isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",i]), nil)]) || ([sButtonToDelete isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",i]), nil)]]))
                        {
                            //return;
                        }
                    }
                    
                    if(!(appDelegate.currentUser == nil))
                    {
                        for (int i = 0; i < maxFollowingRelationships; i++)
                        {
                            if (([sButtonToDelete isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)]) || ([sButtonToDelete isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)]]))
                            {
                                return;
                            }
                        }
                    }
                }
                else if (_searchContext == FASHIONISTAS_SEARCH)
                {
                    //                    if (([sButtonToDelete isEqualToString:NSLocalizedString(@"_FASHIONISTAS_", nil)]) || ([sButtonToDelete isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTAS", nil)]]))
                    //                    {
                    //                        return;
                    //                    }
                    
                    if(!(appDelegate.currentUser == nil))
                    {
                        for (int i = 0; i < maxFollowingRelationships; i++)
                        {
                            if (([sButtonToDelete isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)]) || ([sButtonToDelete isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)]]))
                            {
                                return;
                            }
                        }
                    }
                }
                
                if (_filterSearchVC != nil)
                {
                    [self hideAddSearchTerm];
                    if (objButtonToDelete != nil)
                        [_filterSearchVC removeSearchTermObject:objButtonToDelete];
                    else
                        [_filterSearchVC removeSearchTerm:sButtonToDelete];
                }
                else
                {
                    if(_filterSearchVC == nil)
                    {
                        if (_searchTermsBeforeUpdate == nil)
                        {
                            _searchTermsBeforeUpdate = [[NSMutableArray alloc] initWithArray:_successfulTerms];
                        }
                        else
                        {
                            [_searchTermsBeforeUpdate removeAllObjects];
                            
                            [_searchTermsBeforeUpdate addObjectsFromArray:_successfulTerms];
                        }
                    }
                    BOOL bCheckSearch = (_searchContext == PRODUCT_SEARCH);
                    
                    [self removeSearchTermAtIndex:(buttonEntry-iFixedButtons) checkSuggestions:bCheckSearch];
                    
                    if (self.searchTermsListView.count > 0)
                        [self hideAddSearchTerm];
                    
                    [self.secondCollectionView reloadData];
                    
                    if (bFiltersNew)
                    {
                        [filterManager removeFromFilterObject:objButtonToDelete andCheckSearch:bCheckSearch];
                        //                        return;
                    }
                    else
                    {
                        BOOL bElementRemovedIsProductGroup = NO;
                        if (bCheckSearch)
                        {
                            bElementRemovedIsProductGroup = [objButtonToDelete isKindOfClass:[ProductGroup class]];
                            
                            //                    // Remove entry in array of terms
                            //                    [self.successfulTerms removeObjectAtIndex:(buttonEntry-iFixedButtons)];
                            //
                            //                    // Remove button
                            //                    [self.searchTermsListView removeButton:buttonEntry];
                            
                            
                            if ([objButtonToDelete isKindOfClass:[Feature class]])
                            {
                                // check that there is not any gender selected
                                [self getGenderSelected];
                                
                                if (self.SuggestedFiltersRibbonView.arSelectedButtons.count > 0)
                                {
                                    int iIdxSelected = [self.SuggestedFiltersRibbonView.arSelectedButtons[0] intValue];
                                    NSObject *obj = self.SuggestedFiltersRibbonView.arrayButtons[iIdxSelected];
                                    [self getSuggestedFiltersForProductGroup:selectedProductCategory];
                                    [self showSuggestedFiltersLocallyForObject: obj andButtonEntry:iIdxSelected];
                                }
                                [self updateSuccessulTermsForGender];
                            }
                            if ([objButtonToDelete isKindOfClass:[ProductGroup class]])
                            {
                                bElementRemovedIsProductGroup = YES;
                                ProductGroup * pg = (ProductGroup *)objButtonToDelete;
                                if (_searchContext == PRODUCT_SEARCH)
                                {
                                    if ([pg.idProductGroup isEqualToString:selectedProductCategory.idProductGroup])
                                    {
                                        selectedProductCategory = nil;
                                        iNumSubProductCategories = 0;
                                        [arSelectedSubProductCategory removeAllObjects];
                                        [self updateSuccessulTermsForGender];
                                    }
                                    else
                                    {
                                        iNumSubProductCategories--;
                                        [arSelectedSubProductCategory removeObject:pg];
                                        if (iNumSubProductCategories <= 0)
                                        {
                                            iNumSubProductCategories = 0;
                                            [self addSearchTermWithObject:selectedProductCategory animated:YES performSearch:NO checkSearchTerms:bCheckSearch];
                                        }
                                    }
                                }
                                else
                                {
                                    selectedProductCategory = nil;
                                    iNumSubProductCategories--;
                                    [arSelectedSubProductCategory removeObject:pg];
                                    if (iNumSubProductCategories <= 0)
                                    {
                                        iNumSubProductCategories = 0;
                                        [arSelectedSubProductCategory removeAllObjects];
                                    }
                                    else
                                    {
                                        selectedProductCategory = [[arSelectedSubProductCategory objectAtIndex:iNumSubProductCategories-1] getTopParent];
                                    }
                                    [self updateSuccessulTermsForGender];
                                }
                            }
                            if ([objButtonToDelete isKindOfClass:[Keyword class]])
                            {
                                Keyword *key = (Keyword *)objButtonToDelete;
                                ProductGroup * pg = [self getProductGroupParentFromId:key.productCategoryId];
                                Feature * feat = [self getFeatureFromId:key.featureId];
                                if (pg != nil)
                                {
                                    if ([pg.idProductGroup isEqualToString:selectedProductCategory.idProductGroup])
                                    {
                                        selectedProductCategory = nil;
                                        iNumSubProductCategories = 0;
                                        [arSelectedSubProductCategory removeAllObjects];
                                        [self updateSuccessulTermsForGender];
                                    }
                                    else
                                    {
                                        iNumSubProductCategories--;
                                        [arSelectedSubProductCategory removeObject:pg];
                                        if (iNumSubProductCategories <= 0)
                                        {
                                            iNumSubProductCategories = 0;
                                            [self addSearchTermWithObject:selectedProductCategory animated:YES performSearch:NO  checkSearchTerms:bCheckSearch];
                                        }
                                    }
                                }
                                if (feat != nil)
                                {
                                    // check that there is not any gender selected
                                    [self getGenderSelected];
                                    
                                    if (self.SuggestedFiltersRibbonView.arSelectedButtons.count > 0)
                                    {
                                        if (self.SuggestedFiltersRibbonView.arSelectedButtons.count > 0)
                                        {
                                            int iIdxSelected = [self.SuggestedFiltersRibbonView.arSelectedButtons[0] intValue];
                                            NSObject *obj = self.SuggestedFiltersRibbonView.arrayButtons[iIdxSelected];
                                            [self getSuggestedFiltersForProductGroup:selectedProductCategory];
                                            [self showSuggestedFiltersLocallyForObject: obj andButtonEntry:iIdxSelected];
                                        }
                                    }
                                    [self updateSuccessulTermsForGender];
                                }
                            }
                        }
                        BOOL bUpdatingSearch = NO;
                        if(_filterSearchVC == nil)
                        {
                            if ((_searchContext == PRODUCT_SEARCH) && (bElementRemovedIsProductGroup) && (arSelectedSubProductCategory.count == 0))
                            {
                                // open style tab
                                sLastSelectedSlide = @"";
                                iLastSelectedSlide = 0;
                            }
                            else
                            {
                                if ((self.secondCollectionView.alpha < 1.0) || ([self.secondCollectionView isHidden]))
                                {
                                    bUpdatingSearch = [self updateSearchForTermsChanges];
                                }
                            }
                        }
                        
                        if ((_searchContext == PRODUCT_SEARCH) && (bUpdatingSearch == NO))
                        {
                            if (iGenderSelected == 0) //&& (selectedProductCategory == nil))
                            {
                                [self getSuggestedFiltersGenders];
                                [self setupSuggestedFiltersRibbonView];
                                [self hideFiltersView:YES];
                            }
                            if ((iGenderSelected > 0) && (selectedProductCategory == nil))
                            {
                                [self getSuggestedFiltersProductGroupForGender:iGenderSelected];
                                [self setupSuggestedFiltersRibbonView];
                                if (self.foundSuggestions != nil)
                                {
                                    [self.foundSuggestions removeAllObjects];
                                }
                                if (self.foundSuggestionsPC != nil)
                                {
                                    [self.foundSuggestionsPC removeAllObjects];
                                }
                            }
                            
                            if ([self.successfulTerms count] <= 0)
                            {
                                [self restartSearch];
                            }
                        }
                    }
                }
            }
        }
    }
    else if (slideButtonView == self.SuggestedFiltersRibbonView)
    {
        [self hideAddSearchTerm];
        if (!(self.SuggestedFiltersRibbonView.arrayButtons == nil))
        {
            if (!(buttonEntry >= [self.SuggestedFiltersRibbonView.arrayButtons count]))
            {
                if (_searchContext != BRANDS_SEARCH)
                {
                    
                    NSObject * objectRibbon =[self.SuggestedFiltersRibbonView.arrayButtons objectAtIndex:buttonEntry];
                    if (_searchContext == PRODUCT_SEARCH)
                    {
                        if (bFiltersNew)
                        {
                            [filterManager setupFiltersLocallyForObject:objectRibbon andButtonEntry:buttonEntry];
                        }
                        else
                        {
                            [self showSuggestedFiltersLocallyForObject: objectRibbon andButtonEntry:buttonEntry];
                        }
                    }
                    else
                    {
                        if (_bSuggestedKeywordsFromSearch)
                        {
                            if (![self.SuggestedFiltersRibbonView isSelected:buttonEntry])
                            {
                                [self hideFiltersView:YES performSearch:YES];
                            }
                            else
                            {
                                if (bFiltersNew)
                                {
                                    [filterManager setupFiltersFromSearchForObject:objectRibbon];
                                }
                                else
                                {
                                    [self showSuggestedFiltersFromSearchForObject: objectRibbon];
                                }
                            }
                            
                        }
                        else
                        {
                            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            
                            BOOL bFilterFromServer = ([[appDelegate.config valueForKey:@"load_filters_from_server"] boolValue] == YES);
                            
                            if (bFilterFromServer)
                            {
                                [self showSuggestedFiltersFromServerForObject: objectRibbon];
                            }
                            else
                            {
                                if (bFiltersNew)
                                {
                                    [filterManager setupFiltersLocallyForObject:objectRibbon andButtonEntry:buttonEntry];
                                }
                                else
                                {
                                    [self showSuggestedFiltersLocallyForObject: objectRibbon andButtonEntry:buttonEntry];
                                }
                            }
                            
                            //                        if ([objectRibbon isKindOfClass:[NSString class]])
                            //                            [self addSearchTermWithName:(NSString *)objectRibbon animated:YES];
                            //                        else
                            //                            [self addSearchTermWithObject:objectRibbon animated:YES];
                        }
                    }
                    
                }
                else
                {
                    NSString * letter = [self.SuggestedFiltersRibbonView.arrayButtons objectAtIndex:buttonEntry];
                    
                    // making the serching for the initial
                    [self addSearchTermWithName:letter animated:YES];
                }
            }
        }
    }
    
    [self updateBottomBarSearch];
}

-(void) showSuggestedFiltersFromSearchForObject:(NSObject *) objectRibbon
{
    __block NSPredicate *predicate = nil;
    __block NSString * entityPredicate = @"";
    __block NSArray * _arrSortOrderForSuggestedKeyword;
    __block NSArray * _arrSortAscendingForSuggestedKeyword;
    
    BOOL bPerformSearch = NO;
    
    if ([objectRibbon isKindOfClass:[Feature class]])
    {
        Feature * feat = (Feature*)objectRibbon;
        iGenderSelected = [self getGenderFromName:feat.name];
        [self getSuggestedFiltersProductGroupForGender:iGenderSelected];
    }
    else if ([objectRibbon isKindOfClass:[FeatureGroup class]])
    {
        entityPredicate = @"Feature";
        FeatureGroup * fg = (FeatureGroup*)objectRibbon;
        NSString * sNameTrimmed = [[fg.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString * sPriceTrimmed = [[NSLocalizedString(@"price",nil) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([sNameTrimmed isEqualToString:sPriceTrimmed])
        {
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"priority", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            // feature group of price
            predicate = [NSPredicate predicateWithFormat:@"idFeature IN %@",arrayFeaturesPrices];
        }
        else{
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"name", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            
            NSString * getIdParents = [self getChildrenFeatureGroupIdForPredicate: [fg getAllChildrenId] ];
            NSPredicate *predicateFilterById = [NSPredicate predicateWithFormat:@"idFeature IN %@",self.suggestedFilters];
            if (![getIdParents isEqualToString:@""])
            {
                NSPredicate *predicateParents = [NSPredicate predicateWithFormat:@"featureGroupId IN %@",[fg getAllChildrenId]];
                NSArray *subpreds = [NSArray arrayWithObjects:predicateFilterById, predicateParents, nil];
                predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpreds];
            }
            else
            {
                predicate = predicateFilterById;
            }
        }
    }
    else if ([objectRibbon isKindOfClass:[ProductGroup class]])
    {
        bPerformSearch = YES;
        objectRibbon = ((ProductGroup *)objectRibbon).name;
    }
    else if ([objectRibbon isKindOfClass:[NSString class]])
    {
        NSString * sStringRibbon = (NSString *)objectRibbon;
        
        if ([sStringRibbon isEqualToString:NSLocalizedString(@"_BRANDS_",nil)])
        {
            entityPredicate = @"Brand";
            //            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"priority",@"name", nil];
            //            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil];
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"name", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            
            predicate = [NSPredicate predicateWithFormat:@"(idBrand IN %@)", self.suggestedFilters];
        }
        else if ([sStringRibbon isEqualToString:NSLocalizedString(@"_STYLE_",nil)]  || [sStringRibbon isEqualToString:NSLocalizedString(@"_PRODUCT_TYPE_",nil)])
        {
            entityPredicate = @"ProductGroup";
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"app_name", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            
            predicate = [NSPredicate predicateWithFormat:@"(visible == TRUE) AND (idProductGroup IN %@) AND (idProductGroup IN %@)", self.suggestedFilters, self.successfulTermIdProductCategory];
        }
        else
        {
            bPerformSearch = YES;
        }
    }
    if (bPerformSearch)
    {
        [self addSearchTermWithName:(NSString *)objectRibbon animated:YES];
        [self hideFiltersView:YES];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Then set them via the main queue if the cell is still visible.
            NSDate * timingDate = [NSDate date];
            
            [self initFetchedResultsControllerForKeywordsForEntity:entityPredicate withPredicateObject:predicate anOrderByArray:_arrSortOrderForSuggestedKeyword ascendingArray:_arrSortAscendingForSuggestedKeyword];
            [self.secondCollectionView setContentOffset:self.secondCollectionView.contentOffset animated:NO];
            [self initOperationsLoadingImages];
            [self.imagesQueue cancelAllOperations];
            [self.secondCollectionView reloadData];
            
            [self showKeywordsView:YES];
            
            NSLog(@"ShowSuggestedFiltersFromSearch Time taken: %f", [[NSDate date] timeIntervalSinceDate:timingDate]);
        });
        
    }
    
}

-(void) showSuggestedFiltersLocallyForObject:(NSObject *) objectRibbon andButtonEntry:(int)buttonEntry
{
    BOOL bPerformSearch = NO;
    __block NSPredicate *predicate = nil;
    __block NSString * entityPredicate = @"";
    __block NSArray * _arrSortOrderForSuggestedKeyword;
    __block NSArray * _arrSortAscendingForSuggestedKeyword;
    bLocationQuery = NO;
    bStyleStylistQuery = NO;
    
    
    if ([objectRibbon isKindOfClass:[Feature class]])
    {
        [self.SuggestedFiltersRibbonView unselectButton:buttonEntry];
        Feature * feat = (Feature*)objectRibbon;
        int beforeGender = iGenderSelected;
        long iNumSearchTerms = self.successfulTerms.count;
        iGenderSelected = [self getGenderFromName:feat.name];
        [self addSearchTermWithObject:objectRibbon animated:YES performSearch:NO  checkSearchTerms:YES];
        //        [self getSuggestedFiltersProductGroupForGender:iGenderSelected];
        if (selectedProductCategory == nil)
        {
            [self getSuggestedFiltersProductGroupForGender:iGenderSelected];
        }
        else
        {
            [self getSuggestedFiltersForProductGroup:selectedProductCategory];
        }
        
        if ((beforeGender != iGenderSelected) && (iNumSearchTerms > 0))
        {
            [self updateSearchForTermsChanges];
        }
        else
        {
            [self setupSuggestedFiltersRibbonView];
            iLastSelectedSlide = 0;
            sLastSelectedSlide = @"";
        }
    }
    else if ([objectRibbon isKindOfClass:[ProductGroup class]])
    {
        if (selectedProductCategory == nil)
        {
            [self.SuggestedFiltersRibbonView unselectButton:buttonEntry];
            
            ProductGroup * productGroup = (ProductGroup *)objectRibbon;
            selectedProductCategory = productGroup;
            
            [self addSearchTermWithObject:selectedProductCategory animated:YES performSearch:NO  checkSearchTerms:YES];
            [self getSuggestedFiltersForProductGroup:selectedProductCategory];
            iLastSelectedSlide = 0;
            //        [self setupSuggestedFiltersRibbonView];
            sLastSelectedSlide = @"";
        }
    }
    else
    {
        iLastSelectedSlide = buttonEntry;
        sLastSelectedSlide = [self.SuggestedFiltersRibbonView sGetNameButtonByIdx:buttonEntry];
        
        // management of collectionview
        if (![self.SuggestedFiltersRibbonView isSelected:buttonEntry])
        {
            BOOL bPerformSearch = ([self.searchTermsListView sameFromLastState] == NO);
            [self hideFiltersView:YES performSearch:bPerformSearch];
        }
        else
        {
            
            if ([objectRibbon isKindOfClass:[FeatureGroup class]])
            {
                entityPredicate = @"Feature";
                FeatureGroup * fg = (FeatureGroup*)objectRibbon;
                NSString * sNameTrimmed = [[fg.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString * sPriceTrimmed = [[NSLocalizedString(@"price",nil) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([sNameTrimmed isEqualToString:sPriceTrimmed])
                {
                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"priority", nil];
                    _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
                    // feature group of price
                    predicate = [NSPredicate predicateWithFormat:@"idFeature IN %@",arrayFeaturesPrices];
                }
                else
                {
                    
                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"name", nil];
                    _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
                    
                    NSString * getIdParents = [self getChildrenFeatureGroupIdForPredicate: [fg getAllChildrenId] ];
                    NSPredicate *predicateFilterById = [NSPredicate predicateWithFormat:@"idFeature IN %@",self.suggestedFilters];
                    
                    if ([getIdParents isEqualToString:@""] == NO)
                    {
                        NSPredicate *predicateParents = [NSPredicate predicateWithFormat:@"featureGroupId IN %@",[fg getAllChildrenId]];
                        NSArray *subpreds = [NSArray arrayWithObjects:predicateFilterById, predicateParents, nil];
                        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpreds];
                    }
                    else
                    {
                        predicate = predicateFilterById;
                    }
                }
            }
            else if ([objectRibbon isKindOfClass:[ProductGroup class]])
            {
                objectRibbon = ((ProductGroup *)objectRibbon).name;
            }
            else if ([objectRibbon isKindOfClass:[NSString class]])
            {
                NSString * sStringRibbon = (NSString *)objectRibbon;
                
                if ([sStringRibbon isEqualToString:NSLocalizedString(@"_BRANDS_",nil)])
                {
                    
                    entityPredicate = @"Brand";
                    //                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"priority",@"name", nil];
                    //                    _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil];
                    //                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"name", nil];
                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"order", @"name", nil];
                    _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil];
                    
                    predicate = [NSPredicate predicateWithFormat:@"(idBrand IN %@)", self.suggestedFilters];
                }
                else if ([sStringRibbon isEqualToString:NSLocalizedString(@"_STYLE_",nil)] || [sStringRibbon isEqualToString:NSLocalizedString(@"_PRODUCT_TYPE_",nil)])
                {
                    entityPredicate = @"ProductGroup";
                    //                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"app_name", nil];
                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"order",@"app_name", nil];
                    _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil];
                    
                    if ((selectedProductCategory != nil) || (_searchContext != PRODUCT_SEARCH))
                    {
                        predicate = [NSPredicate predicateWithFormat:@"(visible == TRUE) AND (idProductGroup IN %@) AND (idProductGroup IN %@)", self.suggestedFilters, self.successfulTermIdProductCategory];
                    }
                    else if (_searchContext == PRODUCT_SEARCH)
                    {
                        predicate = [NSPredicate predicateWithFormat:@"(visible == TRUE) AND (idProductGroup IN %@)", self.suggestedFilters];
                    }
                }
                else if ([sStringRibbon isEqualToString:NSLocalizedString(@"_LOCATION_",nil)])
                {
                    bLocationQuery = YES;
                }
                else if ([sStringRibbon isEqualToString:NSLocalizedString(@"_STYLE_STYLIST_",nil)])
                {
                    bStyleStylistQuery = YES;
                }
                else
                {
                    bPerformSearch = YES;
                }
            }
            if (bPerformSearch)
            {
                [self addSearchTermWithName:(NSString *)objectRibbon animated:YES];
                [self hideFiltersView:YES];
            }
            else
            {
                if (!bRestartingSearch)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Then set them via the main queue if the cell is still visible.
                        NSDate * timingDate = [NSDate date];
                        
                        if (predicate != nil)
                        {
                            [self initFetchedResultsControllerForKeywordsForEntity:entityPredicate withPredicateObject:predicate anOrderByArray:_arrSortOrderForSuggestedKeyword ascendingArray:_arrSortAscendingForSuggestedKeyword];
                        }
                        [self.secondCollectionView setContentOffset:self.secondCollectionView.contentOffset animated:NO];
                        [self initOperationsLoadingImages];
                        [self.imagesQueue cancelAllOperations];
                        [self.secondCollectionView reloadData];
                        
                        [self showKeywordsView:YES];
                        
                        if ([entityPredicate isEqualToString:@"Brand"])
                        {
                            [self initBrandsAlphabet];
                        }
                        //                        else if ([entityPredicate isEqualToString:@"ProductGroup"])
                        //                        {
                        //                            [self initProductCategoryAlphabet];
                        //                        }
                        //                        else if ([entityPredicate isEqualToString:@"Feature"])
                        //                        {
                        //                            [self initFeaturesAlphabet];
                        //                        }
                        
                        
                        NSLog(@"ShowSuggestedFiltersLocally Time taken: %f", [[NSDate date] timeIntervalSinceDate:timingDate]);
                    });
                }
            }
        }
    }
}

-(void) showSuggestedFiltersFromServerForObject:(NSObject *) objectRibbon
{
    
}

-(long) iIdxFilterSelected:(NSString*) sFilter
{
    long iIdxRes = -1;
    long iIdx = 0;
    
    NSString * sFilterTrimmed = [[sFilter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    for (NSObject * searchTerm in self.successfulTerms)
    {
        NSString * sSearchTerm = nil;
        NSString * sSearchTermAux = nil;
        if ([searchTerm isKindOfClass:[NSString class]])
        {
            sSearchTerm = (NSString *)searchTerm;
        }
        else if ([searchTerm isKindOfClass:[ProductGroup class]])
        {
            sSearchTerm = ((ProductGroup *)searchTerm).app_name;
            sSearchTermAux =  ((ProductGroup *)searchTerm).name;
        }
        else if ([searchTerm isKindOfClass:[FeatureGroup class]])
        {
            sSearchTerm = ((FeatureGroup *)searchTerm).app_name;
            sSearchTermAux =  ((FeatureGroup *)searchTerm).name;
        }
        else if ([searchTerm isKindOfClass:[Feature class]])
        {
            sSearchTerm = ((Feature *)searchTerm).app_name;
            sSearchTermAux =  ((Feature *)searchTerm).name;
        }
        else if ([searchTerm isKindOfClass:[Brand class]])
        {
            sSearchTerm = ((Brand *)searchTerm).name;
        }
        NSString * searchTermTrimmed = [[sSearchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        if ([searchTermTrimmed.lowercaseString isEqualToString:sFilterTrimmed.lowercaseString])
        {
            iIdxRes = iIdx;
            break;
        }
        
        if (sSearchTermAux != nil)
        {
            NSString * searchTermTrimmed = [[sSearchTermAux stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
            if ([searchTermTrimmed.lowercaseString isEqualToString:sFilterTrimmed.lowercaseString])
            {
                iIdxRes = iIdx;
                break;
            }
        }
        iIdx++;
        
    }
    
    return iIdxRes;
}

-(void) checkSearchTermsWithResults:(NSMutableArray *)arCheckQuery updtaingSubTitle:(BOOL) bUpdateSubtitle
{
    
    //    if (self.searchTermsListView.count == arCheckQuery.count)
    {
        int iNumTotalProducts = INT_MAX;
        int iIdx = 0;
        BOOL updateButtons = NO;
        BOOL markLastRed = NO;
        // looping all suggested filters in the ribbon view
        for(NSObject * object in self.searchTermsListView.arrayButtons)
        {
            // restore color
            [self setPropertyColor:self.searchTermsListView.colorTextButtons forButton:iIdx inSlideView:self.searchTermsListView];
            
            Brand * b = nil;
            ProductGroup * pg = nil;
            Feature * feat = nil;
            if ([object isKindOfClass:[ProductGroup class]])
            {
                pg = (ProductGroup *)object;
            }
            if ([object isKindOfClass:[Feature class]])
            {
                feat = (Feature *)object;
            }
            if ([object isKindOfClass:[Brand class]])
            {
                b = (Brand *)object;
            }
            
            for (CheckSearch * chk in arCheckQuery)
            {
                Keyword * keyword = [self getKeywordFromId:chk.keyword];
                NSString * idElement = [keyword getIdElement];
                Brand * bCheck = [self getBrandFromId:idElement];
                ProductGroup * pgCheck = [self getProductGroupFromId:idElement];
                Feature * featCheck = [self getFeatureFromId:idElement];
                
                //                UIColor *colorLabel;
                if ((pg != nil) && (pgCheck != nil))
                {
                    if ([pg.idProductGroup isEqualToString:pgCheck.idProductGroup])
                    {
                        updateButtons = YES;
                        //                        NSLog(@"product group %@ results %d", pg.name, [chk.results intValue]);
                        int iNumResults = [chk.results intValue];
                        if (iNumResults <= 0)
                        {
                            markLastRed = YES;
                            //                            colorLabel = [UIColor redColor];
                        }
                        //                        else
                        //                        {
                        //                            colorLabel = self.searchTermsListView.colorTextButtons;
                        //                        }
                        if (iNumResults < iNumTotalProducts)
                            iNumTotalProducts = iNumResults;
                        
                        //                        [self setPropertyColor:colorLabel forButton:iIdx inSlideView:self.searchTermsListView];
                        
                        break;
                    }
                }
                else if ((feat != nil) && (featCheck != nil))
                {
                    if ([feat.idFeature isEqualToString:featCheck.idFeature])
                    {
                        updateButtons = YES;
                        //                        NSLog(@"feature %@ results %d", feat.name, [chk.results intValue]);
                        int iNumResults = [chk.results intValue];
                        if (iNumResults <= 0)
                        {
                            markLastRed = YES;
                            //                            colorLabel = [UIColor redColor];
                        }
                        //                        else
                        //                        {
                        //                            colorLabel = self.searchTermsListView.colorTextButtons;
                        //                        }
                        if (iNumResults < iNumTotalProducts)
                            iNumTotalProducts = iNumResults;
                        
                        //                        [self setPropertyColor:colorLabel forButton:iIdx inSlideView:self.searchTermsListView];
                        
                        break;
                    }
                }
                else if ((b != nil) && (bCheck != nil))
                {
                    if ([b.idBrand isEqualToString:bCheck.idBrand])
                    {
                        updateButtons = YES;
                        //                        NSLog(@"brand %@ results %d", b.name, [chk.results intValue]);
                        int iNumResults = [chk.results intValue];
                        if (iNumResults <= 0)
                        {
                            markLastRed = YES;
                            //                            colorLabel = [UIColor redColor];
                        }
                        //                        else
                        //                        {
                        //                            colorLabel = self.searchTermsListView.colorTextButtons;
                        //                        }
                        if (iNumResults < iNumTotalProducts)
                            iNumTotalProducts = iNumResults;
                        
                        //                        [self setPropertyColor:colorLabel forButton:iIdx inSlideView:self.searchTermsListView];
                        
                        break;
                    }
                }
            }
            iIdx++;
        }
        
        if (markLastRed)
        {
            UIColor *colorLabel = [UIColor redColor];
            [self setPropertyColor:colorLabel forButton:iIdx-1 inSlideView:self.searchTermsListView];
        }
        
        if (updateButtons)
        {
            [self.searchTermsListView scrollToTheEnd];
            [self.searchTermsListView updateButtons];
        }
        
        if (bUpdateSubtitle)
        {
            NSString * subTitle = nil;
            
            if(!(_searchContext == FASHIONISTAS_SEARCH || _searchContext == FASHIONISTAPOSTS_SEARCH))
            {
                subTitle = @"";
                
                if (iNumTotalProducts > 0)
                {
                    if (iNumTotalProducts >= 1000)
                    {
                        subTitle = [NSString stringWithFormat:NSLocalizedString(@"_FUTURE_MORETHAN1000_RESULTS_", nil),iNumTotalProducts];
                    }
                    else
                    {
                        if (iNumTotalProducts > 1)
                        {
                            subTitle = [NSString stringWithFormat:NSLocalizedString(@"_FUTURE_NUM_RESULTS_", nil), iNumTotalProducts];
                        }
                        else
                        {
                            subTitle = [NSString stringWithFormat:NSLocalizedString(@"_FUTURE_NUM_RESULT_", nil), iNumTotalProducts];
                        }
                    }
                }
                else
                {
                    subTitle = NSLocalizedString(@"_FUTURE_NO_RESULTS_ERROR_MSG_", nil);
                }
            }
            
            // Show specific title depending on the Search Context
            [self setTopBarTitle:nil andSubtitle:subTitle];
        }
    }
    //    else
    //    {
    //        NSLog(@"Different elements. Check Search %lu, terms: %lu", (unsigned long)arCheckQuery.count, (unsigned long)self.searchTermsListView.count);
    //    }
    
    [self stopActivityCheckSearch];
}

-(void) checkSearchSuggestionsWithResults:(NSMutableArray *)arCheckQuery
{
    
    bUpdatingSelectionColor = NO;
    
    int iGenders = 0;
    Feature * featGender = nil;
    
    if (bFiltersNew == NO)
    {
        if(!_foundSuggestions)
            _foundSuggestions = [[NSMutableDictionary alloc]init];
        if(!_foundSuggestionsDirectly)
            _foundSuggestionsDirectly = [[NSMutableDictionary alloc]init];
        
        if(!_foundSuggestionsDirectly)
            _foundSuggestionsDirectly = [[NSMutableDictionary alloc]init];
        if(!_foundSuggestionsLocations)
            _foundSuggestionsLocations = [[NSMutableDictionary alloc]init];
        if(!_foundSuggestionsStyleStylist)
            _foundSuggestionsStyleStylist = [[NSMutableDictionary alloc]init];
        if(!_foundSuggestionsPC)
            _foundSuggestionsPC = [[NSMutableDictionary alloc]init];
        if(!_foundSuggestionsBrand)
            _foundSuggestionsBrand = [[NSMutableDictionary alloc]init];
        
        
        
        [_foundSuggestions removeAllObjects];
        [_foundSuggestionsLocations removeAllObjects];
        [_foundSuggestionsStyleStylist removeAllObjects];
        [_foundSuggestionsPC removeAllObjects];
        [_foundSuggestionsBrand removeAllObjects];
        
        for (CheckSearch *checkSearch in arCheckQuery)
        {
            if(checkSearch.keyword)
            {
                [_foundSuggestions setObject:checkSearch.keyword forKey:checkSearch.keyword];
                
                // check if the keyword is a gender
                Feature *feat = [self getFeatureFromId:checkSearch.keyword];
                if (feat != nil)
                {
                    NSString * sNameFeatureGroup = [[feat.featureGroup.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([sNameFeatureGroup isEqualToString:@"gender"])
                    {
                        featGender = feat;
                        iGenders++;
                    }
                }
                if([checkSearch.results integerValue] == 0)
                    [_foundSuggestions setObject:checkSearch.keyword forKey:checkSearch.keyword];
                else if([checkSearch.results integerValue] == -2)
                    [_foundSuggestionsPC setObject:checkSearch.keyword forKey:checkSearch.keyword];
                else if([checkSearch.results integerValue] == -3)
                    [_foundSuggestionsBrand setObject:checkSearch.keyword forKey:checkSearch.keyword];
                long iValue = [checkSearch.results integerValue];
                if (iValue < 0)
                {
                    long iIdx = labs(iValue)-1;
                    NSString * sKey = [NSString stringWithFormat:@"%li", iIdx];
                    NSMutableArray * arr =[_foundSuggestionsDirectly objectForKey:sKey];
                    if (arr == nil)
                    {
                        NSMutableArray * arrObjects = [[NSMutableArray alloc] init];
                        [arrObjects addObject:checkSearch];
                        [_foundSuggestionsDirectly setObject:arrObjects forKey:sKey];
                    }
                    else
                    {
                        [arr addObject:checkSearch];
                    }
                    
                    
                }
                /*
                 if([checkSearch.results integerValue] == -4)
                 [_foundSuggestionsLocations setObject:checkSearch.keyword forKey:checkSearch.keyword];
                 else if([checkSearch.results integerValue] == -5)
                 [_foundSuggestionsStyleStylist setObject:checkSearch.keyword forKey:checkSearch.keyword];
                 */
                
            }
        }
        if (iGenders == 1)
        {
            [self cancelCheckSearchOperations];
            [self addSearchTermWithObject:featGender animated:NO performSearch:NO  checkSearchTerms:NO];
            [self.searchTermsListView setLastState];
            [self adaptSuggestedFilterToSearch: NO];
        }
        else
        {
            [self setupSuggestedFiltersRibbonView];
            [self.secondCollectionView reloadData];
        }
    }
    else
    {
        featGender = [filterManager loadSuggestionsFromArray: arCheckQuery];
        if (featGender != nil)
        {
            [self cancelCheckSearchOperations];
            [self addSearchTermWithObject:featGender animated:NO performSearch:NO  checkSearchTerms:NO];
            [self.searchTermsListView setLastState];
            [filterManager getFiltersForProductSearch];
        }
        else
        {
            [filterManager setupSuggestedFiltersRibbonView];
            [self.secondCollectionView reloadData];
        }
    }

    [self stopActivityCheckSuggestions];
    
}

-(void) setPropertyColor:(UIColor *) color forButton:(int) iIdxButton inSlideView:(SlideButtonView *)slideView
{
    SlideButtonProperties * property = [slideView.arrayButtonsProperties objectAtIndex:iIdxButton];
    if (property != nil)
    {
        if ([property isKindOfClass:[NSNull class]])
        {
            property = nil;
            property = [[SlideButtonProperties alloc] init];
            [self.searchTermsListView.arrayButtonsProperties replaceObjectAtIndex:iIdxButton withObject:property];
        }
        property.colorTextButtons = color;
    }
}

#pragma mark - Product type

-(void) manageProductGroup:(ProductGroup *)pg
{
    if (selectedProductCategory != nil)
    {
        if (pg.parent == selectedProductCategory)
        {
            // the product category is parent
            NSMutableArray * arChildren = [pg getAllDescendantsInFoundSuggestions:_foundSuggestions forGender:iGenderSelected];
            NSMutableArray * arChildrenSelected = [self arGetChildrenSelected:arChildren];
            if ([self.searchTermsListView.arrayButtons containsObject:pg] == NO)
            {
                // el padre NO esta seleccionado
                
                // hacemos que se colapsen lo que hubiera abierto
                if (arExpandedSubProductCategory != nil)
                {
                    if (arExpandedSubProductCategory.count > 0)
                    {
                        ProductGroup * pgExpanded = [arExpandedSubProductCategory objectAtIndex:0];
                        if ([pg.idProductGroup isEqualToString:pgExpanded.idProductGroup] == NO)
                        {
                            [arExpandedSubProductCategory removeAllObjects];
                        }
                    }
                    
                    // expandimos automaticamente el padre
                    if (arExpandedSubProductCategory.count == 0)
                    {
                        [arExpandedSubProductCategory addObject:pg];
                    }
                }
                
                // no seleccionado el objeto
                if (arChildrenSelected.count == 0)
                {
                    // numero de hijos seleccionado es 0
                }
                else
                {
                    // numero de hijos seleccionados no es 0
                    
                    // deseleccionar todos los hijos seleccionados
                    for(ProductGroup * pgSelected in arChildrenSelected)
                    {
                        [self removeFromSearchTermProductGroup:pgSelected checkSearchTerms:NO];
                    }
                }
                
                // seleccionamos el padre
                [self addSearchTermWithObject:pg animated:YES performSearch:NO checkSearchTerms:YES];
                iNumSubProductCategories++;
                [arSelectedSubProductCategory addObject:pg];
            }
            else
            {
                // el padre ya está seleccionado
                
                // deseleccionar todos los hijos seleccionados
                for(ProductGroup * pgSelected in arChildrenSelected)
                {
                    [self removeFromSearchTermProductGroup:pgSelected checkSearchTerms:NO];
                }
                // deseleccionamos el padre
                [self removeFromSearchTermProductGroup:pg checkSearchTerms:YES];
            }
        }
        else
        {
            ProductGroup * pgParent = pg.parent;
            NSMutableArray * arSiblings = [pgParent getAllDescendantsInFoundSuggestions:_foundSuggestions forGender:iGenderSelected];
            
            // la product category es un substyle
            if ([self.searchTermsListView.arrayButtons containsObject:pg] == NO)
            {
                // el product category NO está seleccionado
                
                // chequeamos si el padre esta seleccionado o no
                if ([self.searchTermsListView.arrayButtons containsObject:pgParent] == YES)
                {
                    // padre seleccionado
                    
                    // seleccionamos hermanos
                    for (ProductGroup * pgSibling in arSiblings)
                    {
                        if ([pgSibling.idProductGroup isEqualToString:pg.idProductGroup] == NO)
                        {
                            [self addSearchTermWithObject:pgSibling animated:YES performSearch:NO checkSearchTerms:NO];
                            iNumSubProductCategories++;
                            [arSelectedSubProductCategory addObject:pgSibling];
                        }
                    }
                    // deseleccionamos padre
                    [self removeFromSearchTermProductGroup:pgParent checkSearchTerms:YES];
                }
                else
                {
                    // padre no seleccionado
                    
                    
                    // seleccionamos el product category
                    [self addSearchTermWithObject:pg animated:YES performSearch:NO checkSearchTerms:NO];
                    iNumSubProductCategories++;
                    [arSelectedSubProductCategory addObject:pg];
                    // comprobamos si todos los hijos estan seleccionados
                    NSMutableArray * arChildrenSelected = [self arGetChildrenSelected:arSiblings];
                    if (arSiblings.count == arChildrenSelected.count)
                    {
                        // tenemos todos los hijos seleccionados
                        
                        // deseleccionar todos los hijos seleccionados
                        for(ProductGroup * pgSelected in arChildrenSelected)
                        {
                            [self removeFromSearchTermProductGroup:pgSelected checkSearchTerms:NO];
                        }
                        
                        // dejamos seleccionado solo el padre
                        [self addSearchTermWithObject:pgParent animated:YES performSearch:NO checkSearchTerms:YES];
                        iNumSubProductCategories++;
                        [arSelectedSubProductCategory addObject:pgParent];
                    }
                    else
                    {
                        // no todos los hijos estan seleccionados
                        // ya se ha seleccionado el product category
                        [self checkSearchTerms:NO];
                    }
                }
                
            }
            else
            {
                // el product category está seleccionado
                [self removeFromSearchTermProductGroup:pg checkSearchTerms:YES];
                /*
                 // comprobamos si todos los hijos estan deseleccionados
                 NSMutableArray * arChildrenSelected = [self arGetChildrenSelected:arSiblings];
                 if (arChildrenSelected.count <= 0)
                 {
                 // dejamos seleccionado solo el padre
                 [self addSearchTermWithObject:pgParent animated:YES performSearch:NO checkSearchTerms:YES];
                 iNumSubProductCategories++;
                 [arSelectedSubProductCategory addObject:pgParent];
                 }
                 */
            }
        }
    }
    //
    //    if ([self.searchTermsListView.arrayButtons containsObject:pg] == NO)
    //    {
    //        [self addSearchTermWithObject:pg animated:YES performSearch:NO checkSearchTerms:YES];
    //
    //        int iIdx = (int)[self iIdxFilterSelected:selectedProductCategory.app_name];
    //        if (iIdx != -1)
    //        {
    //            [self removeSearchTermAtIndex:iIdx checkSuggestions:NO];
    //        }
    //
    //        iNumSubProductCategories++;
    //        [arSelectedSubProductCategory addObject:pg];
    //    }
    //    else
    //    {
    //        int iIdx = (int)[self iIdxFilterSelected:pg.app_name];
    //        if (iIdx > -1)
    //        {
    //            [self removeSearchTermAtIndex:iIdx checkSuggestions:YES];
    //            iNumSubProductCategories--;
    //            [arSelectedSubProductCategory removeObject:pg];
    //            if (iNumSubProductCategories <= 0)
    //            {
    //                iNumSubProductCategories = 0;
    //                [self addSearchTermWithObject:selectedProductCategory animated:YES performSearch:NO checkSearchTerms:YES];
    //            }
    //        }
    //    }
    //    //            [self.secondCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    [self.secondCollectionView reloadData];
}


-(int) iGetNumChildrenSelected:(NSMutableArray *) arChildren
{
    int iNumSelected = 0;
    for(ProductGroup * pg in arChildren)
    {
        if ([self.searchTermsListView.arrayButtons containsObject:pg] == YES)
        {
            iNumSelected++;
        }
    }
    
    return iNumSelected;
}

-(NSMutableArray *) arGetChildrenSelected:(NSMutableArray *) arChildren
{
    NSMutableArray * arChildrenSelected = [NSMutableArray new];
    
    for(ProductGroup * pg in arChildren)
    {
        if ([self.searchTermsListView.arrayButtons containsObject:pg] == YES)
        {
            [arChildrenSelected addObject:pg];
        }
    }
    
    return arChildrenSelected;
}

#pragma mark - Add Term


// Setup 'Add Term' button
- (void)setupAddTermButton
{
    // Set the delegate to the Add Term text field
    [self.addTermTextField setDelegate:self];
    
    // Setup the Add Term text field appearance
    [self.addTermTextField setValue:[UIFont fontWithName: @"Avenir-Medium" size: 18] forKeyPath:@"_placeholderLabel.font"];
    [self.addTermTextField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.addTermTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
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
    
    if ((_searchContext == PRODUCT_SEARCH) && (!([_resultsArray count] > 0)))
    {
        // Show the Textfield at start
        [self showAddSearchTerm];
    }
}

// Add Term action
- (void)addTermAction:(UIButton *)sender
{
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    if(!([_filterSearchVCContainerView isHidden]))
    {
        return;
    }
    
    [self showMainMenu:nil];
    
    [self showAddSearchTerm];
    
    [_addTermTextField becomeFirstResponder];
}

// Catch the notification when keyboard appears
- (void)keyboardDidChangeFrameWithNotification:(NSNotification *)notification
{
    // Calculate vertical increase
    CGFloat keyboardVerticalIncrease = [self keyboardVerticalIncreaseForNotification:notification];
    
    if(keyboardVerticalIncrease < 0)
    {
        [self hideAddSearchTerm];
    }
    // Properly animate Add Terms text box
    //    [self showAddSearchTermWithOffset:keyboardVerticalIncrease];
}

// Calculate the vertical increase when keyboard appears
- (CGFloat)keyboardVerticalIncreaseForNotification:(NSNotification *)notification
{
    CGFloat keyboardBeginY = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardEndY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardVerticalIncrease = keyboardBeginY - keyboardEndY;
    
    return keyboardVerticalIncrease;
}

// OVERRIDEN: Assign the suggested text to the textfield
-(void) updateTextFieldWithText: (NSString *)text inRange:(NSRange)range
{
    if([self.addTermTextField.text isEqualToString:@""]||range.location==NSNotFound)
    {
        range.length = 0;
        range.location = [self.addTermTextField.text length];
    }
    
    self.addTermTextField.text = [self.addTermTextField.text stringByReplacingCharactersInRange:range withString:text];
    
    [self updateTextRangeWithText:self.addTermTextField.text];

    //DO NOT PERFORM SEARCH! [self textFieldShouldReturn:self.addTermTextField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text
{
    if([textField.text length] == 0)
    {
        return TRUE;
    }
    
    const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    int isBackSpace = strcmp(_char, "\b");
    
    if (isBackSpace == -8)
    {
        if(!(self.textRange == nil))
        {
            if([self.textRange count] > 0)
            {
                if([[self.textRange lastObject] length] >= [self.addTermTextField.text length])
                {
                    [self.textRange removeLastObject];
                }
            }
        }
    }
    
    return YES;
}

// Perform search when user press 'Search'
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (!(self.addTermTextField.text == nil))
    {
        if (!([self.addTermTextField.text isEqualToString:@""]))
        {
            [self addSearchTermWithName:[self.addTermTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] animated:NO];
        }
    }
    
    [self hideAddSearchTerm];
    
    return YES;
}

- (void)showAddSearchTerm
{
    if(!([_addTermTextField isHidden]))
    {
        return;
    }
    
//    if (originalContraintAddSearchTerm != self.bottomConstraints.constant)
//    {
//        return;
//    }
    
    CGFloat offset = ((self.view.frame.size.height)*((IS_IPHONE_4_OR_LESS) ? (0.52) : (0.48)));
    
    // Empty Add Terms text field
    [_addTermTextField setText:@""];
    
    // Show Add Terms text field and set the focus
    [self.view bringSubviewToFront:_addTermTextField];
    [_addTermTextField setHidden:NO];
    
    CGFloat constant = self.bottomConstraints.constant;
    
    CGFloat newConstant = constant + offset;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.bottomConstraints.constant = newConstant;
                         
                         [_addTermTextField setAlpha:1.00];
                         
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
    
    if(_addTermTextField.alpha < 1.00)
    {
        return;
    }
    
    if (originalContraintAddSearchTerm == self.bottomConstraints.constant)
    {
        return;
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
                         
                         [_addTermTextField setAlpha:0.01];
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                         
                         [_addTermTextField setHidden:YES];
                         
                         [_addTermTextField resignFirstResponder];
                         
                     }];
}

-(void) resetAddSearchTerm
{
    self.bottomConstraints.constant = kConstraintBottomAddSearchTerm;;
    
    [_addTermTextField setAlpha:0.01];
    
    [self.view layoutIfNeeded];
    [_addTermTextField setHidden:YES];
    
    [_addTermTextField resignFirstResponder];
}


#pragma mark - Search by Filters


// Features Search action
- (void)featuresSearchAction:(UIButton *)sender
{
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    if(!(_filterSearchVC == nil))
    {
        return;
    }
    else
    {
        // Instantiate the 'FilterSearch' view controller within the container view
        
        if ([UIStoryboard storyboardWithName:@"Search" bundle:nil] != nil)
        {
            @try {
                
                _filterSearchVC = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateViewControllerWithIdentifier:[@(SEARCHFILTERS_VC) stringValue]];
                
            }
            @catch (NSException *exception) {
                
                return;
                
            }
            
            if (_filterSearchVC != nil)
            {
                if (!([self.addTermTextField isHidden]))
                {
                    [self hideAddSearchTerm];
                }
                
                if(_successfulTerms == nil)
                {
                    _successfulTerms = [[NSMutableArray alloc] init];
                }
                
                [_filterSearchVC setSearchTerms:_successfulTerms];
                
                if (_searchTermsBeforeUpdate == nil)
                {
                    _searchTermsBeforeUpdate = [[NSMutableArray alloc] initWithArray:_successfulTerms];
                }
                else
                {
                    [_searchTermsBeforeUpdate removeAllObjects];
                    
                    [_searchTermsBeforeUpdate addObjectsFromArray:_successfulTerms];
                }
                
                [self addChildViewController:_filterSearchVC];
                
                //[_filterSearchVC willMoveToParentViewController:self];
                
                _filterSearchVC.view.frame = CGRectMake(0,0,_filterSearchVCContainerView.frame.size.width, _filterSearchVCContainerView.frame.size.height);
                
                [_filterSearchVCContainerView addSubview:_filterSearchVC.view];
                
                [_filterSearchVC didMoveToParentViewController:self];
                
                
                //Hide the filter terms ribbon
                [self hideSuggestedFiltersRibbonAnimated:YES];
                [self.noFilterTermsLabel setHidden:YES];
                // Set the property that controls whtether the ribbon should be shown or not
                self.bShouldShowSuggestedFiltersRibbonView = [NSNumber numberWithBool:NO];
                
                [_filterSearchVCContainerView setHidden:NO];
                //                [self.view bringSubviewToFront:_filterSearchVCContainerView];
            }
        }
    }
}

- (void)closeSearchingByFiltersCancelling: (BOOL) bCancelling
{
    if (_filterSearchVC != nil)
    {
        if ([_filterSearchVC zoomViewVisible])
        {
            [_filterSearchVC hideZoomView];
            return;
        }
    }
    
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    
    [[_filterSearchVCContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    
    // Set the property that controls whtether the ribbon should be shown or not
    self.bShouldShowSuggestedFiltersRibbonView = [NSNumber numberWithBool:YES];
    //Show the filter terms ribbon
    [self showSuggestedFiltersRibbonAnimated:YES];
    
    [_filterSearchVCContainerView setHidden:YES];
    if (_filterSearchVC != nil)
        [_filterSearchVC hideZoomView];
    
    if((!([_searchTermsBeforeUpdate isEqualToArray:_successfulTerms])) && (!bCancelling))
    {
        [self updateSearchForTermsChanges];
        
        _filterSearchVC = nil;
        
        return;
    }
    
    if((!([_searchTermsBeforeUpdate isEqualToArray:_successfulTerms])) && (bCancelling))
    {
        [_successfulTerms removeAllObjects];
        [self.searchTermsListView removeAllButtons];
        
        for (int i = 0; i < [_searchTermsBeforeUpdate count]; i++)
        {
            [self addSearchTermWithName:[_searchTermsBeforeUpdate objectAtIndex:i]  animated:NO];
        }
    }
    
    [_searchTermsBeforeUpdate removeAllObjects];
    
    _searchTermsBeforeUpdate = nil;
    
    _filterSearchVC = nil;
}

-(void) addSearchTermWithName:(NSString *) name animated:(BOOL) bAnimated
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!([self.searchTermsListView.arrayButtons containsObject:name]))
    {
        if(self.successfulTerms == nil)
        {
            self.successfulTerms = [[NSMutableArray alloc] init];
        }
        
        if(_filterSearchVC == nil)
        {
            if (_searchTermsBeforeUpdate == nil)
            {
                _searchTermsBeforeUpdate = [[NSMutableArray alloc] initWithArray:_successfulTerms];
            }
            else
            {
                [_searchTermsBeforeUpdate removeAllObjects];
                
                [_searchTermsBeforeUpdate addObjectsFromArray:_successfulTerms];
            }
        }
        
        if(_searchContext == HISTORY_SEARCH)
        {
            NSMutableArray *historyPeriods = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < maxHistoryPeriods; i++)
            {
                [historyPeriods addObject:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)];
                [historyPeriods addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)]];
            }
            
            
            for (int i = 0; i < maxHistoryPeriods; i++)
            {
                if ([name isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)])
                {
                    _searchPeriod = i;
                    
                    for (int j = 0; j < [self.searchTermsListView.arrayButtons count]; j++)
                    {
                        if ([historyPeriods containsObject:[self.searchTermsListView.arrayButtons objectAtIndex:j]])
                        {
                            if([self.searchTermsListView.arrayButtons count] > 1)
                            {
                                [self.searchTermsListView changeButtonText:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",_searchPeriod]), nil)] atIndex:j];
                            }
                            else
                            {
                                [self.searchTermsListView changeButtonText:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",_searchPeriod]), nil) atIndex:j];
                            }
                            
                        }
                    }
                    
                    if(_filterSearchVC == nil)
                    {
                        // Update search
                        [self updateSearchForTermsChanges];
                    }
                    
                    return;
                }
            }
        }
        else if(_searchContext == FASHIONISTAPOSTS_SEARCH)
        {
            for (int i = 0; i < maxFashionistaPostTypes; i++)
            {
                if ([name isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",i]), nil)])
                {
                    _searchPostType = i;
                    
                    if(_filterSearchVC == nil)
                    {
                        // Update search
                        [self updateSearchForTermsChanges];
                    }
                    
                    return;
                }
            }
            
            if(!(appDelegate.currentUser == nil))
            {
                NSMutableArray *stylistFollowingRelationships = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < maxFollowingRelationships; i++)
                {
                    [stylistFollowingRelationships addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)];
                    [stylistFollowingRelationships addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)]];
                }
                
                
                for (int i = 0; i < maxFollowingRelationships; i++)
                {
                    if ([name isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)])
                    {
                        _searchStylistRelationships = i;
                        
                        for (int j = 0; j < [self.searchTermsListView.arrayButtons count]; j++)
                        {
                            if ([stylistFollowingRelationships containsObject:[self.searchTermsListView.arrayButtons objectAtIndex:j]])
                            {
                                if([self.searchTermsListView.arrayButtons count] > 2)
                                {
                                    [self.searchTermsListView changeButtonText:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)] atIndex:j];
                                }
                                else
                                {
                                    [self.searchTermsListView changeButtonText:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil) atIndex:j];
                                }
                            }
                        }
                        
                        if(_filterSearchVC == nil)
                        {
                            // Update search
                            [self updateSearchForTermsChanges];
                        }
                        
                        return;
                    }
                }
            }
            
            
            NSString * pene = [[name lowercaseString] capitalizedString];
            pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (([_successfulTerms containsObject: pene] == NO) && ([_successfulTerms containsObject: [NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), pene]] == NO))
            {
                [_successfulTerms addObject: pene];
                
                // Add button
                [self.searchTermsListView addButton:pene];
            }
            
            //_searchStylistRelationships = ALLSTYLISTS;
            
            if(_filterSearchVC == nil)
            {
                // Update search
                [self updateSearchForTermsChanges];
            }
            
            return;
        }
        else if(_searchContext == FASHIONISTAS_SEARCH)
        {
            //            if([name isEqualToString:NSLocalizedString(@"_FASHIONISTA_POSTS_", nil)])
            //            {
            //                _searchContext = FASHIONISTAPOSTS_SEARCH;
            //
            //                // Show specific title depending on the Search Context
            //                [self setTopBarTitle:NSLocalizedString(([NSString stringWithFormat:@"_VCTITLE_%i_",_searchContext]), nil) andSubtitle:nil];
            //
            //                for (int j = 0; j < [self.searchTermsListView.arrayButtons count]; j++)
            //                {
            //                    if([[self.searchTermsListView.arrayButtons objectAtIndex:j] isKindOfClass:[NSString class]])
            //                    {
            //                        if (([[self.searchTermsListView.arrayButtons objectAtIndex:j] isEqualToString:NSLocalizedString(@"_FASHIONISTAS_", nil)]) || ([[self.searchTermsListView.arrayButtons objectAtIndex:j] isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTAS_", nil)]]))
            //                        {
            //                            [self.searchTermsListView changeButtonText:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTA_POSTS_", nil)] atIndex:j];
            //                        }
            //                    }
            //                }
            //
            //                if(_filterSearchVC == nil)
            //                {
            //                    // Update search
            //                    [self updateSearchForTermsChanges];
            //                }
            //
            //                return;
            //            }
            
            if(!(appDelegate.currentUser == nil))
            {
                NSMutableArray *stylistFollowingRelationships = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < maxFollowingRelationships; i++)
                {
                    [stylistFollowingRelationships addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)];
                    [stylistFollowingRelationships addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)]];
                }
                
                
                for (int i = 0; i < maxFollowingRelationships; i++)
                {
                    if ([name isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)])
                    {
                        _searchStylistRelationships = i;
                        
                        for (int j = 0; j < [self.searchTermsListView.arrayButtons count]; j++)
                        {
                            if ([stylistFollowingRelationships containsObject:[self.searchTermsListView.arrayButtons objectAtIndex:j]])
                            {
                                if([self.searchTermsListView.arrayButtons count] > 1)
                                {
                                    [self.searchTermsListView changeButtonText:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)] atIndex:j];
                                }
                                else
                                {
                                    [self.searchTermsListView changeButtonText:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil) atIndex:j];
                                }
                            }
                        }
                        
                        if(_filterSearchVC == nil)
                        {
                            // Update search
                            [self updateSearchForTermsChanges];
                        }
                        
                        return;
                    }
                }
            }
            
            NSString * pene = [[name lowercaseString] capitalizedString];
            pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (([_successfulTerms containsObject: pene] == NO) && ([_successfulTerms containsObject: [NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), pene]] == NO))
            {
                [_successfulTerms addObject: pene];
                
                // Add button
                [self.searchTermsListView addButton:pene];
            }
            
            //_searchStylistRelationships = ALLSTYLISTS;
            
            if(_filterSearchVC == nil)
            {
                // Update search
                [self updateSearchForTermsChanges];
            }
            
            return;
        }
        else if (_searchContext == BRANDS_SEARCH)
        {
            [_successfulTerms removeAllObjects];
            [self.searchTermsListView removeAllButtons];
        }
        
        //Add new term(s) to list of terms
        if (![name isEqualToString:@"#"])  // en brands el caracter # es para todas las brands
        {
            NSString * pene = [[name lowercaseString] capitalizedString];
            pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if ([_successfulTerms containsObject: pene] == NO)
            {
                [_successfulTerms addObject: pene];
                
                // Add button
                [self.searchTermsListView addButton:pene];
            }
        }
        
        if(_filterSearchVC == nil)
        {
            // Update search
            [self updateSearchForTermsChanges];
        }
    }
    else
    {
        /*
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_TERM_ALREADY_IN_LIST_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
         
         [alertView show];
         */
    }
}

-(void) addSearchTermWithObject:(NSObject *) object animated:(BOOL) bAnimated
{
    [self addSearchTermWithObject:object animated:bAnimated performSearch:YES checkSearchTerms:YES];
}

-(void) addSearchTermWithObject:(NSObject *) object animated:(BOOL) bAnimated performSearch:(BOOL) bPerformSearch checkSearchTerms:(BOOL) bCheck
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!([self.searchTermsListView.arrayButtons containsObject:object]))
    {
        if(self.successfulTerms == nil)
        {
            self.successfulTerms = [[NSMutableArray alloc] init];
        }
        
        if(_filterSearchVC == nil)
        {
            if (_searchTermsBeforeUpdate == nil)
            {
                _searchTermsBeforeUpdate = [[NSMutableArray alloc] initWithArray:_successfulTerms];
            }
            else
            {
                [_searchTermsBeforeUpdate removeAllObjects];
                
                [_searchTermsBeforeUpdate addObjectsFromArray:_successfulTerms];
            }
        }
        
        if(_searchContext == HISTORY_SEARCH)
        {
            NSMutableArray *historyPeriods = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < maxHistoryPeriods; i++)
            {
                [historyPeriods addObject:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)];
                [historyPeriods addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)]];
            }
            
            
            for (int i = 0; i < maxHistoryPeriods; i++)
            {
                if ([[object toStringButtonSlideView] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)])
                {
                    _searchPeriod = i;
                    
                    for (int j = 0; j < [self.searchTermsListView.arrayButtons count]; j++)
                    {
                        if ([historyPeriods containsObject:[self.searchTermsListView.arrayButtons objectAtIndex:j]])
                        {
                            if([self.searchTermsListView.arrayButtons count] > 1)
                            {
                                [self.searchTermsListView changeButtonText:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",_searchPeriod]), nil)] atIndex:j];
                            }
                            else
                            {
                                [self.searchTermsListView changeButtonText:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",_searchPeriod]), nil) atIndex:j];
                            }
                        }
                    }
                    
                    if(_filterSearchVC == nil)
                    {
                        // Update search
                        if (bPerformSearch)
                            [self updateSearchForTermsChanges];
                    }
                    
                    if (bPerformSearch)
                        return;
                }
            }
        }
        else if(_searchContext == FASHIONISTAPOSTS_SEARCH)
        {
            for (int i = 0; i < maxFashionistaPostTypes; i++)
            {
                if ([[object toStringButtonSlideView] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",i]), nil)])
                {
                    _searchPostType = i;
                    
                    if(_filterSearchVC == nil)
                    {
                        // Update search
                        if (bPerformSearch)
                            [self updateSearchForTermsChanges];
                    }
                    
                    if (bPerformSearch)
                        return;
                }
            }
            
            if(!(appDelegate.currentUser == nil))
            {
                NSMutableArray *stylistFollowingRelationships = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < maxFollowingRelationships; i++)
                {
                    [stylistFollowingRelationships addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)];
                    [stylistFollowingRelationships addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)]];
                }
                
                
                for (int i = 0; i < maxFollowingRelationships; i++)
                {
                    if ([[object toStringButtonSlideView] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)])
                    {
                        _searchStylistRelationships = i;
                        
                        for (int j = 0; j < [self.searchTermsListView.arrayButtons count]; j++)
                        {
                            if ([stylistFollowingRelationships containsObject:[self.searchTermsListView.arrayButtons objectAtIndex:j]])
                            {
                                if([self.searchTermsListView.arrayButtons count] > 1)
                                {
                                    [self.searchTermsListView changeButtonText:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)] atIndex:j];
                                }
                                else
                                {
                                    [self.searchTermsListView changeButtonText:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil) atIndex:j];
                                }
                            }
                        }
                        
                        if(_filterSearchVC == nil)
                        {
                            // Update search
                            if (bPerformSearch)
                                [self updateSearchForTermsChanges];
                        }
                        
                        if (bPerformSearch)
                            return;
                    }
                }
            }
            
            //_searchStylistRelationships = ALLSTYLISTS;
            
            if(_filterSearchVC == nil)
            {
                // Update search
                if (bPerformSearch)
                    [self updateSearchForTermsChanges];
            }
            
            if (bPerformSearch)
                return;
        }
        else if(_searchContext == FASHIONISTAS_SEARCH)
        {
            //            if([[object toStringButtonSlideView] isEqualToString:NSLocalizedString(@"_FASHIONISTA_POSTS_", nil)])
            //            {
            //                _searchContext = FASHIONISTAPOSTS_SEARCH;
            //
            //                // Show specific title depending on the Search Context
            //                [self setTopBarTitle:NSLocalizedString(([NSString stringWithFormat:@"_VCTITLE_%i_",_searchContext]), nil) andSubtitle:nil];
            //
            //                for (int j = 0; j < [self.searchTermsListView.arrayButtons count]; j++)
            //                {
            //                    if([[self.searchTermsListView.arrayButtons objectAtIndex:j] isKindOfClass:[NSString class]])
            //                    {
            //                        if (([[self.searchTermsListView.arrayButtons objectAtIndex:j] isEqualToString:NSLocalizedString(@"_FASHIONISTAS_", nil)]) || ([[self.searchTermsListView.arrayButtons objectAtIndex:j] isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTAS_", nil)]]))
            //                        {
            //                            [self.searchTermsListView changeButtonText:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(@"_FASHIONISTA_POSTS_", nil)] atIndex:j];
            //                        }
            //                    }
            //                }
            //
            //                if(_filterSearchVC == nil)
            //                {
            //                    // Update search
            //                    [self updateSearchForTermsChanges];
            //                }
            //
            //                return;
            //            }
            
            if(!(appDelegate.currentUser == nil))
            {
                NSMutableArray *stylistFollowingRelationships = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < maxFollowingRelationships; i++)
                {
                    [stylistFollowingRelationships addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)];
                    [stylistFollowingRelationships addObject:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)]];
                }
                
                
                for (int i = 0; i < maxFollowingRelationships; i++)
                {
                    if ([[object toStringButtonSlideView] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)])
                    {
                        _searchStylistRelationships = i;
                        
                        for (int j = 0; j < [self.searchTermsListView.arrayButtons count]; j++)
                        {
                            if ([stylistFollowingRelationships containsObject:[self.searchTermsListView.arrayButtons objectAtIndex:j]])
                            {
                                if([self.searchTermsListView.arrayButtons count] > 1)
                                {
                                    [self.searchTermsListView changeButtonText:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil)] atIndex:j];
                                }
                                else
                                {
                                    [self.searchTermsListView changeButtonText:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",_searchStylistRelationships]), nil) atIndex:j];
                                }
                            }
                        }
                        
                        if(_filterSearchVC == nil)
                        {
                            // Update search
                            if (bPerformSearch)
                                [self updateSearchForTermsChanges];
                        }
                        
                        if (bPerformSearch)
                            return;
                    }
                }
            }
            
            //_searchStylistRelationships = ALLSTYLISTS;
            
            if(_filterSearchVC == nil)
            {
                // Update search
                if (bPerformSearch)
                    [self updateSearchForTermsChanges];
            }
            
            if (bPerformSearch)
                return;
        }
        
        //Add new term(s) to list of terms
        NSString * pene = [[[object toStringButtonSlideView] lowercaseString] capitalizedString];
        if ([object isKindOfClass:[ProductGroup class]])
        {
            pene = ((ProductGroup *)object).name;
        }
        else if ([object isKindOfClass:[Feature class]])
        {
            pene = ((Feature *)object).name;
        }
        else if ([object isKindOfClass:[FeatureGroup class]])
        {
            pene = ((FeatureGroup *)object).name;
        }
        pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        [_successfulTerms addObject: pene];
        
        // Add button
        [self.searchTermsListView addButtonWithObject:object];
        
        if(_filterSearchVC == nil)
        {
            // Update search
            if (bPerformSearch)
            {
                [self updateSearchForTermsChanges];
            }
            else
            {
                if (!bRestartingSearch)
                {
                    // check the search terms
                    if (bCheck)
                    {
                        [self checkSearchTerms:NO];
                    }
                }
            }
        }
    }
    else
    {
        /*
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_TERM_ALREADY_IN_LIST_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
         
         [alertView show];
         */
    }
}


- (void) removeSearchTermAtIndex:(int) iIndex checkSuggestions:(BOOL) bCheck
{
    if((iIndex >= 0) && (iIndex < [_successfulTerms count]))
    {
        [_successfulTerms removeObjectAtIndex:iIndex];
        
        int iFixedButtons = 0;
        
        if(_searchContext == HISTORY_SEARCH)
            iFixedButtons = 1;
        else if(_searchContext == FASHIONISTAS_SEARCH)
            iFixedButtons = 1;
        else if(_searchContext == FASHIONISTAPOSTS_SEARCH)
            iFixedButtons = 1;
        
        [self.searchTermsListView removeButton:iIndex+iFixedButtons];//((_searchContext == HISTORY_SEARCH) ? (iIndex+1) : (iIndex))];
    }
    
    
    
    if(bCheck)
    {
        [self cancelCheckSearchOperations];
        [self checkSearchTerms:NO];
    }
}

-(void) removeFromSearchTermProductGroup:(ProductGroup *)pgDelete checkSearchTerms:(BOOL) bCheckSearchTerms
{
    int iIdx = (int)[self iIdxFilterSelected:pgDelete.app_name];
    if (iIdx > -1)
    {
        [arSelectedSubProductCategory removeObject:pgDelete];
        iNumSubProductCategories--;
        if (iNumSubProductCategories < 0)
            iNumSubProductCategories = 0;
        [self removeSearchTermAtIndex:iIdx checkSuggestions:bCheckSearchTerms];
    }
    else
    {
        iIdx = (int)[self iIdxFilterSelected:pgDelete.name];
        if (iIdx > -1)
        {
            [arSelectedSubProductCategory removeObject:pgDelete];
            iNumSubProductCategories--;
            if (iNumSubProductCategories < 0)
                iNumSubProductCategories = 0;
            [self removeSearchTermAtIndex:iIdx checkSuggestions:bCheckSearchTerms];
        }
    }
}

-(void) hideFilterSearch
{
    [self closeSearchingByFiltersCancelling:NO];
}

-(void)updateCollectionViewFiltersWithPredicate:(NSPredicate *)predicate orEntity:(NSString *)entityPredicate withOrderArray:(NSArray *)_arrSortOrderForSuggestedKeyword andOrdeAscending:(NSArray *)_arrSortAscendingForSuggestedKeyword
{
    if (!bRestartingSearch)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Then set them via the main queue if the cell is still visible.
            NSDate * timingDate = [NSDate date];
            
            if (predicate != nil)
            {
                [self initFetchedResultsControllerForKeywordsForEntity:entityPredicate withPredicateObject:predicate anOrderByArray:_arrSortOrderForSuggestedKeyword ascendingArray:_arrSortAscendingForSuggestedKeyword];
            }
            [self.secondCollectionView setContentOffset:self.secondCollectionView.contentOffset animated:NO];
            [self initOperationsLoadingImages];
            [self.imagesQueue cancelAllOperations];
            [self.secondCollectionView reloadData];
            
            if (bFiltersNew)
            {
                [filterManager showFiltersView:YES];
            }
            else
            {
                [self showKeywordsView:YES];
            }
            
            if ([entityPredicate isEqualToString:@"Brand"])
            {
                if (bFiltersNew)
                {
                    [filterManager initBrandsAlphabet];
                }
                else
                {
                    [self initBrandsAlphabet];
                }
            }
            
            NSLog(@"ShowSuggestedFiltersLocally Time taken: %f", [[NSDate date] timeIntervalSinceDate:timingDate]);
        });
    }
}

#pragma mark - Transitions between View Controllers


// Check if the current view controller must show the slide label
- (BOOL)shouldCreateSlideLabel
{
    return NO;
    // Create the slide label for any ViewController coming from another one, and for the initial LogIn ViewController
    if ([self fromViewController] != nil)
    {
        return YES;
    }
    // KK:
    else
    {
        NSString * backQuery = (NSString*)[_searchQueue lastObject];
        NSString * forwardQuery = (NSString*)[_forwardSearchQueue lastObject];
        if(backQuery || forwardQuery) // We want to get the n-1 search query to pop it
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
}

- (BOOL) shouldCreateBackButton{
    NSString * backQuery = (NSString*)[_searchQueue lastObject];
    return ([self fromViewController] != nil) || backQuery;
}

- (BOOL)shouldCreateForwardButton{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString * forwardQuery = (NSString*)[_forwardSearchQueue lastObject];
    NSNumber * forwardVC = [appDelegate.lastDismissedVCQueue lastObject];
    
    return (forwardQuery || forwardVC);
}

// OVERRIDE: Return the string to be set on the slide label
- (NSString *)stringForSlideLabel
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString * backQuery = (NSString*)[_searchQueue lastObject];
    NSString * forwardQuery = (NSString*)[_forwardSearchQueue lastObject];
    NSNumber * forwardVC = [appDelegate.lastDismissedVCQueue lastObject];
    
    if ([self fromViewController] != nil)
    {
        if(forwardQuery || forwardVC)
        {
            return NSLocalizedString(@"_SLIDEBACKANDFORWARD_LBL_", nil);
        }
        else
        {
            return NSLocalizedString(@"_SLIDEBACK_LBL_", nil);
        }
    }
    else if(backQuery)
    {
        if(forwardQuery || forwardVC)
        {
            return NSLocalizedString(@"_SLIDEBACKANDFORWARD_LBL_", nil);
        }
        else
        {
            return NSLocalizedString(@"_SLIDEBACK_LBL_", nil);
        }
    }
    else if(forwardQuery || forwardVC)
    {
        return NSLocalizedString(@"_SLIDEFORWARD_LBL_", nil);
    }
    else
    {
        return @"";
    }
}

// OVERRIDE: Subtitle button action
- (void)subtitleButtonAction:(UIButton *)sender
{
    if(!(self.getTheLookReferenceProduct == nil))
    {
        if(!(self.getTheLookReferenceProduct.productId == nil))
        {
            if(!([self.getTheLookReferenceProduct.productId isEqualToString:@""]))
            {
                // Perform request to get the result contents
                NSLog(@"Getting contents for product: %@", self.getTheLookReferenceProduct.name);
                
                _selectedResult = _getTheLookReferenceProduct;
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:self.getTheLookReferenceProduct.productId, nil];
                
                [self performRestGet:GET_PRODUCT withParamaters:requestParameters];
                
                return;
            }
        }
    }
    
    [super subtitleButtonAction:sender];
}


// Hide Menu view if the user touches anywhere on the screen
- (void)onTouchBackgroundImage
{
    [self hideFiltersView:YES performSearch:YES];
    
    [self showSuggestedFiltersRibbonAnimated:NO];
    
    if(!([self.mainMenuView isHidden]))
    {
        [self.mainMenuView hideMainMenuViewAnimated: YES];
    }
    
    [[self addTermTextField] resignFirstResponder];
    
    if ((_searchContext == PRODUCT_SEARCH) && ([_resultsArray count] <= 0))
    {
        [self showAddSearchTerm];
    }
}

// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Action to perform when user swipes to right: go to previous screen
- (void)swipeRightAction
{
    
    if (!self.webViewContrainer.hidden) {
        [self closeAvailiabilityDetailView];
        return;
    }
    // get topmost search base view controller
    BaseViewController * topMostController = (BaseViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topMostController.presentedViewController != nil)
    {
        topMostController = (BaseViewController*)topMostController.presentedViewController;
    }
    
    
    if(self != topMostController && self.searchContext != FASHIONISTAS_SEARCH)
    {
        [topMostController swipeRightAction];
        return;
    }
    
    if (bFiltersNew)
    {
        if ([filterManager zoomViewVisible])
        {
            [filterManager hideZoomView];
            return;
        }
    }
    else
    {
        if (self.zoomBackgroundView.hidden == NO)
        {
            [self hideZoomView];
            
            return;
        }
    }
    
    if(!([self.hintBackgroundView isHidden]))
    {
        [self hintPrevAction:nil];
        
        return;
    }
    
    [self hideFiltersView:YES];
    
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        [self closeAddingItemToWardrobeHighlightingButton:nil withSuccess:NO];
    }
    else if(!([_filterSearchVCContainerView isHidden]))
    {
        [self closeSearchingByFiltersCancelling:NO];
    }
    //    else if (!(self.parentViewController == nil))
    //    {
    //        if ([[self parentViewController] isKindOfClass: [FashionistaPostViewController class]])
    //        {
    //            [((FashionistaPostViewController *)[self parentViewController]) closeAddingProductsToContentWithSuccess:YES];
    //        }
    //    }
    else if (([self.selectFeaturesView isHidden] == NO) && (_currentSearchQuery != nil))
    {
        [self hideFiltersView:YES];
        int iNumResults = [self iGetSearchNumResults];
        
        NSString * subTitle = nil;
        
        //if(!(_searchContext == FASHIONISTAS_SEARCH || _searchContext == FASHIONISTAPOSTS_SEARCH))
        {
            if(iNumResults > 0)
            {
                if(iNumResults >= 1000)
                {
                    subTitle = [NSString stringWithFormat:NSLocalizedString(@"_MORETHAN1000_RESULTS_", nil), iNumResults];
                }
                else
                {
                    if(iNumResults > 1)
                    {
                        subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULTS_", nil), iNumResults];
                    }
                    else
                    {
                        subTitle = [NSString stringWithFormat:NSLocalizedString(@"_NUM_RESULT_", nil), iNumResults];
                    }
                }
            }
            else
            {
                subTitle = NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil);
            }
        }
        
        [self setTopBarTitle:nil andSubtitle:subTitle];
        
        [self.searchTermsListView restoreLastState];
        [self.successfulTerms removeAllObjects];
        unsigned long iNumTerms = [self.searchTermsListView count];
        for (int iIdx = 0; iIdx < iNumTerms; iIdx ++)
        {
            NSString * sTerm = [self.searchTermsListView sGetNameButtonByIdx:iIdx];
            [self.successfulTerms addObject:sTerm];
        }
        
        [self getSuggestedFilters];
        
        [self.SuggestedFiltersRibbonView unselectButtons];
    }
    else
    {
        // We will preserve a search history queue and we will navigate back through it until it is empty
        NSString * query = (NSString*)[_searchQueue lastObject];
        if(query) // We want to get the n-1 search query to pop it
        {
            [_forwardSearchQueue addObject:query];
            [_searchQueue removeObject:query];
            query = (NSString*)[_searchQueue lastObject];
        }
        
        if(query) // Ok, we have a search query, perform it
        {
            // Empty old results array
            [_resultsArray removeAllObjects];
            
            // Empty old results groups array
            [_resultsGroups removeAllObjects];
            
            _currentSearchQuery = nil;
            
            [_searchQueue removeObject:query];
            if ([query isEqualToString:@""])
            {
                [self restartSearch];
            }
            else
            {
                bComingFromSwipeSearchNavigation = YES;
                [self performSearchWithString:query];
            }
        }
        else
        {
            if(self.fromViewController != nil)
            {
                //[self hideFiltersView:YES];
                [super swipeRightAction];
            }
            else
            {
                [self restartSearch];
                
                //if ((self.parentViewController == nil))
                {
                    if((_searchContext == PRODUCT_SEARCH) && (self.fromViewController == nil))
                    {
                        [self createBottomControls];
                    }
                }
            }
        }
        
    }
}

// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Action to perform when user swipes to right: go to previous screen
- (void)swipeLeftAction
{
    if (bFiltersNew)
    {
        if ([filterManager zoomViewVisible])
        {
            return;
        }
    }
    else
    {
        if (self.zoomBackgroundView.hidden == NO)
        {
            return;
        }
    }
    
    if(!([self.hintBackgroundView isHidden]))
    {
        [self hintNextAction:nil];
        
        return;
    }
    
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        [self closeAddingItemToWardrobeHighlightingButton:nil withSuccess:NO];
        
        return;
    }
    else if(!([_filterSearchVCContainerView isHidden]))
    {
        return;
    }
    else if (([self.selectFeaturesView isHidden] == NO) && (_currentSearchQuery != nil))
    {
        return;
    }
    else
    {
        // We will preserve a search history queue and we will navigate back through it until it is empty
        NSString * query = (NSString*)[_forwardSearchQueue lastObject];
        
        if(query) // Ok, we have a search query, perform it
        {
            // Empty old results array
            [_resultsArray removeAllObjects];
            
            // Empty old results groups array
            [_resultsGroups removeAllObjects];
            
            _currentSearchQuery = nil;
            
            [_forwardSearchQueue removeObject:query];
            
            if ([query isEqualToString:@""])
            {
                [self restartSearch];
                
                return;
            }
            else
            {
                bComingFromSwipeSearchNavigation = YES;
                [self performSearchWithString:query];
                
                return;
            }
        }
    }
    
    [super swipeLeftAction];
}

/*
 // OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Left action
 - (void)leftAction:(UIButton *)sender
 {
 [self hideFiltersView:YES];
 
 if(!([_addToWardrobeVCContainerView isHidden]))
 {
 return;
 }
 
 if(![[self activityIndicator] isHidden])
 {
 return;
 }
 
 if(!([_filterSearchVCContainerView isHidden]))
 {
 {
 [self closeSearchingByFiltersCancelling:YES];
 }
 
 return;
 }
 
 if(!(_addingProductsToWardrobeID == nil))
 {
 if(!_bAddingProductsToPostContentWardrobe)
 {
 if (!(self.parentViewController == nil))
 {
 if ([[self parentViewController] isKindOfClass: [FashionistaPostViewController class]])
 {
 [((FashionistaPostViewController *)[self parentViewController]) closeAddingProductsToContentWithSuccess:YES];
 
 return;
 }
 }
 }
 }
 
 if((!(_searchContext == PRODUCT_SEARCH)) && (!(_searchContext == FASHIONISTAS_SEARCH)))
 {
 if (!([self.searchTermsListView count] > 0))
 {
 // El botón izquierdo se mantendrá por defecto, en este caso POST
 [super leftAction:sender];
 }
 else
 {
 // El botón izquierdo será para limpiar la búsqueda
 [self restartSearch];
 }
 }
 else
 {
 // El botón izquierdo se mantendrá por defecto, en este caso POST
 [super leftAction:sender];
 }
 }
 */
// Confirmation for cancelling filters search
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
    {
        if ([alertView.title isEqualToString:NSLocalizedString(@"_CANCELFILTERSEARCH_", nil)])
        {
            [self closeSearchingByFiltersCancelling:YES];
        }
        else if ([alertView.title isEqualToString:NSLocalizedString(@"_CANCELFILTERSEARCHANDGO_", nil)])
        {
            [self closeSearchingByFiltersCancelling:YES];
            
            [super actionForMainSecondCircleMenuEntry];
        }
        else if ([alertView.title isEqualToString:NSLocalizedString(@"_RESTARTSEARCH_", nil)])
        {
            [self restartSearch];
        }
    }
}

// OVERRIDE: Circle menu action: might be overriden to have a particular action within each ViewController
-(void) actionForMainFirstCircleMenuEntry
{
    [self hideFiltersView:YES];
    [self addTermAction:nil];
}

// OVERRIDE: Circle menu action: might be overriden to have a particular action within each ViewController
-(void) actionForMainSecondCircleMenuEntry
{
    [self hideFiltersView:YES];
    if(!(_addingProductsToWardrobeID == nil))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_", nil) message:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    if(!([_filterSearchVCContainerView isHidden]))
    {
        /*
         if(!([_searchTermsBeforeUpdate isEqualToArray:_successfulTerms]))
         {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELFILTERSEARCHANDGO_", nil) message:NSLocalizedString(@"_CANCELFILTERSEARCH_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_BACK_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
         
         [alertView show];
         
         return;
         }
         else*/
        {
            [self closeSearchingByFiltersCancelling:YES];
        }
    }
    
    [self transitionToViewController:VISUALSEARCH_VC withParameters:nil];
}

// OVERRIDE: Circle menu action: might be overriden to have a particular action within each ViewController
-(void) actionForMainThirdCircleMenuEntry
{
    [self hideFiltersView:YES];
    [self featuresSearchAction:nil];
}

// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Right action
- (void)rightAction:(UIButton *)sender
{
    if(self.searchContext!=FASHIONISTAS_SEARCH&&self.searchContext!=TRENDING_SEARCH&&self.searchContext!=HISTORY_SEARCH){
        if(!([_addToWardrobeVCContainerView isHidden]))
        {
            return;
        }
        
        if(!([_filterSearchVCContainerView isHidden]))
        {
            [self closeSearchingByFiltersCancelling:NO];
            
            return;
        }
        
        if(![[self activityIndicator] isHidden])
        {
            return;
        }
        
        //if (!([self.searchTermsListView count] > 0))
        if ([self.searchTermsListView sameFromLastState])
        {
            [self addTermAction:nil];
            
            return;
        }
        
        if (_searchContext == BRANDS_SEARCH)
        {
            [self addTermAction:nil];
            
            return;
        }
        
        //    if(_searchContext == HISTORY_SEARCH)
        //    {
        //        if ((!([self.searchTermsListView count] > 0)) || (([self.searchTermsListView count] == 1) && (([[self.searchTermsListView.arrayButtons objectAtIndex:0] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",TODAY]), nil)]))))
        //        {
        //            return;
        //        }
        //    }
        //    else if(_searchContext == FASHIONISTAPOSTS_SEARCH)
        //    {
        //        if ((!([self.searchTermsListView count] > 0)) || ((([self.searchTermsListView count] == 2) && (([[self.searchTermsListView.arrayButtons objectAtIndex:0] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",ALLPOSTS]), nil)]))) && ((([self.searchTermsListView count] == 2) && (([[self.searchTermsListView.arrayButtons objectAtIndex:1] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",ALLSTYLISTS]), nil)]))))))
        //        {
        //            return;
        //        }
        //    }
        //    else if(_searchContext == FASHIONISTAS_SEARCH)
        //    {
        //        if ((!([self.searchTermsListView count] > 0)) || (([self.searchTermsListView count] == 1) && (([[self.searchTermsListView.arrayButtons objectAtIndex:0] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",ALLSTYLISTS]), nil)]))))
        //        {
        //            return;
        //        }
        //    }
        
        // TODO - Test
        
        NSString * key = [NSString stringWithFormat:@"HIGHLIGHTSEARCH_%d", [self.restorationIdentifier intValue]];
        
        if([self isKindOfClass:[SearchBaseViewController class]])
        {
            SearchBaseViewController * s = (SearchBaseViewController*)self;
            int iContext = s.searchContext;
            key = [NSString stringWithFormat:@"HIGHLIGHTSEARCH_%d_%d", [self.restorationIdentifier intValue], iContext];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Save into defaults if doesn't already exists
        if (!([defaults objectForKey:key]))
        {
            [defaults setInteger:1 forKey:key];
            
            [defaults synchronize];
        }
        else
        {
            int iNumSearches = (int)[defaults integerForKey:key];
            
            [defaults setInteger:(iNumSearches+1) forKey:key];
            
            [defaults synchronize];
        }
        
        [self updateSearchForTermsChanges];
        [self hideFiltersView:YES];
        return;
        
        // TODO: Ojo! he cambiado el alert por la accion directa
        
        [self restartSearch];
    }else{
        [super rightAction:sender];
    }
}
#ifndef ADD_OSAMA
- (void)searchProduct
{
    [self rightAction:nil];
}
#endif

- (void)restartSearch
{
    [self restartSearchForcing:NO];
}

- (void)restartSearchForcing:(BOOL) bForce
{
    bRestartingSearch = YES;
    [_categoryTerms removeAllObjects];
    if (bFiltersNew)
    {
        [filterManager restartSearch];
    }
    else
    {
        //    iGenderSelected = 0;
        selectedProductCategory = nil;
        iNumSubProductCategories = 0;
        [arSelectedSubProductCategory removeAllObjects];
        iLastSelectedSlide = 0;
        sLastSelectedSlide = @"";
    }
    
    [self hideFiltersView:YES];
    
    if(_searchContext == HISTORY_SEARCH)
    {
        if ((!([self.searchTermsListView count] > 0)) || (([self.searchTermsListView count] == 1) && (([[self.searchTermsListView.arrayButtons objectAtIndex:0] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",TODAY]), nil)]))))
        {
            return;
        }
    }
    else if((_searchContext == FASHIONISTAPOSTS_SEARCH) && (!(bForce)))
    {
        //if ((!([self.searchTermsListView count] > 0)) || ((([self.searchTermsListView count] == 2) && (([[self.searchTermsListView.arrayButtons objectAtIndex:0] isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"_SEARCHTERMS_SEPARATOR_", nil), NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",ALLPOSTS]), nil)]]))) && ((([self.searchTermsListView count] == 2) && (([[self.searchTermsListView.arrayButtons objectAtIndex:1] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",ALLSTYLISTS]), nil)]))))))
        if ((!([self.searchTermsListView count] > 0)) || (((([self.searchTermsListView count] == 1) && (([[self.searchTermsListView.arrayButtons objectAtIndex:0] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",ALLSTYLISTS]), nil)]))))))
        {
            return;
        }
    }
    else if((_searchContext == FASHIONISTAS_SEARCH) && (!(bForce)))
    {
        if ((!([self.searchTermsListView count] > 0)) || (([self.searchTermsListView count] == 1) && (([[self.searchTermsListView.arrayButtons objectAtIndex:0] isEqualToString:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",ALLSTYLISTS]), nil)]))))
        {
            return;
        }
    }
    
    if ((!([self.searchTermsListView count] > 0)) && (!([_resultsArray count] > 0)))
    {
        [self getBackgroundAdForCurrentUser];
        
        [self showAddSearchTerm];
        
        [self.searchTermsListView setLastState];
        
        bRestartingSearch = NO;
        
        filterManager.bRestartingSearch = NO;
        
        return;
    }
    
    if(!(_searchContext == STYLES_SEARCH))
    {
        NSString * subTitle = nil;
        
        //if(!(_searchContext == FASHIONISTAS_SEARCH || _searchContext == FASHIONISTAPOSTS_SEARCH))
        {
            subTitle = NSLocalizedString(@"_NO_SEARCH_KEYWORDS_MSG_", nil);
        }
        
        // Show specific title depending on the Search Context
        [self setTopBarTitle:nil andSubtitle:subTitle];
    }
    
    // Empty successful terms array
    [self.successfulTerms removeAllObjects];
    [self.searchTermsListView removeAllButtons];
    
    if (bFiltersNew)
    {
        [filterManager initFilters];
    }
    else
    {
        [self.suggestedFilters removeAllObjects];
        [self.suggestedFiltersObject removeAllObjects];
    }
    
    // Empty not successful terms string
    self.notSuccessfulTerms = @"";
    [self setNotSuccessfulTermsText:@""];
    
    // Hide Filter Terms Label
    [self.noFilterTermsLabel setHidden:YES];
    
    int resultsBeforeUpdate = (int) [_resultsArray count];
    
    // Empty old results array
    [_resultsArray removeAllObjects];
    
    // Empty old results array
    [_resultsGroups removeAllObjects];
    
    _currentSearchQuery = nil;
    
    // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
    if ([self getFetchedResultsControllerForCellType:@"ResultCell" ] == nil)
    {
        [self initFetchedResultsController];
    }
    
    // Update Fetched Results Controller
    [self performFetchForCollectionViewWithCellType:@"ResultCell"];
    
    // Update collection view
    [self updateCollectionViewWithCellType:@"ResultCell" fromItem:0 toItem:resultsBeforeUpdate deleting:TRUE];
    
    [self setBackgroundImage];
    
    // Set TODAY as the default selected history period
    _searchPeriod = TODAY;
    
    // Set 'Any' as the default selected type of post to retrieve
    _searchPostType = ALLPOSTS;
    
    // Set ALL as the default relationships filter for stylists search
    _searchStylistRelationships = ALLSTYLISTS;
    
    if (bFiltersNew)
    {
        [filterManager initFoundSuggestions];
    }
    else
    {
        if (self.foundSuggestions != nil)
        {
            [self.foundSuggestions removeAllObjects];
        }
        if(self.foundSuggestionsPC != nil)
        {
            [self.foundSuggestionsPC removeAllObjects];
        }
    }
    
    switch (_searchContext)
    {
        case HISTORY_SEARCH:
        case BRANDS_SEARCH:
        case TRENDING_SEARCH:
        case FASHIONISTAPOSTS_SEARCH:
        case FASHIONISTAS_SEARCH:
        case STYLES_SEARCH:
            
            [self performSearch];
            
            break;
            
        case PRODUCT_SEARCH:
            
            // cancel the request for getting the suggested keyword from a search, because in this point the suggested keyword are the product categories
            [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:[self getPatternForConnectionType:GET_SEARCH_SUGGESTEDFILTERKEYWORDS intendedForStringFormat:NO]];
            //            [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
            
            [self getBackgroundAdForCurrentUser];
            
            [self getSuggestedFilters];
            
            [self showAddSearchTerm];
            
            break;
            
        default:
            break;
    }
    
    [self.searchTermsListView setLastState];
    
    [self updateBottomBarSearch];
    
    bRestartingSearch = NO;
    filterManager.bRestartingSearch = NO;
}

// OVERRIDE: To control the case when the user is adding products to a post content wardrobe
- (void)showMainMenu:(UIButton *)sender
{
    [self hideFiltersView:YES];
    if((!(sender == nil)) && (!(_addingProductsToWardrobeID == nil)))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_", nil) message:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }
    else
    {
        [super showMainMenu:sender];
    }
}
/*
 - (void)middleLeftAction:(UIButton *)sender
 {
 //    if ([self.selectFeaturesView isHidden] == NO)
 //    {
 //        return;
 //    }
 
 [self hideFiltersView:YES];
 
 if(!([_addToWardrobeVCContainerView isHidden]))
 {
 return;
 }
 
 if(![[self activityIndicator] isHidden])
 {
 return;
 }
 
 if(!([_filterSearchVCContainerView isHidden]))
 {
 {
 [self closeSearchingByFiltersCancelling:YES];
 }
 
 return;
 }
 
 //    if(!(_addingProductsToWardrobeID == nil))
 //    {
 //        if(!_bAddingProductsToPostContentWardrobe)
 //        {
 //            if (!(self.parentViewController == nil))
 //            {
 //                if ([[self parentViewController] isKindOfClass: [FashionistaPostViewController class]])
 //                {
 //                    [((FashionistaPostViewController *)[self parentViewController]) closeAddingProductsToContentWithSuccess:YES];
 //
 //                    return;
 //                }
 //            }
 //        }
 //    }
 
 if (_searchContext == PRODUCT_SEARCH)
 {
 [self restartSearch];
 }
 else
 {
 [super middleLeftAction:sender];
 }
 }
 
 - (void)middleRightAction:(UIButton *)sender
 {
 //    if ([self.selectFeaturesView isHidden] == NO)
 //    {
 //        return;
 //    }
 
 [self hideFiltersView:YES];
 
 if(!([_addToWardrobeVCContainerView isHidden]))
 {
 return;
 }
 
 if(![[self activityIndicator] isHidden])
 {
 return;
 }
 
 if(!([_filterSearchVCContainerView isHidden]))
 {
 {
 [self closeSearchingByFiltersCancelling:YES];
 }
 
 return;
 }
 
 if(!(_addingProductsToWardrobeID == nil))
 {
 if(!_bAddingProductsToPostContentWardrobe)
 {
 if (!(self.parentViewController == nil))
 {
 if ([[self parentViewController] isKindOfClass: [FashionistaPostViewController class]])
 {
 [((FashionistaPostViewController *)[self parentViewController]) closeAddingProductsToContentWithSuccess:YES];
 
 return;
 }
 }
 }
 }
 
 if (_searchContext == FASHIONISTAPOSTS_SEARCH)
 {
 [self restartSearch];
 }
 else if (_searchContext == FASHIONISTAS_SEARCH)
 {
 [self switchToPostSearch:nil];
 }
 else
 {
 [super middleRightAction:sender];
 }
 }
 */

#pragma mark - Test Login

// User delegate: log in
// Peform an action once the user logs in
- (void)actionAfterLogIn
{
    [super actionAfterLogIn];
    // Initialize the filter terms ribbon
    //    [self initSuggestedFilters];
//    [self startLoadingInfoFilterFromServer];
    
    // Reload User Wardrobes
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //
    //    [appDelegate getSearchKeywords];
    
    NSDictionary* userInfo = @{@"total": @"actionAfterLogIn"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
    
    if(!(_addingProductsToWardrobeID == nil))
    {
        
    }
    else if (!(appDelegate.currentUser == nil))
    {
        // Reload User Wardrobes & Follows
        
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
//                                return;// TO REGENERATE LAST COREDATA FILES!!!
                // ALSO SET RETURN IN 'getCurrentUserInitialData'
                // ALSO SET DATA = NIL IN 'getInitialDB'
                // ALSO SET RETURN IN SearchBaseViewController::'viewWillAppear'
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                
                [self performRestGet:GET_USER_WARDROBES withParamaters:requestParameters];
                
                [self performRestGet:GET_USER_FOLLOWS withParamaters:requestParameters];
                
                [self performRestGet:GET_USER_NOTIFICATIONS withParamaters:requestParameters];
            }
        }
    }
    
    return;
}
- (void)actionAfterAutoLogIn
{
    [self updateUsernameLabel];
    // Initialize the filter terms ribbon
//    [self startLoadingInfoFilterFromServer];
    
    // Reload User Wardrobes
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //
    //    [appDelegate getSearchKeywords];
    
    NSDictionary* userInfo = @{@"total": @"actionAfterLogIn"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
    
    if(!(_addingProductsToWardrobeID == nil))
    {
        
    }
    else if (!(appDelegate.currentUser == nil))
    {
        if(([appDelegate.currentUser.isFashionista boolValue]) == YES)
        {
            
        }
        
        // Reload User Wardrobes & Follows
        
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
//                                return;// TO REGENERATE LAST COREDATA FILES!!!
                // ALSO SET RETURN IN 'getCurrentUserInitialData'
                // ALSO SET DATA = NIL IN 'getInitialDB'
                // ALSO SET RETURN IN SearchBaseViewController::'viewWillAppear'
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                
                [self performRestGet:GET_USER_WARDROBES withParamaters:requestParameters];
                
                [self performRestGet:GET_USER_FOLLOWS withParamaters:requestParameters];
                
                //[self performRestGet:GET_USER_NOTIFICATIONS withParamaters:requestParameters];
            }
        }
    }
    
    return;
}

// Peform an action once the user logs in
- (void)actionAfterLogInWithError
{
    [super actionAfterLogInWithError];
    
//    [self startLoadingInfoFilterFromServer];
    NSDictionary* userInfo = @{@"total": @"actionAfterLogInWithError"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.bAutoLogin)
    {
        if ((appDelegate.bLoadingFilterInfo) && (appDelegate.bLoadedFilterInfo == NO))
            appDelegate.bLoadingFilterInfo = NO;
    }
    
    
    // Initialize the filter terms ribbon
    //    [self initSuggestedFilters];
    
    
    //    [appDelegate getSearchKeywords];
    
    return;
}

// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    
    if (_searchContext == HISTORY_SEARCH)
    {
        return;
    }
    else
    {
        [self closeAddingItemToWardrobeHighlightingButton:nil withSuccess:NO];
    }
}

#pragma mark - Get keywords

-(void) initStructuresForSuggestedKeywords
{
    if (_productGroupsParentForSuggestedKeywords != nil)
    {
        [_productGroupsParentForSuggestedKeywords removeAllObjects];
    }
    else
    {
        _productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
    }
    
    if (arrayFeaturesPrices != nil)
    {
        [arrayFeaturesPrices removeAllObjects];
    }
    else
    {
        arrayFeaturesPrices = [[NSMutableArray alloc] init];
    }
    
    if (_successfulTermProductCategory != nil)
    {
        [_successfulTermProductCategory removeAllObjects];
    }
    else
    {
        _successfulTermProductCategory = [[NSMutableArray alloc]init];
    }
    
    if (_successfulTermIdProductCategory != nil)
    {
        [_successfulTermIdProductCategory removeAllObjects];
    }
    else
    {
        _successfulTermIdProductCategory = [[NSMutableArray alloc]init];
    }
    
    if (selectedProductCategory != nil)
    {
        //        [_successfulTermProductCategory addObject:selectedProductCategory];
        //        [_successfulTermIdProductCategory addObject:selectedProductCategory.idProductGroup];
        if (_searchContext == PRODUCT_SEARCH)
        {
            NSMutableArray * arDescendants = [selectedProductCategory getAllDescendants];
            for(ProductGroup * pg in arDescendants)
            {
                [_successfulTermProductCategory addObject:pg];
                [_successfulTermIdProductCategory addObject:pg.idProductGroup];
            }
        }
        else
        {
            for (ProductGroup * pgParent in arSelectedProductCategories)
            {
                NSMutableArray * arDescendants = [pgParent getAllDescendants];
                for(ProductGroup * pg in arDescendants)
                {
                    [_successfulTermProductCategory addObject:pg];
                    [_successfulTermIdProductCategory addObject:pg.idProductGroup];
                }
            }
        }
        
    }
    
}

-(Keyword *) getKeywordFromName:(NSString *)name
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    NSString *regexString  = [NSString stringWithFormat:@"%@", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Keyword" andPredicate:@"name matches[cd] %@" withString:regexString sortingWithKey:@"idKeyword" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Keyword * tmpKeyword = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
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

-(Keyword *) getKeywordFromId:(NSString *)idKeyword
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    NSString *regexString  = idKeyword; //[NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Keyword" andPredicate:@"idKeyword = %@" withString:regexString sortingWithKey:@"idKeyword" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Keyword * tmpKeyword = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
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

-(ProductGroup *) getProductGroupFromName:(NSString *) name
{
    if (bLoadedProductCategories)
    {
        ProductGroup * tmpProductGroup = [dictProductCategoriesByName objectForKey:name];
        if (tmpProductGroup == nil)
        {
            tmpProductGroup = [dictProductCategoriesByAppName objectForKey:name];
        }
        
        if (tmpProductGroup != nil)
        {
            ProductGroup * productGroupParent = [tmpProductGroup getTopParent];
            
            if (_productGroupsParentForSuggestedKeywords == nil)
            {
                _productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
            }
            
            if (![_productGroupsParentForSuggestedKeywords containsObject:productGroupParent])
                [_productGroupsParentForSuggestedKeywords addObject:productGroupParent];
            
            
            return tmpProductGroup;
        }
        
        return nil;
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //    NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idProductGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        if ([[keywordsFetchedResultsController fetchedObjects] count] == 0)
        {
            keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"app_name matches[cd] %@" withString:name sortingWithKey:@"idProductGroup" ascending:YES];
            
        }
        
        
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProductGroup == nil))
            {
                if(!(tmpProductGroup.idProductGroup == nil))
                {
                    if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
                    {
                        ProductGroup * productGroupParent = [tmpProductGroup getTopParent];
                        
                        if (_productGroupsParentForSuggestedKeywords == nil)
                        {
                            _productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
                        }
                        
                        if (![_productGroupsParentForSuggestedKeywords containsObject:productGroupParent])
                            [_productGroupsParentForSuggestedKeywords addObject:productGroupParent];
                        
                        
                        //                        if (tmpProductGroup.parent != nil)
                        //                            return tmpProductGroup.parent;
                        //
                        //                        return productGroupParent;
                        
                        return tmpProductGroup;
                    }
                }
            }
        }
    }
    return nil;
}

-(ProductGroup *) getProductGroupParentFromId:(NSString *) idProductGroup
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //    NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idProductGroup" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"idProductGroup = %@" withString:idProductGroup sortingWithKey:@"idProductGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProductGroup == nil))
            {
                if(!(tmpProductGroup.idProductGroup == nil))
                {
                    if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
                    {
                        ProductGroup * productGroupParent = [tmpProductGroup getTopParent];
                        
                        if (_productGroupsParentForSuggestedKeywords == nil)
                        {
                            _productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
                        }
                        
                        if (![_productGroupsParentForSuggestedKeywords containsObject:productGroupParent])
                            [_productGroupsParentForSuggestedKeywords addObject:productGroupParent];
                        
                        
                        //                        if (tmpProductGroup.parent != nil)
                        //                            return tmpProductGroup.parent;
                        
                        return productGroupParent;
                    }
                }
            }
        }
    }
    return nil;
}

-(ProductGroup *) getProductGroupFromId:(NSString *) idProductGroup
{
    if (bLoadedProductCategories)
    {
        return [dictProductCategoriesById objectForKey:idProductGroup];
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //    NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idProductGroup" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"idProductGroup = %@" withString:idProductGroup sortingWithKey:@"idProductGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProductGroup == nil))
            {
                if(!(tmpProductGroup.idProductGroup == nil))
                {
                    if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
                    {
                        return tmpProductGroup;
                        //                        ProductGroup * productGroupParent = [tmpProductGroup getTopParent];
                        //
                        //                        if (_productGroupsParentForSuggestedKeywords == nil)
                        //                        {
                        //                            _productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
                        //                        }
                        //
                        //                        if (![_productGroupsParentForSuggestedKeywords containsObject:productGroupParent])
                        //                            [_productGroupsParentForSuggestedKeywords addObject:productGroupParent];
                        //
                        //
                        //                        //                        if (tmpProductGroup.parent != nil)
                        //                        //                            return tmpProductGroup.parent;
                        //
                        //                        return productGroupParent;
                    }
                }
            }
        }
    }
    return nil;
}
-(void) getAllProductGroupsToDict
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"NOT (idProductGroup = %@)" withString:@"0" sortingWithKey:@"idProductGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProductGroup == nil))
            {
                if(!(tmpProductGroup.idProductGroup == nil))
                {
                    if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
                    {
                        [dictProductCategoriesById setObject:tmpProductGroup forKey:tmpProductGroup.idProductGroup];
                        [dictProductCategoriesByName setObject:tmpProductGroup forKey:tmpProductGroup.name];
                        [dictProductCategoriesByAppName setObject:tmpProductGroup forKey:tmpProductGroup.app_name];
                    }
                }
            }
        }
    }
}

-(Brand *) getBrandFromName:(NSString *)name
{
    if (bLoadedBrands)
    {
        Brand * tmpBrand = [dictBrandsByName objectForKey:name];
        return tmpBrand;
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpBrand == nil))
            {
                if(!(tmpBrand.idBrand == nil))
                {
                    if(!([tmpBrand.idBrand isEqualToString:@""]))
                    {
                        return tmpBrand;
                    }
                }
            }
        }
    }
    return nil;
}

-(Brand *) getBrandFromId:(NSString *)idBrand
{
    if (bLoadedBrands)
    {
        return [dictBrandsById objectForKey:idBrand];
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"idBrand = %@" withString:idBrand sortingWithKey:@"idBrand" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpBrand == nil))
            {
                if(!(tmpBrand.idBrand == nil))
                {
                    if(!([tmpBrand.idBrand isEqualToString:@""]))
                    {
                        return tmpBrand;
                    }
                }
            }
        }
    }
    return nil;
}
-(NSMutableArray *) getAllBrands
{
    NSMutableArray * arrAllbrands = [[NSMutableArray alloc] init];
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"NOT (idBrand = %@)" withString:@"0" sortingWithKey:@"idBrand" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpBrand == nil))
            {
                if(!(tmpBrand.idBrand == nil))
                {
                    if(!([tmpBrand.idBrand isEqualToString:@""]))
                    {
                        [arrAllbrands addObject:tmpBrand];
                    }
                }
            }
        }
    }
    return arrAllbrands;
}

-(void) getAllBrandsToDict
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"NOT (idBrand = %@)" withString:@"0" sortingWithKey:@"idBrand" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpBrand == nil))
            {
                if(!(tmpBrand.idBrand == nil))
                {
                    if(!([tmpBrand.idBrand isEqualToString:@""]))
                    {
                        [dictBrandsById setObject:tmpBrand forKey:tmpBrand.idBrand];
                        [dictBrandsByName setObject:tmpBrand forKey:tmpBrand.name];
                    }
                }
            }
        }
    }
}

-(Feature *)getFeatureFromId:(NSString *)idFeature
{
    if (bLoadedFeatures)
    {
        return [dictFeaturesById objectForKey:idFeature];
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicate:@"idFeature = %@" withString:idFeature sortingWithKey:@"idFeature" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeature == nil))
            {
                if(!(tmpFeature.idFeature == nil))
                {
                    if(!([tmpFeature.idFeature isEqualToString:@""]))
                    {
                        return tmpFeature;
                    }
                }
            }
        }
    }
    return nil;
}
-(Feature *)getFeatureFromName:(NSString *)sName
{
    if (bLoadedFeatures)
    {
        Feature * tmpFeature = [dictFeaturesByName objectForKey:sName];
        return tmpFeature;
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicate:@"name matches[cd] %@" withString:sName sortingWithKey:@"idFeature" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeature == nil))
            {
                if(!(tmpFeature.idFeature == nil))
                {
                    if(!([tmpFeature.idFeature isEqualToString:@""]))
                    {
                        return tmpFeature;
                    }
                }
            }
        }
    }
    return nil;
}

-(void) getAllFeaturesToDict
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicate:@"NOT (idFeature = %@)" withString:@"0" sortingWithKey:@"idFeature" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeature == nil))
            {
                if(!(tmpFeature.idFeature == nil))
                {
                    if(!([tmpFeature.idFeature isEqualToString:@""]))
                    {
                        [dictFeaturesById setObject:tmpFeature forKey:tmpFeature.idFeature];
                        [dictFeaturesByName setObject:tmpFeature forKey:tmpFeature.name];
                    }
                }
            }
        }
    }
}

-(FeatureGroup *) getFeatureGroupFromFeatureName:(NSString *) name
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    if([name isEqualToString:@"< $50"] || [name isEqualToString:@"$50-$200"]  || [name isEqualToString:@"$200$-$500"]  || [name isEqualToString:@"> $500"] )
    {
        keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:@"Price" sortingWithKey:@"idFeatureGroup" ascending:YES];
        if (!(keywordsFetchedResultsController == nil))
        {
            for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
            {
                FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
                
                if(!(tmpFeatureGroup == nil))
                {
                    if(!(tmpFeatureGroup.idFeatureGroup == nil))
                    {
                        if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                        {
                            for (Feature *f in tmpFeatureGroup.features)
                            {
                                if ([f.name isEqualToString:name])
                                {
                                    [arrayFeaturesPrices addObject:f.idFeature];
                                    break;
                                }
                            }
                            //if ([self isFeatureGroup:tmpFeatureGroup inProductGroups:_productGroupsParentForSuggestedKeywords])
                            return tmpFeatureGroup;
                        }
                    }
                }
            }
        }
    }
    
    
    //    NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idFeature" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeature == nil))
            {
                if(!(tmpFeature.idFeature == nil))
                {
                    if(!([tmpFeature.idFeature isEqualToString:@""]))
                    {
                        if ([_productGroupsParentForSuggestedKeywords count] > 0)
                        {
                            if ([self isFeatureGroup:[tmpFeature.featureGroup getTopParent] inProductGroups:_productGroupsParentForSuggestedKeywords])
                                return [tmpFeature.featureGroup getTopParent];
                        }
                        else
                        {
                            return [tmpFeature.featureGroup getTopParent];
                        }
                        //                        return tmpFeature.featureGroup;
                    }
                }
            }
        }
    }
    return nil;
}

-(FeatureGroup *)getFeatureGroupFromId:(NSString *)idFeatureGroup
{
    if (bLoadedFeaturesGroups)
    {
        return [dictFeatureGroupsById objectForKey:idFeatureGroup];
    }
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"idFeatureGroup = %@" withString:idFeatureGroup sortingWithKey:@"idFeatureGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        return tmpFeatureGroup;
                    }
                }
            }
        }
    }
    return nil;
}

-(FeatureGroup *)getFeatureGroupFromName:(NSString *)name
{
    if (bLoadedFeaturesGroups)
    {
        FeatureGroup * tmpFeatureGroup = [dictFeatureGroupsByName objectForKey:name];
        return tmpFeatureGroup;
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idFeatureGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        return tmpFeatureGroup;
                    }
                }
            }
        }
    }
    return nil;
}

-(void) getAllFeatureGroupsToDict
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"NOT (idFeatureGroup = %@)" withString:@"0" sortingWithKey:@"idFeatureGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        if (tmpFeatureGroup.name != nil)
                        {
                            [dictFeatureGroupsById setObject:tmpFeatureGroup forKey:tmpFeatureGroup.idFeatureGroup];
                            FeatureGroup * fg = [dictFeatureGroupsByName objectForKey:tmpFeatureGroup.name];
                            if (fg == nil)
                            {
                                [dictFeatureGroupsByName setObject:tmpFeatureGroup forKey:tmpFeatureGroup.name];
                            }
                            else
                            {
                                NSLog(@"Feature: %@ - %@ - %@", tmpFeatureGroup.name, tmpFeatureGroup.idFeatureGroup, fg.idFeatureGroup);
                            }
                        }
                    }
                }
            }
        }
    }
}


// Initialize a specific Fetched Results Controller to fetch the local keywords in order to force user to select one
- (NSFetchedResultsController *)fetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate withString:(NSString *)stringForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    NSFetchRequest * keywordssFetchRequest = nil;
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    if (keywordssFetchRequest == nil)
    {
        if(!(stringForPredicate == nil))
        {
            if(!([stringForPredicate isEqualToString:@""]))
            {
                keywordssFetchRequest = [[NSFetchRequest alloc] init];
                
                // Entity to look for
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                
                [keywordssFetchRequest setEntity:entity];
                
                // Filter results
                
                [keywordssFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, stringForPredicate]];
                
                // Sort results
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                
                [keywordssFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                [keywordssFetchRequest setFetchBatchSize:20];
            }
        }
    }
    
    if(keywordssFetchRequest)
    {
        // Initialize Fetched Results Controller
        
        //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
        
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:keywordssFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
        
        keywordsFetchedResultsController = fetchedResultsController;
        
        keywordsFetchedResultsController.delegate = self;
    }
    
    if(keywordsFetchedResultsController)
    {
        // Perform fetch
        
        NSError *error = nil;
        
        if (![keywordsFetchedResultsController performFetch:&error])
        {
            // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
            
            NSLog(@"Couldn't fetch elements. Unresolved error: %@, %@", error, [error userInfo]);
            
            return nil;
        }
    }
    
    return keywordsFetchedResultsController;
}
// Initialize a specific Fetched Results Controller to fetch the local keywords in order to force user to select one
- (NSFetchedResultsController *)fetchedResultsControllerWithEntity:(NSString *)entityName andPredicateObject:(NSPredicate *)predicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    NSFetchRequest * keywordssFetchRequest = nil;
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    if (keywordssFetchRequest == nil)
    {
        if(!(predicate == nil))
        {
            keywordssFetchRequest = [[NSFetchRequest alloc] init];
            
            // Entity to look for
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
            
            [keywordssFetchRequest setEntity:entity];
            
            // Filter results
            
            [keywordssFetchRequest setPredicate:predicate];
            
            // Sort results
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
            
            [keywordssFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            [keywordssFetchRequest setFetchBatchSize:20];
        }
    }
    
    if(keywordssFetchRequest)
    {
        // Initialize Fetched Results Controller
        
        //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
        
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:keywordssFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
        
        keywordsFetchedResultsController = fetchedResultsController;
        
        keywordsFetchedResultsController.delegate = self;
    }
    
    if(keywordsFetchedResultsController)
    {
        // Perform fetch
        
        NSError *error = nil;
        
        if (![keywordsFetchedResultsController performFetch:&error])
        {
            // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
            
            NSLog(@"Couldn't fetch elements. Unresolved error: %@, %@", error, [error userInfo]);
            
            return nil;
        }
    }
    
    return keywordsFetchedResultsController;
}


-(NSObject *) getKeywordElementForName:(NSString *) sNameKeyword
{
    //get the appDelegate
    
    Brand* brand = [self getBrandFromName:sNameKeyword];
    if (brand != nil)
    {
        return brand;
    }
    
    ProductGroup* pg = [self getProductGroupFromName:sNameKeyword];
    if (pg != nil)
    {
        return pg;
    }
    
    FeatureGroup* fg = [self getFeatureGroupFromFeatureName:sNameKeyword];
    if (fg!= nil)
    {
        return fg;
    }
    
    return nil;
}

-(BOOL) allSuggestedProductGroup
{
    for (NSString * sSuggestedkeyword in self.suggestedFilters)
    {
        //        ProductGroup * pg = [self getProductGroupFromName:sSuggestedkeyword];
        ProductGroup * pg = [self getProductGroupFromId:sSuggestedkeyword];
        if (pg == nil)
            return NO;
    }
    
    return (self.suggestedFilters.count > 0);
}

-(FeatureGroup *) allSuggestedFromSameFeatureGroup
{
    FeatureGroup * featureGroupOfFeature = nil;
    for (NSString * sSuggestedkeyword in self.suggestedFilters)
    {
        //        ProductGroup * pg = [self getProductGroupFromName:sSuggestedkeyword];
        Feature * feat = [self getFeatureFromId:sSuggestedkeyword];
        if (feat == nil)
            return nil;
        
        if (featureGroupOfFeature == nil)
        {
            featureGroupOfFeature = feat.featureGroup;
            continue;
        }
        
        if ([featureGroupOfFeature.idFeatureGroup isEqualToString:feat.featureGroupId] == NO)
        {
            return nil;
        }
        
    }
    
    return featureGroupOfFeature;
}


-(BOOL) isFeatureGroup:(FeatureGroup *)fg inProductGroups:(NSMutableArray *)productGroups
{
    for(ProductGroup *pg in productGroups)
    {
        if ([pg existsFeatureGroupByName:fg.name])
            return YES;
    }
    return NO;
}

-(void) showKeywordsView:(BOOL) bAnimated
{
    [self.secondCollectionView setContentOffset:self.secondCollectionView.contentOffset animated:NO];
    //    [self.secondCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    
    //float yOffset = (self.parentViewController == nil) ? (220) : (183);
    if ((_searchContext == FASHIONISTAPOSTS_SEARCH) || (_searchContext == FASHIONISTAS_SEARCH))
    {
        self.constraintTopSearchFeatureView.constant = ((self.parentViewController == nil) ? (kConstraintTopSearchFeatureViewVisibleStylist) : (kConstraintTopSearchFeatureViewVisibleWhenEmbedded));
    }
    else
    {
        self.constraintTopSearchFeatureView.constant = ((self.parentViewController == nil) ? (kConstraintTopSearchFeatureViewVisible) : (kConstraintTopSearchFeatureViewVisibleWhenEmbedded));
    }
    [self.view layoutIfNeeded];
    
    [self.addTermButton setHidden:YES];
    
    
    if ((self.selectFeaturesView.hidden == YES) || ((self.selectFeaturesView.hidden == NO) && (self.secondCollectionView.alpha < 1.0)))
    {
        [self.secondCollectionView setAlpha:0.0];
        
        [self.selectFeaturesView setHidden:NO];
        [self.secondCollectionView setHidden:NO];
        [self.selectFeaturesView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.0]];
        self.constraintTopSearchFeatureView.constant = ((![self shouldCreateSlideLabel]) ? (kConstraintTopSearchFeatureViewHidden) : (kConstraintTopSearchFeatureViewHiddenWhenEmbedded));
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             [self.selectFeaturesView setHidden:NO];
                             [self.secondCollectionView setHidden:NO];
                             
                             [self.selectFeaturesView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.8]];
                             [self.secondCollectionView setAlpha:1.0];
                             if ((_searchContext == FASHIONISTAPOSTS_SEARCH) || (_searchContext == FASHIONISTAS_SEARCH))
                             {
                                 self.constraintTopSearchFeatureView.constant = ((self.parentViewController == nil) ? (kConstraintTopSearchFeatureViewVisibleStylist) : (kConstraintTopSearchFeatureViewVisibleWhenEmbedded));
                             }
                             else
                             {
                                 self.constraintTopSearchFeatureView.constant = ((self.parentViewController == nil) ? (kConstraintTopSearchFeatureViewVisible) : (kConstraintTopSearchFeatureViewVisibleWhenEmbedded));
                             }
                             
                             [self.selectFeaturesView layoutIfNeeded];
                             
                             if (scrollBrandAlphabetBDK != nil)
                             {
                                 CGRect frameAlphabet = scrollBrandAlphabetBDK.frame;
                                 
                                 frameAlphabet.origin.y =  self.SuggestedFiltersRibbonView.frame.size.height + self.selectFeaturesView.frame.origin.y + 4;
                                 float fTotalHeight = self.selectFeaturesView.frame.size.height - 60 - self.SuggestedFiltersRibbonView.frame.size.height - 4;
                                 if (self.fromViewController != nil)
                                     fTotalHeight = self.selectFeaturesView.frame.size.height - 85 - self.SuggestedFiltersRibbonView.frame.size.height - 4;
                                 frameAlphabet.size.height = fTotalHeight;
                                 
                                 scrollBrandAlphabetBDK.frame = frameAlphabet;
                             }
                         }
                         completion:^(BOOL finished) {
                             
                             [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
                             [self hideBackgroundAddButton];
                             
                             //                         NSLog(@"Rect Alphabet Origin (%f, %f) Size(%f, %f)", scrollBrandAlphabetBDK.frame.origin.x, scrollBrandAlphabetBDK.frame.origin.y, scrollBrandAlphabetBDK.frame.size.width, scrollBrandAlphabetBDK.frame.size.height);
                             
                             
                             //                         if (scrollBrandAlphabetBDK != nil)
                             //                         {
                             //                             CGRect frameAlphabet = scrollBrandAlphabetBDK.frame;
                             //
                             //                             frameAlphabet.origin.y =  self.SuggestedFiltersRibbonView.frame.size.height + self.selectFeaturesView.frame.origin.y;
                             //                             frameAlphabet.size.height = self.selectFeaturesView.frame.size.height - 60 - self.SuggestedFiltersRibbonView.frame.size.height;
                             //
                             //                             scrollBrandAlphabetBDK.frame = frameAlphabet;
                             //                         }
                             
                             float fTotalHeight = self.selectFeaturesView.frame.size.height - 60;// - self.SuggestedFiltersRibbonView.frame.size.height - 4;
                             if ([self shouldCreateSlideLabel])
                                 fTotalHeight = self.selectFeaturesView.frame.size.height - 80;// - self.SuggestedFiltersRibbonView.frame.size.height - 4;
                             CGRect frameShadowBottom = viewBottomFilterShadow.frame;
                             frameShadowBottom.size.width = self.selectFeaturesView.frame.size.width;
                             frameShadowBottom.origin.y = fTotalHeight;
                             viewBottomFilterShadow.frame = frameShadowBottom;
                             [self.selectFeaturesView bringSubviewToFront:viewBottomFilterShadow];
                             viewBottomFilterShadow.hidden = NO;
                             viewBottomFilterShadow.alpha = 0.0;
                             
                             [UIView animateWithDuration:1.5
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^ {
                                                  viewBottomFilterShadow.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished) {
                                              }
                              ];
                         }];
    }
}

-(void) hideFiltersView: (BOOL) bAnimated
{
    if (bFiltersNew)
    {
        [filterManager hideFiltersView:bAnimated];
    }
    else
    {
        [self hideFiltersView:bAnimated performSearch:NO];
    }
}

-(void) hideFiltersView: (BOOL) bAnimated performSearch:(BOOL) bSearch
{
    if (bFiltersNew)
    {
        [filterManager hideFiltersView:bAnimated performSearch:bSearch];
        return;
    }

    [self hideAlphabet];
    
    if(self.selectFeaturesView.hidden == YES)
    {
        [self.selectFeaturesView setHidden:YES];
        [self.secondCollectionView setHidden:YES];
        return;
    }
    
    [self.addTermButton setHidden:NO];
    
    if (bSearch)
    {
        [self updateSearchForTermsChanges];
    }
    
    [self.SuggestedFiltersRibbonView unselectButtons];
    
    self.constraintTopSearchFeatureView.constant = ((self.parentViewController == nil) ? (kConstraintTopSearchFeatureViewVisible) : (kConstraintTopSearchFeatureViewVisibleWhenEmbedded));
    viewBottomFilterShadow.alpha = 0.0;
    viewBottomFilterShadow.hidden = YES;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         [self.selectFeaturesView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.0]];
                         [self.secondCollectionView setAlpha:0.0];
                         self.constraintTopSearchFeatureView.constant = ((self.parentViewController == nil) ? (kConstraintTopSearchFeatureViewHidden) : (kConstraintTopSearchFeatureViewHiddenWhenEmbedded));
                         [self.selectFeaturesView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self.selectFeaturesView setHidden:YES];
                         [self.secondCollectionView setHidden:YES];
                         [self setBackgroundImage];
                         [self.SuggestedFiltersRibbonView unselectButtons];
                     }];
    
}

-(NSString *) getNameFilterForPredicate
{
    NSString * sFilter = @"";
    
    int iIdx = 0;
    for (NSString * sSuggestedKeyword in _suggestedFilters)
    {
        //        NSString *regexString  = [NSString stringWithFormat:@"%@.*", [sSuggestedKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        NSString *regexString  = [sSuggestedKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString * sFilterName;
        if (iIdx == 0)
        {
            sFilterName = [NSString stringWithFormat:@"(name = '%@')", regexString];
        }
        else{
            sFilterName = [NSString stringWithFormat:@" OR (name = '%@')", regexString];
        }
        sFilter = [sFilter stringByAppendingString:sFilterName];
        
        iIdx++;
    }
    
    return sFilter;
}

-(NSString *) getIdFilterForPredicate:(NSString *) sEntity
{
    NSString * sFilter = @"";
    
    int iIdx = 0;
    for (NSString * sSuggestedKeyword in _suggestedFilters)
    {
        //        NSString *regexString  = [NSString stringWithFormat:@"%@.*", [sSuggestedKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        NSString *regexString  = [sSuggestedKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString * sFilterName;
        if (iIdx == 0)
        {
            sFilterName = [NSString stringWithFormat:@"(id%@ = '%@')", sEntity, regexString];
        }
        else{
            sFilterName = [NSString stringWithFormat:@" OR (id%@ = '%@')", sEntity, regexString];
        }
        sFilter = [sFilter stringByAppendingString:sFilterName];
        
        iIdx++;
    }
    
    return sFilter;
}

-(NSString *) getChildrenFeatureGroupIdForPredicate:(NSMutableArray *) childrenFeatureGroupId
{
    NSString * sFilter = @"";
    
    int iIdx = 0;
    for (NSString * sIdFeatureGroup in childrenFeatureGroupId)
    {
        NSString *sFilterName;
        if (iIdx == 0)
        {
            sFilterName = [NSString stringWithFormat:@"(featureGroupId=='%@')", sIdFeatureGroup];
        }
        else{
            sFilterName = [NSString stringWithFormat:@" OR (featureGroupId=='%@')", sIdFeatureGroup];
        }
        sFilter = [sFilter stringByAppendingString:sFilterName];
        
        iIdx++;
    }
    
    return sFilter;
}


-(void) addBrandsFrom:(NSMutableArray *) arElements to:(NSMutableArray *) completeSuggestedFiltersList
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name IN %@", arElements];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"idBrand IN %@", arElements];
    
    //BOOL bFirst = YES;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicateObject:predicate sortingWithKey:@"idBrand" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpBrand == nil))
            {
                if(!(tmpBrand.idBrand == nil))
                {
                    if(!([tmpBrand.idBrand isEqualToString:@""]))
                    {
                        //                        if (bFirst)
                        //                        {
                        //                            bFirst = NO;
                        //                            continue;
                        //                        }
                        
                        NSString * sBrand = NSLocalizedString(@"_BRANDS_",nil);
                        if (![completeSuggestedFiltersList containsObject:sBrand])
                        {
                            [completeSuggestedFiltersList addObject:sBrand];
                        }
                        break;
                    }
                }
            }
        }
    }
}

-(void) addProductGroupFrom:(NSMutableArray *) arElements to:(NSMutableArray *) completeSuggestedFiltersList
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name IN %@", arElements];
    NSPredicate * predicate = nil;
    if (_successfulTermIdProductCategory != nil)
    {
        predicate = [NSPredicate predicateWithFormat:@"(idProductGroup IN %@) AND (idProductGroup IN %@)", arElements, _successfulTermIdProductCategory];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"(idProductGroup IN %@)", arElements];
    }
    predicate = [NSPredicate predicateWithFormat:@"(idProductGroup IN %@)", arElements];
    
    //BOOL bFirst = YES;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicateObject:predicate sortingWithKey:@"idProductGroup" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProductGroup == nil))
            {
                if(!(tmpProductGroup.idProductGroup == nil))
                {
                    if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
                    {
                        // save the productGroup parent in the array
                        ProductGroup * productGroupParent = [tmpProductGroup getTopParent];
                        if (_productGroupsParentForSuggestedKeywords == nil)
                        {
                            _productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
                        }
                        
                        if (![_productGroupsParentForSuggestedKeywords containsObject:productGroupParent])
                            [_productGroupsParentForSuggestedKeywords addObject:productGroupParent];
                        
                        if ([tmpProductGroup.visible boolValue])
                        {
                            //                            if (bFirst)
                            //                            {
                            //                                bFirst = NO;
                            //                                continue;
                            //                            }
                            if ((selectedProductCategory == nil) ||
                                ((selectedProductCategory != nil) && ([tmpProductGroup.idProductGroup isEqualToString:selectedProductCategory.idProductGroup] == NO))
                                )
                            {
                                if ([self.successfulTermIdProductCategory count] > 0)
                                {
                                    // check that the product category is a child of the succesful product category, only if there are product category as successful terms
                                    if ([self.successfulTermIdProductCategory containsObject:tmpProductGroup.idProductGroup])
                                    {
                                        NSString * sStyle = NSLocalizedString(@"_STYLE_",nil);
                                        if (selectedProductCategory == nil)
                                            sStyle = NSLocalizedString(@"_PRODUCT_TYPE_",nil);
                                        if (![completeSuggestedFiltersList containsObject:sStyle])
                                        {
                                            [completeSuggestedFiltersList addObject:sStyle];
                                            break;
                                        }
                                    }
                                }
                                else{
                                    NSString * sStyle = NSLocalizedString(@"_STYLE_",nil);
                                    if (selectedProductCategory == nil)
                                        sStyle = NSLocalizedString(@"_PRODUCT_TYPE_",nil);
                                    if (![completeSuggestedFiltersList containsObject:sStyle])
                                    {
                                        [completeSuggestedFiltersList addObject:sStyle];
                                        break;
                                    }
                                }
                            }
                        }
                        
                        //                        break;
                    }
                }
            }
        }
    }
}

-(void) addFeatureGroupFrom:(NSMutableArray *) arElements to:(NSMutableArray *) completeSuggestedFiltersList orderBy: (NSMutableArray *) featureGroupsOrdered
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name IN %@", arElements];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"idFeature IN %@", arElements];
    
    NSDictionary * _kwFeatures = [[NSMutableDictionary alloc]init];
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicateObject:predicate sortingWithKey:@"idFeature" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeature == nil))
            {
                if(!(tmpFeature.idFeature == nil))
                {
                    if(!([tmpFeature.idFeature isEqualToString:@""]))
                    {
                        // get the feature group parent
                        FeatureGroup * fgParent = [tmpFeature.featureGroup getTopParent];
                        NSString * sNameFG = [fgParent.name.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([sNameFG isEqualToString:@"gender"] == NO)
                        {
                            NSMutableArray* objNumFeatures = [_kwFeatures valueForKey:fgParent.name];
                            if (objNumFeatures != nil)
                            {
                                [objNumFeatures addObject:fgParent];
                            }
                            else
                            {
                                objNumFeatures = [[NSMutableArray alloc] initWithObjects:fgParent, nil];
                                [_kwFeatures setValue:objNumFeatures forKey:fgParent.name];
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // recorrido por el diccionario y añadiendo solo aquellos elementos con mas de 1 elemento
    NSArray * allKey = [_kwFeatures allKeys];
    NSMutableArray * sortedKeyArray = [[NSMutableArray alloc] initWithArray:[allKey sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    // bucle recorriendo los featuregroup ordenados
    for(FeatureGroup * fgOrdered in featureGroupsOrdered)
    {
        for (NSString* key in  sortedKeyArray) {
            NSMutableArray * objNumFeatures = [_kwFeatures objectForKey:key];
            //int iIntValue = (int)[objNumFeatures count];
            FeatureGroup * fgParent =objNumFeatures[0] ;
            if (fgParent.idFeatureGroup == fgOrdered.idFeatureGroup)
            {
                //        if (iIntValue > 1)
                //        {
                //                if ([_productGroupsParentForSuggestedKeywords count] > 0)
                //                {
                //                    if ([self isFeatureGroup:[fgParent getTopParent] inProductGroups:_productGroupsParentForSuggestedKeywords])
                //                    {
                //                        if (![completeSuggestedFiltersList containsObject:fgParent])
                //                        {
                //                            [completeSuggestedFiltersList addObject:fgParent];
                //                        }
                //
                //                    }
                //                }
                //                else
                {
                    if (![completeSuggestedFiltersList containsObject:[fgParent getTopParent]])
                    {
                        [completeSuggestedFiltersList addObject:[fgParent getTopParent]];
                    }
                }
                //        }
                //        else
                //        {
                //            NSLog(@"Only 1 feature in %@", fgParent.name);
                //        }
                [sortedKeyArray removeObject:key];
                break;
            }
        }
    }
    
    /*
     // seguimos rellenando los featuregroups que no estaban del product category
     for (NSString* key in  sortedKeyArray) {
     NSMutableArray * objNumFeatures = [_kwFeatures objectForKey:key];
     //int iIntValue = (int)[objNumFeatures count];
     FeatureGroup * fgParent =objNumFeatures[0] ;
     //        if (iIntValue > 1)
     //        {
     if ([_productGroupsParentForSuggestedKeywords count] > 0)
     {
     if ([self isFeatureGroup:fgParent  inProductGroups:_productGroupsParentForSuggestedKeywords])
     {
     if (![completeSuggestedFiltersList containsObject:fgParent])
     {
     [completeSuggestedFiltersList addObject:fgParent];
     }
     
     }
     }
     else
     {
     if (![completeSuggestedFiltersList containsObject:fgParent])
     {
     [completeSuggestedFiltersList addObject:fgParent];
     }
     }
     //        }
     //        else
     //        {
     //            NSLog(@"Only 1 feature in %@", fgParent.name);
     //        }
     }
     */
}

-(void) addPricesGroupFrom:(NSMutableArray *) arElements to:(NSMutableArray *) completeSuggestedFiltersList
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    //BOOL bFirst = YES;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:@"Price" sortingWithKey:@"idFeatureGroup" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        for (Feature *f in tmpFeatureGroup.features)
                        {
                            for(NSString * sElement in arElements)
                            {
                                //                                if ([f.name isEqualToString:sElement])
                                if ([f.idFeature isEqualToString:sElement])
                                {
                                    [arrayFeaturesPrices addObject:f.idFeature];
                                    //                                    if (bFirst)
                                    //                                    {
                                    //                                        bFirst = NO;
                                    //                                        continue;
                                    //                                    }
                                    if (![completeSuggestedFiltersList containsObject:tmpFeatureGroup])
                                    {
                                        [completeSuggestedFiltersList addObject:tmpFeatureGroup];
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void) addFeatureGroupWithName:(NSString *)sName from:(NSMutableArray *) arElements to:(NSMutableArray *) completeSuggestedFiltersList
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    //BOOL bFirst = YES;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:sName sortingWithKey:@"idFeatureGroup" ascending:YES];
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"idFeatureGroup = %@" withString:sName sortingWithKey:@"idFeatureGroup" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        for (Feature *f in tmpFeatureGroup.features)
                        {
                            //if(![_foundSuggestions objectForKey:f.idFeature])
                            //  continue;
                            
                            for(NSString * sElement in arElements)
                            {
                                if ([f.idFeature isEqualToString:sElement])
                                {
                                    if ([sName isEqualToString:@"gender"])
                                    {
                                        if ([self isGenderInProductCategorySuccess:f.name])
                                        {
                                            if (![completeSuggestedFiltersList containsObject:tmpFeatureGroup])
                                            {
                                                [completeSuggestedFiltersList addObject:tmpFeatureGroup];
                                            }
                                            break;
                                        }
                                        else
                                        {
                                            NSLog(@"Gender not in successProductCategory %@", f.name);
                                            // remove the gender not in success product category
                                            [arElements removeObject:sElement];
                                            break;
                                        }
                                        
                                    }
                                    else
                                    {
                                        //                                    [arrayFeaturesPrices addObject:f.idFeature];
                                        //                                    if (bFirst)
                                        //                                    {
                                        //                                        bFirst = NO;
                                        //                                        continue;
                                        //                                    }
                                        if (![completeSuggestedFiltersList containsObject:tmpFeatureGroup])
                                        {
                                            [completeSuggestedFiltersList addObject:tmpFeatureGroup];
                                        }
                                        break;
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

-(NSMutableArray *) getFeaturesOfFeatureGroupByName: (NSString *)sNameFeatureGroup
{
    sNameFeatureGroup = [[sNameFeatureGroup lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableArray * arFeaturesOfFeatureGroup = [[NSMutableArray alloc] init];
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    //BOOL bFirst = YES;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:sNameFeatureGroup sortingWithKey:@"idFeatureGroup" ascending:YES];
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"idFeatureGroup = %@" withString:sName sortingWithKey:@"idFeatureGroup" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        NSMutableArray * allChildrenOfFeatureGroup = [tmpFeatureGroup getAllChildren];
                        for (FeatureGroup * fg in allChildrenOfFeatureGroup)
                        {
                            for (Feature *f in fg.features)
                            {
                                if ([arFeaturesOfFeatureGroup containsObject:f] == NO)
                                {
                                    [arFeaturesOfFeatureGroup addObject:f];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return arFeaturesOfFeatureGroup;
    
}

#pragma mark - Downloading info for filter search
/*
-(void) startLoadingInfoFilterFromServer
{
    timingDate = [NSDate date];
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if ((appDelegate.bLoadedFilterInfo == NO) && (appDelegate.bLoadingFilterInfo == NO))
    {
        appDelegate.bLoadingFilterInfo = YES;
        
        bLoadedFeaturesGroups = NO;
        bLoadingLocalDatabase = NO;
        
        [self loadAllBrands];
        
        [self loadAllFeaturesGroup];
        
        //    [self loadBrandsPriority];
        //
        //    [self loadAllProductCategory];
        //
        [self getSearchKeywords];
    }
    else if (appDelegate.bLoadedFilterInfo == YES)
        //    else
    {
        appDelegate.splashScreen = NO;
        [self finishedLoadingFilterInfo];
        
        [self stopActivityFeedback];
        
        NSLog(@"SplashScreen Time taken: %f", [[NSDate date] timeIntervalSinceDate:timingDate]);
    }
    
    //    [self stopActivityFeedback];
    //    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGFILTERS_ACTV_MSG_", nil)];
    
}

-(void) loadAllProductCategory
{
    
    // make two requests to the server,
    
    // Get all product catgeories: "http://192.168.1.99:1337/productcategory?parent=null&limit=-1&populate=featuresGroup,productCategories"
    // one to get all the product categories with all its producta category children and features groups
    // the second one to get all the features from the server, with the featuresgroups
    // http://192.168.1.99:1337/feature?limit=-1&populate=featureGroup
    
    NSLog(@"Loading all product categories info");
    
    // get all product categories
    [self performRestGet:GET_ALLPRODUCTCATEGORIES withParamaters:nil];
}

-(void) checkDebugProductGroup
{
    // get coredata context
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    // test query
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity to look for
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProductGroup" inManagedObjectContext:currentContext];
    
    [fetchRequest setEntity:entity];
    
    // Filter results
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentId = nil" ]];
    
    NSError *error;
    
    //self.productGroups
    NSArray * pProductGroup = [currentContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"Num ProductGroup %ld ---------------------------", (unsigned long)pProductGroup.count);
    for(int i = 0; i < pProductGroup.count; i++)
    {
        // Buscamos a los hijos (addPcSubGroupsObject)
        ProductGroup * pg = [pProductGroup objectAtIndex:i];
        
        NSLog(@"ProductGroup ---------------------------");
        NSLog(@"Name: %@", pg.name);
        NSLog(@"Icon: %@", pg.icon);
        NSLog(@"IconPath: %@", pg.iconPath);
        NSLog(@"Num children: %ld", (unsigned long)pg.productGroups.count);
        NSLog(@"Num product group: %ld", (unsigned long)pg.featuresGroup.count);
        NSLog(@"Num product group order: %ld", (unsigned long)pg.featuresGroupOrder.count);
        NSLog(@"----------------------------------------");
    }
    
}


-(void) setupAllProductCategoriesWithMapping:(NSArray *)productCategoriesMapping
{
    //    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    // remove all features group with gender
    //    appDelegate.productGroups = [NSMutableArray arrayWithArray:[self fetchProductCategories]];
    //
    //    [self filterProductCategoryByFeatureGroupAndGender: appDelegate.productGroups];
    //
    //[self checkDebugProductGroup];
    
    NSDictionary* userInfo = @{@"total": @"setupAllProductCategoriesWithMapping"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
    
}

-(void) loadAllFeatures
{
    NSLog(@"Loading features info");
    // get all product categories
    [self performRestGet:GET_ALLFEATURES withParamaters:nil];
}

-(void) setupAllFeaturesWithMapping:(NSArray *)featureGroupMapping
{
    
    NSDictionary* userInfo = @{@"total": @"setupAllFeaturesWithMapping"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
}

-(void) loadAllFeaturesGroup
{
    NSLog(@"Loading feature groups info");
    // get all product categories
    [self performRestGet:GET_ALLFEATUREGROUPS withParamaters:nil];
}

-(void) setupAllFeatureGroupsWithMapping:(NSArray *)featureGroupMapping
{
    NSDictionary* userInfo = @{@"total": @"setupAllFeatureGroupsWithMapping"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
}

-(void) loadBrandsPriority
{
    
    // make two requests to the server,
    
    // Get all brands "http://209.133.201.250:8080/brand?where={"priority":{"$gt":0}}&sort=priority desc&limit=-1"
    
    NSLog(@"Loading brands info");
    
    // get all product categories
    [self performRestGet:GET_PRIORITYBRANDS withParamaters:nil];
}

-(void) loadAllBrands
{
    
    // make two requests to the server,
    
    // Get all brands "http://209.133.201.250:8080/brand?where={"priority":{"$gt":0}}&sort=priority desc&limit=-1"
    
    NSLog(@"Loading all brands info");
    
    // get all product categories
    [self performRestGet:GET_ALLBRANDS withParamaters:nil];
}

-(void) setupPriorityBrandsWithMapping:(NSArray *)featureGroupMapping
{
    NSDictionary* userInfo = @{@"total": @"setupPriorityBrandsWithMapping"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
}

-(void) setupAllBrandsWithMapping:(NSArray *)featureGroupMapping
{
    NSDictionary* userInfo = @{@"total": @"setupAllBrandsWithMapping"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
}

-(void) finishedLoadingFilterInfo
{
    //[self checkDebugProductGroup];
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.bLoadingFilterInfo = NO;
    appDelegate.bLoadedFilterInfo = YES;
    
    
    appDelegate.productGroups = [NSMutableArray arrayWithArray:[self fetchProductCategories]];
    
    [self filterProductCategoryByFeatureGroupAndGender: appDelegate.productGroups];
    
    [self initDataFromLocalDatabase];
    
    //    [self stopActivityFeedback];
    
    //    NSDictionary* userInfo = @{@"total": @"finishedLoadingFilterInfo"};
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
    
}

-(NSArray *) fetchProductCategories
{
    // get coredata context
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    // test query
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity to look for
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProductGroup" inManagedObjectContext:currentContext];
    
    [fetchRequest setEntity:entity];
    
    // Filter results
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentId = nil" ]];
    
    // sort by name
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"app_name" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error;
    
    //self.productGroups
    NSArray * pProductGroup = [currentContext executeFetchRequest:fetchRequest error:&error];
    
    return pProductGroup;
}

-(void) filterProductCategoryByFeatureGroupAndGender:(NSMutableArray *)productCategories
{
    NSMutableArray * copyProductCategories = [[NSMutableArray alloc] initWithArray:productCategories];
    [productCategories removeAllObjects];
    // looping all product categories filtering the product ctagoeries withour featuregroup
    for(ProductGroup * pg in copyProductCategories)
    {
        
        if ((pg.visible == nil) || ((pg.visible != nil) && ([pg.visible boolValue])))
        {
            int iNumFeatures = [pg getNumFeaturesGroup];
            if (iNumFeatures > 1)
            {
                [productCategories addObject:pg];
            }
            else if (iNumFeatures == 1)
            {
                // only one featureGRoup, check if is gender
                if (![pg existsFeatureGroupByName:@"gender"])
                {
                    [productCategories addObject:pg];
                }
                else
                {
                    NSLog(@"Product category con un solo feature group y es gender. %@", pg.name);
                }
                
            }
        }
    }
}

int iNumDownloadingTask = 0;
int iNumMaxMessage = 4;
NSDate * timingDate;

-(void) closeSplashView:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    
    NSLog(@"*************************************** %@ %i %i", userInfo[@"total"], iNumDownloadingTask, iNumMaxMessage);
    
    if (![userInfo[@"total"] isEqualToString:@"getSearchKeywords"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([userInfo[@"total"] isEqualToString:@"ErrorConnection"])
        {
            if (appDelegate.bLoadingFilterInfo)
            {
                NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[errorMessage objectAtIndex:0]message:[errorMessage objectAtIndex:1] delegate:nil cancelButtonTitle:[errorMessage objectAtIndex:2] otherButtonTitles:nil];
                
                [alertView show];
            }
            
            appDelegate.splashScreen = NO;
            
            appDelegate.bLoadingFilterInfo = NO;
            appDelegate.bLoadedFilterInfo = NO;
            
            [self stopActivityFeedback];
            
            iNumDownloadingTask++;
            
            if((iNumDownloadingTask < iNumMaxMessage)&& (!appDelegate.bLoadedFilterInfo))
            {
                appDelegate.splashScreen = YES;
            }
        }
        else
        {
            iNumDownloadingTask++;
            if (iNumDownloadingTask > iNumMaxMessage)
            {
                
                appDelegate.splashScreen = NO;
                
                // force the load the local database
                bLoadingLocalDatabase = NO;
                bLoadedFeaturesGroups = NO;
                [self finishedLoadingFilterInfo];
                
                [self getSuggestedFilters];
                
                [self stopActivityFeedback];
                
                NSLog(@"SplashScreen Time taken: %f", [[NSDate date] timeIntervalSinceDate:timingDate]);
                
            }
        }
    }
}

- (void) getSearchKeywords
{
    NSLog(@"Fetching all keywords...");
    
    NSDate *methodStart = [NSDate date];
    NSString * requestString = [NSString stringWithFormat:@"/keyword?where={\"$or\":[{\"feature\":{\"$exists\":1}},{\"productcategory\":{\"$exists\":1}},{\"brand\":{\"$exists\":1}}]}&limit=-1"];
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:requestString
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
         
         NSDate *methodFinish = [NSDate date];
         
         NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
         
         NSLog(@"Keywords List fetched! It took: %f", executionTime);
         
         NSDictionary* userInfo = @{@"total": @"getSearchKeywords"};
         [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
     }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         NSDate *methodFinish = [NSDate date];
         
         NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
         
         // There was some problem with the communication with the GS server
         NSLog(@"Ooops! Keywords List NOT fetched...%f", executionTime);
     }];
}
*/
#pragma mark - Zoom View
-(void) initZoomView
{
    
    if (self.parentViewController != nil)
    {
        // Init the hint view
        self.zoomView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height)];
        self.zoomBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height)];
    }
    else
    {
        self.zoomView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.zoomBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }
    
    
    self.zoomView.clipsToBounds = NO;
    self.zoomView.contentMode = UIViewContentModeScaleAspectFit;
    self.zoomView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.zoomView.layer.shadowOffset = CGSizeMake(0,5);
    self.zoomView.layer.shadowOpacity = 0.5;
    self.zoomView.hidden = YES;
    
    
    // And the hint background view
    self.zoomBackgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    self.zoomBackgroundView.hidden = YES;
    
    self.zoomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.zoomLabel.backgroundColor = [UIColor blackColor];
    self.zoomLabel.textColor = [UIColor whiteColor];
    self.zoomLabel.textAlignment = NSTextAlignmentCenter;
    [self.zoomLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:14]];
    [self.zoomBackgroundView addSubview:self.zoomLabel];
    
    if (self.parentViewController != nil)
    {
        [self.parentViewController.view addSubview:self.zoomView];
        [self.parentViewController.view addSubview:self.zoomBackgroundView];
        
        [self.parentViewController.view bringSubviewToFront:self.zoomBackgroundView];
        [self.parentViewController.view bringSubviewToFront:self.zoomView];
    }
    else
    {
        [self.view addSubview:self.zoomView];
        [self.view addSubview:self.zoomBackgroundView];
        
        [self.view bringSubviewToFront:self.zoomBackgroundView];
        [self.view bringSubviewToFront:self.zoomView];
        
    }
}

- (void)onTapFeatureZoomButton:(UIButton *)sender
{
    if (bFiltersNew)
    {
        [filterManager zoomFilterButton:sender];
        return;
    }
    
    NSLog(@"Click ZoomIn");
    
    UIButton * btn = (UIButton *)sender;
    [self loadImageZoomView:[btn imageForState:UIControlStateApplication] andLabel:[btn titleForState:UIControlStateApplication]];
    [self showZoomView];
}


-(void) onTapFeatureExpandButton:(UIButton *)sender
{
    if (bFiltersNew)
    {
        [filterManager expandFilterButton:sender];
        return;
    }
    
    long iIndex = sender.tag;
    int iSection = (int)iIndex / OFFSET;
    int iItem = iIndex % OFFSET;
    
    NSObject * obj = [_filteredFilters objectAtIndex:iItem];
    if (arSectionsProductType.count > 0)
    {
        SectionProductType * objSection = [arSectionsProductType objectAtIndex:iSection];
        NSArray * arObjects = objSection.arElements;
        obj = [arObjects objectAtIndex:iItem];
    }
    
    if (obj != nil)
    {
        if ([arExpandedSubProductCategory containsObject:obj])
        {
            [arExpandedSubProductCategory removeObject:obj];
        }
        else
        {
            [arExpandedSubProductCategory removeAllObjects];
            [arExpandedSubProductCategory addObject:obj];
        }
        
        [self.secondCollectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.secondCollectionView reloadData];
        });
        
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            //your stuff happens here
        //            //after the reloadData/invalidateLayout finishes executing
        //            if (arSectionsProductType.count > 0)
        //            {
        //                SectionProductType * sectionPG = [arSectionsProductType objectAtIndex:0];
        //                int iItemScrollTo = 0;
        //                BOOL bTrobat = NO;
        //                for(ProductGroup * pg in sectionPG.arElements)
        //                {
        //                    if ([pg.idProductGroup isEqualToString:((ProductGroup *)obj).idProductGroup])
        //                    {
        //                        bTrobat = YES;
        //                        break;
        //                    }
        //                    iItemScrollTo++;
        //                }
        //                if (bTrobat)
        //                {
        //                    // volver a buscar el item para obtener la nueva seccion y item
        //                    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:iItemScrollTo inSection:0];
        //                    [self.secondCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        //                }
        //            }
        //        });
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context
{
    // You will get here when the reloadData finished
    if ([keyPath isEqualToString:@"contentSize"])
    {
        if (arSectionsProductType.count > 0)
        {
            if (arExpandedSubProductCategory.count > 0)
            {
                ProductGroup * pgExpanded = [arExpandedSubProductCategory objectAtIndex:0];
                
                SectionProductType * sectionPG = [arSectionsProductType objectAtIndex:0];
                int iItemScrollTo = 0;
                BOOL bTrobat = NO;
                for(ProductGroup * pg in sectionPG.arElements)
                {
                    if ([pg.idProductGroup isEqualToString:pgExpanded.idProductGroup])
                    {
                        bTrobat = YES;
                        break;
                    }
                    iItemScrollTo++;
                }
                if (bTrobat)
                {
                    // volver a buscar el item para obtener la nueva seccion y item
                    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:iItemScrollTo inSection:0];
                    [self.secondCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                }
            }
        }
    }
    
    [self.secondCollectionView removeObserver:self forKeyPath:@"contentSize" context:NULL];
    
}

-(void) showZoomView
{
    if (self.zoomView.hidden == NO)
        return;
    
    UIView * view;
    if (self.parentViewController != nil)
    {
        [self.parentViewController.view bringSubviewToFront:self.zoomBackgroundView];
        [self.parentViewController.view bringSubviewToFront:self.zoomView];
        view = self.parentViewController.view;
    }
    else
    {
        [self.view bringSubviewToFront:self.zoomBackgroundView];
        [self.view bringSubviewToFront:self.zoomView];
        view = self.view;
    }
    
    // load the image
    //    [self.zoomView setImage:[UIImage imageNamed:@"Wardrobes.jpg"]];
    float fNewW = view.frame.size.width * 0.8;
    float fNewH = view.frame.size.height * 0.8;
    float fOffX = view.frame.size.width * 0.1;
    float fOffY = view.frame.size.height * 0.1;
    
    self.zoomLabel.userInteractionEnabled = YES;
    self.zoomLabel.alpha = 0.0;
    self.zoomLabel.hidden = NO;
    self.zoomLabel.frame = CGRectMake(fOffX, fOffY-40, fNewW, 40);
    self.zoomView.hidden = NO;
    self.zoomView.alpha = 0.0;
    self.zoomBackgroundView.hidden = NO;
    self.zoomBackgroundView.alpha = 0.0;
    
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         self.zoomView.frame = CGRectMake(fOffX, fOffY, fNewW, fNewH);
                         self.zoomView.alpha = 1.0;
                         self.zoomBackgroundView.alpha = 1.0;
                         self.zoomLabel.alpha = 1.0;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void) loadImageZoomViewFromPath:(NSString *) pathImage andLabel:(NSString *) textLabel
{
    self.zoomLabel.text = textLabel;
    
    if ([UIImage isCached:pathImage])
    {
        UIImage * image = [UIImage cachedImageWithURL:pathImage];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        [self.zoomView setImage:image];
        
    }
    else
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:pathImage];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.zoomView setImage:image];
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }
    
}

-(void) loadImageZoomView:(UIImage *) image andLabel:(NSString *)textLabel
{
    self.zoomLabel.text = textLabel;
    
    [self.zoomView setImage:image];
    
}

-(void) hideZoomView
{
    if (bFiltersNew)
    {
        [filterManager hideZoomView];
        return;
    }
    
    if (self.zoomView.hidden == YES)
        return;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         self.zoomView.alpha = 0.0;
                         self.zoomBackgroundView.alpha = 0.0;
                         
                     } completion:^(BOOL finished) {
                         self.zoomView.hidden = YES;
                         self.zoomBackgroundView.hidden = YES;
                     }];
    
}

-(BOOL) zoomViewVisible
{
    if (bFiltersNew)
    {
        return [filterManager zoomViewVisible];
    }
    
    return (self.zoomView.hidden == NO);
}

-(void) updateBottomBarSearch
{
    [self setNavigationButtons];
    
    switch (_searchContext)
    {
        case HISTORY_SEARCH:
            break;
        case TRENDING_SEARCH:
            break;
        case FASHIONISTAPOSTS_SEARCH:
            break;
        case FASHIONISTAS_SEARCH:
            break;
        case BRANDS_SEARCH:
            break;
        default:
            break;
    }
    
}

#pragma mark - Bottons to switch between Posts and Stylists

// Clear Terms action
- (void)switchToPostSearch:(UIButton *)sender
{
    if(_bLoadingStylistsOrPosts)
        return;
    
    [self showMainMenu:nil];
    
    [self.postsSearch setBackgroundImage:[UIImage imageNamed:@"PostAndStylistButtonBackground.png"] forState:UIControlStateNormal];
    [self.postsSearch setBackgroundImage:[UIImage imageNamed:@"PostAndStylistButtonBackground.png"] forState:UIControlStateHighlighted];
    [self.postsSearch setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.stylistsSearch setBackgroundImage:nil forState:UIControlStateNormal];
    [self.stylistsSearch setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.stylistsSearch setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    _searchContext = FASHIONISTAPOSTS_SEARCH;
    
    // Show specific title depending on the Search Context
    [self setTopBarTitle:[self stringForBarTitle] andSubtitle:nil];
    
    // Perform the first search
    [self restartSearchForcing:YES];
    [self showHintsFirstTime];
}

// Clear Terms action
- (void)switchToStylistSearch:(UIButton *)sender
{
    if(_bLoadingStylistsOrPosts)
        return;
    
    [self showMainMenu:nil];
    
    [self.stylistsSearch setBackgroundImage:[UIImage imageNamed:@"PostAndStylistButtonBackground.png"] forState:UIControlStateNormal];
    [self.stylistsSearch setBackgroundImage:[UIImage imageNamed:@"PostAndStylistButtonBackground.png"] forState:UIControlStateHighlighted];
    [self.stylistsSearch setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.postsSearch setBackgroundImage:nil forState:UIControlStateNormal];
    [self.postsSearch setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.postsSearch setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    _searchContext = FASHIONISTAS_SEARCH;
    
    // Show specific title depending on the Search Context
    [self setTopBarTitle:[self stringForBarTitle] andSubtitle:nil];
    
    // Perform the first search
    [self restartSearchForcing:YES];
    [self showHintsFirstTime];
}

@end
