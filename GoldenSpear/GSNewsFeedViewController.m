//
//  GSNewsFeedViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 12/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSNewsFeedViewController.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+UserManagement.h"
#import "SearchBaseViewController.h"
#import "FashionistaUserListViewController.h"
#import "AddItemToWardrobeViewController.h"
#import "FashionistaCoverPageViewController.h"
#import "Ad.h"

#define kOffsetForBottomScroll -60

@interface BaseViewController (Protected)

- (void)panGesture:(UIPanGestureRecognizer *)sender;
- (void)showMessageWithImageNamed:(NSString*)imageNamed;

@end

@implementation GSNewsFeedViewController{
    BOOL fromSuggested;
    BOOL showedSuggestedOnce;
    
    BOOL searchingPosts;
    
    NSString *postId;
    
    BOOL searchSuggestion;
    
    NSMutableArray *suggestList;
    BOOL magazineLoading;
    
    NSMutableArray *userWardrobesElements;
    NSMutableDictionary *gsElements;
    NSMutableArray *adList;
}

- (void)dealloc{
    postsDoubleDisplayController = nil;
    self.postsArray = nil;
    self.selectedPost = nil;
    self.selectedPostToDelete = nil;
    downloadQueue = nil;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
}

- (void)cancelCurrentSearch{
    if([downloadQueue count]>0){
        interruptedSearch = YES;
        [self resetPostsQueue];
    }
}

- (void)selectAButton{
    [self selectTheButton:self.leftButton];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self cancelCurrentSearch];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    gsElements = [NSMutableDictionary new];
    NSInteger n = 4/5;
    NSInteger m = floor(4/5);
    // Init collection views cell types
    [self setupCollectionViewsWithCellTypes:[[NSMutableArray alloc] initWithObjects:GSPOST_CELL, nil]];
    
    // Initialize results array
    if (_postsArray == nil)
    {
        _postsArray = [[NSMutableArray alloc] init];
    }
    
    // Check if there are results
    [self initFetchedResultsControllerForCollectionViewWithCellType:GSPOST_CELL WithEntity:@"FashionistaPost" andPredicate:@"idFashionistaPost IN %@" inArray:_postsArray sortingWithKeys:[NSArray arrayWithObject:@"createdAt"] ascending:NO andSectionWithKeyPath:nil];
    
    downloadedPosts = [NSMutableDictionary new];
    downloadQueue = [NSMutableArray new];
    
    [self setupPostsController];
    
    [self.startNewsfeedButton makeInsetShadowWithRadius:8 Color:[UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:0.2] Directions:[NSArray arrayWithObjects:@"top", nil]];
    
    searchingPosts = YES;
    searchSuggestion = NO;
    suggestList = [[NSMutableArray alloc] init];
    
    //Setup a fetched results controller to fetch the current user wardrobes
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!(appDelegate.addingProductsToWardrobeID == nil))
    {
        if(!([appDelegate.addingProductsToWardrobeID isEqualToString:@""]))
        {
            _addingProductsToWardrobeID = appDelegate.addingProductsToWardrobeID;
        }
    }
    
    if(appDelegate.currentUser)
    {
        [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"userId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idWardrobe" ascending:YES];
        
        if (!(_wardrobesFetchedResultsController == nil))
        {
            userWardrobesElements = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < [[_wardrobesFetchedResultsController fetchedObjects] count]; i++)
            {
                Wardrobe * tmpWardrobe = [[_wardrobesFetchedResultsController fetchedObjects] objectAtIndex:i];
                
                if([tmpWardrobe.idWardrobe isEqualToString:_addingProductsToWardrobeID])
                {
                    _addingProductsToWardrobe = tmpWardrobe;
                }
                
                [userWardrobesElements addObjectsFromArray:tmpWardrobe.itemsId];
            }
            
            _wardrobesFetchedResultsController = nil;
            _wardrobesFetchRequest = nil;
            
            [self initFetchedResultsControllerWithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:userWardrobesElements sortingWithKey:@"idGSBaseElement" ascending:YES];
        }
    }

}

- (void)fullPostReset{
    [self.postsArray removeAllObjects];
    [downloadedPosts removeAllObjects];
    [gsElements removeAllObjects];
    [self cancelCurrentSearch];
}

- (BOOL)shouldCenterTitle{
    return YES;
}

- (void)setupPostsController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BasicScreens" bundle:[NSBundle mainBundle]];
    postsDoubleDisplayController = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",DOUBLEDISPLAY_VC]];
    
    [postsDoubleDisplayController willMoveToParentViewController:self];
    [self.doubleViewContainer addSubview:postsDoubleDisplayController.view];
    [self addChildViewController:postsDoubleDisplayController];
    [postsDoubleDisplayController didMoveToParentViewController:self];
    [postsDoubleDisplayController setupAutolayout];
    
    postsDoubleDisplayController.delegate = self;
    postsDoubleDisplayController.itemsPerRow = 3;
    postsDoubleDisplayController.cellsHideHeader = NO;
    
    postsDoubleDisplayController.alwaysHideEmptyListLabel = YES;
    
    [postsDoubleDisplayController switchView];
    postsDoubleDisplayController.bFromNewsFeed = YES;
}

