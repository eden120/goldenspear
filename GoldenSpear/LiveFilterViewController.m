//
//  LiveFilterViewController.m
//  GoldenSpear
//
//  Created by Crane on 9/19/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "LiveFilterViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"

#import "GSTaggingScrollBtnView.h"
#import "FilterLocationViewController.h"
#import "FilterAgeRangeViewController.h"
#import "FilterEthnicityViewController.h"
#import "LiveAddItemView.h"
#import "LiveLookView.h"
#import "LiveTagsView.h"
#import "LiveProductView.h"
#import "LiveBrandView.h"
#import "FilterSearchViewController.h"
#import "FilterSearchBrandViewController.h"
#define TOPBAR_TRANSPARENT_COLOR [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f]
#define CLICKING_TRANSPARENT_COLOR [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f]

#define CATEGORY_SCROLLVIEW_HEIGHT 160
#define COLLECTIONVIEW_CELL_WIDTH 70
#define COLLECTIONVIEW_CELL_HEIGHT 120
#define TAGS_FILTER_SKIP 0
#define TAGS_FILTER_LIMIT 30

@interface LiveFilterViewController ()

@end

enum {
    LIVE_FILTER_LOCATIONS = 0,
    LIVE_FILTER_DEMOGRAPHICS,
    LIVE_FILTER_LOOKS,
    LIVE_FILTER_TAGS,
    LIVE_FILTER_PRODUCTS,
    LIVE_FILTER_BRAND
};

enum{
    SEARCH_COUNTRY = 0,
    SEARCH_STATE,
    SEARCH_CITY,
    SERACH_GENDER,
    SEARCH_AGE,
    SEARCH_ETHINICITY
};

@implementation LiveFilterViewController {
    UICollectionView *looksCollectionView;
    UITextField *lookSearchBar;
    UITableView *lookTableView;
    UITextField *tagsSearchBar;
    UITableView *tagsTableView;
    UIView *selectedTagView;
    UIView *tagsView;
    
    NSArray *btnArray;
    NSArray *btnImgArray;
    NSArray *btnInactImgArray;
    NSMutableArray *catArray;
    NSMutableArray *ToolBtnArray;
    NSMutableArray *btnCountLabel;
    NSMutableArray *btnTitleLabel;
    NSMutableArray *textViewArry;
    
    NSMutableArray *layerArry;

    NSMutableArray *looksArry;
    NSMutableArray *typeLooks;
    NSMutableArray *popularTags;
    
    NSLayoutConstraint *lookTableviewHeightContrast;
    NSLayoutConstraint *tagTableviewHeightContrast;
    NSLayoutConstraint *tagSelectedHeightContrast;
    NSLayoutConstraint *tagsViewHeightContrast;
    
    NSMutableArray *tagsButtons;
    NSMutableArray *selectedTagsButtons;
    NSMutableArray *lookSearchArry;
    NSMutableArray *tagsSearchArry;
    BOOL lookSearchActive;
    
    UIView *productContainerView;
    UIView *brandContainerView;
    UIView *contentView;
    UIView *catView;

    CGFloat toolbarSpace;
    FilterSearchViewController *_filterTagVC;
    FilterSearchBrandViewController *_filterBrandVC;

    BOOL productORBrand;
    BOOL isPostSuccess;
    int postingCount;
    int postingEthnicityCount;

    NSMutableArray *_countries;
    NSMutableArray *_states;
    NSMutableArray *_cities;

    NSMutableArray *_ageArray;
    NSMutableArray *_selectedEthnicities;
    NSMutableArray *_selectedLooks;
    NSMutableArray *_selectedTags;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isPostSuccess = NO;
    [self initActivityFeedback];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityLabel];
    [self hideTopBar];
    
    ToolBtnArray = [[NSMutableArray alloc]init];
    catArray = [[NSMutableArray alloc]init];
    btnCountLabel = [[NSMutableArray alloc]init];
    btnTitleLabel = [[NSMutableArray alloc]init];
    textViewArry = [[NSMutableArray alloc]init];
    layerArry = [[NSMutableArray alloc]init];

    looksArry = [[NSMutableArray alloc]init];
    typeLooks = [[NSMutableArray alloc]init];
    lookSearchArry = [[NSMutableArray alloc]init];
    popularTags = [[NSMutableArray alloc]init];
    tagsSearchArry = [[NSMutableArray alloc]init];
    tagsButtons = [[NSMutableArray alloc]init];
    selectedTagsButtons = [[NSMutableArray alloc]init];
    _countries = [[NSMutableArray alloc]init];
    _states = [[NSMutableArray alloc]init];
    _cities = [[NSMutableArray alloc]init];
    
    _ageArray = [[NSMutableArray alloc]init];
    _selectedEthnicities = [[NSMutableArray alloc]init];
    _selectedLooks = [[NSMutableArray alloc]init];
    _selectedTags = [[NSMutableArray alloc]init];
    
    btnArray = @[@"LOCATIONS", @"DEMOGRAPHICS", @"LOOKS", @"TAGS", @"PRODUCTS", @"BRAND"];
    btnInactImgArray = @[@"LocationInact", @"live_demo_inact.png", @"live_look_inact.png",  @"live_tag_filter_inact.png", @"live_product_inact.png", @"live_brand_inact.png"];
    btnImgArray = @[@"Location", @"live_demo.png", @"live_look.png",  @"live_tag_filter.png",@"live_product.png", @"live_brand.png"];
    
    [self setBtnOnScrollView];
    CGRect scrRect = [[UIScreen mainScreen]bounds];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(_bodyScrollView.bounds.origin.x, _bodyScrollView.bounds.origin.y, scrRect.size.width, scrRect.size.height - 55)];
    [_bodyScrollView addSubview:contentView];
    
    [self getCategoryList];
}

