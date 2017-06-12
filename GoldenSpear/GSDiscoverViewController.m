//
//  GSDiscoverViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSDiscoverViewController.h"
#import "FashionistaPost.h"
#import "GSPostCategoryOrderManager.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+KeyboardSuggestionBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "Ad.h"
#import "BaseViewController+TopBarManagement.h";

#define GSPOST_CELL @"PostCell"
#define kOffsetForBottomScroll -60
#define TIME_DURATION       4

#define ADNUM   4

@implementation GSDiscoverHomeTableViewCell

- (void)prepareForReuse{
    self.cellImage.image = [UIImage imageNamed:@"no-image.png"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UILongPressGestureRecognizer* longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longRecognizer];
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Long Press Start HOME");
        [self.cellDelegate longPressedHomeCell:self];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.cellDelegate closeHomeQV];
        NSLog(@"Long Press End");
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

@end


@implementation GSDiscoverCollectionViewCell

- (void)prepareForReuse{
    self.cellImage.image = [UIImage imageNamed:@"no-image.png"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UILongPressGestureRecognizer* longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longRecognizer];
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.cellDelegate longPressedCollectionCell:self];
        NSLog(@"Long Press Start");
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.cellDelegate closeCollectionQV];
        NSLog(@"Long Press End");
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

@end

@implementation GSDiscoverViewController{
    NSMutableArray* premiumPosts;
    NSMutableArray* normalPosts;
    
    NSMutableArray* resultsArray;
    NSArray* sectionsArray;
    NSString* searchString;
    BOOL homeStyle;
    NSString* sortString;
    SlideButtonView* sectionsList;
    NSString* sectionString;
    UIView* visibleScrollView;
    BOOL isRefreshing;
    BOOL showingOptions;
    BOOL mustRefresh;
    NSArray* optionsArray;
    NSString* loadingUser;
    BOOL loadingProfileFromVideo;
    
    BOOL hasLoadedData;
    
    NSTimer *timer;
    
    NSInteger homeselectedIndex;
    NSInteger collectionselectedIndex;
    
    BOOL isHomeTable;
    
    NSMutableArray *adList;
    GSBaseElement *selectedElement;
}

- (void)dealloc{
    self.currentSearchQuery = nil;
}

- (void)selectAButton{
    [self selectTheButton:self.middleRightButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    homeStyle = YES;
    [self setupSectionsListView];
    sortString = @"";
    searchString = @"";
    sectionString = @"";
    [self setupListLayout];
    
    self.postsArray = [NSMutableArray new];
    resultsArray = [NSMutableArray new];
    premiumPosts = [NSMutableArray new];
    normalPosts = [NSMutableArray new];
    
    self.optionsView.viewDelegate = self;
    //Must re-add height constraint because it is broken for comming from another nib
    self.optionsViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.optionsView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute: NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:46];
    [self.optionsView addConstraint:self.optionsViewHeightConstraint];
    
    self.emptyListLabel.text = NSLocalizedString(@"_LIST_NO_DISCOVER_RESULTS_", nil);
    
    ((GSDiscoverCollectionViewLayout*)self.collectionView.collectionViewLayout).discoverCollectionDelegate = self;
    [self getAds];
    [self loadCurrentQuery];
    [self setupKeyboardSuggestionBarForTextField:self.searchField];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BasicScreens" bundle:[NSBundle mainBundle]];
    _quickVC = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",QUICKVIEW_VC]];
    
    homeselectedIndex = 0;
    collectionselectedIndex = 0;
    
    isHomeTable = YES;
}

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
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_currentSearchQuery, [NSNumber numberWithInteger:[self.postsArray count]], nil];
        
        
        [self performRestGet:GET_SEARCH_RESULTS_WITHIN_DISCOVER withParamaters:requestParameters];
        
    }
}

- (void)reloadTheData{
    [self setMainFetchedResultsController:nil];
    [self setMainFetchRequest:nil];
    
    [self loadCurrentQuery];
}