- (void)dismissControllerModal{
    [super dismissControllerModal];
    if(fromSuggested){
        [self showStartButton:NO];
        [self reloadTheData];
    }
    fromSuggested = NO;
}

- (void)reloadTheData{
    [self setMainFetchedResultsController:nil];
    [self setMainFetchRequest:nil];
    
    [self getSuggestionList];
    [self getAds];
    [self getUserPosts];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    BOOL showFeedback = NO;
    if(interruptedSearch){
        [self preloadAllPosts];
        interruptedSearch = NO;
        
    }else if(!finishedDownloading)
    {
        showFeedback = YES;
        // Get / Reload the Fashionista User Pages
        [self reloadTheData];
    }
    if(!showFeedback){
        [self stopActivityFeedback];
    }
    [self.doubleViewContainer layoutIfNeeded];
    
    
    [self loadDataFromServer];
}

#pragma mark - Connection functions
- (void)getSuggestionList {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
    
    [self performRestGet:GET_FOLLOWERS_FOLLOWINGS_COUNT withParamaters:requestParameters];
}

-(void)getAds {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSArray *requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, @"newsfeed", nil];
    
    [self performRestGet:GET_AD withParamaters:requestParameters];
}

- (void)getUserPosts
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    User* theUser = appDelegate.currentUser;
    if (!(theUser.idUser == nil))
    {
        if (!([theUser.idUser isEqualToString:@""]))
        {
            if(!(self.bAskingForMoreDataInDoubleDisplay))
            {
                NSLog(@"Retrieving User NewsFeed");
                
                // Perform request to get the search results
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:theUser.idUser, nil];
                
                self.bAskingForMoreDataInDoubleDisplay = YES;

                [self performRestGet:GET_USER_NEWSFEED withParamaters:requestParameters];
            }
        }
    }
}

- (void)showStartButton:(BOOL)showOrNot{
    if (showOrNot) {
        self.startNewsfeedButton.hidden = NO;
        [self.doubleViewContainer.superview sendSubviewToBack:self.doubleViewContainer];
    }else{
        self.startNewsfeedButton.hidden = YES;
        [self.startNewsfeedButton.superview sendSubviewToBack:self.startNewsfeedButton];
    }
}

- (void)showSuggestedUsersController{
    showedSuggestedOnce = YES;
    fromSuggested = YES;
    [super showSuggestedUsersController];
}

- (void)processRestConnection:(connectionType)connection WithErrorMessage:(NSArray *)errorMessage forOperation:(RKObjectRequestOperation *)operation{
    switch (connection) {
        case GET_FULL_POST:
        case GET_POST:
            if(!loadingPostInPage){
                loadingPostInPage = [downloadQueue firstObject];
                [downloadedPosts removeObjectForKey:loadingPostInPage];
                [gsElements removeObjectForKey:loadingPostInPage];
                NSInteger postIndex = -1;
                for (NSInteger i = 0; i<[self.postsArray count]&&postIndex<0; i++) {
                    NSString* postId = [self.postsArray objectAtIndex:i];
                    if ([postId isEqualToString:loadingPostInPage]) {
                        postIndex = i;
                    }
                }
                if(postIndex>=0){
                    [self.postsArray removeObjectAtIndex:postIndex];
                }
                loadingPostInPage = nil;
                [self nextInQueue];
            }
            break;
        default:
            [super processRestConnection:connection WithErrorMessage:errorMessage forOperation:operation];
            break;
    }
}

- (void)processUserListAnswer:(NSArray*)mappingResult andConnection:(connectionType)connection{
    // Paramters for next VC (ResultsViewController)
    searchingPosts = YES;
    NSArray * parametersForNextVC = [NSArray arrayWithObjects: mappingResult, [NSNumber numberWithInt:connection], nil];
    
    [self stopActivityFeedback];
    
    if ([mappingResult count] > 0)
    {
        UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
        BaseViewController *nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(USERLIST_VC) stringValue]];
        
        [self prepareViewController:nextViewController withParameters:parametersForNextVC];
        [(SearchBaseViewController*)nextViewController setSearchContext:FASHIONISTAS_LIKE];
        [self showViewControllerModal:nextViewController];
        ((FashionistaUserListViewController*)nextViewController).shownRelatedUser = _shownStylist;
        ((FashionistaUserListViewController*)nextViewController).userListMode = LIKEUSERS;
        ((FashionistaUserListViewController*)nextViewController).postId = postId;
        [self setTitleForModal:@"LIKES"];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_FOLLOWERSORFOLLOWING_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }
}