- (void)viewWillAppear:(BOOL)animated
{
    postingCount = 0;
    int tag = 0;
    for (int i = 0; i < ToolBtnArray.count; i++) {
        UIButton *btn = [ToolBtnArray objectAtIndex:i];
        if (i == tag) {
            NSString *imgStr = [btnImgArray objectAtIndex:i];
            [btn setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
        } else {
            NSString *imgStr = [btnInactImgArray objectAtIndex:i];
            [btn setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
        }
    }

    _countries = self.filtercountries.mutableCopy;
    _states = self.filterstates.mutableCopy;
    _cities = self.filtercities.mutableCopy;
    _ageArray = self.filterageArray.mutableCopy;
    _selectedEthnicities = self.filterselectedEthnicities.mutableCopy;
    _selectedLooks = self.filterselectedLooks.mutableCopy;
    _selectedTags =self.filterselectedTags.mutableCopy;
    _selCatArry = self.filterCatArry.mutableCopy;
    _isSelectedMale = self.setSelectedMale;
    _isSelectedFemale = self.setSelectedFemale;
    
    [self initializeLocationFilter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldCreateBottomButtons
{
    return YES;
}

- (void)setBtnOnScrollView
{
    CGRect scrRect = [[UIScreen mainScreen]bounds];
    
    CGFloat space = CGRectGetWidth(scrRect)/ (btnArray.count - 1);
    toolbarSpace = space;
    self.toolScrollView.contentSize = CGSizeMake(space * (btnArray.count + 2), CGRectGetHeight(_toolScrollView.bounds));
    self.toolScrollView.contentOffset = CGPointMake(0, 0);
    self.toolScrollView.delaysContentTouches = NO;
    
    int idx = 0;
    _toolScrollView.backgroundColor = TOPBAR_TRANSPARENT_COLOR;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, space * (btnArray.count + 2), CGRectGetHeight(_toolScrollView.bounds))];
    view.backgroundColor = [UIColor clearColor];
    [self.toolScrollView addSubview:view];
    
    
    for (idx = 0; idx < btnArray.count; idx++) {
        
        GSTaggingScrollBtnView *btnView =
        [[[NSBundle mainBundle] loadNibNamed:@"GSTaggingScrollBtnView" owner:self options:nil] objectAtIndex:0];
        
        NSString *str = [btnArray objectAtIndex:idx];
        NSString *imgStr = [btnInactImgArray objectAtIndex:idx];
        [btnView.tagBtn setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
        [btnView.tagBtn setTitle:str forState:UIControlStateNormal];
        [btnView.tagBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] forState:UIControlStateNormal];
        
        btnView.tagBtn.tag = idx;
        [btnView.tagBtn addTarget:self action:@selector(toolBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [ToolBtnArray addObject:btnView.tagBtn];
        if (idx == 0) {
            btnView.frame = CGRectMake(2 + space * idx, 0, 60, CGRectGetHeight(self.toolScrollView.bounds));

        } else if (idx == 1) {
            btnView.frame = CGRectMake(5 + space * idx, 0, 80, CGRectGetHeight(self.toolScrollView.bounds));
        } else {
            btnView.frame = CGRectMake(4 + space * idx, 0, 60, CGRectGetHeight(self.toolScrollView.bounds));
        }
        [view addSubview:btnView];
    }
}

- (void)toolBtnAction:(UIButton*)sender
{
    int tag = (int)sender.tag;
    for (int i = 0; i < ToolBtnArray.count; i++) {
        UIButton *btn = [ToolBtnArray objectAtIndex:i];
        if (i == tag) {
            NSString *imgStr = [btnImgArray objectAtIndex:i];
            [btn setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
        } else {
            NSString *imgStr = [btnInactImgArray objectAtIndex:i];
            [btn setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
        }
    }
    
    switch (tag) {
        case LIVE_FILTER_LOCATIONS:
            [self initializeLocationFilter];
            break;
        case LIVE_FILTER_DEMOGRAPHICS:
            [_toolScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self initalizeDEMOFilter];
            break;
        case LIVE_FILTER_LOOKS:
            [_toolScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self initializeLookFilter];
            break;
        case LIVE_FILTER_TAGS:
            [_toolScrollView setContentOffset:CGPointMake(toolbarSpace, 0) animated:YES];
            [self initializeTagsFilter];
            break;
        case LIVE_FILTER_PRODUCTS:
            [_toolScrollView setContentOffset:CGPointMake(toolbarSpace, 0) animated:YES];
            [self initializeProductFilter];
            break;
        case LIVE_FILTER_BRAND:
            [self initializeBrandFilter];
            break;
        default:
            break;
    }
}

//Setup category scrollview
-(void)setupCategoryView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x, contentView.bounds.origin.y, contentView.bounds.size.width, CATEGORY_SCROLLVIEW_HEIGHT)];
    [contentView addSubview:scrollView];
    CGFloat itemWidth = 70;
    CGFloat offsetX = 20;
    CGFloat offsetY = 10;
    CGFloat firstLine = 5;
    CGFloat secondLine = firstLine + offsetY + itemWidth;
    CGFloat currentPosX = 15;
    CGFloat currentPosY = 5;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(scrollView.bounds.origin.x, scrollView.bounds.origin.y, secondLine + (offsetX + itemWidth) * catArray.count, scrollView.bounds.size.height)];
    view.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:view];
    
    for (int i = 0; i < catArray.count; i++) {
        LiveStreamingCategory *cat = [catArray objectAtIndex:i];
        BOOL isSelected = NO;
        for (LiveStreamingCategory *sCat in _selCatArry) {
            if ([sCat.idLiveStreamingCategory isEqualToString:cat.idLiveStreamingCategory]) {
                isSelected = YES;
                break;
            }
        }
        UIButton *itemView = [[UIButton alloc]initWithFrame:CGRectMake(currentPosX, currentPosY, itemWidth, itemWidth)];
        //        UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(currentPosX, currentPosY, itemWidth, itemWidth)];
        itemView.layer.cornerRadius = itemWidth/2;
        itemView.backgroundColor = [UIColor whiteColor];
        itemView.layer.borderColor = [UIColor blackColor].CGColor;
        itemView.layer.borderWidth = 2.0f;
        
        NSString *ctcount = [NSString stringWithFormat:@"%@", cat.numLiveStreams];
        
        UILabel *ctLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, itemWidth, 20)];
        ctLbl.text = ctcount;
        ctLbl.textAlignment = NSTextAlignmentCenter;
        ctLbl.textColor = [UIColor blackColor];
        [ctLbl setFont:[UIFont fontWithName:@"Avenir-Medium" size:20]];
        [itemView addSubview:ctLbl];
        [btnCountLabel addObject:ctLbl];
        UILabel *nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(-5, itemWidth/2, itemWidth+10, 15)];
        nameLbl.text = cat.name;
        nameLbl.textAlignment = NSTextAlignmentCenter;
        nameLbl.textColor = [UIColor blackColor];
        [nameLbl setFont:[UIFont fontWithName:@"AvantGarde-Book" size:13]];
        [itemView addSubview:nameLbl];
        [btnTitleLabel addObject:nameLbl];
        itemView.tag = i;

        [itemView addTarget:self action:@selector(clickedCatItem:) forControlEvents:UIControlEventTouchUpInside];
        ctLbl.textColor = isSelected? [UIColor whiteColor]: [UIColor blackColor];
        nameLbl.textColor = isSelected? [UIColor whiteColor]: [UIColor blackColor];        
       
        [itemView setBackgroundColor:isSelected? TOPBAR_TRANSPARENT_COLOR: [UIColor whiteColor]];
        
        
        [view addSubview:itemView];
        
        currentPosX += itemWidth/2 + offsetX;
        if (currentPosY == firstLine) {
            currentPosY = secondLine;
        } else if(currentPosY == secondLine) {
            currentPosY = firstLine;
        }
    }
    scrollView.contentSize = CGSizeMake(currentPosX + itemWidth, scrollView.frame.size.height);
    
}

- (void)clickedCatItem:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    LiveStreamingCategory  *cat = [catArray objectAtIndex:tag];
    BOOL isSelected = NO;
    if ([_selCatArry containsObject:cat]) {
        isSelected = NO;
        [_selCatArry removeObject:cat];
    } else {
        isSelected = YES;
        [_selCatArry addObject:cat];
    }

    UILabel *countLabl = [btnCountLabel objectAtIndex:tag];
    countLabl.textColor = isSelected? [UIColor whiteColor]: [UIColor blackColor];
    UILabel *titleLabl = [btnTitleLabel objectAtIndex:tag];
    titleLabl.textColor = isSelected? [UIColor whiteColor]: [UIColor blackColor];
    
    [UIView animateWithDuration:0.4 animations:^{
        [sender setBackgroundColor:CLICKING_TRANSPARENT_COLOR];
    }
                     completion:^(BOOL finished) {
                         [sender setBackgroundColor:isSelected? TOPBAR_TRANSPARENT_COLOR: [UIColor whiteColor]];
                         
                     }];
    
    
}
- (void)getCategoryList
{
    if (catArray.count > 0) return;
    
    NSLog(@"Getting live streaming category...");
    
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
    
    [self performRestGet:GET_LIVESTREAMINGCATEGORIES withParamaters:nil];
}


- (IBAction)saveAction:(id)sender {
    postingCount = 0;
    _setSelectedMale = _isSelectedMale;
    _setSelectedFemale = _isSelectedFemale;
    
   self.filtercountries = _countries.mutableCopy;
   self.filterstates =  _states.mutableCopy;
    self.filtercities = _cities.mutableCopy;
    self.filterageArray = _ageArray.mutableCopy;
    self.filterselectedEthnicities = _selectedEthnicities.mutableCopy;
    self.filterselectedLooks = _selectedLooks.mutableCopy;
    self.filterselectedTags = _selectedTags.mutableCopy;
    
    NSMutableArray *tmpCat = _selCatArry;
    if ([self.filterDelegate respondsToSelector:@selector(setCategories:Arry:)]) {
        [self.filterDelegate setCategories:self Arry:tmpCat];
    }
    
    if ([self.filterDelegate respondsToSelector:@selector(setGender:Male:Female:)]) {
        [self.filterDelegate setGender:self Male:_isSelectedMale Female:_isSelectedFemale];
    }
    
    NSMutableArray *products = [_filterTagVC getSelectedProductGroup];
    if ([self.filterDelegate respondsToSelector:@selector(setProducts:Arry:)]) {
        [self.filterDelegate setProducts:self Arry:products];
    }
    
    NSMutableArray *brands = [_filterBrandVC getSelectedBrands];
    if ([self.filterDelegate respondsToSelector:@selector(setBrands:Arry:)]) {
        [self.filterDelegate setBrands:self Arry:brands];
    }
    
    [self dismissView];
}


- (void)dismissView {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    
    // NSLog(@"%s: controller.view.window=%@", _func_, controller.view.window);
    UIView *view = self.view.window;
    [view.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];

}

- (IBAction)backAction:(id)sender {
    [self dismissView];
}

#pragma mark - Avoid user leave post creation unless cancelled or finished

- (void)leftAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)middleLeftAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)homeAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)middleRightAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)rightAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