- (void)configOptions{
    optionsArray = [GSPostCategoryOrderManager getPostOrderingForSection:DISCOVER_VC];
    NSMutableArray* finalOptionsArray = [NSMutableArray new];
    NSMutableArray* finalOptionsTitlesArray = [NSMutableArray new];
    for (PostOrdering* pO in optionsArray) {
        if (!homeStyle||[pO.visibleInLandingPage boolValue]) {
            NSString* finalString = [pO.name uppercaseString];
            if([sortString isEqualToString:pO.orderingId]){
                finalString = [NSLocalizedString(@"_NO_SORTING_FILTER_", nil) uppercaseString];
            }
            [finalOptionsTitlesArray addObject:finalString];
            [finalOptionsArray addObject:pO];
        }
    }
    optionsArray = [NSArray arrayWithArray:finalOptionsArray];
    [self.optionsView setOptions:finalOptionsTitlesArray];
    [self.optionsView layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)setupListLayout{
    if(homeStyle){
        self.homeTableView.hidden = NO;
        [self.homeTableView.superview sendSubviewToBack:self.collectionView];
        self.collectionView.hidden = YES;
        visibleScrollView = self.homeTableView;
    }else{
        self.collectionView.hidden = NO;
        [self.collectionView.superview sendSubviewToBack:self.homeTableView];
        self.homeTableView.hidden = YES;
        visibleScrollView = self.collectionView;
        ((GSDiscoverCollectionViewLayout*)self.collectionView.collectionViewLayout).forceReLayout = YES;
    }
    [self showEmptyList:NO];
    [visibleScrollView performSelector:@selector(reloadData)];
}

- (void)showEmptyList:(BOOL)showOrNot{
    if (showOrNot) {
        self.emptyListLabel.hidden = NO;
        [self.emptyListLabel.superview bringSubviewToFront:self.emptyListLabel];
    }else{
        self.emptyListLabel.hidden = YES;
        [self.emptyListLabel.superview sendSubviewToBack:self.emptyListLabel];
    }
}

- (void)processHomeResults:(NSArray*)mappingResult{
    [self resetQuery];
    // Get the list of results that were provided
    for (GSBaseElement *result in mappingResult)
    {
        if([result isKindOfClass:[GSBaseElement class]])
        {
            if(!(result.fashionistaPostId == nil))
            {
                if  (!([result.fashionistaPostId isEqualToString:@""]))
                {
                    //[UIImage cachedImageWithURL:result.preview_image];
                    [self preLoadImage:result.preview_image];
                    [self.postsArray addObject:result.fashionistaPostId];
                    [resultsArray addObject:result];
                }
            }
        }
    }
}

- (void)processFilteredResults:(NSArray*)mappingResult{
    // Get the list of results that were provided
    for (GSBaseElement *result in mappingResult)
    {
        if([result isKindOfClass:[GSBaseElement class]])
        {
            if(!(result.fashionistaPostId == nil))
            {
                if  (!([result.fashionistaPostId isEqualToString:@""]))
                {
                    if(isRefreshing){
                        if(!([self.postsArray containsObject:result.fashionistaPostId])||homeStyle)
                        {
                            [self resetQuery];
                        }
                        isRefreshing = NO;
                    }
                    if(!([self.postsArray containsObject:result.fashionistaPostId]))
                    {
                        [self preLoadImage:result.preview_image];
                        if(result.premium!=nil&&[result.premium boolValue]){
                            [premiumPosts addObject:result];
                        }else{
                            [normalPosts addObject:result];
                        }
                        /*
                        [self.postsArray addObject:result.fashionistaPostId];
                        [resultsArray addObject:result];
                         */
                    }
                }
            }
        }
    }
}

- (void)actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult{
    NSArray * parametersForNextVC = nil;
    __block FashionistaPost * selectedSpecificPost;
    
    NSMutableArray * postContent = [[NSMutableArray alloc] init];
    __block NSNumber * postLikesNumber = [NSNumber numberWithInt:0];
    NSMutableArray * resultComments = [[NSMutableArray alloc] init];
    
    __block SearchQuery * searchQuery;
    __block User* theUser;
    
    __block User *currentUser;
    
    switch (connection) {
        case GET_FASHIONISTAWITHNAME:
        {
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     theUser = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            
            NSArray* parametersForNextVC = [NSArray arrayWithObjects: theUser, [NSNumber numberWithBool:NO], [NSNumber numberWithBool:loadingProfileFromVideo], nil];
            [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            [self stopActivityFeedback];
            break;
        }
        case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            [self stopActivityFeedback];
            hasLoadedData = YES;
            [self resetQuery];
            isRefreshing = NO;
            [self setupListLayout];
            [self showEmptyList:YES];
            break;
        }
        case FINISHED_SEARCH_WITH_RESULTS:
        {
            hasLoadedData = YES;
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[SearchQuery class]]))
                 {
                     searchQuery = obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            self.currentSearchQuery = searchQuery;
            
            if([mappingResult count] > 0)
            {
                if(homeStyle){
                    [self processHomeResults:mappingResult];
                }else{
                    [self processFilteredResults:mappingResult];
                }
            }
            
            // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
            if ([self getFetchedResultsControllerForCellType:GSPOST_CELL ] == nil)
            {
                [self initFetchedResultsControllerForCollectionViewWithCellType:GSPOST_CELL WithEntity:@"FashionistaPost" andPredicate:@"idFashionistaPost IN %@" inArray:_postsArray sortingWithKeys:[NSArray arrayWithObjects:@"createdAt", nil]  ascending:NO andSectionWithKeyPath:nil];
            }
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:GSPOST_CELL];
            if(isRefreshing){
                isRefreshing = NO;
            }
            [self stopActivityFeedback];
            [self setupListLayout];
            if([self.postsArray count]>0){
                [self showEmptyList:NO];
            }else{
                [self showEmptyList:YES];
            }
            break;
        }
        case GET_FULL_POST:
        {
            User* postUser = nil;
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
            
            postContent = [NSMutableArray arrayWithArray:[selectedSpecificPost.contents allObjects]];
            
            if (loadingUser) {
                loadingProfileFromVideo = NO;
                for (FashionistaContent *content in postContent)
                {
                    if(content.video&&![content.video isEqualToString:@""]){
                        loadingProfileFromVideo = YES;
                    }
                }
                [self loadFashionista:loadingUser];
                loadingUser = nil;
            }else{
                // Get the list of contents that were provided
                for (FashionistaContent *content in postContent)
                {
                    [self preLoadImage:content.image];
                    //[UIImage cachedImageWithURL:content.image];
                }
                
                postUser = selectedSpecificPost.author;
                
                // Paramters for next VC (ResultsViewController)
                parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], selectedSpecificPost, postContent, resultComments, [NSNumber numberWithBool:NO], postLikesNumber, postUser, selectedElement, self.currentSearchQuery, nil];
                
                
                if((!([parametersForNextVC count] < 2)) && ([postContent count] > 0))
                {
                    [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
                }
                [self stopActivityFeedback];
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
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

- (void)resetQuery{
    [self.postsArray removeAllObjects];
    [resultsArray removeAllObjects];
    [premiumPosts removeAllObjects];
    [normalPosts removeAllObjects];
}

- (void)loadCurrentQuery{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    User* theUser = appDelegate.currentUser;
    if (!(theUser.idUser == nil))
    {
        if (!([theUser.idUser isEqualToString:@""]))
        {
            NSLog(@"Retrieving User Discover");
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            [self resetQuery];
            hasLoadedData = NO;
            [self setupListLayout];
            homeStyle = NO;
            if([sectionString isEqualToString:@""]&&
               [sortString isEqualToString:@""]&&
               [searchString isEqualToString:@""]){
                homeStyle = YES;
            }
            NSString* formattedSearchString = [self composeStringhWithTermsOfArray:[searchString componentsSeparatedByString:@" "] encoding:YES];
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:theUser.idUser,sectionString,sortString,formattedSearchString, nil];
            
            [self performRestGet:GET_USER_DISCOVER withParamaters:requestParameters];
        }
    }
}