-(void)processSuggestListAnswer:(NSArray*)mappingResult {
    searchSuggestion = YES;
    [suggestList removeAllObjects];
    suggestList = [NSMutableArray new];
    if ([mappingResult count] > 0) {
        for (GSBaseElement *result in mappingResult) {
            if ([result isKindOfClass:[GSBaseElement class]]) {
                NSLog(@"User Image : %@", result.preview_image);
                NSLog(@"User Name : %@", result.mainInformation);
                NSLog(@"User Info :' %@", result.additionalInformation);
                NSLog(@"Fashionista ID : %@", result.fashionistaId);
                [self preLoadImage:result.preview_image];
                [suggestList addObject:result];
            }
        }
    }
    
    [postsDoubleDisplayController setSuggestList:suggestList];
}

- (void)actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult{
    
    NSArray * parametersForNextVC = nil;
    __block FashionistaPost * selectedSpecificPost;
    
    NSMutableArray * postContent = [[NSMutableArray alloc] init];
    __block NSNumber * postLikesNumber = [NSNumber numberWithInt:0];
    NSMutableArray * resultComments = [[NSMutableArray alloc] init];
    
    __block SearchQuery * searchQuery;
    
    switch (connection) {
            
        case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            self.bAskingForMoreDataInDoubleDisplay = NO;

            [self stopActivityFeedback];
            if ([self.postsArray count]==0) {
                [self stopActivityFeedback];
                [self showStartButton:YES];
                if(!showedSuggestedOnce){
                    [self showSuggestedUsersController];
                }
            }
            isRefreshing = NO;
            break;
        }
        case FINISHED_SEARCH_WITH_RESULTS:
        {
            self.bAskingForMoreDataInDoubleDisplay = NO;

            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[SearchQuery class]]))
                 {
                     searchQuery = obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            if (searchQuery.numresults > 0) {
                if (!searchingPosts) {
                    [self stopActivityFeedback];
                    [self processUserListAnswer:mappingResult andConnection:connection];
                    break;
                }
            }
            
            self.currentQuery = searchQuery;
            
            if([mappingResult count] > 0)
            {
                // Get the list of results that were provided
                for (GSBaseElement *result in mappingResult)
                {
                    if([result isKindOfClass:[GSBaseElement class]])
                    {
                        if(!(result.fashionistaPostId == nil))
                        {
                            NSLog(@"Fashionista Post ID : %@", result.fashionistaPostId);
                            NSLog(@"Fashionista : %@", result.posttype);
                            if  (!([result.fashionistaPostId isEqualToString:@""]))
                            {
                                if(isRefreshing){
                                    
                                    [self fullPostReset];
                                    isRefreshing = NO;
                                }
                                if(!([self.postsArray containsObject:result.fashionistaPostId]))
                                {
                                    [self preLoadImage:result.preview_image];
                                    if(result.content_type&&[result.content_type integerValue]==1){
                                        [self preLoadImage:result.content_url];
                                    }
                                    [self.postsArray addObject:result.fashionistaPostId];
                                    [downloadedPosts setObject:[result postParamsFromBaseElement] forKey:result.fashionistaPostId];
                                    [gsElements setObject:result forKey:result.fashionistaPostId];
                                    [postsDoubleDisplayController newDataObjectGathered:[result postParamsFromBaseElement]];
                                }
                            }
                            
                            searchSuggestion = NO;
                        }
                        else {
                            searchSuggestion = YES;
                            
                            if (![suggestList containsObject:result]) {
                                [self preLoadImage:result.preview_image];
                                [suggestList addObject:result];
                            }
                        }
                    }
                }
            }
            
            if (searchSuggestion) {
                searchSuggestion = NO;
                self.currentUserQuery = searchQuery;
                [postsDoubleDisplayController setSuggestList:suggestList];
//                [suggestList removeAllObjects];
//                suggestList = [NSMutableArray new];
                break;
            }

            // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
            if ([self getFetchedResultsControllerForCellType:GSPOST_CELL ] == nil)
            {
                [self initFetchedResultsControllerForCollectionViewWithCellType:GSPOST_CELL WithEntity:@"FashionistaPost" andPredicate:@"idFashionistaPost IN %@" inArray:_postsArray sortingWithKeys:[NSArray arrayWithObjects:@"createdAt", nil]  ascending:NO andSectionWithKeyPath:nil];
            }
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:GSPOST_CELL];
            if ([self.postsArray count]==0) {
                [self showStartButton:YES];
                if(!showedSuggestedOnce){
                    [self showSuggestedUsersController];
                }
            }else{
                [self showStartButton:NO];
                [self stopActivityFeedback];
                //[self preloadAllPosts];
                [postsDoubleDisplayController refreshData];
            }
            if(isRefreshing){
                isRefreshing = NO;
                [self stopActivityFeedback];
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
            parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], selectedSpecificPost, postContent, resultComments, [NSNumber numberWithBool:NO], postLikesNumber, postUser, self.selectedElement, nil];
            
            if(loadingPostInPage&&[loadingPostInPage isEqualToString:selectedSpecificPost.idFashionistaPost]){
                loadingPostInPage = nil;
                [self stopActivityFeedback];
                [self nextInQueue];
                if((!([parametersForNextVC count] < 2)) && ([postContent count] > 0))
                {
                    if (magazineLoading) {
                        [self transitionToViewController:FASHIONISTACOVERPAGE_VC withParameters:parametersForNextVC];
                    }
                    else {
                        [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
                    }
                }
            }else{
                if(!(selectedSpecificPost.idFashionistaPost==nil))
                {
                    if(cancelOperation){
                        cancelOperation = NO;
                    }else{
                        [downloadedPosts setObject:parametersForNextVC forKey:selectedSpecificPost.idFashionistaPost];
                        [postsDoubleDisplayController newDataObjectGathered:parametersForNextVC];
                    }
                }
                [self nextInQueue];
                
            }
            [self stopActivityFeedback];
            break;
        }
        case GET_AD:
        {
            [adList removeAllObjects];
            adList = [NSMutableArray new];
            for (Ad *result in mappingResult) {
                if ([result isKindOfClass:[Ad class]]) {
                    [adList addObject:result];
                }
            }
            
            if ([adList count]>0) {
                [postsDoubleDisplayController setAdList:adList];
            }
        }
        case GET_POST:
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
                                //[resultComments addObject:comment.idComment];
                                [resultComments addObject:comment];
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
                            if(!([postContent containsObject:content]))
                            {
                                [postContent addObject:content];
                                [self preLoadImage:content.image];
                                //[UIImage cachedImageWithURL:content.image];
                            }
                        }
                    }
                }
            }
            
            // Get the list of contents that were provided
            for (User *content in mappingResult)
            {
                if([content isKindOfClass:[User class]])
                {
                    if(!(content.idUser == nil))
                    {
                        if  (!([content.idUser isEqualToString:@""]))
                        {
                            postUser = content;
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], selectedSpecificPost, postContent, resultComments, [NSNumber numberWithBool:NO], postLikesNumber, postUser, nil];
            
            if(loadingPostInPage&&[loadingPostInPage isEqualToString:selectedSpecificPost.idFashionistaPost]){
                loadingPostInPage = nil;
                [self stopActivityFeedback];
                [self nextInQueue];
                if((!([parametersForNextVC count] < 2)) && ([postContent count] > 0))
                {
                    [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
                }
            }else{
                if(!(selectedSpecificPost.idFashionistaPost==nil))
                {
                    if(cancelOperation){
                        cancelOperation = NO;
                    }else{
                        [downloadedPosts setObject:parametersForNextVC forKey:selectedSpecificPost.idFashionistaPost];
                        [postsDoubleDisplayController newDataObjectGathered:parametersForNextVC];
                    }
                }
                [self nextInQueue];
                
            }
            [self stopActivityFeedback];
            break;
        }
        case GET_FOLLOWERS_FOLLOWINGS_COUNT:
        {
            NSNumber * numberFollowers = (NSNumber*)[[mappingResult firstObject] valueForKey:@"followers"];
            NSNumber * numberFollowings = (NSNumber*)[[mappingResult firstObject] valueForKey:@"followings"];
            
            int iNumberOfFollowers = [numberFollowers intValue];
            int iNumberOfFollowing = [numberFollowings intValue];
            
            if (iNumberOfFollowing + iNumberOfFollowers < 500) {
                searchSuggestion = YES;
                
                AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
                NSArray *requestParameters = [[NSArray alloc] initWithObjects:@"", @"suggested", appDelegate.currentUser.idUser, nil];
            
                [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAS withParamaters:requestParameters];
            }
            break;
        }
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

#pragma mark - DoubleViewDelegate

- (NSInteger)getNumberOfCompleteDownloadedPosts{
    NSInteger i = 0;
    NSDictionary* checkDict = downloadedPosts;
    for (id object in [checkDict allValues]) {
        if ([object isKindOfClass:[NSArray class]]) {
            i++;
        }
    }
    return i;
}

//Gets the total number of Posts fetched
- (NSInteger)getNumberOfPostsDownloaded{
    
    return [self.postsArray count];
}

- (void)showAvailabilityDetailViewWithURLString:(NSString*)sURL
{
    NSString *url = [NSString stringWithFormat:@"http://%@", sURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    [self setTopBarTitle:[NSURL URLWithString:url].host andSubtitle:nil];
    self.webContainerVC.hidden = NO;
    [self.view bringSubviewToFront:self.webContainerVC];
    [self bringBottomControlsToFront];
    [self bringTopBarToFront];
}

-(void)swipeRightAction {
    [self setTopBarTitle:NSLocalizedString(@"_VCTITLE_101_", nil) andSubtitle:nil];
    
    if(!self.webContainerVC.hidden)
    {
        [self closeAvailiabilityDetailView];
    }
}

- (void)closeAvailiabilityDetailView
{
    [UIView transitionWithView:self.webContainerVC
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:^{
                        [self.view bringSubviewToFront:self.doubleViewContainer];
                        [self bringBottomControlsToFront];
                        [self bringTopBarToFront];
                        self.webContainerVC.hidden = YES;
                    }
                    completion:^(BOOL finished){
                        
                    }];
    
}

#pragma mark GSDoubleDisplayDelegate
-(void)doubleDisplay:(GSDoubleDisplayViewController *)displayController openPostFromAD:(NSString*)postID {
    magazineLoading = false;
    [self resetPostsQueue];
    self.selectedPost = postID;
    loadingPostInPage = self.selectedPost;
    [downloadQueue addObject:self.selectedPost];
    [self processQueue];
}

-(void)doubleDisplay:(GSDoubleDisplayViewController *)displayController openProfileFromAD:(NSString*)profileID {
    
}

-(void)doubleDisplay:(GSDoubleDisplayViewController *)displayController openProductFromAD:(NSString*)productID {
    
}

-(void)doubleDisplay:(GSDoubleDisplayViewController *)displayController openWebFromAD:(NSString*)webLink {
    NSString *urlStr = webLink;
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
    urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    //            NSInteger colon = [urlStr rangeOfString:@":"].location;
    //
    //            if (colon != NSNotFound)
    //            {
    //                urlStr = [urlStr substringFromIndex:colon]; // strip off existing scheme
    //
    //                urlStr = [@"https" stringByAppendingString:urlStr];
    //            }
    
    NSURL * url = [NSURL URLWithString:urlStr];
    NSLog(@"Host : %@", url.host);
    [self setTopBarTitle:url.host andSubtitle:@""];
    [self showAvailabilityDetailViewWithURLString:urlStr];
    
    // purchase statistics
    //[self uploadProductPurchase];
    
    return;
}

- (NSInteger)numberOfSectionsInDataForDoubleDisplay:(GSDoubleDisplayViewController *)displayController forMode:(GSDoubleDisplayMode)displayMode{
    switch (displayMode) {
        case GSDoubleDisplayModeCollection:
            return 0;
            break;
            
        case GSDoubleDisplayModeList:
            return [self getNumberOfCompleteDownloadedPosts];
            break;
    }
}

- (NSInteger)doubleDisplay:(GSDoubleDisplayViewController *)displayController numberOfRowsInSection:(NSInteger)section forMode:(GSDoubleDisplayMode)displayMode{
    switch (displayMode) {
        case GSDoubleDisplayModeCollection:
            return [self getNumberOfPostsDownloaded];
            break;
            
        case GSDoubleDisplayModeList:
            return 1;
            break;
    }
}

- (id)doubleDisplay:(GSDoubleDisplayViewController *)displayController objectForRowAtIndexPath:(NSIndexPath *)indexPath forMode:(GSDoubleDisplayMode)displayMode{
    switch (displayMode) {
        case GSDoubleDisplayModeCollection:
            return [self.postsArray objectAtIndex:indexPath.item];
            break;
            
        case GSDoubleDisplayModeList:
            return [self.postsArray objectAtIndex:indexPath.section];
            break;
    }
}

- (id)doubleDisplay:(GSDoubleDisplayViewController *)displayController dataForRowAtIndexPath:(NSIndexPath *)indexPath forMode:(GSDoubleDisplayMode)displayMode{
    switch (displayMode) {
        case GSDoubleDisplayModeCollection:
            return [self getSimplePostDataAtIndexPath:indexPath];
            break;
        case GSDoubleDisplayModeList:
            return [self getExtendedPostDataAtIndexPath:indexPath];
            break;
    }
    
}

- (void)doubleDisplay:(GSDoubleDisplayViewController *)displayController selectItemAtIndexPath:(NSIndexPath *)indexPath isMagazine:(BOOL)isMagazine{
    if(![[self activityIndicator] isHidden])
        return;
    magazineLoading = isMagazine;
    [self openPostAtIndexPath:indexPath];
}

- (void)openPostAtIndexPath:(NSIndexPath *)indexPath{
    
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    [self resetPostsQueue];
    self.selectedPost = [self.postsArray objectAtIndex:indexPath.item];
    _selectedElement = [gsElements objectForKey:self.selectedPost];
    loadingPostInPage = self.selectedPost;
    [downloadQueue addObject:self.selectedPost];
    [self processQueue];
}

- (void)doubleDisplay:(GSDoubleDisplayViewController *)displayController notifyPanGesture:(UIPanGestureRecognizer *)sender{
    [super panGesture:sender];
}

- (void)doubleDisplay:(GSDoubleDisplayViewController *)displayController objectDeleted:(id)object{
    [downloadedPosts removeObjectForKey:object];
    
    [self getUserPosts];
    self.selectedPostToDelete = nil;
    
    // Update Fetched Results Controller
    [self performFetchForCollectionViewWithCellType:GSPOST_CELL];
    
    // Update collection view
    [self updateCollectionViewWithCellType:GSPOST_CELL fromItem:0 toItem:-1 deleting:FALSE];
    [postsDoubleDisplayController refreshData];
}

- (void)doubleDisplay:(GSDoubleDisplayViewController*)displayController commentDeleted:(NSInteger)comment fromPost:(NSString*)idPost{
    NSMutableArray* postData = [NSMutableArray arrayWithArray:[downloadedPosts objectForKey:idPost]];
    if ([postData count]>3) {
        NSMutableArray* comments = [NSMutableArray arrayWithArray:[postData objectAtIndex:3]];
        [comments removeObjectAtIndex:comment];
        [postData replaceObjectAtIndex:3 withObject:comments];
        [downloadedPosts setObject:postData forKey:idPost];
    }
}

- (void)doubleDisplay:(GSDoubleDisplayViewController*)displayController commentAdded:(Comment*)comment toPost:(NSString*)idPost updated:(NSInteger)updatedIndex{
    if (updatedIndex>=0) {
        [self updateComment:comment inPost:idPost atIndex:updatedIndex];
    }else{
        [self addTheComment:comment inPost:idPost];
    }
}

- (void)addTheComment:(Comment*)comment inPost:(NSString*)idPost{
    NSMutableArray* postData = [NSMutableArray arrayWithArray:[downloadedPosts objectForKey:idPost]];
    NSMutableArray* comments = [NSMutableArray arrayWithArray:[postData objectAtIndex:3]];
    [comments addObject:comment];
    [postData replaceObjectAtIndex:3 withObject:comments];
    [downloadedPosts setObject:postData forKey:idPost];
}

- (void)updateComment:(Comment*)comment inPost:(NSString*)idPost atIndex:(NSInteger)index{
    NSMutableArray* postData = [NSMutableArray arrayWithArray:[downloadedPosts objectForKey:idPost]];
    NSMutableArray* comments = [NSMutableArray arrayWithArray:[postData objectAtIndex:3]];
    
    [comments replaceObjectAtIndex:index withObject:comment];
    [postData replaceObjectAtIndex:3 withObject:comments];
    [downloadedPosts setObject:postData forKey:idPost];
}

- (void)doubleDisplay:(GSDoubleDisplayViewController *)vC viewProfilePushed:(User *)theUser{
    [self startActivityFeedbackWithMessage:@""];
    NSArray* parametersForNextVC = [NSArray arrayWithObjects: theUser, [NSNumber numberWithBool:NO], nil, nil];
    [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
    [self dismissControllerModal];
}

- (void)doubleDisplay:(NSString*)postid {
    NSArray * requestParameters = [[NSArray alloc] initWithObjects: postid, nil];
    
    searchingPosts = NO;
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    //_shownStylist = user;
    
    postId = postid;
    [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAS_LIKE_POST withParamaters:requestParameters];
}

- (GSBaseElement*)getElement:(id)content {
    NSString *fashionistaPostId = [content objectAtIndex:1];
    GSBaseElement *element = [gsElements objectForKey:fashionistaPostId];
    return element;
}

- (void)addToWardrobe:(id)content button:(UIButton *)sender{
    NSLog(@"Add Wardrobe");
    
    NSString *fashionistaPostId = [content objectAtIndex:1];
    GSBaseElement *element = [gsElements objectForKey:fashionistaPostId];
    
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
    
    //Calculate the actual section in FetchedResultsController
    
    if(!(element == nil))
    {
        if (!([self doesCurrentUserWardrobesContainItemWithId:element]))
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
                    [addItemToWardrobeVC setItemToAdd:element];
                    
                    NSLog(@"IdBaseElement : %@", element.idGSBaseElement);
                    
                    [addItemToWardrobeVC setButtonToHighlight:sender];
                    
                    [self addChildViewController:addItemToWardrobeVC];
                    
                    //[addItemToWardrobeVC willMoveToParentViewController:self];
                    
                    addItemToWardrobeVC.view.frame = CGRectMake(0,0,_wardrobeVC.frame.size.width, _wardrobeVC.frame.size.height);
                    
                    [_wardrobeVC addSubview:addItemToWardrobeVC.view];
                    
                    [addItemToWardrobeVC didMoveToParentViewController:self];
                    
                    [_wardrobeVC setHidden:NO];
                    
                    [_wardrobeBackground setHidden:NO];
                    
                    [self.view bringSubviewToFront:_wardrobeBackground];
                    
                    [self.view bringSubviewToFront:_wardrobeVC];
                }
            }
        }
    }

}

#pragma mark - Post Getting functions

- (void)getPostFromGSServer:(NSString*)thePost{
    if(!([thePost isEqualToString:@""]))
    {
        // Perform request to get the result contents
        // Provide feedback to user
        if(loadingPostInPage){
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
        }
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:thePost, [NSNumber numberWithBool:magazineLoading], nil];
        
        [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
    }
}

- (NSArray *)getSimplePostDataAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item>=[self.postsArray count]) {
        return nil;
    }
    FashionistaPost * tmpPost = [self.postsArray objectAtIndex:indexPath.item];
    
    BOOL bShowHanger = YES;
    
    NSArray * cellContent = [NSArray arrayWithObjects: tmpPost, [NSNumber numberWithBool:bShowHanger], [NSNumber numberWithBool:NO], nil];
    
    return cellContent;
}