#pragma mark - Location Filter
-(void)initializeLocationFilter
{
    UIView *containerView = nil;
    for (int i = 0; i < layerArry.count; i++) {
        UIView *view = [layerArry objectAtIndex:i];
        if (view.tag == LIVE_FILTER_LOCATIONS) {
            view.hidden = NO;
            containerView = view;
        } else {
            view.hidden = YES;
        }
    }
    if (containerView != nil) {
        return;
    }
    
    NSMutableArray *catArry = [[NSMutableArray alloc]initWithObjects:@"SEARCH COUNTRY", @"SEARCH STATE / REGION", @"SEARCH CITY / PROVINCE", nil];
    
    containerView = [[UIView alloc]initWithFrame:CGRectMake(0, CATEGORY_SCROLLVIEW_HEIGHT + 5, contentView.bounds.size.width, contentView.bounds.size.height - CATEGORY_SCROLLVIEW_HEIGHT)];
    containerView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:containerView];
    _bodyScrollView.contentSize = CGSizeMake(contentView.frame.size.width, CATEGORY_SCROLLVIEW_HEIGHT + 55 + containerView.bounds.size.height);
    containerView.tag = LIVE_FILTER_LOCATIONS;

    [layerArry addObject:containerView];

    [self createAddView:catArry container:containerView type:LIVE_FILTER_LOCATIONS];
}

- (void)createAddView:(NSMutableArray*) arry container: (UIView*)contView type:(int)type {
    CGFloat height = contView.frame.size.height;
    CGFloat width = contView.frame.size.width;
    CGFloat viewHeight = (height - 20) / 3;

    for (int i = 0; i < arry.count; i++ ) {
        NSString *title = [arry objectAtIndex:i];
        LiveAddItemView *addView =
        [[[NSBundle mainBundle] loadNibNamed:@"LiveAddItemView" owner:self options:nil] objectAtIndex:0];
        addView.titleLab.text = title;
        
        addView.addBtn.tag = 3 * type + i;
        [addView.addBtn addTarget:self action:@selector(showSearchView:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapped:)];
        [addView.contentText addGestureRecognizer:gestureRecognizer];
        addView.contentText.tag = 3 * type + i;
        [textViewArry addObject:addView.contentText];
        
        
        if (SERACH_GENDER == 3 * type + i) {  //Demograpics - GENDER
            addView.addBtn.hidden = YES;
            
            NSMutableAttributedString *mutableAttributedString;
            mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:@"Male | Female"];

            [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:_isSelectedMale?[UIColor blackColor]:[UIColor grayColor] range:NSMakeRange(0,4)];
             [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:_isSelectedFemale?[UIColor blackColor]:[UIColor grayColor] range:NSMakeRange(7,6)];
            addView.contentText.attributedText = mutableAttributedString;
            
        } else {
            addView.contentText.text = @"All";
            addView.addBtn.hidden = NO;
        }
        
        addView.frame = CGRectMake(10, viewHeight * i, width - 20, viewHeight - 10);
        [contView addSubview:addView];
        
        if (type == LIVE_FILTER_LOCATIONS)
            [self showValues:3 * type + i];
        else {
            if (SEARCH_AGE == 3 * type + i) {
                 [self setAgeRageView:addView.contentText showingArry:_ageArray];
            } else if (SEARCH_ETHINICITY == 3 * type + i) {
                [self showEthnicityBox:addView.contentText showingArry:_selectedEthnicities];
            }
        }
    }
}

- (void)showSearchView: (UIButton*)sender
{
    int tag = sender.tag;
    switch (tag) {
        case SEARCH_COUNTRY:
            //search country
            [self showLocationFilterSearchView:tag];
            break;
        case SEARCH_STATE:
            
            if (_countries.count <= 0)
            {
                // show message please select a country first
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_SELECT_COUNTRY_STATE_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
                
                [alertView show];
                
                return;
            }
            [self showLocationFilterSearchView:tag];

            break;
        case SEARCH_CITY:
            if (_countries.count <= 0)
            {
                // show message please select a country first
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_SELECT_COUNTRY_STATE_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
                
                [alertView show];
                
                return;
            }
            [self showLocationFilterSearchView:tag];

            break;
        case SEARCH_AGE:
        {
            UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
            FilterAgeRangeViewController *nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(LIVEAGELANGESEARCH_VC) stringValue]];
            [nextViewController setSearchContext:FASHIONISTAS_SEARCH];
            nextViewController.userListMode = SUGGESTED;
            nextViewController.ageArry = _ageArray;
            nextViewController.filterAgeDelegate = self;
            nextViewController.type = tag;
            [self prepareViewController:nextViewController withParameters:nil];
            [self showViewControllerModal:nextViewController];
            [self setTitleForModal:NSLocalizedString(@"_LIVE_AGE_RANGE_", nil)];
            break;
        }
        case SEARCH_ETHINICITY:
        {
            NSString* destinationStoryboard = @"FashionistaContents";
            UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:destinationStoryboard bundle:nil];
            
            if (nextStoryboard != nil)
            {
                
                FilterEthnicityViewController *vc = [nextStoryboard instantiateViewControllerWithIdentifier:[@(ETHNICITY_VC) stringValue]];
                vc.selectedEthy = _selectedEthnicities;
                vc.filterEthnicityDelegate = self;
                vc.type = tag;
                
                [self prepareViewController:vc withParameters:nil];
                [self showViewControllerModal:vc];
                           }
                [self setTitleForModal:NSLocalizedString(@"_LIVE_ETHNICITY_", nil)];

            break;
        }
        default:
            break;
    }
}

- (void)showLocationFilterSearchView:(int)type
{
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    FilterLocationViewController *nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(LIVELOCATIONSEARCH_VC) stringValue]];
    
    nextViewController.filterLocationDelegate = self;
    nextViewController.searchType = type;
    nextViewController.countries = _countries.mutableCopy;
    nextViewController.states = _states.mutableCopy;
    nextViewController.cities = _cities.mutableCopy;
    
    [self prepareViewController:nextViewController withParameters:nil];
    [nextViewController setSearchContext:FASHIONISTAS_SEARCH];
    nextViewController.userListMode = SUGGESTED;
    [self showViewControllerModal:nextViewController];
    [self setTitleForModal:@"LOCATION"];
}

- (void)showValues:(int)type
{
    UITextView *textview = [textViewArry objectAtIndex:type];
    textview.text = @"All";
    NSString *locStr = nil;
    switch (type) {
        case SEARCH_COUNTRY:   //countries
            for (int i = 0; i < _countries.count; i++ ) {
                Country *ct = [_countries objectAtIndex:i];
                if (i == 0 ) {
                    locStr = [NSString stringWithFormat:@"%@", ct.name];
                } else {
                    locStr = [NSString stringWithFormat:@"%@ | %@", locStr, ct.name];
                }
            }
            break;
        case SEARCH_STATE:  //states
            
            for (int i = 0; i < _states.count; i++ ) {
                
                StateRegion*ct = [_states objectAtIndex:i];
                if (i == 0 ) {
                    locStr = [NSString stringWithFormat:@"%@", ct.name];
                } else {
                    locStr = [NSString stringWithFormat:@"%@ | %@", locStr, ct.name];
                }
            }
            break;
        case SEARCH_CITY:   //cities
            
            for (int i = 0; i < _cities.count; i++ ) {
                City *ct = [_cities objectAtIndex:i];
                if (i == 0) {
                    locStr = [NSString stringWithFormat:@"%@", ct.name];
                } else {
                    locStr = [NSString stringWithFormat:@"%@ | %@", locStr, ct.name];
                }
            }
            break;
        default:
            break;
            
    };
    
    if (locStr != nil)
        textview.text = locStr;

}