-(void)getAds {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSArray *requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, @"discover", nil];
    
    [self performRestGet:GET_AD withParamaters:requestParameters];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    sectionsList.frame = self.sectionContainer.bounds;
}

-(void)setupSectionsListView
{
    sectionsList = [SlideButtonView new];
    
    [self.sectionContainer addSubview:sectionsList];
    
    sectionsList.frame = self.sectionContainer.bounds;
    
    sectionsList.delegate = self;
    
    [sectionsList setMinWidthButton:5];
    
    [sectionsList setSpaceBetweenButtons:0];
    [sectionsList setBShowShadowsSides:YES];
    [sectionsList setBUppercaseButtonsText:YES];
    [sectionsList setFont:[UIFont fontWithName:@"Avenir-medium" size:16]];
    [sectionsList setPaddingButton:10];
    
    SlideButtonProperties* properties = [SlideButtonProperties new];
    properties.colorSelectedTextButtons = [UIColor blackColor];
    properties.colorTextButtons = [UIColor colorWithRed:227./255. green:227./255. blue:227./255. alpha:1];
    
    [sectionsList setColorSelectedTextButtons:[UIColor blackColor]];
    [sectionsList setColorTextButtons:[UIColor colorWithRed:227./255. green:227./255. blue:227./255. alpha:1]];
    sectionsList.typeSelection = HIGHLIGHT_TYPE;
    sectionsList.bUnselectWithClick = YES;
    
    [sectionsList setSNameButtonImageHighlighted:@"termListButtonBackground.png"];
    
    sectionsArray = [GSPostCategoryOrderManager getPostCategoriesForSection:DISCOVER_VC];
    for (PostCategory* pC in sectionsArray) {
        [sectionsList addButton:pC.name withProperties:properties];
    }
    [sectionsList setBackgroundColor:[UIColor clearColor]];
    [sectionsList setColorBackgroundButtons:[UIColor clearColor]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sortPush:(UIButton*)sender {
    [self.view endEditing:YES];
    [self showOptions:YES fromPoint:sender.center];
}

- (void)showOptions:(BOOL)showOrNot fromPoint:(CGPoint)anchor{
    showingOptions = showOrNot;
    
    if (showOrNot) {
        [self configOptions];
        self.optionsView.superview.alpha = 1;
        [self.optionsView moveAngleToPosition:anchor.x];
        [self.optionsView.superview layoutIfNeeded];
        
        [self.optionsView.superview.superview bringSubviewToFront:self.optionsView.superview];
    }else{
        [self.optionsView.superview.superview sendSubviewToBack:self.optionsView.superview];
        self.optionsView.superview.alpha = 0;
    }
}

- (void)optionsView:(GSOptionsView *)optionView heightChanged:(CGFloat)newHeight{
    self.optionsViewHeightConstraint.constant = newHeight;
    [self.optionsView layoutIfNeeded];
}

- (void)optionsView:(GSOptionsView *)optionView selectOptionAtIndex:(NSInteger)option{
    if ([optionsArray count]>option) {
        PostOrdering* selectedOrdering = [optionsArray objectAtIndex:option];
        if([selectedOrdering.orderingId isEqualToString:sortString]){
            sortString = @"";
        }else{
            sortString = selectedOrdering.orderingId;
        }
        [self loadCurrentQuery];
    }
    [self closeOptions:nil];
}

- (IBAction)headerPushed:(UIButton*)sender {
    [sectionsList selectButton:(int)sender.tag];
    [self changeSection:(int)sender.tag];
}

- (IBAction)closeOptions:(id)sender {
    if(showingOptions){
        [self showOptions:NO fromPoint:CGPointZero];
    }
}

- (void)loadFashionista:(NSString*)userName{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:userName, nil];
    
    [self performRestGet:GET_FASHIONISTAWITHNAME withParamaters:requestParameters];
}

- (IBAction)userPushed:(UIButton *)sender {
    [self.view endEditing:YES];
    NSString* postId = [self.postsArray objectAtIndex:sender.tag];
    selectedElement = [resultsArray objectAtIndex:sender.tag];
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:postId, nil];
    
    loadingUser = sender.titleLabel.text;
    [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
}

- (IBAction)searchPushed:(id)sender {
    if(![searchString isEqualToString:self.searchField.text]){
        searchString = self.searchField.text;
        [self loadCurrentQuery];
    }
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self searchPushed:nil];
    return YES;
}