- (NSArray *)getExtendedPostDataAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section>=[self.postsArray count]) {
        return nil;
    }
    
    //FashionistaPost * tmpPost = [self.selectedPagePosts objectAtIndex:indexPath.row];
    NSString * tmpPost = [self.postsArray objectAtIndex:indexPath.section];
    
    //Check dictionary if post has been downloaded
    id maybePost = [downloadedPosts objectForKey:tmpPost];
    
    if([maybePost isKindOfClass:[NSArray class]]){
        return maybePost;
    }else if(![maybePost isKindOfClass:[NSNumber class]]||interruptedSearch)
    {
        //Download the data
        if(!(tmpPost == nil))
        {
            [downloadedPosts setObject:[NSNumber numberWithInteger:indexPath.section] forKey:tmpPost];
            
            [downloadQueue addObject:tmpPost];
            [self processQueue];
        }
    }
    
    return nil;
}

- (void)processQueue{
    if(!downloadingInQueue){
        if([downloadQueue count]>0){
            downloadingInQueue = YES;
            NSString* thePost = [downloadQueue firstObject];
            [self getPostFromGSServer:thePost];
        }else{
            finishedDownloading = YES;
        }
    }
}

- (BOOL)nextInQueue{
    if(downloadingInQueue){
        downloadingInQueue = NO;
        if ([downloadQueue count]>0) {
            [downloadQueue removeObjectAtIndex:0];
        }
    }
    [self processQueue];
    
    return ([downloadQueue count]>0);
}