#pragma mark -- Filter location delegate
- (void)setLocations:(NSMutableArray *)locations type:(int)type
{
    if ( locations == nil || locations.count <= 0 ) return;
    
    UITextView *textview = [textViewArry objectAtIndex:type];
    textview.text = @"";
    NSString *locStr;
    switch (type) {
        case SEARCH_COUNTRY:   //countries
            for (Country *ct in locations) {
                if (![_countries containsObject:ct]) {
                    [_countries addObject:ct];
                }
            }
            
            for (int i = 0; i < _countries.count; i++ ) {
                Country *ct = [_countries objectAtIndex:i];
                if (i == 0 ) {
                    locStr = [NSString stringWithFormat:@"%@", ct.name];
                } else {
                    locStr = [NSString stringWithFormat:@"%@ | %@", locStr, ct.name];
                }
            }
            break;
        case SEARCH_STATE:  //states
            for (StateRegion *ct in locations) {
                if (![_states containsObject:ct]) {
                    [_states addObject:ct];
                }
            }

            for (int i = 0; i < _states.count; i++ ) {
                
                StateRegion*ct = [_states objectAtIndex:i];
                if (i == 0 ) {
                    locStr = [NSString stringWithFormat:@"%@", ct.name];
                } else {
                    locStr = [NSString stringWithFormat:@"%@ | %@", locStr, ct.name];
                }
            }
            break;
        case SEARCH_CITY:   //cities
           // [cities addObjectsFromArray: locations];
            for (City *ct in locations) {
                if (![_cities containsObject:ct]) {
                    [_cities addObject:ct];
                }
            }
            for (int i = 0; i < _cities.count; i++ ) {
                City *ct = [_cities objectAtIndex:i];
                if (i == 0) {
                    locStr = [NSString stringWithFormat:@"%@", ct.name];
                } else {
                    locStr = [NSString stringWithFormat:@"%@ | %@", locStr, ct.name];
                }
            }
            break;
        default:
            break;
            
    };
    
    textview.text = locStr;
}