- (void)changeSection:(int)buttonEntry{
    [self.view endEditing:YES];
    if([sectionsList isSelected:buttonEntry]){
        sectionString = ((PostCategory*)[sectionsArray objectAtIndex:buttonEntry]).categoryId;
    }else{
        sectionString = @"";
    }
    //Reset current filters
    self.searchField.text = @"";
    sortString = @"";
    searchString = @"";
    [self loadCurrentQuery];
}

#pragma mark - ViewController override

- (void)showViewControllerModal:(UIViewController*)destinationVC withTopBar:(BOOL)topBarOrNot{

    [super showViewControllerModal:destinationVC withTopBar:topBarOrNot];
}

- (void)showViewControllerModal:(UIViewController*)destinationVC{
    [super showViewControllerModal:destinationVC];
}

- (void)dismissControllerModal{
    [super dismissControllerModal];
}


#pragma mark - SliderButton Delegate
- (void)slideButtonView:(SlideButtonView *)slideButtonView btnClick:(int)buttonEntry
{
    [self changeSection:buttonEntry];
}

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSDiscoverHomeTableViewCell* cell = (GSDiscoverHomeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"homeCell" forIndexPath:indexPath];
    GSBaseElement* post = [resultsArray objectAtIndex:indexPath.row];
    NSString* sectionTitle = ((PostCategory*)[sectionsArray objectAtIndex:indexPath.row]).name;
    cell.headerButton.tag = indexPath.row;
    cell.sectionLabel.text = [sectionTitle uppercaseString];
    cell.cellImage.clipsToBounds = YES;
    [cell.cellImage setImageWithURL:[NSURL URLWithString:post.preview_image] placeholderImage:[UIImage imageNamed:@"no_image_big.png"]];
    cell.cellTitle.text = post.additionalInformation;
    cell.cellDelegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [resultsArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (homeStyle) {
        return 1;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    NSString* postId = [self.postsArray objectAtIndex:indexPath.row];
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    GSBaseElement* post = [resultsArray objectAtIndex:indexPath.row];
    selectedElement = post;
    BOOL isMagazine = NO;
    if (post.post_magazinecategory != nil && ![post.post_magazinecategory isEqualToString:@""]) {
        isMagazine = YES;
    }
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:postId, [NSNumber numberWithBool:isMagazine], nil];
    
    loadingUser = NO;
    [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSBaseElement* post = [resultsArray objectAtIndex:indexPath.row];
    if ([post.additionalInformation isEqualToString:@"gs_dummy"]){
        return 0;
    }
    return tableView.rowHeight;
}

#pragma mark - GSDiscoverHomeTableViewCell Protocol
- (void)longPressedHomeCell:(GSDiscoverHomeTableViewCell *)theCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:theCell.headerButton.tag inSection:0];
    GSBaseElement *post = [resultsArray objectAtIndex:theCell.headerButton.tag];
    homeselectedIndex = theCell.headerButton.tag;
    isHomeTable = YES;
    [self showViewControllerModal:_quickVC withTopBar:NO];
    _quickVC.delegate = self;
    _quickVC.itemIndexPath = indexPath;
    [_quickVC setPostWithPost:post];
    [self startTimer];
}