- (void)preloadAllPosts{
    if ([self.postsArray count]==0) {
        [self stopActivityFeedback];
    }else if([self.postsArray count]!=[downloadedPosts count]){
        finishedDownloading = NO;
    }
    for (int i = 0; i<[self.postsArray count]; i++) {
        [self getExtendedPostDataAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
    }
    [postsDoubleDisplayController refreshData];
}

- (void)resetPostsQueue{
    FashionistaPost* postToSave = nil;
    if(downloadingInQueue){
        cancelOperation = YES;
        postToSave = [downloadQueue firstObject];
    }
    [downloadQueue removeAllObjects];
    if(postToSave){
        [downloadQueue addObject:postToSave];
    }
    
    NSMutableDictionary* savedPosts = [NSMutableDictionary new];
    //Delete all posts non-downloaded from list
    for (NSString* key in [downloadedPosts allKeys]) {
        id entry = [downloadedPosts objectForKey:key];
        if([entry isKindOfClass:[NSArray class]]){
            [savedPosts setObject:entry forKey:key];
        }
    }
    downloadedPosts = savedPosts;
}

- (void)resetPostsForFiltering{
    if(downloadingInQueue){
        cancelOperation = YES;
    }
    [downloadQueue removeAllObjects];
    [self nextInQueue];
    
    [self.postsArray removeAllObjects];
    [gsElements removeAllObjects];
    
    NSMutableDictionary* savedPosts = [NSMutableDictionary new];
    
    //Delete all posts non-downloaded from list
    for (NSString* key in [downloadedPosts allKeys]) {
        id entry = [downloadedPosts objectForKey:key];
        if([entry isKindOfClass:[NSArray class]]){
            [savedPosts setObject:entry forKey:key];
        }
    }
    downloadedPosts = savedPosts;
    [self getUserPosts];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ((scrollView.contentOffset.y <= kOffsetForBottomScroll) && (scrollView.isDragging))
    {
        isRefreshing = YES;
        [self reloadTheData];
    }
}

- (void)updateSearch
{
    // Check that the string to search is valid
    if (!((_currentQuery == nil) || ([_currentQuery.idSearchQuery isEqualToString:@""])))
    {
        if(!(self.bAskingForMoreDataInDoubleDisplay))
        {
            NSLog(@"Performing search with terms: %@", _currentQuery.searchQuery);
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_currentQuery, [NSNumber numberWithInteger:[self.postsArray count]], nil];
            
            self.bAskingForMoreDataInDoubleDisplay = YES;
            searchSuggestion = YES;
            
            [self performRestGet:GET_SEARCH_RESULTS_WITHIN_NEWSFEED withParamaters:requestParameters];
        }
    }
}