- (void)textViewTapped:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"Single Tap");
    UITextView *textView_New = (UITextView *)recognizer.view;
    CGPoint pos = [recognizer locationInView:textView_New];
    NSLog(@"Tap Gesture Coordinates: %.2f %.2f", pos.x, pos.y);
    UITextPosition *tapPos = [textView_New closestPositionToPoint:pos];
    UITextRange * wr = [textView_New.tokenizer rangeEnclosingPosition:tapPos withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    
    NSString *selectedText = [textView_New textInRange:wr];
    NSLog(@"selectedText: %@", selectedText);
    if (selectedText == nil || [selectedText isEqualToString:@""])
        return;
    
    NSRange range = [self selectedRangeInTextView:textView_New cornvertRange:wr];
    NSLog(@"WORD: %d", range.location);
    
    
    NSString *sting = textView_New.text;
    int startPosition = 0, endPosotion = 0;
    for (int i = (int)range.location; i >= 0; i--) {
        char character = [sting characterAtIndex:i];
        
        if (character == '|') {
            startPosition = i + 2;
            break;
        }
        if (i == 0) {
            startPosition = i;
            break;
        }
    }
    
    for (int i = (int)range.location; i < [sting length]; i++) {
        char character = [sting characterAtIndex:i];
        if (character == '|') {
            endPosotion = i - 1;
            break;
        }
        if (i == [sting length] - 1) {
            endPosotion = [sting length];
            break;
        }
    }
    

    
    UITextRange *newRange = [self frameOfTextRange:NSMakeRange(startPosition, endPosotion - startPosition) inTextView:textView_New];
    
    NSString *allSelectedText = [textView_New textInRange:newRange];
    NSLog(@"selectedText: %@", allSelectedText);
    
    NSInteger tag = textView_New.tag;
    switch (tag) {
        case SEARCH_COUNTRY:  //location - country
        {
            Country *ct = nil;
            for (ct in _countries) {
                if ([ct.name isEqualToString:allSelectedText]) {
                    break;
                }
                    
            }
            
            if (ct != nil) {
                [_countries removeObject:ct];
                [self setTextInCounry:textView_New Arry:_countries Type:SEARCH_COUNTRY];
            }
            break;
        }
        case SEARCH_STATE:  //location - states
        {
            StateRegion *ct = nil;
            for (ct in _states) {
                if ([ct.name isEqualToString:allSelectedText]) {
                    break;
                }
                
            }
            
            if (ct != nil) {
                [_states removeObject:ct];
                [self setTextInCounry:textView_New Arry:_states Type:SEARCH_STATE];
            }
            break;
        }
        case SEARCH_CITY:  //location - city
        {
            City *ct = nil;
            for (ct in _cities) {
                if ([ct.name isEqualToString:allSelectedText]) {
                    break;
                }
                
            }
            
            if (ct != nil) {
                [_cities removeObject:ct];
                [self setTextInCounry:textView_New Arry:_cities Type:SEARCH_CITY];
            }
            break;
        }
        case SERACH_GENDER:
        {
            NSMutableAttributedString *mutableAttributedString;
            mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:textView_New.text];
            
            if (startPosition == 0) {
                _isSelectedMale = !_isSelectedMale;
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:_isSelectedMale? [UIColor blackColor]:[UIColor grayColor] range:NSMakeRange(0,4)];
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:_isSelectedFemale? [UIColor blackColor]:[UIColor grayColor] range:NSMakeRange(7,6)];
            } else if (startPosition == 7) {
                _isSelectedFemale = !_isSelectedFemale;
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:_isSelectedMale? [UIColor blackColor]:[UIColor grayColor] range:NSMakeRange(0,4)];
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:_isSelectedFemale? [UIColor blackColor]:[UIColor grayColor] range:NSMakeRange(7,6)];
            }
            textView_New.attributedText = mutableAttributedString;

            break;
        }
        case SEARCH_AGE:
        {
            NSDictionary *selectedDic;
            
        
            for (NSDictionary *dic in _ageArray) {
                NSString *str = [NSString stringWithFormat:@"%@ - %@", dic[@"MinAge"], dic[@"MaxAge"]];
                if ([str isEqualToString:allSelectedText]) {
                        selectedDic = dic;
                        break;
                }
            }
            
            if (selectedDic != nil) {
                [_ageArray removeObject:selectedDic];
                [self setAgeRageView:textView_New showingArry:_ageArray];
            }
            break;
        }
        case SEARCH_ETHINICITY:
        {
            for (NSDictionary *dic in _selectedEthnicities) {
                NSString *str = nil;
                id other = [dic objectForKey:kOtherKey];
                if(other){
                    if(![other isEqualToString:@""]){
                        str = other;
                    }
                }else{
                    str = [dic objectForKey:kNameKey];
                }
                if (str != nil && [str isEqualToString:allSelectedText]) {
                    [self removeOnEthnicityBox:textView_New dic:dic];
                    return;
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)setTextInCounry:(UITextView*)textview Arry:(NSMutableArray*)arry Type:(int) type
{
    NSString *locStr = @"All";
    for (int i = 0; i < arry.count; i++) {
        if (type == 0) {
            Country *ct = [arry objectAtIndex:i];
            if (i == SEARCH_COUNTRY ) {
                locStr = [NSString stringWithFormat:@"%@", ct.name];
            } else {
                locStr = [NSString stringWithFormat:@"%@ | %@", locStr, ct.name];
            }
        }
        else if (type == SEARCH_STATE) {
            StateRegion *ct = [arry objectAtIndex:i];
            if (i == 0 ) {
                locStr = [NSString stringWithFormat:@"%@", ct.name];
            } else {
                locStr = [NSString stringWithFormat:@"%@ | %@", locStr, ct.name];
            }
        }
        else if (type == SEARCH_CITY) {
            City *ct = [arry objectAtIndex:i];
            if (i == 0 ) {
                locStr = [NSString stringWithFormat:@"%@", ct.name];
            } else {
                locStr = [NSString stringWithFormat:@"%@ | %@", locStr, ct.name];
            }
        }
    }
    
    textview.text = locStr;
}
- (UITextRange *)frameOfTextRange:(NSRange)range inTextView:(UITextView *)textView
{
    UITextPosition *beginning = textView.beginningOfDocument;
    UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [textView positionFromPosition:start offset:range.length];
    UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
    
    return textRange;
}

- (NSRange) selectedRangeInTextView:(UITextView*)textView cornvertRange:(UITextRange*)selectedRange
{
    UITextPosition* beginning = textView.beginningOfDocument;
    
    //    UITextRange* selectedRange = textView.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [textView offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [textView offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

#pragma mark - Demographics Filter
- (void)initalizeDEMOFilter
{
    UIView *containerView = nil;
    for (int i = 0; i < layerArry.count; i++) {
        UIView *view = [layerArry objectAtIndex:i];
        if (view.tag == LIVE_FILTER_DEMOGRAPHICS) {
            view.hidden = NO;
            containerView = view;
        } else {
            view.hidden = YES;
        }
    }
    if (containerView != nil) {
        return;
    }
    
    NSMutableArray *catArry = [[NSMutableArray alloc]initWithObjects:@"GENDER", @"AGE RANGE", @"ETHNICITY", nil];
    containerView = [[UIView alloc]initWithFrame:CGRectMake(0, CATEGORY_SCROLLVIEW_HEIGHT + 5, contentView.bounds.size.width, contentView.bounds.size.height - CATEGORY_SCROLLVIEW_HEIGHT)];
    containerView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:containerView];
    _bodyScrollView.contentSize = CGSizeMake(contentView.frame.size.width, CATEGORY_SCROLLVIEW_HEIGHT + 55 + containerView.bounds.size.height);
    
    [layerArry addObject:containerView];
    containerView.tag = LIVE_FILTER_DEMOGRAPHICS;
    [self createAddView:catArry container:containerView type:LIVE_FILTER_DEMOGRAPHICS];
}

-(void)setAgeRageView:(UITextView*)textView showingArry:(NSMutableArray*)arry
{
    NSString *ageStr = @"All";
    for (int i = 0; i < _ageArray.count; i++) {
        NSDictionary *dic = [_ageArray objectAtIndex:i];
        NSString *minStr = dic[@"MinAge"];
        NSString *maxStr = dic[@"MaxAge"];
        
        if (i == 0) {
            ageStr = [NSString stringWithFormat:@"%@ - %@", minStr, maxStr];
        } else {
            ageStr = [NSString stringWithFormat:@"%@ | %@ - %@", ageStr ,minStr, maxStr];
        }
    }
    
    textView.text = ageStr;
}

#pragma mark - FilterAgeRangeDelegate
- (void)setAgeRange:(NSMutableArray *)ages type:(int)type
{
    if (ages == nil || ages.count <= 0) return;
    UITextView *textview = [textViewArry objectAtIndex:type];
    _ageArray = ages.mutableCopy;

    [self setAgeRageView:textview showingArry:_ageArray];
    
}
#pragma mark - FilterEthinicityDelegate
- (void)setEthnicity:(NSMutableArray *)ethnicties type:(int)type
{
    if (ethnicties == nil || ethnicties.count <= 0) return;
    UITextView *textview = [textViewArry objectAtIndex:type];
    _selectedEthnicities = ethnicties.mutableCopy;
    
    [self showEthnicityBox:textview showingArry:_selectedEthnicities];
}
- (void)showEthnicityBox:(UITextView*)textView showingArry:(NSMutableArray*)arry
{
    NSString *title = @"All";
    for (NSDictionary *selDic in arry) {
        NSString *str;
        id other = [selDic objectForKey:kOtherKey];
        if(other){
            if(![other isEqualToString:@""]){
                str = other;
            }
        }else{
            str = [selDic objectForKey:kNameKey];
        }
        
        if (str != nil && ![str isEqualToString:@""]) {
            if ([title isEqualToString:@""] || [title isEqualToString:@"All"]) {
                title = str;
            } else {
                title = [NSString stringWithFormat:@"%@ | %@", title, str];
            }
        }
    }
    textView.text = title;

}
- (void)removeOnEthnicityBox:(UITextView*)txtView dic:(NSDictionary*)ethny
{
    id other = [ethny objectForKey:kOtherKey];
    if(other){
        NSDictionary *delDic = nil;
        for (NSDictionary *dic in _selectedEthnicities) {
            NSString *dicStr = [dic objectForKey:kIdKey];
            if ([[ethny objectForKey:kIdKey] isEqualToString:dicStr]) {
                delDic = dic;
                break;
                
            }
        }
        if (delDic != nil) {
            [_selectedEthnicities removeObject:delDic];
            [self showEthnicityBox:txtView showingArry:_selectedEthnicities];
        }
    }
    else {
        if ([_selectedEthnicities containsObject:ethny]) {
            [_selectedEthnicities removeObject:ethny];
            [self showEthnicityBox:txtView showingArry:_selectedEthnicities];
        }
    }
}
#pragma mark - Filter Look
- (void)initializeLookFilter
{
    
    UIView *containerView = nil;
    for (int i = 0; i < layerArry.count; i++) {
        UIView *view = [layerArry objectAtIndex:i];
        if (view.tag == LIVE_FILTER_LOOKS) {
            view.hidden = NO;
            containerView = view;
        } else {
            view.hidden = YES;
        }
    }
    if (containerView != nil) {
        return;
    }

    containerView = [[UIView alloc]initWithFrame:CGRectMake(0, CATEGORY_SCROLLVIEW_HEIGHT + 5, contentView.bounds.size.width, contentView.bounds.size.height - CATEGORY_SCROLLVIEW_HEIGHT)];
    containerView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:containerView];
    _bodyScrollView.contentSize = CGSizeMake(contentView.frame.size.width, CATEGORY_SCROLLVIEW_HEIGHT + 55 + containerView.bounds.size.height);
    containerView.tag = LIVE_FILTER_LOOKS;
    [layerArry addObject:containerView];
//    
    LiveLookView *lookView =
    [[[NSBundle mainBundle] loadNibNamed:@"LiveLookView" owner:self options:nil] objectAtIndex:0];

    lookView.searchView.layer.borderColor = [UIColor grayColor].CGColor;
    lookView.searchBar.delegate = self;
    lookView.searchView.layer.borderWidth = 1.0f;
    lookSearchBar = lookView.searchBar;
    
    lookView.searchResultTableView.layer.borderColor = [UIColor grayColor].CGColor;
    lookView.searchResultTableView.layer.borderWidth = 1.0f;
    lookView.searchResultTableView.delegate =self;
    lookView.searchResultTableView.dataSource =self;
    lookView.tableviewHeightContrast.constant = 0;
    [lookView.searchResultTableView setAllowsMultipleSelection:YES];

    lookTableviewHeightContrast = lookView.tableviewHeightContrast;
    lookTableView = lookView.searchResultTableView;
    
    lookView.frame = containerView.bounds;
    [containerView addSubview: lookView];
    
    CGRect scrRect = [[UIScreen mainScreen]bounds];
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    looksCollectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(lookView.collectionViewLayer.bounds.origin.x, lookView.collectionViewLayer.bounds.origin.y, scrRect.size.width - 15, scrRect.size.height/2) collectionViewLayout:layout];
    [looksCollectionView setDataSource:self];
    [looksCollectionView setDelegate:self];
    [looksCollectionView setAllowsMultipleSelection:YES];
    [looksCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [looksCollectionView setBackgroundColor:[UIColor whiteColor]];
    
    
    [lookView.collectionViewLayer addSubview:looksCollectionView];
    //backend call
    lookSearchActive = NO;
    [self getTypeLookList];
    
}
- (void)getTypeLookList
{
    NSLog(@"Getting type look list...");
    
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
    
    [self performRestGet:GET_TYPELOOKS withParamaters:nil];
}

#pragma mark - collectionview delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"collection count %ld", typeLooks.count);
    if (lookSearchActive)
        return lookSearchArry.count;
    return [typeLooks count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *collectionViewCell;

    collectionViewCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    UIImageView *imgView = nil;
    UILabel *lbl = nil;
    for (UIView *view in [collectionViewCell subviews]) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    NSDictionary *cellDic = nil;
    
    if (lookSearchActive) {
        cellDic = [lookSearchArry objectAtIndex:indexPath.row];
        imgView = cellDic[@"ImageView"];
        lbl = cellDic[@"Label"];
        [collectionViewCell addSubview:imgView];
        [collectionViewCell addSubview:lbl];
    } else {
        if (looksArry.count > indexPath.row) {
            cellDic = [looksArry objectAtIndex:indexPath.row];
            imgView = cellDic[@"ImageView"];
            lbl = cellDic[@"Label"];
            [collectionViewCell addSubview:imgView];
            [collectionViewCell addSubview:lbl];
        } else {
            TypeLook *typeLook = [typeLooks objectAtIndex:indexPath.row];
            NSLog(@"typelook %@", typeLook);
            imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, collectionViewCell.frame.size.width, collectionViewCell.frame.size.height - 30)];
            
            imgView.layer.borderColor = [UIColor grayColor].CGColor;
            imgView.layer.borderWidth = 1.0f;

            for (int i = 0; i < _selectedLooks.count; i++) {
                NSDictionary *tDic = [_selectedLooks objectAtIndex:i];
                TypeLook *tl = tDic[@"TypeLookObject"];
                if ([tl.idTypeLook isEqualToString:typeLook.idTypeLook]) {
                    imgView.layer.borderColor = [UIColor yellowColor].CGColor;
                    imgView.layer.borderWidth = 2.0f;
                    break;
                }
            }
           
            
            [collectionViewCell addSubview:imgView];
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[IMAGESBASEURL stringByAppendingString:typeLook.picture]]];
                if ( data == nil )
                    return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // WARNING: is the cell still using the same data by this point??
                    imgView.image = [UIImage imageWithData: data];
                });
            });
            
            
            lbl = [[UILabel alloc]initWithFrame:CGRectMake(0,collectionViewCell.frame.size.height - 30, collectionViewCell.frame.size.width, 30)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.font = [UIFont fontWithName:@"AvantGarde-Book" size:12 ];
            lbl.numberOfLines = 2;
            lbl.text = typeLook.name;
            
            [collectionViewCell addSubview:lbl];
            NSDictionary *aDic= [NSDictionary dictionaryWithObjectsAndKeys:
                                 imgView, @"ImageView",
                                 lbl, @"Label",
                                 indexPath, @"Index",
                                 typeLook, @"TypeLookObject",
                                 nil];
            [looksArry addObject:aDic];

        }
    }
    imgView.clipsToBounds = YES;
    [collectionViewCell layoutIfNeeded];
    
    return collectionViewCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(COLLECTIONVIEW_CELL_WIDTH, COLLECTIONVIEW_CELL_HEIGHT);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (lookSearchActive) {
        NSDictionary *dic = [lookSearchArry objectAtIndex:indexPath.row];
        [self selectLookCollectionViewCell:dic SelectOption:YES];

    } else {
        if (looksArry.count > indexPath.row) {
            NSDictionary *dic = [looksArry objectAtIndex:indexPath.row];
            [self selectLookCollectionViewCell:dic SelectOption:YES];
        }
    }
    
    NSArray<NSIndexPath*>* selectedIndexes = collectionView.indexPathsForSelectedItems;
    for (int i = 0; i < selectedIndexes.count; i++) {
        NSIndexPath* currentIndex = selectedIndexes[i];
        if (![currentIndex isEqual:indexPath] && currentIndex.section != 1) {
            [collectionView deselectItemAtIndexPath:currentIndex animated:YES];
        }
    }
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (lookSearchActive) {
        NSDictionary *dic = [lookSearchArry objectAtIndex:indexPath.row];
        [self selectLookCollectionViewCell:dic SelectOption:NO];
        
    } else {
        if (looksArry.count > indexPath.row) {
            NSDictionary *dic = [looksArry objectAtIndex:indexPath.row];
            [self selectLookCollectionViewCell:dic SelectOption:NO];
        }
    }
}

