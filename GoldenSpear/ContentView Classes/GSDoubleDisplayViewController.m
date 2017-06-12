//
//  GSDoubleDisplayViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 29/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSDoubleDisplayViewController.h"

#import "AppDelegate.h"
#import "GSContentViewPost.h"

#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"

#import "FashionistaAddCommentViewController.h"
#import "UILabel+CustomCreation.h"
#import "GSImageTaggableView.h"
#import "GSSuggestionCell.h"
#import "UIImageView+WebCache.h"
#import "Ad.h"

#define GSImageCollectionId @"imageCollectionCell"
#define GSPostCollectionId  @"postCollectionCell"
#define GSPostCollectionHeaderId  @"postCollectionHeaderView"
#define GSSuggestCollectionId  @"suggestionCell"
#define GSPostLoadingId  @"postLoadingCell"
#define TIME_DURATION       4

#define ADNUM  3
@interface BaseViewController (protected)

- (void)showMessageWithImageNamed:(NSString*)imageNamed;

@end

@interface GSDoubleDisplayViewController (){
    NSMutableDictionary* postCellExpanded;
    NSMutableDictionary* postCellHeights;
    NSMutableDictionary* userLikesPosts;
    NSMutableDictionary* postsInOperations;
    NSMutableDictionary* heightChangeReasons;
    NSMutableDictionary* postIndexes;
    
    UIView* currentlyVisibleCollectionView;
    
    GSContentViewPost* _processingPost;
    
    BOOL mustDownloadMoreData;
    
    NSInteger numberOfRowsOnLastRedraw;
    
    NSInteger updatingCommentIndex;
    
    NSInteger commentToDelete;
    
    NSString* _processingPostId;
    
    BOOL showingOptions;
    
    NSArray* optionHandlers;
    
    NSMutableDictionary* commentIndexDict;
    
    NSMutableArray* visibleCells;
    
    NSTimer *timer;
    NSInteger timeDuration;
    NSInteger currentIndex;
    /*
     BOOL pendingRefresh;
    BOOL isScrolling;
    BOOL blockReload;
    NSTimer* reloadControlTimer;
     */
    
    BOOL isGETLIKE;
    
    NSMutableArray *suggestList;
    NSIndexPath *selectedPath;
    
    NSMutableArray *adList;
    
    GSBaseElement *selectedElement;
}

@end

@implementation GSDoubleDisplayViewController