- (void)updateUserSearch
{
    // Check that the string to search is valid
    if (!((_currentUserQuery == nil) || ([_currentUserQuery.idSearchQuery isEqualToString:@""])))
    {
        if(!(self.bAskingForMoreDataInDoubleDisplay))
        {
            NSLog(@"Performing search with terms: %@", _currentUserQuery.searchQuery);
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_currentUserQuery, [NSNumber numberWithInteger:[suggestList count]], nil];
            
            self.bAskingForMoreDataInDoubleDisplay = YES;
            searchSuggestion = YES;
            
            [self performRestGet:GET_SEARCH_RESULTS_WITHIN_NEWSFEED withParamaters:requestParameters];
        }
    }
}


- (void)askForMoreDataInDoubleDisplay:(GSDoubleDisplayViewController *)vC{
    
        NSInteger currentItems = [self getNumberOfCompleteDownloadedPosts];
        NSInteger searchResults = [self.currentQuery.numresults integerValue];
        if(currentItems<searchResults){
            [self updateSearch];
            
        }
}

- (void)askForMoreUserInDoubleDisplay:(GSDoubleDisplayViewController *)vC{
    
    NSInteger currentItems = [suggestList count];
    NSInteger searchResults = [self.currentUserQuery.numresults integerValue];
    if(currentItems<searchResults){
        [self updateUserSearch];
        
    }
}