- (void)selectLookCollectionViewCell:(NSDictionary *)dic SelectOption:(BOOL)YesOrNo
{
    UIImageView *imgView = dic[@"ImageView"];
 
    TypeLook *typeLook = dic[@"TypeLookObject"];
   
    NSDictionary *selDic = nil;
    for (int i = 0; i < _selectedLooks.count; i++) {
        NSDictionary *tDic = [_selectedLooks objectAtIndex:i];
        TypeLook *tl = tDic[@"TypeLookObject"];
        if ([tl.idTypeLook isEqualToString:typeLook.idTypeLook]) {
            selDic = tDic;
            break;
        }
    }
    
    if (selDic == nil) {
        imgView.layer.borderColor = [UIColor clearColor].CGColor;
        imgView.layer.borderColor = [UIColor yellowColor].CGColor;
        imgView.layer.borderWidth = 2.0f;
        
        
        [_selectedLooks addObject: dic];
    } else {
        imgView.layer.borderColor = [UIColor clearColor].CGColor;
        imgView.layer.borderColor = [UIColor grayColor].CGColor;
        imgView.layer.borderWidth = 1.0f;

        [_selectedLooks removeObject: selDic];
    }
    
    imgView.clipsToBounds = YES;
}

#pragma mark - searchbar delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *searchText = textField.text;
    [textField resignFirstResponder];
    
    if (textField == lookSearchBar) {        
        if (lookSearchArry.count > 0) [lookSearchArry removeAllObjects];
        
        if ([searchText isEqualToString:@""]) {
            lookSearchActive = NO;
            lookTableviewHeightContrast.constant = 0;
            [lookTableView reloadData];
            [looksCollectionView reloadData];
            
            return YES;
        }

        for (NSDictionary *dic in looksArry) {
            TypeLook *typelook = dic[@"TypeLookObject"];
            NSRange range = [typelook.name  rangeOfString: searchText options: NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                [lookSearchArry addObject:dic];
            }
        }
        
        if (lookSearchArry.count >= 2) {
            lookSearchActive = YES;
            lookTableviewHeightContrast.constant = 62;
            [lookTableView reloadData];
        } else if (lookSearchArry.count == 1) {
            lookTableviewHeightContrast.constant = 31;
            lookSearchActive = YES;
            [lookTableView reloadData];
        } else {
            lookSearchActive = YES;
            [lookTableView reloadData];
            lookTableviewHeightContrast.constant = 0;
        }
        
        [looksCollectionView reloadData];
    } else if (textField == tagsSearchBar) {
        if (tagsSearchArry.count > 0) [tagsSearchArry removeAllObjects];
        
        if ([searchText isEqualToString:@""]) {
//            lookSearchActive = NO;
            tagTableviewHeightContrast.constant = 0;
            
            [tagsTableView reloadData];
            
            return YES;
        }
        
        [self getTagsListWithStringFilter:searchText];
    }
    return YES;
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == lookTableView)
        return lookSearchArry.count;
    else {
        return tagsSearchArry.count;
    }    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    if (tableView == lookTableView) {
        // Configure the cell...
        NSDictionary *dic = [lookSearchArry objectAtIndex:indexPath.row];
        TypeLook *typeLook = dic[@"TypeLookObject"];
        
        cell.textLabel.text = typeLook.name;
        cell.textLabel.font = [UIFont fontWithName:@"AvantGarde-Book" size:14 ];
    } else if (tableView == tagsTableView) {
        // Configure the cell...
        Keyword *keyword = [tagsSearchArry objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"#%@", keyword.name];
        cell.textLabel.font = [UIFont fontWithName:@"AvantGarde-Book" size:14 ];
    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Tweak for reusing superclass function
    // Hide Add Terms text field
    if (tableView == lookTableView) {
        NSDictionary *dic = [lookSearchArry objectAtIndex:indexPath.row];
        TypeLook *typeLook = dic[@"TypeLookObject"];
        
        NSLog(@"select  %@", typeLook.name);
        [self selectLookCollectionViewCell:dic SelectOption:YES];
        [looksCollectionView reloadData];
    } else if (tableView == tagsTableView) {
        Keyword *keyword = [tagsSearchArry objectAtIndex:indexPath.row];
        for (int i = 0; i < popularTags.count; i++) {
            Keyword *kw = [popularTags objectAtIndex:i];
            if ([kw.idKeyword isEqualToString:keyword.idKeyword]) {
                if (![_selectedTags containsObject:kw]) {
                    [_selectedTags addObject:kw];
                    [self setScrollViewButtons:_selectedTags Container:selectedTagView Contrast:tagSelectedHeightContrast Type:1];
                    UIButton *btn = [tagsButtons objectAtIndex:i];
                    [btn setSelected:YES];
                    break;
                }
            }
        }
        if (![_selectedTags containsObject:keyword]) { //new add keyword
            [_selectedTags addObject:keyword];
            [self setScrollViewButtons:_selectedTags Container:selectedTagView Contrast:tagSelectedHeightContrast Type:1];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == lookTableView) {
        NSDictionary *dic = [lookSearchArry objectAtIndex:indexPath.row];
        TypeLook *typeLook = dic[@"TypeLookObject"];
        
        NSLog(@"select  %@", typeLook.name);
        
        [self selectLookCollectionViewCell:dic SelectOption:NO];
        [looksCollectionView reloadData];
    } else if (tableView == tagsTableView) {
        Keyword *keyword = [tagsSearchArry objectAtIndex:indexPath.row];
        for (int i = 0; i < popularTags.count; i++) {
            Keyword *kw = [popularTags objectAtIndex:i];
            if ([kw.idKeyword isEqualToString:keyword.idKeyword]) {
                if ([_selectedTags containsObject:kw]) {
                    [_selectedTags removeObject:kw];
                    [self setScrollViewButtons:_selectedTags Container:selectedTagView Contrast:tagSelectedHeightContrast Type:1];
                    UIButton *btn = [tagsButtons objectAtIndex:i];
                    [btn setSelected:NO];
                    break;
                }
            }
        }
    }
}
#pragma mark - Tags Filter
- (void)initializeTagsFilter
{
    UIView *containerView = nil;
    for (int i = 0; i < layerArry.count; i++) {
        UIView *view = [layerArry objectAtIndex:i];
        if (view.tag == LIVE_FILTER_TAGS) {
            view.hidden = NO;
            containerView = view;
        } else {
            view.hidden = YES;
        }
    }
    if (containerView != nil) {
        return;
    }
    
    containerView = [[UIView alloc]initWithFrame:CGRectMake(0, CATEGORY_SCROLLVIEW_HEIGHT + 5, contentView.bounds.size.width, contentView.bounds.size.height - CATEGORY_SCROLLVIEW_HEIGHT)];
    containerView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:containerView];
    _bodyScrollView.contentSize = CGSizeMake(contentView.frame.size.width, CATEGORY_SCROLLVIEW_HEIGHT + 55 + containerView.bounds.size.height);
    containerView.tag = LIVE_FILTER_TAGS;
    [layerArry addObject:containerView];
    
    LiveTagsView *tv =
    [[[NSBundle mainBundle] loadNibNamed:@"LiveTagsView" owner:self options:nil] objectAtIndex:0];
    
    tv.searchView.layer.borderColor = [UIColor grayColor].CGColor;
    tv.searchBar.delegate = self;
    tv.searchView.layer.borderWidth = 1.0f;
    tagsSearchBar = tv.searchBar;
    
    tv.tableView.layer.borderColor = [UIColor grayColor].CGColor;
    tv.tableView.layer.borderWidth = 1.0f;
    tv.tableView.delegate =self;
    tv.tableView.dataSource =self;
    tv.tableViewHeight.constant = 0;
    [tv.tableView setAllowsMultipleSelection:YES];
    
    tagTableviewHeightContrast = tv.tableViewHeight;
    tagSelectedHeightContrast = tv.selectedTagViewHeight;
    tagSelectedHeightContrast.constant = 0;
    tagsViewHeightContrast = tv.tagsViewHeight;
    tagsTableView = tv.tableView;
    tagsView = tv.tagsView;
    selectedTagView = tv.selectedTagView;
    
    tv.frame = containerView.bounds;
    [containerView addSubview: tv];
    [self getTagsList];
}
- (void)getTagsList
{
    NSInteger skip = TAGS_FILTER_SKIP;
    NSInteger limit = TAGS_FILTER_LIMIT;
    
    NSLog(@"Getting type look list...");
    NSArray * requestParameters;
    requestParameters = [[NSArray alloc] initWithObjects:@"", [NSNumber numberWithInteger:skip], [NSNumber numberWithInteger:limit], nil];
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
    
    [self performRestGet:GET_MOST_POPULAR_HASHTAG withParamaters:requestParameters];
}