- (void)dealloc{
    self.imagesQueue = nil;
    postCellHeights = nil;
    userLikesPosts = nil;
    postsInOperations = nil;
    heightChangeReasons = nil;
    postCellExpanded = nil;
    currentlyVisibleCollectionView = nil;
    _processingPost = nil;
    _processingPostId = nil;
    postIndexes = nil;
    visibleCells = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //Set collections
    [self.collectionView setCollectionCellIdentifiers:@[GSImageCollectionId] withClasses:@[[GSImageCollectionViewCell class]]];
    self.cellsHideHeader = NO;
    currentlyVisibleCollectionView = self.collectionView;
    
    postCellHeights = [NSMutableDictionary new];
    userLikesPosts = [NSMutableDictionary new];
    postsInOperations = [NSMutableDictionary new];
    heightChangeReasons = [NSMutableDictionary new];
    postCellExpanded = [NSMutableDictionary new];
    postIndexes = [NSMutableDictionary new];
    
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    
    [self.listView registerNib:[UINib nibWithNibName:@"GSContentSectionHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:GSPostCollectionHeaderId];
    self.mainCollectionCellType = @"CommentCell";
    self.emptyListLabel.text = NSLocalizedString(@"_LIST_NO_IMAGEPOSTS_RESULTS_", nil);
    
    self.optionsView.viewDelegate = self;
    
    visibleCells = [NSMutableArray new];
    isGETLIKE = NO;
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BasicScreens" bundle:[NSBundle mainBundle]];
    _quickVC = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",QUICKVIEW_VC]];
    
    timeDuration = 0;
    suggestList = [[NSMutableArray alloc] init];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    for (GSPostTableViewCell* cell in visibleCells) {
        [cell resumeDisplayingCell];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopVisibleCells];
}

- (void)setupAutolayout{
    //Height
    NSLayoutConstraint* aConstraint = [NSLayoutConstraint constraintWithItem:self.view.superview
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1
                                                                    constant:0];
    [self.view.superview addConstraint:aConstraint];
    
    //Width
    aConstraint = [NSLayoutConstraint constraintWithItem:self.view.superview
                                               attribute:NSLayoutAttributeWidth
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self.view
                                               attribute:NSLayoutAttributeWidth
                                              multiplier:1
                                                constant:0];
    [self.view.superview addConstraint:aConstraint];
    
    //Center Hori
    aConstraint = [NSLayoutConstraint constraintWithItem:self.view.superview
                                               attribute:NSLayoutAttributeCenterX
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self.view
                                               attribute:NSLayoutAttributeCenterX
                                              multiplier:1
                                                constant:0];
    [self.view.superview addConstraint:aConstraint];
    //Center Vert
    aConstraint = [NSLayoutConstraint constraintWithItem:self.view.superview
                                               attribute:NSLayoutAttributeCenterY
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self.view
                                               attribute:NSLayoutAttributeCenterY
                                              multiplier:1
                                                constant:0];
    [self.view.superview addConstraint:aConstraint];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.optionsViewHeight = [NSLayoutConstraint constraintWithItem:self.optionsView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute: NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:46];
    [self.optionsView addConstraint:self.optionsViewHeight];
}

- (void)setupStandAlone{
    if (self.delegate) {
        [self hideTopBar];
    }else{
        
    }
}

- (void)setDelegate:(id<GSDoubleDisplayDelegate>)delegate{
    _delegate = delegate;
    [self setupStandAlone];
}

- (void)quickViewLikeUpdatingFinished{
    //[self dismissControllerModal];
    [self.delegate doubleDisplayLikeUpdatingFinished];
}

- (void)showMessageWithImageNamed:(NSString *)imageNamed andSharedObject:(Share *)sharedObject{
    self.currentSharedObject = sharedObject;
    [self showMessageWithImageNamed:imageNamed];
}

-(void) showMessageWithImageNamed:(NSString *)imageName{
    if (self.delegate) {
        [self.delegate showMessageWithImageNamed:imageName andSharedObject:self.currentSharedObject];
    }else{
        [super showMessageWithImageNamed:imageName];
    }
}

- (void)showHintsFirstTime{
    if (self.delegate) {
        [(BaseViewController*)self.delegate showHintsFirstTime];
    }else{
        
    }
}

- (void)hintAction:(UIButton *)sender{
    if (self.delegate) {
        [(BaseViewController*)self.delegate hintAction:sender];
    }else{
        
    }
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
    [self.delegate doubleDisplay:self notifyPanGesture:sender];
}

- (void)actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult{
    __block User * currentUser;
    
    NSArray * parametersForNextVC;
    NSManagedObjectContext *currentContext;
    Wardrobe* _wardrobeSelected = nil;
    
    __block id selectedSpecificResult;
    NSMutableArray * resultContent = [[NSMutableArray alloc] init];
    NSMutableArray * resultReviews = [[NSMutableArray alloc] init];
    NSMutableArray * resultAvailabilities = [[NSMutableArray alloc] init];
    NSMutableArray *review_array = [[NSMutableArray alloc] init];
    
    switch (connection)
    {
        case GET_WARDROBE:
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
            parametersForNextVC = [NSArray arrayWithObjects:_wardrobeSelected, [NSNumber numberWithBool:FALSE], selectedElement, nil];
            [self stopActivityFeedback];
            
            [self transitionToViewController:WARDROBECONTENT_VC withParameters:parametersForNextVC];
            break;
        }
        case UPLOAD_SHARE:
        {
            // Get the list of comments that were provided
            for (Share *newShare in mappingResult)
            {
                if([newShare isKindOfClass:[Share class]])
                {
                    [self socialShareActionWithShareObject:((Share*) newShare) andPreviewImage:[UIImage cachedImageWithURL:_processingPost.preview_image]];
                    
                    break;
                }
            }
            _processingPost = nil;
            break;
        }
        case GET_FASHIONISTAWITHNAME:
        {
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     currentUser = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            if(currentUser){
                
                if (isGETLIKE) {
                    [self.delegate doubleDisplay:currentUser];
                    [self stopActivityFeedback];
                    isGETLIKE = NO;
                    break;
                }
                
                [self.delegate doubleDisplay:self viewProfilePushed:currentUser];
            }
            
            [self stopActivityFeedback];

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
            BOOL _currentUserLikesPost = NO;
            GSContentViewPost* thePost = nil;
            // Get the list of comments that were provided
            for (NSMutableDictionary *userLikesPostDict in mappingResult)
            {
                if([userLikesPostDict isKindOfClass:[NSMutableDictionary class]])
                {
                    NSNumber * like = [userLikesPostDict objectForKey:@"like"];
                    NSString * postId = [userLikesPostDict objectForKey:@"post"];
                    [userLikesPosts setObject:like forKey:postId];
                    
                    _currentUserLikesPost = (like.intValue > 0);
                    thePost = [postsInOperations objectForKey:postId];
                    [postsInOperations removeObjectForKey:postId];
                }
            }
            [thePost setLikeState:_currentUserLikesPost];
            break;
        }
        case GET_ONLYPOST_LIKES_NUMBER:
        {
            NSNumber* _postLikesNumber;
            // Get the list of comments that were provided
            for (NSMutableDictionary *postLikesNumberDict in mappingResult)
            {
                if([postLikesNumberDict isKindOfClass:[NSMutableDictionary class]])
                {
                    _postLikesNumber = [postLikesNumberDict objectForKey:@"likes"];
                }
            }
            
            [_processingPost setLikesNumber:[_postLikesNumber integerValue]];
            _processingPost = nil;
            break;
        }
        case LIKE_POST:
        case UNLIKE_POST:
        {
            /*
            BOOL _currentUserLikesPost = ((connection == LIKE_POST) ? (YES) : (NO));
            
            [_processingPost setLikeState:_currentUserLikesPost];
             */
            // Reload Post Likes
            
            if(!(_processingPost.thePostId == nil))
            {
                if(!([_processingPost.thePostId isEqualToString:@""]))
                {
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:_processingPost.thePostId, nil];
                    
                    [self performRestGet:GET_ONLYPOST_LIKES_NUMBER withParamaters:requestParameters];
                }
            }
            
            [self.delegate doubleDisplayLikeUpdatingFinished];
            [self stopActivityFeedback];
            break;
        }
        case GET_USER:
        {
            //Maybe re-layout post content
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
                            uploadedComment = content;
                            break;
                        }
                    }
                }
            }
            if(![self performFetchForCollectionViewWithCellType:@"CommentCell"])
            {
                [self initFetchedResultsControllerForCollectionViewWithCellType:@"CommentCell" WithEntity:@"Comment" andPredicate:@"idComment IN %@" inArray:@[uploadedComment.idComment] sortingWithKeys:[NSArray arrayWithObject:@"date"] ascending:NO andSectionWithKeyPath:nil];
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
            
            [self.delegate doubleDisplay:self commentAdded:uploadedComment toPost:_processingPostId updated:updatingCommentIndex];
            
            if(updatingCommentIndex<0){
                [self updateHeightForItemAtRow:[[postIndexes objectForKey:_processingPostId] integerValue]];
            }
            [self refreshData:YES];
            //[self.listView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
            
            [self stopActivityFeedback];
            
            [self closeWriteComment];
            
            _processingPost = nil;
            _processingPostId = nil;
            break;
        }
        case DELETE_POST:
        {
            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            //[currentContext deleteObject:_processingPost.thePost];
            
            [currentContext processPendingChanges];
            
            if (![currentContext save:nil])
            {
                NSLog(@"Save did not complete successfully.");
            }
            [postCellHeights removeObjectForKey:_processingPost.thePostId];
            [userLikesPosts removeObjectForKey:_processingPost.thePostId];
            
            //Tell the delegate!
            [self.delegate doubleDisplay:self objectDeleted:_processingPost.thePostId];
            
            _processingPost = nil;
            
            [self stopActivityFeedback];
            [self performSelector:@selector(refreshData) withObject:nil afterDelay:0.1];
            
            break;
        }
        case DELETE_COMMENT:
        {
            [self.delegate doubleDisplay:self commentDeleted:commentToDelete fromPost:_processingPost.thePostId];
            [self updateHeightForItemAtRow:[[postIndexes objectForKey:_processingPost.thePostId] integerValue]];
            for(NSString* idComment in [commentIndexDict allKeys]){
                NSInteger indexValue = [[commentIndexDict objectForKey:idComment] integerValue];
                if (indexValue>commentToDelete) {
                    [commentIndexDict setValue:[NSNumber numberWithInteger:indexValue-1] forKey:idComment];
                }
            }
            
            [self stopActivityFeedback];
            
            _processingPost = nil;
            [self refreshData:YES];
            break;
        }
        case POST_FOLLOW:
        {
            [((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser.unfollowedPosts removeObjectForKey:_processingPost.thePostId];
            _processingPost = nil;
            break;
        }
        case POST_UNFOLLOW:
        {
            [((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser.unfollowedPosts setObject:[mappingResult firstObject] forKey:_processingPost.thePostId];
            _processingPost = nil;
            break;
        }
        case POST_NO_NOTICES:
        {
            [((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser.unnoticedPosts setObject:[mappingResult firstObject] forKey:_processingPost.thePostId];
            _processingPost = nil;
            break;
        }
        case POST_YES_NOTICES:
        {
            [((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser.unnoticedPosts removeObjectForKey:_processingPost.thePostId];
            _processingPost = nil;
            break;
        }
        case GET_PRODUCT:
        {
            //bGettingDataOfElement = NO;
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
            parametersForNextVC = [NSArray arrayWithObjects: @"ProductAdd", selectedSpecificResult, resultContent, resultReviews, resultAvailabilities, review_array, nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:PRODUCTSHEET_VC withParameters:parametersForNextVC];
            
            break;
        }

        default:
            break;
    }
}

#pragma mark - Data control for double view

- (void)switchView{
    currentlyVisibleCollectionView.hidden = YES;
    self.showingExtendedView = !self.showingExtendedView;
    if (self.showingExtendedView) {
        currentlyVisibleCollectionView = self.listView;
    }else{
        currentlyVisibleCollectionView = self.collectionView;
    }
    currentlyVisibleCollectionView.hidden = NO;
    [currentlyVisibleCollectionView.superview bringSubviewToFront:currentlyVisibleCollectionView];
    [self refreshVisibleView];
}

- (void)refreshData{
    [self refreshData:NO];
}

- (void)refreshVisibleView{
    [self refreshData:YES];
}

- (void)refreshData:(BOOL)onlyVisible{
    [self selfCheckMoreData];
    if(onlyVisible){
        [currentlyVisibleCollectionView performSelector:@selector(reloadData)];
    }else{
        [self.listView reloadData];
        [self.collectionView reloadData];
    }
}

- (void)selfCheckMoreData{
    NSInteger total = [self.delegate doubleDisplay:self numberOfRowsInSection:0 forMode:GSDoubleDisplayModeCollection];
    NSInteger downloaded = [self.delegate numberOfSectionsInDataForDoubleDisplay:self forMode:GSDoubleDisplayModeList];
    mustDownloadMoreData = (downloaded < total);
    if(total>0||self.alwaysHideEmptyListLabel){
        self.emptyListLabel.hidden = YES;
        [self.emptyListLabel.superview sendSubviewToBack:self.emptyListLabel];
    }else{
        self.emptyListLabel.hidden = NO;
        [self.emptyListLabel.superview bringSubviewToFront:self.emptyListLabel];
    }
}

- (void)setItemsPerRow:(NSInteger)itemsPerRow{
    if (itemsPerRow<=0) {
        itemsPerRow=1;
    }
    _itemsPerRow = itemsPerRow;
}

- (void)setSuggestList:(NSMutableArray*)data {
    [suggestList removeAllObjects];
    suggestList = [NSMutableArray new];
    
    for (int i = 0; i < [data count]; i ++) {
        GSBaseElement *gs = [data objectAtIndex:i];
        if (![self doesCurrentUserFollowsStylistWithId:gs.fashionistaId]) {
            [suggestList addObject:gs];
        }
    }
    
    if ([suggestList count] < 5) {
        [self.delegate updateUserSearch];
    }
    //suggestList = data;
    [_listView reloadData];
}

-(void)setAdList:(NSMutableArray*)data {
    [adList removeAllObjects];
    adList = [NSMutableArray new];
    
    adList = data;
}

- (void)newDataObjectGathered:(NSArray*)data{
    BOOL completePost = [[data firstObject] boolValue];
    NSString* postId;
    if(completePost){
        if ([data count]<7) {
            return;
        }
        FashionistaPost* thePost = [data objectAtIndex:1];
        postId = thePost.idFashionistaPost;
    }else{
        if ([data count]<12) {
            return;
        }
        postId = [data objectAtIndex:1];
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat estimatedSize = [GSContentViewPost estimatedSizeForFullPostWithData:data andControllerWidth:width];
    [postCellHeights setObject:[NSNumber numberWithFloat:estimatedSize] forKey:postId];
    //[self selfCheckMoreData];
    /*
    if(currentlyVisibleCollectionView==self.listView){
        [self refreshVisibleView];
    }
     */
}

- (IBAction)closeListOptions:(id)sender {
    if(showingOptions){
        [self showOptions:NO fromPoint:CGPointZero];
    }
}

- (void)updateHeightForItemAtRow:(NSInteger)row{
    NSArray* data = [self.delegate doubleDisplay:self dataForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:row] forMode:GSDoubleDisplayModeList];
    if ([data count]<7) {
        return;
    }
    CGFloat estimatedSize = [GSContentViewPost estimatedSizeForFullPostWithData:data andControllerWidth:self.view.frame.size.width];
    
    BOOL completePost = [[data firstObject] boolValue];
    NSString* postId;
    if(completePost){
        FashionistaPost* thePost = [data objectAtIndex:1];
        postId = thePost.idFashionistaPost;
    }else{
        postId = [data objectAtIndex:1];
    }
    [postCellHeights setObject:[NSNumber numberWithFloat:estimatedSize] forKey:postId];
    [self selfCheckMoreData];
    if(currentlyVisibleCollectionView==self.listView){
        [self refreshVisibleView];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //Add one row for spinner
    NSInteger downloadedRows = [self.delegate numberOfSectionsInDataForDoubleDisplay:self forMode:GSDoubleDisplayModeList];
    numberOfRowsOnLastRedraw = downloadedRows;
    return downloadedRows + (mustDownloadMoreData ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger numSections = [self numberOfSectionsInTableView:tableView];
    if (mustDownloadMoreData&&(indexPath.section == numSections-1)) {
        return 30;
    }
    if(indexPath.section>numSections){
        return 0;
    }
    id aPost = [self.delegate doubleDisplay:self objectForRowAtIndexPath:indexPath forMode:GSDoubleDisplayModeList];
    NSString* postId;
    if ([aPost isKindOfClass:[FashionistaPost class]]) {
        postId = ((FashionistaPost*)aPost).idFashionistaPost;
    }else{
        postId = aPost;
    }
    NSNumber* postHeight = [postCellHeights objectForKey:postId];
    if(!postHeight){
        postHeight = [NSNumber numberWithInteger:400];
        [postCellHeights setObject:postHeight forKey:postId];
    }
    
    if (!_cellsHideHeader && indexPath.section == 0) {
        CGFloat height = [postHeight floatValue] + 151;
        return height;
    }
    if (_bFromNewsFeed) {
        if (!_cellsHideHeader && indexPath.section % ADNUM == ADNUM - 1) {
            int n = indexPath.section / ADNUM;
            if (indexPath.section / ADNUM >= [adList count]) {
                return [postHeight floatValue];
            }
            CGFloat height = [postHeight floatValue] + 200;
            return height;
        }
    }
    return [postHeight floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger numSections = [self numberOfSectionsInTableView:tableView];
    if (mustDownloadMoreData&&(indexPath.section == numSections-1)) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:GSPostLoadingId forIndexPath:indexPath];
        [(UIActivityIndicatorView*)[cell viewWithTag:100] startAnimating];
        return cell;
    }
    
    if (!_cellsHideHeader && indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postFirstCell" forIndexPath:indexPath];
        if(![visibleCells containsObject:cell]){
            [visibleCells addObject:cell];
        }
        NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:indexPath forMode:GSDoubleDisplayModeList];
        if ([theData count]>0) {
            [self fillExtendedPostCell:cell withData:theData atIndexPath:indexPath];
        }
        
        return cell;
    }
    
    if (_bFromNewsFeed) {
        if (!_cellsHideHeader && indexPath.section % ADNUM == ADNUM - 1 ) {
            if (indexPath.section / ADNUM < [adList count]) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postADCell" forIndexPath:indexPath];
                if(![visibleCells containsObject:cell]){
                    [visibleCells addObject:cell];
                }

                NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:indexPath forMode:GSDoubleDisplayModeList];
                if ([theData count]>0) {
                    [self fillExtendedPostCell:cell withData:theData atIndexPath:indexPath];
                }
        
                return cell;
            }
        }
    }
    NSString* reuseIdentifier = GSPostCollectionId;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if(![visibleCells containsObject:cell]){
        [visibleCells addObject:cell];
    }
    NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:indexPath forMode:GSDoubleDisplayModeList];
    if ([theData count]>0) {
        [self fillExtendedPostCell:cell withData:theData atIndexPath:indexPath];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    GSContentSectionHeaderView* header = (GSContentSectionHeaderView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:GSPostCollectionHeaderId];
    header.delegate = self;
    header.tag = section;
    NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] forMode:GSDoubleDisplayModeList];
    if ([theData count]>=7) {
        BOOL completePost = [[theData firstObject] boolValue];
        NSString* postId;
        NSString* postOwner_picture;
        NSString* postOwner_name;
        NSString* postLocation;
        NSString* posttype;
        NSString* postTitle;
        if(completePost){
            FashionistaPost* thePost = [theData objectAtIndex:1];
            postId = thePost.idFashionistaPost;
            User* postOwner = [theData objectAtIndex:6];
            postOwner_picture = postOwner.picture;
            postOwner_name = postOwner.fashionistaName;
            postLocation = thePost.location;
            posttype = thePost.type;
            postTitle = thePost.name;
        }else{
            postId = [theData objectAtIndex:1];
            postOwner_picture = [theData objectAtIndex:6];
            postOwner_name = [theData objectAtIndex:7];
            postLocation = [theData objectAtIndex:4];
            posttype = [theData objectAtIndex:15];
            postTitle = [theData objectAtIndex:14];
        }
        
        if ([posttype isEqualToString:@"wardrobe"]) {
            header.headerSubtitle.text = postTitle;
        }
        else {
            header.headerSubtitle.text = postLocation;
        }
        header.contentId = postId;
        UIImage* anImage = [GSContentViewPost getTheImage:postOwner_picture];
        if(anImage){
            header.headerImage.image = anImage;
        }else{
            [header.headerImage setImageWithURL:[NSURL URLWithString:postOwner_picture] placeholderImage:[UIImage imageNamed:@"no_image.png"]];
        }
        header.headerTitle.text = postOwner_name;
        
        if (_cellsHideHeader) {
            NSString *posttype = [theData objectAtIndex:14];
            if ([posttype isEqualToString:@"magazine"]) {
                NSLog(@"Magazine Category : %@", [theData objectAtIndex:15]);
                NSLog(@"Location Info : %@", postLocation);
                header.headerImage.hidden = YES;
                header.titleImageWidthConstraint.constant = 0;
                header.headerTitle.text = [theData objectAtIndex:15];
                header.headerSubtitle.text = postLocation;
            }
        }
        else {
            header.headerImage.hidden = NO;
            header.titleImageWidthConstraint.constant = 23;
            header.headerTitle.text = postOwner_name;
            header.headerSubtitle.text = postLocation;
        }
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSInteger numSections = [self numberOfSectionsInTableView:tableView];
    if (mustDownloadMoreData&&(section == numSections-1)) {
        return 0;
    }
    
    if(_cellsHideHeader) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:indexPath forMode:GSDoubleDisplayModeList];
        NSString *posttype = [theData objectAtIndex:14];
        
        if ([posttype isEqualToString:@"magazine"]) {
            return 55;
        }
        
        return 0;
    }
    return 55;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [(GSPostTableViewCell*)cell endDisplayingCell];
    [visibleCells removeObject:cell];
}

//Fills an extended post collectionView Cell with data
- (void)fillExtendedPostCell:(UITableViewCell*)cell withData:(NSArray*)cellData atIndexPath:(NSIndexPath *)indexPath{
    if(!cellData){
        return;
    }
    GSPostTableViewCell* theCell = (GSPostTableViewCell*)cell;
    BOOL completePost = [[cellData firstObject] boolValue];
    NSString* postId;
    if(completePost){
        FashionistaPost* thePost = [cellData objectAtIndex:1];
        postId = thePost.idFashionistaPost;
    }else{
        postId = [cellData objectAtIndex:1];
    }
    
    if ([postCellExpanded objectForKey:postId]) {
        [theCell setExpandedComments];
    }
    [postIndexes setObject:[NSNumber numberWithInteger:indexPath.section] forKey:postId];
    
    [theCell setContentData:cellData];
    id userLikesThisPost = [userLikesPosts objectForKey:theCell.thePostId];
    if ([userLikesThisPost isKindOfClass:[NSNumber class]]) {
        [theCell.theContent setLikeState:[userLikesThisPost boolValue]];
    }else{
        if(theCell.thePostId){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, theCell.thePostId, nil];
            [postsInOperations setObject:theCell.theContent forKey:theCell.thePostId];
            [self performRestGet:GET_USER_LIKES_POST withParamaters:requestParameters];
        }
    }
    theCell.theContent.postDelegate = self;
    
    if (_bFromNewsFeed) {
        if (indexPath.section == 0) {
            [theCell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
        }
    
        if (indexPath.section % ADNUM == ADNUM - 1) {
            NSInteger index = indexPath.section / ADNUM;
            if (index >= [adList count]) {
                return;
            }
            Ad *result = [adList objectAtIndex:index];
            NSString *imageURL = [NSString stringWithFormat:@"%@%@", IMAGESBASEURL, result.image];
            [theCell.adImage sd_setImageWithURL:[NSURL URLWithString:imageURL]];
            theCell.adButton.tag = index;
            [theCell.adButton addTarget:self action:@selector(onTapADImage:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath* reversedPath = [NSIndexPath indexPathForRow:indexPath.section inSection:0];
    NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:indexPath forMode:GSDoubleDisplayModeList];
    NSString *posttype = [theData objectAtIndex:14];
    BOOL isMagazine = NO;
    if ([posttype isEqualToString:@"magazine"]) {
        isMagazine = YES;
    }
    [self.delegate doubleDisplay:self selectItemAtIndexPath:reversedPath isMagazine:isMagazine];
}

- (void)stopVisibleCells{
    for (GSPostTableViewCell* cell in visibleCells) {
        [cell endDisplayingCell];
    }
}

-(void)onTapADImage:(UIButton*)sender {
    Ad *result = [adList objectAtIndex:sender.tag];
    
    if (result.website != nil && ![result.website isEqualToString:@""]) {
        [self.delegate doubleDisplay:self openWebFromAD:result.website];
    }
    else if (result.productId != nil && ![result.productId isEqualToString:@""]) {
       // [self.delegate doubleDisplay:self openProductFromAD:result.productId];
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:result.productId, nil];
        
        [self performRestGet:GET_PRODUCT withParamaters:requestParameters];
    }
    else if (result.profileId != nil && ![result.profileId isEqualToString:@""]) {
        //[self.delegate doubleDisplay:self openProfileFromAD:result.profileId];
        [self openFashionistaWithId:result.profileId];
    }
    else if (result.postId != nil && ![result.postId isEqualToString:@""]) {
        [self.delegate doubleDisplay:self openPostFromAD:result.postId];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([collectionView isKindOfClass:[SuggestionCollectionView class]]) {
        return 1;
    }
    return [self.delegate numberOfSectionsInDataForDoubleDisplay:self forMode:GSDoubleDisplayModeCollection];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isKindOfClass:[SuggestionCollectionView class]]) {
        return [suggestList count];
    }
    return [self.delegate doubleDisplay:self numberOfRowsInSection:section forMode:GSDoubleDisplayModeCollection];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isKindOfClass:[SuggestionCollectionView class]]) {
        GSSuggestionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GSSuggestCollectionId forIndexPath:indexPath];
        GSBaseElement *result = (GSBaseElement *)[suggestList objectAtIndex:indexPath.item];

        [cell.image sd_setImageWithURL:[NSURL URLWithString:result.preview_image] placeholderImage:[UIImage imageNamed:@"no_image.png"]];
        
        cell.name.text = result.mainInformation;
        cell.followButton.tag = indexPath.item;
        [cell.followButton addTarget:self action:@selector(onTapFollowUser:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    NSString* reuseIdentifier = [(GSChangingCollectionView*)collectionView currentCellIdentifier];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:indexPath forMode:GSDoubleDisplayModeCollection];
    if ([theData count]>0) {
        [self fillImagePostCell:cell withData:theData atIndexPath:indexPath];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isKindOfClass:[SuggestionCollectionView class]]) {
        return CGSizeMake(100, 130);
    }
    
    CGFloat cellWidth = floorf((collectionView.frame.size.width - (_itemsPerRow-1))/_itemsPerRow);
    if (_isWardrobe) {
        return CGSizeMake(cellWidth, cellWidth + 20);
    }
    return CGSizeMake(cellWidth, cellWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isKindOfClass:[SuggestionCollectionView class]]) {
        GSBaseElement *result = (GSBaseElement *)[suggestList objectAtIndex:indexPath.item];
        [self openFashionistaWithId:result.fashionistaId];
        return;
    }
    
    NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:indexPath forMode:GSDoubleDisplayModeCollection];
    NSArray* postData = [theData firstObject];
    NSString *posttype = [postData objectAtIndex:16];
    
    BOOL isMagazine = NO;
    if ([posttype isEqualToString:@"magazine"]) {
        isMagazine = YES;
    }
    [self.delegate doubleDisplay:self selectItemAtIndexPath:indexPath isMagazine:isMagazine];
}