-(void)closeHomeQV {
    [self dismissControllerModal];
    [self stopTimer];
}

#pragma mark - Timer
-(void)startTimer {
    [self stopTimer];
    timer = [NSTimer scheduledTimerWithTimeInterval:TIME_DURATION
                                             target:self
                                           selector:@selector(showProductFullView)
                                           userInfo:nil
                                            repeats:NO];
}

-(void)stopTimer {
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
}

-(void)showProductFullView {
    [self stopTimer];
    
    [_quickVC imageTapped:nil];
}

#pragma mark - QuickView protocol

- (void)detailTappedForQuickView:(GSQuickViewViewController*)vC{
    
    [self dismissControllerModal];
    [self.view endEditing:YES];
    
    NSString* postId;
    
    if (isHomeTable) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:homeselectedIndex inSection:0];
        postId = [self.postsArray objectAtIndex:homeselectedIndex];

        [_homeTableView deselectRowAtIndexPath:indexPath animated:NO];
        selectedElement = [resultsArray objectAtIndex:homeselectedIndex];
    }
    else {
        postId = [self.postsArray objectAtIndex:collectionselectedIndex];
        selectedElement = [resultsArray objectAtIndex:collectionselectedIndex];
    }
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:postId, nil];
    
    loadingUser = NO;
    [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
}

- (void)commentContentForQuickView:(GSQuickViewViewController*)vC{
    
}

- (void)quickView:(GSQuickViewViewController *)vC viewProfilePushed:(User *)theUser{
    
}
#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (!homeStyle) {
        return 1;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GSDiscoverCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    if (indexPath.row % ADNUM == ADNUM - 1) {
        int index = indexPath.row / ADNUM;
        if (index < [adList count]) {
            Ad *result = [adList objectAtIndex:index];
            NSString *imageURL = [NSString stringWithFormat: @"%@%@", IMAGESBASEURL, result.image];
            [cell.cellImage setImageWithURL:[NSURL URLWithString:imageURL]];
            
            return cell;
        }
    }
    GSBaseElement* post = [resultsArray objectAtIndex:indexPath.row];
    cell.cellImage.clipsToBounds = YES;
    [cell.cellImage setImageWithURL:[NSURL URLWithString:post.preview_image] placeholderImage:[UIImage imageNamed:@"no_image_big.png"]];
    cell.cellTitle.text = post.additionalInformation;
    [cell.userButton setTitle:post.mainInformation forState:UIControlStateNormal];
    cell.userButton.tag = indexPath.row;
    cell.cellDelegate = self;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [resultsArray count] + [adList count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    int index = indexPath.row / ADNUM;
    
    if (indexPath.row % ADNUM == ADNUM - 1) {
        
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
                
                loadingUser = NO;
                [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
            }
            return;
        }
    }
    NSString* postId = [self.postsArray objectAtIndex:indexPath.row];
    selectedElement = [resultsArray objectAtIndex:indexPath.row];
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:postId, [NSNumber numberWithBool:NO], nil];
    
    loadingUser = NO;
    [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 100);
}