- (void)getTagsListWithStringFilter:(NSString *)filterStr
{
    NSInteger skip = TAGS_FILTER_SKIP;
    NSInteger limit = TAGS_FILTER_LIMIT;
    
    NSLog(@"Getting type look list...");
    NSArray * requestParameters;
    requestParameters = [[NSArray alloc] initWithObjects:filterStr, [NSNumber numberWithInteger:skip], [NSNumber numberWithInteger:limit], nil];
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
    
    [self performRestGet:GET_HASHTAG withParamaters:requestParameters];
}

- (void)setScrollViewButtons:(NSMutableArray*)arry Container:(UIView*)container Contrast:(NSLayoutConstraint*)contrast Type:(int)type
{
    if (type == 1) {
        for (UIView *view in [container subviews]) {
            if ([view isKindOfClass:[UIButton class]]) {
                [view removeFromSuperview];
            }
        }
    }

    if (arry.count <= 0) {
        contrast.constant = 0;
        return;
    }
    
    CGRect scrRect = [[UIScreen mainScreen]bounds];
    CGFloat width = 0, height = 0;
    CGFloat widthSpace = 10, heightSpace = 5;
    NSLog(@"array count %ld", arry.count);
    
    
    for (int i = 0; i< arry.count; i++) {
        Keyword *keyword = [arry objectAtIndex:i];
        NSString *str = keyword.name;
        
        CGSize size = [str sizeWithAttributes:
                       @{NSFontAttributeName: [UIFont fontWithName:@"AvantGarde-Book" size:13]}];
        
        UIButton *btn = [self createScrollBtn:str Size:size Container:container];
        btn.tag = i;
        [btn addTarget:self action:@selector(btn_selected:) forControlEvents:UIControlEventTouchUpInside];
        if (width + btn.frame.size.width + widthSpace > scrRect.size.width) {
            width = 0;
            height += btn.frame.size.height + heightSpace;
            btn.frame = CGRectMake(width, height, btn.frame.size.width, btn.frame.size.height);
            
            width += btn.frame.size.width + widthSpace;
            
        } else {
            btn.frame = CGRectMake(width, height, btn.frame.size.width, btn.frame.size.height);
            
            width += btn.frame.size.width + widthSpace;
        }
        if (type == 0) {
            [tagsButtons addObject:btn];
            if (_selectedTags.count > 0) {
                if ([_selectedTags containsObject:keyword])
                    [btn setSelected:YES];
                else
                    [btn setSelected:NO];
                [self setScrollViewButtons:_selectedTags Container:selectedTagView Contrast:tagSelectedHeightContrast Type:1];

            } else{
                [btn setSelected:NO];
            }
                
        } else if (type == 1) {
            [btn setSelected:YES];
        }
        
        
    }
    contrast.constant = height + 30;
    
   
}

- (void)btn_selected:(UIButton*)btn
{
    NSInteger tag = btn.tag;

    UIView *view = [btn superview];
    if (view == tagsView) {
        Keyword *keyword = [popularTags objectAtIndex:tag];
        [btn setSelected:![btn isSelected]];
        NSLog(@"selected button --> %@",[popularTags objectAtIndex:tag]);
        if ([btn isSelected]) {
            [_selectedTags addObject:keyword];
        } else {
            if ([_selectedTags containsObject:keyword]) {
                [_selectedTags removeObject:keyword];
            }
        }
        [self setScrollViewButtons:_selectedTags Container:selectedTagView Contrast:tagSelectedHeightContrast Type:1];
    } else if (view == selectedTagView) {
        Keyword *keyword = [_selectedTags objectAtIndex:tag];
        if ([_selectedTags containsObject:keyword]) {
            [_selectedTags removeObject:keyword];
        }
        [self setScrollViewButtons:_selectedTags Container:selectedTagView Contrast:tagSelectedHeightContrast Type:1];
        
        for (int i = 0; i < popularTags.count; i++) {

            Keyword *kw = [popularTags objectAtIndex:i];
            if ([kw.idKeyword isEqualToString:keyword.idKeyword]) {
                UIButton *btn = [tagsButtons objectAtIndex:i];
                [btn setSelected:NO];
            }
        }
    }
    
}

- (UIButton*)createScrollBtn:(NSString*)title Size:(CGSize)size Container:(UIView*)con {
    NSString *str = [NSString stringWithFormat:@"#%@", title];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, size.width * 1.5, size.height + 3)];
    [btn setTitle:str forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:@"AvantGarde-Book" size:13]];
    
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    [con addSubview:btn];
    
    return btn;
}
#pragma mark - Product filter
- (void)initializeProductFilter
{
    UIView *containerView = nil;
    for (int i = 0; i < layerArry.count; i++) {
        UIView *view = [layerArry objectAtIndex:i];
        if (view.tag == LIVE_FILTER_PRODUCTS) {
            view.hidden = NO;
            containerView = view;
        } else {
            view.hidden = YES;
        }
    }
    if (containerView != nil) {
        return;
    }
    
    containerView = [[UIView alloc]initWithFrame:CGRectMake(0, CATEGORY_SCROLLVIEW_HEIGHT + 5, contentView.bounds.size.width, contentView.bounds.size.height - CATEGORY_SCROLLVIEW_HEIGHT)];
    containerView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:containerView];
    _bodyScrollView.contentSize = CGSizeMake(contentView.frame.size.width, CATEGORY_SCROLLVIEW_HEIGHT + 55 + containerView.bounds.size.height);
    containerView.tag = LIVE_FILTER_PRODUCTS;
    [layerArry addObject:containerView];
    
     LiveProductView *tv =
    [[[NSBundle mainBundle] loadNibNamed:@"LiveProductView" owner:self options:nil] objectAtIndex:0];
    productContainerView = tv.containerView;
    tv.backgroundColor = [UIColor whiteColor];
    tv.frame = containerView.bounds;
    [containerView addSubview: tv];
    productORBrand = YES;
    [self showProductSearchView];

}