//Fills an image post collectionView cell with data
- (void)fillImagePostCell:(UICollectionViewCell*)cell withData:(NSArray*)cellData atIndexPath:(NSIndexPath *)indexPath{
    GSImageCollectionViewCell* theCell = (GSImageCollectionViewCell*)cell;
    theCell.cellDelegate = self;
    theCell.tag = indexPath.row;
    NSArray* postData = [cellData firstObject];
    BOOL isComplete = [[postData objectAtIndex:0] boolValue];
    NSString* preview_image;
    if (isComplete) {
        FashionistaPost* thePost = [postData objectAtIndex:1];
        preview_image = thePost.preview_image;
    }else{
        preview_image = [postData objectAtIndex:2];
    }
    
    NSString *posttype = [postData objectAtIndex:15];
    if ([posttype isEqualToString:@"magazine"]) {
        theCell.magazineIcon.hidden = NO;
    }
    else {
        theCell.magazineIcon.hidden = YES;
    }

    if ([posttype isEqualToString:@"wardrobe"]) {
        theCell.wardrobeIcon.hidden = NO;
    }
    else {
        theCell.wardrobeIcon.hidden = YES;
    }

    if ([posttype isEqualToString:@"article"]) {
        theCell.postIcon.hidden = NO;
    }
    else {
        theCell.postIcon.hidden = YES;
    }

    
    if (_isWardrobe) {
        if (_isOwner) {
            theCell.hangerButton.hidden = YES;
        }
        else {
            theCell.hangerButton.hidden = NO;
        }
        theCell.titleLabel.hidden = NO;
        if ([postData count] > 14) {
            NSLog(@"Wardrobe Title : %@", [postData objectAtIndex:14]);
            theCell.titleLabel.text = [postData objectAtIndex:14];
        }
    }
    else {
        theCell.titleLabel.hidden = YES;
        theCell.hangerButton.hidden = YES;
    }
    
    theCell.hangerButton.tag = indexPath.item;
    
    [theCell.hangerButton addTarget:self action:@selector(onTapAddWardrobe:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString* imageURL = preview_image;
    NSLog(@"ImageURL:%@", [postData objectAtIndex:14]);
    if ([UIImage isCached:imageURL])
    {
        UIImage * image = [UIImage cachedImageWithURL:imageURL];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image_big.png"];
        }
        
        theCell.theImage.image = image;
    }
    else
    {
        [theCell.theImage setImageWithURL:[NSURL URLWithString:preview_image] placeholderImage:[UIImage imageNamed:@"no_image_big.png"]];
    }
}

#pragma mark - GSPostTableViewCell protocols

- (void)postTableViewCell:(GSPostTableViewCell *)postCell heightChanged:(CGFloat)newHeight reason:(GSPostContentHeightChangeReason)aReason forceResize:(BOOL)forceResize{
    CGFloat oldHeight = [[postCellHeights objectForKey:postCell.thePostId] floatValue];
    
    if (oldHeight!=newHeight&&!(postCell.thePostId==nil)) {
        NSMutableArray* postHeightChangeReason = [heightChangeReasons objectForKey:postCell.thePostId];
        if (!postHeightChangeReason) {
            postHeightChangeReason = [NSMutableArray new];
            [heightChangeReasons setObject:postHeightChangeReason forKey:postCell.thePostId];
        }
        if (forceResize||![postHeightChangeReason containsObject:[NSNumber numberWithInt:aReason]])
        {
            [postHeightChangeReason addObject:[NSNumber numberWithInt:aReason]];
            [postCellHeights setObject:[NSNumber numberWithFloat:newHeight] forKey:postCell.thePostId];
            [self refreshData:YES];
        }
    }
}

- (void)postTableViewCell:(GSPostTableViewCell *)postCell downloadContentImage:(NSString *)imageURL{
    if ([UIImage isCached:imageURL])
    {
        UIImage * image = [UIImage cachedImageWithURL:imageURL];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image_big.png"];
        }
        [postCell.theContent setPostImage];
    }
    else
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:imageURL];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image_big.png"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [postCell.theContent setPostImage];
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }
}

