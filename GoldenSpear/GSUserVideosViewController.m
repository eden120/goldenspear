//
//  GSDiscoverViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSUserVideosViewController.h"
#import "FashionistaPost.h"
#import "GSPostCategoryOrderManager.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+KeyboardSuggestionBarManagement.h"

#define GSPOST_CELL @"PostCell"
#define kOffsetForBottomScroll -60

@implementation GSUserVideosCollectionViewCell

@end

@implementation GSUserVideosViewController{
    NSMutableArray* resultsArray;
    NSArray* sectionsArray;
    NSString* searchString;
    NSString* sortString;
    SlideButtonView* sectionsList;
    NSString* sectionString;

    BOOL isRefreshing;
    BOOL showingOptions;
    BOOL mustRefresh;
    NSArray* optionsArray;
}

#pragma mark - ViewController override

- (void)showViewControllerModal:(UIViewController*)destinationVC withTopBar:(BOOL)topBarOrNot{
    if (self.delegate) {
        [(BaseViewController*)self.delegate showViewControllerModal:destinationVC withTopBar:topBarOrNot];
    }else{
        [super showViewControllerModal:destinationVC withTopBar:topBarOrNot];
    }
}

- (void)showViewControllerModal:(UIViewController*)destinationVC{
    if (self.delegate) {
        [(BaseViewController*)self.delegate showViewControllerModal:destinationVC];
    }else{
        [super showViewControllerModal:destinationVC];
    }
}

- (void)dismissControllerModal{
    if (self.delegate) {
        [(BaseViewController*)self.delegate dismissControllerModal];
    }else{
        [super dismissControllerModal];
    }
}

// OVERRIDE: Action to perform when user swipes to right: go to previous screen
- (void)panGesture:(UIPanGestureRecognizer *)sender{
    [self.delegate videosController:self notifyPanGesture:sender];
}

- (BOOL)hidesTopBar{
    return YES;
}

- (void)dealloc{
    self.currentSearchQuery = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    // Do any additional setup after loading the view.
    [self setupSectionsListView];
    sortString = @"";
    searchString = @"";
    sectionString = @"";

    self.postsArray = [NSMutableArray new];
    resultsArray = [NSMutableArray new];
    
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
    
    self.emptyListLabel.text = NSLocalizedString(@"_LIST_NO_VIDEOPOSTS_RESULTS_", nil);

    ((GSVideoCollectionViewLayout*)self.collectionView.collectionViewLayout).videoCollectionDelegate = self;
    [self loadCurrentQuery];
    [self setupKeyboardSuggestionBarForTextField:self.searchField];
}

// OVERRIDEN: Assign the suggested text to the textfield
-(void) updateTextFieldWithText: (NSString *)text inRange:(NSRange)range
{
    if([self.searchField.text isEqualToString:@""]||range.location==NSNotFound)
    {
        range.length = 0;
        range.location = [self.searchField.text length];
    }
    
    self.searchField.text = [self.searchField.text stringByReplacingCharactersInRange:range withString:text];
    
    [self updateTextRangeWithText:self.searchField.text];
    
    //DO NOT PERFORM SEARCH! [self textFieldShouldReturn:self.addTermTextField];
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
        
        
        [self performRestGet:GET_SEARCH_RESULTS_WITHIN_FASHIONISTAPOSTS withParamaters:requestParameters];
        
    }
}

- (void)reloadTheData{
    [self setMainFetchedResultsController:nil];
    [self setMainFetchRequest:nil];
    
    [self loadCurrentQuery];
}