#pragma mark - Brand filter
- (void)initializeBrandFilter
{
    UIView *containerView = nil;
    for (int i = 0; i < layerArry.count; i++) {
        UIView *view = [layerArry objectAtIndex:i];
        if (view.tag == LIVE_FILTER_BRAND) {
            view.hidden = NO;
            containerView = view;
        } else {
            view.hidden = YES;
        }
    }
    if (containerView != nil) {
        return;
    }
    
    containerView = [[UIView alloc]initWithFrame:CGRectMake(0, CATEGORY_SCROLLVIEW_HEIGHT + 5, contentView.bounds.size.width, contentView.bounds.size.height - CATEGORY_SCROLLVIEW_HEIGHT)];
    containerView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:containerView];
    _bodyScrollView.contentSize = CGSizeMake(contentView.frame.size.width, CATEGORY_SCROLLVIEW_HEIGHT + 55 + containerView.bounds.size.height);
    containerView.tag = LIVE_FILTER_BRAND;
    [layerArry addObject:containerView];
    
    LiveBrandView *tv =
    [[[NSBundle mainBundle] loadNibNamed:@"LiveBrandView" owner:self options:nil] objectAtIndex:0];
    brandContainerView = tv.containerView;
    tv.backgroundColor = [UIColor whiteColor];
    tv.frame = containerView.bounds;
    [containerView addSubview: tv];
    productORBrand = NO;

    [self showBrandSearchView];
}
- (void)showBrandSearchView
{
    
    
    if ([UIStoryboard storyboardWithName:@"Search" bundle:nil] != nil)
    {
        
        @try {
            
            _filterBrandVC = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateViewControllerWithIdentifier:[@(SEARCHBRANDFILTERS_VC) stringValue]];
            
        }
        @catch (NSException *exception) {
            
            return;
            
        }
        
        if (_filterBrandVC != nil)
        {
            //            _selectedContentToAddKeyword = nil;
            //            _selectedContentToAddKeyword = [self setClickedContentGroup:sender];
            //            long iGroup = sender.tag % kMultiplierTagForGroup;
            //            _selectedGroupToAddKeyword = [NSNumber numberWithLong:iGroup];
            [self showFilterForBrand];
        }
    }
}

-(void) showFilterForBrand
{
    [self addChildViewController:_filterBrandVC];
    
    if (self.keywordsSelected != nil)
    {
        [self.keywordsSelected removeAllObjects];
    }
    else
    {
        self.keywordsSelected = [[NSMutableArray alloc] init];
    }
    // TODO: add the existing keywords to this array self.keywordsSelected
    [_filterBrandVC setType:productORBrand? 0 : 1];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _filterBrandVC.bAutoSwap = ([[appDelegate.config valueForKey:@"tag_post_auto_swap"] boolValue] == YES);
    
    
    //[_filterSearchVC willMoveToParentViewController:self];
    
    _filterBrandVC.view.frame = CGRectMake(0,0,brandContainerView.frame.size.width, brandContainerView.frame.size.height);
    
    brandContainerView.backgroundColor = [UIColor whiteColor];
    
    [brandContainerView addSubview:_filterBrandVC.view];
    
    [_filterBrandVC didMoveToParentViewController:self];
    
    //Hide the filter terms ribbon
    [self hideSuggestedFiltersRibbonAnimated:YES];
    [self.noFilterTermsLabel setHidden:YES];
    // Set the property that controls whtether the ribbon should be shown or not
    self.bShouldShowSuggestedFiltersRibbonView = [NSNumber numberWithBool:NO];
    
    _filterBrandVC.selectedBrands = _filterbrands;
    [_filterBrandVC setSearchTerms:self.keywordsSelected];
    
    [brandContainerView setHidden:NO];
}

- (void)showProductSearchView
{
  
    
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
//            _selectedContentToAddKeyword = nil;
//            _selectedContentToAddKeyword = [self setClickedContentGroup:sender];
//            long iGroup = sender.tag % kMultiplierTagForGroup;
//            _selectedGroupToAddKeyword = [NSNumber numberWithLong:iGroup];
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
    [_filterTagVC setType:productORBrand? 0 : 1];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _filterTagVC.bAutoSwap = ([[appDelegate.config valueForKey:@"tag_post_auto_swap"] boolValue] == YES);
    
    
    //[_filterSearchVC willMoveToParentViewController:self];
    
    _filterTagVC.view.frame = CGRectMake(0,0,productContainerView.frame.size.width, productContainerView.frame.size.height);
    
    productContainerView.backgroundColor = [UIColor whiteColor];
    
    [productContainerView addSubview:_filterTagVC.view];
    
    [_filterTagVC didMoveToParentViewController:self];
    
    //Hide the filter terms ribbon
    [self hideSuggestedFiltersRibbonAnimated:YES];
    [self.noFilterTermsLabel setHidden:YES];
    // Set the property that controls whtether the ribbon should be shown or not
    self.bShouldShowSuggestedFiltersRibbonView = [NSNumber numberWithBool:NO];
    
    _filterTagVC.selectedProducts = _filterproducts;
    [_filterTagVC setSearchTerms:self.keywordsSelected];
    
    [productContainerView setHidden:NO];
}

-(void) hideFilterSearch
{
    [self closeFilterForTags];
}
- (void)closeFilterForTags
{
    return;
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    
    [[productContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
//    [productContainerView setHidden:YES];
    
//    _filterTagVC = nil;
}

#pragma mark - Backend Call
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    __block LiveStreamingCategory *liveStreamingCategoryObj;
    __block TypeLook *typeLookObj;
    __block Keyword *keywordObj;
    switch (connection) {
        case GET_LIVESTREAMINGCATEGORIES:
        {
            // Get the LiveStreaming object mapped from the API call response
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[LiveStreamingCategory class]]))
                 {
                     liveStreamingCategoryObj = obj;
                     if (liveStreamingCategoryObj.idLiveStreamingCategory != nil) {
                         if (![liveStreamingCategoryObj.idLiveStreamingCategory isEqualToString:@""]) {
                             [catArray addObject:liveStreamingCategoryObj];
                         }
                     }
                 }
             }];
            
            
            NSLog(@"%@", [NSString stringWithFormat:@"LiveStreaming successfully uploaded! Retrieved Id: %ld", (unsigned long)catArray.count]);
            [self setupCategoryView];
            
            [self stopActivityFeedback];
            break;
        }
        case GET_TYPELOOKS:
        {
            // Get the LiveStreaming object mapped from the API call response
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[TypeLook class]]))
                 {
                     typeLookObj = obj;
                     if (typeLookObj.idTypeLook != nil) {
                         if (![typeLookObj.idTypeLook isEqualToString:@""]) {
                             [typeLooks addObject:typeLookObj];
                         }
                     }
                 }
             }];
            
            
            NSLog(@"Getting TypeLook object Succesfully!");
            [looksCollectionView reloadData];
            
            [self stopActivityFeedback];
            break;
        }
        case GET_MOST_POPULAR_HASHTAG:
        {
            // Get the LiveStreaming object mapped from the API call response
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Keyword class]]))
                 {
                     keywordObj = obj;
                     if (keywordObj.idKeyword != nil) {
                         if (![keywordObj.idKeyword isEqualToString:@""]) {
                             [popularTags addObject:keywordObj];
                         }
                     }
                 }
             }];
            
            
            NSLog(@"Getting TypeLook object Succesfully!");
            [self setScrollViewButtons:popularTags Container:tagsView Contrast:tagsViewHeightContrast Type:0];
            [self stopActivityFeedback];
            break;
        }
        case GET_HASHTAG:
        {
            // Get the LiveStreaming object mapped from the API call response
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Keyword class]]))
                 {
                     keywordObj = obj;
                     if (keywordObj.idKeyword != nil) {
                         if (![keywordObj.idKeyword isEqualToString:@""]) {
                             [tagsSearchArry addObject:keywordObj];
                         }
                     }
                 }
             }];
            
            if (tagsSearchArry.count < 5) {
                tagTableviewHeightContrast.constant = 30 * tagsSearchArry.count;
            } else {
                tagTableviewHeightContrast.constant = 30 * 5;
            }
            
            NSLog(@"Getting TypeLook object Succesfully!");
            [tagsTableView reloadData];
            [self stopActivityFeedback];
            break;
        }
        
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
            
    }
}


@end