- (void)postTableViewCell:(GSPostTableViewCell *)postCell downloadProfileImage:(NSString *)imageURL{
    if ([UIImage isCached:imageURL])
    {
        UIImage * image = [UIImage cachedImageWithURL:imageURL];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image_big.png"];
        }
        
        [postCell.theContent setProfileImage];
    }
    else
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:imageURL];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image_big.png"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [postCell.theContent setProfileImage];
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }
}

-(void)onTapAddWardrobe:(UIButton*)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:indexPath forMode:GSDoubleDisplayModeCollection];
    
    [self.delegate addToWardrobe:theData button:sender];
}

-(void)onTapEditWardrobe:(UIButton*)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:indexPath forMode:GSDoubleDisplayModeCollection];
    
    
}

#pragma mark - Timer
-(void)startTimer {
    [self stopTimer];
    timeDuration = 0;
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

#pragma mark - GSCollectionViewCell Protocol

- (void)longPressedCell:(GSImageCollectionViewCell *)theCell{
    NSIndexPath* thePath = [NSIndexPath indexPathForRow:theCell.tag inSection:0];
    NSArray* fullData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:thePath forMode:GSDoubleDisplayModeCollection];
    if ([fullData count]>0) {
        NSArray* theData = [fullData firstObject];
        
        [self showViewControllerModal:_quickVC withTopBar:NO];
        _quickVC.delegate = self;
        _quickVC.itemIndexPath = thePath;
        BOOL completePost = [[theData firstObject] boolValue];
        NSString* postId;
        if(completePost){
            FashionistaPost* thePost = [theData objectAtIndex:1];
            postId = thePost.idFashionistaPost;
        }else{
            postId = [theData objectAtIndex:1];
        }
        _processingPostId = postId;
        [_quickVC setPost:theData];
        [self startTimer];
    }
}