- (void)configOptions{
    optionsArray = [GSPostCategoryOrderManager getPostOrderingForSection:USERPROFILE_VC];
    NSMutableArray* finalOptionsArray = [NSMutableArray new];
    NSMutableArray* finalOptionsTitlesArray = [NSMutableArray new];
    for (PostOrdering* pO in optionsArray) {
            NSString* finalString = [pO.name uppercaseString];
            if([sortString isEqualToString:pO.orderingId]){
                finalString = [NSLocalizedString(@"_NO_SORTING_FILTER_", nil) uppercaseString];
            }
            [finalOptionsTitlesArray addObject:finalString];
            [finalOptionsArray addObject:pO];
    }
    optionsArray = [NSArray arrayWithArray:finalOptionsArray];
    [self.optionsView setOptions:finalOptionsTitlesArray];
    [self.optionsView layoutIfNeeded];
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

- (void)actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult{
    NSArray * parametersForNextVC = nil;
    __block FashionistaPost * selectedSpecificPost;
    
    NSMutableArray * postContent = [[NSMutableArray alloc] init];
    __block NSNumber * postLikesNumber = [NSNumber numberWithInt:0];
    NSMutableArray * resultComments = [[NSMutableArray alloc] init];
    
    __block SearchQuery * searchQuery;
    __block User* theUser;
    
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
            
            //TODO: Mark if it comes from video
            
            NSArray* parametersForNextVC = [NSArray arrayWithObjects: theUser, [NSNumber numberWithBool:NO], nil, nil];
            [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            [self stopActivityFeedback];
            break;
        }
        case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            [self stopActivityFeedback];
            [self resetQuery];
            isRefreshing = NO;
            [self.collectionView reloadData];
            [self showEmptyList:YES];
            break;
        }
        case FINISHED_SEARCH_WITH_RESULTS:
        {   
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
                                    if(!([self.postsArray containsObject:result.fashionistaPostId]))
                                    {
                                        [self resetQuery];
                                    }
                                    isRefreshing = NO;
                                }
                                if(!([self.postsArray containsObject:result.fashionistaPostId]))
                                {
                                    [self.postsArray addObject:result.fashionistaPostId];
                                    [resultsArray addObject:result];
                                }
                            }
                        }
                    }
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
            ((GSVideoCollectionViewLayout*)self.collectionView.collectionViewLayout).forceReLayout = YES;
            [self.collectionView reloadData];
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
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

- (void)resetQuery{
    [self.postsArray removeAllObjects];
    [resultsArray removeAllObjects];
}

- (void)loadCurrentQuery{
    if (!(_shownStylist.idUser == nil))
    {
        if (!([_shownStylist.idUser isEqualToString:@""]))
        {
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            [self resetQuery];
            
            NSString* formattedSearchString = [self composeStringhWithTermsOfArray:[searchString componentsSeparatedByString:@" "] encoding:YES];
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownStylist.idUser,@"",@"2",sectionString,sortString,formattedSearchString, nil];
            
            [self performRestGet:GET_FASHIONISTAPOSTS withParamaters:requestParameters];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self fixLayout];
}

- (void)fixLayout{
    sectionsList.frame = self.sectionContainer.bounds;
    [sectionsList updateButtons];
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
    
    sectionsArray = [GSPostCategoryOrderManager getPostCategoriesForSection:USERPROFILE_VC];
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

#pragma mark - SliderButton Delegate
- (void)slideButtonView:(SlideButtonView *)slideButtonView btnClick:(int)buttonEntry
{
    [self changeSection:buttonEntry];
}

#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GSUserVideosCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    GSBaseElement* post = [resultsArray objectAtIndex:indexPath.row];
    [cell.cellImage setImageWithURL:[NSURL URLWithString:post.preview_image] placeholderImage:[UIImage imageNamed:@"no_image.png"]];
    cell.cellTitle.text = post.additionalInformation;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [resultsArray count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    NSString* postId = [self.postsArray objectAtIndex:indexPath.row];
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    GSBaseElement* post = [resultsArray objectAtIndex:indexPath.row];
    BOOL isMagazine = NO;
    if (post.post_magazinecategory != nil && ![post.post_magazinecategory isEqualToString:@""]) {
        isMagazine = YES;
    }
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:postId, [NSNumber numberWithBool:isMagazine], nil];
    
    [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 100);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.y <= kOffsetForBottomScroll)
    {
        mustRefresh = YES;
    }else{
        mustRefresh = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [(id<UIScrollViewDelegate>)self.delegate scrollViewDidScroll:scrollView];
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

- (CGFloat)numberOfItemsInCollection{
    return [self collectionView:self.collectionView numberOfItemsInSection:0];
}

@end