- (IBAction)showSuggestedUsers:(id)sender {
    [self showSuggestedUsersController];
}

- (void)doubleDisplayLikeUpdatingFinished{
    
}

- (void)showMessageWithImageNamed:(NSString *)imageNamed andSharedObject:(Share *)sharedObject{
    self.currentSharedObject = sharedObject;
    [self showMessageWithImageNamed:imageNamed];
}

-(void)uploadPostSharedIn:(NSString *) sSocialNetwork
{
    // Check that the name is valid
    
    if (!(self.currentSharedObject.sharedPostId == nil))
    {
        if(!([self.currentSharedObject.sharedPostId isEqualToString:@""]))
        {
            // Post the FashionistaPostShared object
            
            FashionistaPostShared * newPostShared = [[FashionistaPostShared alloc] init];
            
            newPostShared.socialNetwork = sSocialNetwork;
            
            [newPostShared setPostId:self.currentSharedObject.sharedPostId];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newPostShared setUserId:appDelegate.currentUser.idUser];
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
    [self uploadPostSharedIn:sSocialNetwork];
}

-(void)showFullVideo:(NSInteger)orientation {
    if ([self.postsArray count] <= 0) {
        return;
    }
    FullVideoViewController *fullVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FullVideoViewController"];
    fullVC.modalPresentationStyle = UIModalPresentationPopover;
    fullVC.orientation = orientation;
    NSString* url = [postsDoubleDisplayController getCurrentVideoURL];
    if (url == nil || [url isEqualToString:@""]) {
        return;
    }
    
    fullVC.currentTime = [postsDoubleDisplayController getCurrentTime];
    fullVC.isSound = [postsDoubleDisplayController hasSoundNow];
    fullVC.videoURL = url;
    fullVC.delegate = self;
    [self presentViewController:fullVC animated:YES completion:nil];
}

-(void)setPlayer:(CMTime)time hasSound:(BOOL)sound{
    [postsDoubleDisplayController setCurrentTime:time hassound:sound];
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

- (BOOL) doesCurrentUserWardrobesContainItemWithId:(GSBaseElement *)item
{
    NSString * itemId = @"";
    
    _wardrobesFetchedResultsController = nil;
    _wardrobesFetchRequest = nil;
    
    [self initFetchedResultsControllerWithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:userWardrobesElements sortingWithKey:@"idGSBaseElement" ascending:YES];
    
    if (!(item == nil))
    {
        
        if(!(item.productId == nil))
        {
            if(!([item.productId isEqualToString:@""]))
            {
                itemId = item.productId;
            }
        }
        else if(!(item.wardrobeQueryId == nil))
        {
            if(!([item.wardrobeQueryId isEqualToString:@""]))
            {
                itemId = item.wardrobeQueryId;
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
    
    [[_wardrobeVC subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    //[[self.childViewControllers lastObject] didMoveToParentViewController:nil];
    
    [_wardrobeVC setHidden:YES];
    
    [_wardrobeBackground setHidden:YES];
}

@end