-(void)closeQV {
    [self dismissControllerModal];
    [self stopTimer];
}

-(void)onTapFollowUser:(UIButton*)sender {
    GSBaseElement *result = (GSBaseElement *)[suggestList objectAtIndex:sender.tag];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    setFollow * newFollow = [[setFollow alloc] init];
        
    [newFollow setFollow:result.fashionistaId];
        
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newFollow, nil];
        
    [self performRestPost:FOLLOW_USER withParamaters:requestParameters];
    
    GSPostTableViewCell* theCell = [_listView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [suggestList removeObjectAtIndex:sender.tag];
    [theCell.suggestionList reloadData];
    if ([suggestList count] == 4) {
        [self.delegate updateUserSearch];
    }
//    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
//    [theCell.suggestionList deleteItemsAtIndexPaths:@[indexpath]];
}

#pragma mark - QuickView protocol

- (void)detailTappedForQuickView:(GSQuickViewViewController*)vC{
    [self dismissControllerModal];
    NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:vC.itemIndexPath forMode:GSDoubleDisplayModeCollection];
    NSArray* postData = [theData firstObject];
    NSString *posttype = [postData objectAtIndex:14];
    BOOL isMagazine = NO;
    if ([posttype isEqualToString:@"magazine"]) {
        isMagazine = YES;
    }
    [self.delegate doubleDisplay:self selectItemAtIndexPath:vC.itemIndexPath isMagazine:isMagazine];
}