#pragma mark - GSDiscoverCollectionViewCell Protocol
- (void)longPressedCollectionCell:(GSDiscoverCollectionViewCell *)theCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:theCell.userButton.tag inSection:0];
    _quickVC.itemIndexPath = indexPath;
    GSBaseElement *post = [resultsArray objectAtIndex:theCell.userButton.tag];
    collectionselectedIndex = theCell.userButton.tag;
    isHomeTable = NO;
    [self showViewControllerModal:_quickVC withTopBar:NO];
    _quickVC.delegate = self;
    _quickVC.itemIndexPath = indexPath;
    [_quickVC setPostWithPost:post];
    [self startTimer];

}

- (void)closeCollectionQV {
    [self dismissControllerModal];
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.y <= kOffsetForBottomScroll)
    {
        mustRefresh = YES;
    }else{
        mustRefresh = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset == 0)
    {
        // then we are at the top
    }
    else if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight)
    {
        NSInteger searchResults = [self.currentSearchQuery.numresults integerValue];
        if([self.postsArray count]<searchResults){
            [self updateSearch];
        }
    }
    if(mustRefresh){
        isRefreshing = YES;
        [self reloadTheData];
    }
    mustRefresh = NO;
}

#pragma mark - CollectionLayout

- (void)finishedLayouting:(NSArray *)outPostsIdOrder andOutPosts:(NSArray *)outPostsOrder{
    self.postsArray = [NSMutableArray arrayWithArray:outPostsIdOrder];
    resultsArray = [NSMutableArray arrayWithArray:outPostsOrder];
    if([self.postsArray count]>0||!hasLoadedData){
        [self showEmptyList:NO];
    }else{
        [self showEmptyList:YES];
    }
}

- (NSArray *)getAllPosts{
    NSArray* array = [NSArray arrayWithObjects:premiumPosts,normalPosts, nil];
    return array;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void)swipeRightAction{
    
    if (!self.webViewContainer.hidden) {
        [self closeAvailiabilityDetailView];
        return;
    }
    if(homeStyle){
        [super swipeRightAction];
    }else{
        [self.view endEditing:YES];
        [sectionsList unselectButtons];
        
        sectionString = @"";
        self.searchField.text = @"";
        sortString = @"";
        searchString = @"";
        [self loadCurrentQuery];
    }
}

#pragma mark - Suggested Bar

-(void) updateTextFieldWithText: (NSString *)text inRange:(NSRange)range
{
    if([self.searchField.text isEqualToString:@""])
    {
        range.length = 0;
        range.location = 0;
    }
    
    self.searchField.text = [self.searchField.text stringByReplacingCharactersInRange:range withString:text];
    
    [self updateTextRangeWithText:self.searchField.text];
    
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
                if([[self.textRange lastObject] length] >= [self.searchField.text length])
                {
                    [self.textRange removeLastObject];
                }
            }
        }
    }
    
    return YES;
}

- (void)middleRightAction:(UIButton *)sender{
    if(!homeStyle){
        [self swipeRightAction];
    }
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
    self.webViewContainer.hidden = NO;
    [self.view bringSubviewToFront:self.webViewContainer];
    [self bringBottomControlsToFront];
//    [self bringTopBarToFront];
}

- (void)closeAvailiabilityDetailView
{
    [self setTopBarTitle:NSLocalizedString(@"_VCTITLE_104_", nil) andSubtitle:nil];
    
    [UIView transitionWithView:self.webViewContainer
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:^{
                        [self.view bringSubviewToFront:self.homeTableView];
                        [self.view bringSubviewToFront:self.collectionView];
                        [self bringBottomControlsToFront];
  //                      [self bringTopBarToFront];
                        self.webViewContainer.hidden = YES;
                    }
                    completion:^(BOOL finished){
                        
                    }];
    
}

//- (void)bringTopBarToFront
//{
//    [self.view bringSubviewToFront:self.topBarView];
//    
//    [self.view bringSubviewToFront:self.activityIndicator];
//    [self.view bringSubviewToFront:self.activityLabel];
//    [self.view bringSubviewToFront:self.hintBackgroundView];
//    [self.view bringSubviewToFront:self.hintView];
//}

@end