- (void)commentContentForQuickView:(GSQuickViewViewController*)vC{
    [self showCommentView:vC.itemIndexPath.row withOldComment:nil];
}

- (void)quickView:(GSQuickViewViewController *)vC viewProfilePushed:(User *)theUser{
    [self.delegate doubleDisplay:self viewProfilePushed:theUser];
}

#pragma mark - UI Operations utilities

- (void)closeWriteComment
{
    [self dismissControllerModal];
    [self refreshData];
}

- (void)loadOwnerImage:(NSString*)imageURL forPost:(NSString*)postId inHeader:(GSContentSectionHeaderView*)header{
    if ([UIImage isCached:imageURL])
    {
        UIImage * image = [UIImage cachedImageWithURL:imageURL];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        header.headerImage.image = image;
        [header layoutSubviews];
    }
    else
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:imageURL];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([header.contentId isEqualToString:postId]) {
                    header.headerImage.image = image;
                    [header layoutSubviews];
                }
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }
}

#pragma mark - ContentViewDelegate

- (void)searchForKeywords:(NSArray*)keywordsArray categoryTerms:(NSMutableArray*)categoryTerms{
    
}

- (void)getNumberOfMatchs:(NSMutableDictionary *)searchDictionary {
    
}

- (void)openWardrobeWithId:(id)content{
    
    selectedElement = [self.delegate getElement:content];
    NSString* wardrobeId = selectedElement.wardrobeQueryId;
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.completeUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                        message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobeId, nil];
    
    [self performRestGet:GET_WARDROBE withParamaters:requestParameters];
}

-(void)wardrobePush:(id)content button:(UIButton *)sender{
    [self.delegate addToWardrobe:content button:sender];
}

- (void)openFashionistaWithId:(NSString *)userId{
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:userId, nil];
    
    [self performRestGet:GET_FASHIONISTA withParamaters:requestParameters];
}

- (void)openFashionistaWithUsername:(NSString *)userName{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:userName, nil];
    
    [self performRestGet:GET_FASHIONISTAWITHNAME withParamaters:requestParameters];
}

- (void)contentPost:(GSContentViewPost *)contentPost doLike:(BOOL)likeOrNot{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        [contentPost setLikeState:!likeOrNot];
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
    
    _processingPost = contentPost;
    
    if (likeOrNot)
    {
        if (!(_processingPost.thePostId == nil))
        {
            
                if(!([_processingPost.thePostId isEqualToString:@""]))
                {
                    if (!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            // Perform request to like post
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            //[self startActivityFeedbackWithMessage:NSLocalizedString(@"_LIKING_USER_MSG_", nil)];
                            
                            // Post the PostLike object
                            
                            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            PostLike *newPostLike = [[PostLike alloc] initWithEntity:[NSEntityDescription entityForName:@"PostLike" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                            
                            [newPostLike setUserId:appDelegate.currentUser.idUser];
                            
                            [newPostLike setPostId:_processingPost.thePostId];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostLike, nil];
                            
                            [self performRestPost:LIKE_POST withParamaters:requestParameters];
                        }
                    }
                
            }
        }
    }
    else
    {
        if (!(_processingPost.thePostId == nil))
        {
            
                if(!([_processingPost.thePostId isEqualToString:@""]))
                {
                    if (!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            
                            // Perform request to like post
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UNLIKING_USER_MSG_", nil)];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, _processingPost.thePostId, nil];
                            
                            [self performRestGet:UNLIKE_POST withParamaters:requestParameters];
                        }
                    }
                }
            
        }
    }
}

- (void)getLikeUsers:(GSContentViewPost*)contentPost {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.completeUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                        message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    _processingPost = contentPost;
    
    if (!(_processingPost.thePostId == nil))
    {
            
        if(!([_processingPost.thePostId isEqualToString:@""])) {
            NSLog(@"Get Like Users : %@", _processingPost.thePostId);
            
            //isGETLIKE = YES;
            
            [self.delegate doubleDisplay:_processingPost.thePostId];
            //[self openFashionistaWithUsername:_processingPost.postOwner_name];
        }
    }
}

- (void)showCommentView:(NSInteger)index withOldComment:(Comment*)comment{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"FashionistaContents" bundle:[NSBundle mainBundle]];
    FashionistaAddCommentViewController* theVC = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",ADDCOMMENT_VC]];
    theVC.commentDelegate = self;
    theVC.oldComment = comment;
    [self showViewControllerModal:theVC];
    if(theVC.oldComment){
        theVC.commentIndex = index;
        [theVC setTitleForModal:@"EDIT COMMENT"];
    }
}

- (void)commentContentPost:(GSContentViewPost *)contentPost atIndex:(NSInteger)index{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.completeUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                        message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    _processingPost = contentPost;
     _processingPostId = contentPost.thePostId;
    [self showCommentView:index withOldComment:contentPost.editingComment];
}

- (void)updateNewComment:(Comment *)theComment{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGCOMMENT_ACTV_MSG_", nil)];
    
    [theComment setFashionistaPostId:_processingPostId];
    NSArray * requestParameters = [[NSArray alloc] initWithObjects: _processingPostId, theComment, nil];
    updatingCommentIndex = -1;
    [self performRestPost:ADD_COMMENT_TO_POST withParamaters:requestParameters];
}

- (void)updateOldComment:(Comment *)theComment atIndex:(NSInteger)index{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGCOMMENT_ACTV_MSG_", nil)];
    
    [theComment setFashionistaPostId:_processingPostId];
    NSArray * requestParameters = [[NSArray alloc] initWithObjects: _processingPostId, theComment,[NSNumber numberWithBool:YES], nil];
    //updatingCommentIndex = index;
    updatingCommentIndex = [[commentIndexDict objectForKey:theComment.idComment] integerValue];
    commentIndexDict = nil;
    [self performRestPost:ADD_COMMENT_TO_POST withParamaters:requestParameters];
}

- (void)contentPost:(GSContentViewPost *)contentPost deleteComment:(Comment *)theComment atIndex:(NSInteger)commentIndex{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGCOMMENT_ACTV_MSG_", nil)];
    
    //commentToDelete = commentIndex;
    commentToDelete = [[commentIndexDict objectForKey:theComment.idComment] integerValue];
    NSArray * requestParameters = [[NSArray alloc] initWithObjects: _processingPost.thePostId, theComment, nil];
    [self performRestDelete:DELETE_COMMENT withParamaters:requestParameters];
}

- (void)deletePost:(GSContentViewPost*)contentPost{
    _processingPost = contentPost;
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:_processingPost.thePostId, nil];
    [self performRestDelete:DELETE_POST withParamaters:requestParameters];
}

- (void)startEditMode:(GSContentViewPost*)contentPost{
    [self setEditMode:contentPost withMode:YES];
}

- (void)setEditMode:(GSContentViewPost*)contentPost withMode:(BOOL)editMode{
    if(editMode){
        _processingPost = contentPost;
    }else{
        _processingPost = nil;
    }
    [contentPost setEditMode:editMode];
}

- (void)sharePost:(GSContentViewPost*)contentPost{
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    Share * newShare = [[Share alloc] initWithEntity:[NSEntityDescription entityForName:@"Share" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
    
    [newShare setSharedPostId:contentPost.thePostId];
    
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

- (void)switchNotifications:(GSContentViewPost*)contentPost{
    //New operation for switching on/off notifications for post
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    PostUserUnfollow* unfollow = [appDelegate.currentUser.unnoticedPosts objectForKey:_processingPost.thePostId];
    if(unfollow){
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:unfollow, nil];
        [self performRestDelete:POST_YES_NOTICES withParamaters:requestParameters];
    }else{
        unfollow = [PostUserUnfollow new];
        unfollow.userId = appDelegate.currentUser.idUser;
        unfollow.postId = contentPost.thePostId;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:unfollow, nil];
        
        [self performRestPost:POST_NO_NOTICES withParamaters:requestParameters];
    }
}

-(void)products:(GSContentViewPost*)contentPost {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:@"This Feature will be coming soon." delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

- (void)unfollowImage:(GSContentViewPost*)contentPost{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    PostUserUnfollow* unfollow = [appDelegate.currentUser.unfollowedPosts objectForKey:_processingPost.thePostId];
    if(unfollow){
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:unfollow, nil];
        [self performRestDelete:POST_FOLLOW withParamaters:requestParameters];
    }else{
        unfollow = [PostUserUnfollow new];
        unfollow.userId = appDelegate.currentUser.idUser;
        unfollow.postId = contentPost.thePostId;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:unfollow, nil];
        [self performRestPost:POST_UNFOLLOW withParamaters:requestParameters];
    }
}

- (void)saveImage:(GSContentViewPost*)contentPost{
    UIImageWriteToSavedPhotosAlbum(((GSImageTaggableView*)contentPost.taggableView).imageView.image, nil, nil, nil);
    UIAlertView* anAlert = [[UIAlertView alloc] initWithTitle:@"Save Image"
                                                      message:@"Image saved succesfully"
                                                     delegate:nil
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
    [anAlert show];
}

- (void)flagPost:(GSContentViewPost*)contentPost{
    _processingPost = contentPost;
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
        
        if(buttonIndex == 1)
        {
            // Check that the name is valid
            
            if (!(_processingPost.thePostId == nil))
            {
                if(!([_processingPost.thePostId isEqualToString:@""]))
                {
                    // Post the PostContentReport object
                    
                    PostContentReport * newPostContentReport = [[PostContentReport alloc] init];
                    
                    [newPostContentReport setPostId:_processingPost.thePostId];
                    
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
        }else{
            _processingPost = nil;
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

- (void)expandComments:(GSContentViewPost *)contentPost{
    [postCellExpanded setObject:[NSNumber numberWithInt:1] forKey:contentPost.thePostId];
}

- (void)configOptions:(BOOL)showPublic{
    NSMutableArray* optionsArray = [NSMutableArray new];
    NSMutableArray* handlersArray = [NSMutableArray new];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //DELETE
    if (appDelegate.currentUser.name==_processingPost.postOwner_name){
        [optionsArray addObject:@"DELETE"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(deletePost:)]];
    }
    //EDIT
    if ([_processingPost hasOwnComments]){
        [optionsArray addObject:@"EDIT COMMENTS"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(startEditMode:)]];
    }
    //SHARE
    {
        [optionsArray addObject:@"SHARE"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(sharePost:)]];
    }
    //UNFOLLOW IMAGE
    if (appDelegate.currentUser.name!=_processingPost.postOwner_name&&_processingPost.isFollowingOwner){
        NSString* optionString = @"UNFOLLOW IMAGE";
        if ([appDelegate.currentUser.unfollowedPosts objectForKey:_processingPost.thePostId]) {
            optionString = @"FOLLOW IMAGE";
        }
        [optionsArray addObject:optionString];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(unfollowImage:)]];
    }
    //SAVE IMAGE
    {
        [optionsArray addObject:@"SAVE IMAGE"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(saveImage:)]];
    }
    //FLAG
    if (appDelegate.currentUser.name!=_processingPost.postOwner_name){
        [optionsArray addObject:@"FLAG"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(flagPost:)]];
    }
    //TURN ON NOTIFICATIONS
    {
        NSString* optionString = @"TURN OFF NOTIFICATIONS";
        if ([appDelegate.currentUser.unnoticedPosts objectForKey:_processingPost.thePostId]) {
            optionString = @"TURN ON NOTIFICATIONS";
        }
        [optionsArray addObject:optionString];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(switchNotifications:)]];
    }
    //PUBLIC  - THIS IS FOR ONLY WARDROBE
    if (showPublic){
        [optionsArray addObject:@"PRODUCTS"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(products:)]];
    }
    
    optionHandlers = [NSArray arrayWithArray:handlersArray];
    [self.optionsView setOptions:optionsArray];
    [self.optionsView layoutIfNeeded];
}

- (void)optionsView:(GSOptionsView *)optionView selectOptionAtIndex:(NSInteger)option{
    if ([optionHandlers count]>option) {
        SEL retriveSelector = [[optionHandlers objectAtIndex:option] pointerValue];
        [self performSelector:retriveSelector withObject:_processingPost];
    }
    [self closeListOptions:nil];
}

- (void)optionsView:(GSOptionsView *)optionView heightChanged:(CGFloat)newHeight{
    self.optionsViewHeight.constant = newHeight;
    [self.optionsView layoutIfNeeded];
}

- (void)openOptionsForContent:(GSContentViewPost *)contentPost atWindowPoint:(CGPoint)anchor{
    _processingPost = contentPost;
    BOOL showPublic = !contentPost.hangerButton.hidden;
    [self configOptions:(BOOL)showPublic];
    CGPoint viewPoint = CGPointZero;
    if(!showingOptions){
        [self.optionsView showUpToDown:YES];
        //Check if it fits screen or show it downToUp
        viewPoint = [self.optionsBackground convertPoint:anchor fromView:[UIApplication sharedApplication].keyWindow];
        CGFloat optionsHeight = self.optionsView.frame.size.height;
        CGFloat superHeight = [UIScreen mainScreen].bounds.size.height-88;
        if((anchor.y+optionsHeight>superHeight)){
            [self.optionsView showUpToDown:NO];
            optionsHeight = self.optionsView.frame.size.height;
            viewPoint.y -= 10 + optionsHeight;
        }else{
            viewPoint.y += 10;
            [self.optionsView showUpToDown:YES];
        }
    }
    [self showOptions:!showingOptions fromPoint:viewPoint];
}

- (void)showOptions:(BOOL)showOrNot fromPoint:(CGPoint)anchor{
    showingOptions = showOrNot;
    
    if (showOrNot) {
        self.optionsBackground.alpha = 1;
        self.optionsViewTop.constant = anchor.y;
        [self.optionsView moveAngleToPosition:anchor.x];
        [self.optionsView layoutIfNeeded];
        
        [self.optionsBackground.superview bringSubviewToFront:self.optionsBackground];
    }else{
        [self.optionsBackground.superview sendSubviewToBack:self.optionsBackground];
        self.optionsBackground.alpha = 0;
    }
}

- (void)contentPost:(GSContentViewPost*)contentPost showComments:(NSArray*)comments withEditMode:(BOOL)editOrNot{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"FashionistaContents" bundle:[NSBundle mainBundle]];
    GSCommentViewController* theVC = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",COMMENTS_VC]];
    theVC.commentDelegate = self;
    theVC.commentArray = comments;
    theVC.shouldEdit = editOrNot;
    [self showViewControllerModal:theVC];
}

- (void)contentPost:(GSContentViewPost*)contentPost showComments:(NSArray*)comments withEditMode:(BOOL)editOrNot andCommentIndexes:(NSDictionary*)indexDict{
    commentIndexDict = [NSMutableDictionary dictionaryWithDictionary:indexDict];
    [self contentPost:contentPost showComments:comments withEditMode:editOrNot];
}

- (void)commentController:(GSCommentViewController *)controller prepareForUpdateComment:(Comment *)oldComment atIndex:(NSInteger)index{
    _processingPostId = _processingPost.thePostId;
    [self dismissControllerModal];
    [self showCommentView:index withOldComment:oldComment];
}

- (void)commentController:(GSCommentViewController *)controller deleteComment:(Comment *)oldComment atIndex:(NSInteger)index dismiss:(BOOL)dismiss{
    if (dismiss) {
        [self dismissControllerModal];
    }
    [self contentPost:nil deleteComment:oldComment atIndex:index];
}

- (void)commentController:(GSCommentViewController *)controller openFashionistaWithName:(NSString *)userName{
    [self dismissControllerModal];
    [self openFashionistaWithUsername:userName];
}

- (void)resetCellSize:(NSIndexPath*)indexPath height:(NSInteger)height {
    GSPostTableViewCell *cell = [self.listView cellForRowAtIndexPath:indexPath];
    
    cell.adHeightConstraint.constant = height;
    
    //[cell layoutIfNeeded];
}

#pragma mark - ScrollDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [(id<UIScrollViewDelegate>)self.delegate scrollViewDidScroll:scrollView];
    
//    NSArray *visibles = [self.listView indexPathsForVisibleRows];
//    
//    for (GSPostTableViewCell *cell in visibleCells) {
//        NSIndexPath *indexPath = [self.listView indexPathForCell:cell];
//        if (indexPath.section == 0) {
//            
//            CGRect cellRectInTable = [self.listView rectForRowAtIndexPath:indexPath];
//            CGRect cellInSuperview = [self.listView convertRect:cellRectInTable toView:[self.listView superview]];
//            
//            if (cellInSuperview.origin.y > self.view.frame.size.height - cellRectInTable.size.height + 200) {
//                NSLog(@"AD is not display");
//                
//                [self resetCellSize:indexPath height:0];
//            }
//            else if (cellInSuperview.origin.y < self.view.frame.size.height - cellRectInTable.size.height + 200 && cellInSuperview.origin.y > self.view.frame.size.height / 2 - cellRectInTable.size.height + 100) {
//                NSLog(@"AD is at Bottom");
//                NSInteger height = 200 * (self.view.frame.size.height - cellRectInTable.size.height - cellInSuperview.origin.y) / (self.view.frame.size.height / 2);
//                [self resetCellSize:indexPath height:height];
//            }
//            else if (cellInSuperview.origin.y < self.view.frame.size.height / 2 - cellRectInTable.size.height + 100 && cellInSuperview.origin.y > -cellRectInTable.size.height) {
//                NSLog(@"AD is at Top");
//                NSInteger height = 200 * (self.view.frame.size.height / 2 + cellRectInTable.size.height + cellInSuperview.origin.y) / (self.view.frame.size.height / 2);
//                [self resetCellSize:indexPath height:height];
//            }
//            else if (cellInSuperview.origin.y < -cellRectInTable.size.height) {
//                NSLog(@"AD is not display");
//                [self resetCellSize:indexPath height:0];
//            }
//        }
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(!mustDownloadMoreData||scrollView==self.collectionView){
        float scrollViewHeight = scrollView.frame.size.height;
        float scrollViewWidth = scrollView.frame.size.width;
        float scrollContentSizeHeight = scrollView.contentSize.height;
        float scrollContentSizeWidth = scrollView.contentSize.width;
        float scrollOffsetX = scrollView.contentOffset.y;
        float scrollOffsetY = scrollView.contentOffset.x;
        
        if (scrollOffsetY != 0) {
            if (scrollOffsetY + scrollViewWidth >= scrollContentSizeWidth) {
                [self.delegate askForMoreUserInDoubleDisplay:self];
            }
        }
        
        if (scrollOffsetX != 0)
        {
            if (scrollOffsetX + scrollViewHeight >= scrollContentSizeHeight)
            {
                [self.delegate askForMoreDataInDoubleDisplay:self];
            }
        }
    }
}

#pragma mark - ContentSection Delegate

- (void)headerTouched:(GSContentSectionHeaderView *)header{
    NSInteger section = header.tag;
    NSArray* theData = [self.delegate doubleDisplay:self dataForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] forMode:GSDoubleDisplayModeList];
    if ([theData count]>=7) {
        BOOL completePost = [[theData firstObject] boolValue];
        NSString* userName;
        if(completePost){
            User* postOwner = [theData objectAtIndex:6];
            userName = postOwner.fashionistaName;
        }else{
            userName = [theData objectAtIndex:7];
        }
        [self openFashionistaWithUsername:userName];
    }
}

-(NSString*)getCurrentVideoURL {
    
    for (int i = 0; i < [visibleCells count]; i++) {
        
        GSPostTableViewCell* theCell = (GSPostTableViewCell*)[visibleCells objectAtIndex:i];
        if ([theCell getVideoURL] == nil || [[theCell getVideoURL] isEqualToString:@""]) {
                
        }
        else {
            currentIndex = i;
            return [theCell getVideoURL];
        }
    }
    
    return nil;
}

-(CMTime)getCurrentTime {
    GSPostTableViewCell* theCell = (GSPostTableViewCell*)[visibleCells objectAtIndex:currentIndex];
    
    return [theCell getCurrentTime];
}

-(BOOL)hasSoundNow {
    GSPostTableViewCell* theCell = (GSPostTableViewCell*)[visibleCells objectAtIndex:currentIndex];
    
    return [theCell hasSoundNow];
}

-(void)setCurrentTime:(CMTime)time hassound:(BOOL)sound{
    GSPostTableViewCell* theCell = (GSPostTableViewCell*)[visibleCells objectAtIndex:currentIndex];
    
    [theCell setCurrentTime:time hasSound:sound];
}

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

@end
