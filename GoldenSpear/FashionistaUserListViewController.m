//
//  FashionistaUserListViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 3/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "FashionistaUserListViewController.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "AppDelegate.h"
#import "FashionistaUserListViewCell.h"

@interface SearchBaseViewController (Protected)

- (NSInteger)numberOfItemsInSection:(NSInteger)section forCollectionViewWithCellType:(NSString *)cellType;
- (NSInteger)numberOfSectionsForCollectionViewWithCellType:(NSString *)cellType;
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath;
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath;
- (void)updateSearch;
- (void)performSearchWithString:(NSString*)stringToSearch;
-(NSString *) stringForStylistRelationship:(followingRelationships)stylistRelationShip;
- (void)initFetchedResultsController;
- (void)updateCollectionViewWithCellType:(NSString *)cellType fromItem:(int)startItem toItem:(int)endItem deleting:(BOOL)deleting;
- (void)scrollViewDidScroll:(UIScrollView*)scrollView;

@end

@implementation UIView (testing)



@end

@implementation FashionistaUserListViewController

- (void)dealloc{
    self.imagesQueue = nil;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    self.searchContext = FASHIONISTAS_SEARCH;
    self.fashionistaSearch = YES;
}

- (void)operationAfterLoadingSearch:(BOOL)hasResults{
    if(!hasResults){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }else{
        [self stopActivityFeedback];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    self.fashionistaSearch = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.fashionistaSearch = YES;
}

- (IBAction)doSearchPush:(id)sender {
    [self performSearch];
}

- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    NSArray * parametersForNextVC = nil;
    __block id selectedSpecificResult;
    
    switch (connection)
    {
        case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            [self stopActivityFeedback];
            
            [self operationAfterLoadingSearch:NO];
            break;
        }
        case FINISHED_SEARCH_WITH_RESULTS:
        {
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            [self.userDisplayList reloadData];
            [self operationAfterLoadingSearch:YES];
            break;
        }
        case UNFOLLOW_USER:
        case FOLLOW_USER:
        {
            [self stopActivityFeedback];
            
            break;
        }
        case GET_FASHIONISTA:
        {
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
            parametersForNextVC = [NSArray arrayWithObjects: selectedSpecificResult, [NSNumber numberWithBool:NO], [self currentSearchQuery], nil];
            
            [self stopActivityFeedback];
            
            if(!self.currentPresenterViewController){
                [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            }else{
                [self.currentPresenterViewController transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
                [self.currentPresenterViewController dismissControllerModal];
            }
            break;
        }
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

- (IBAction)followButtonPushed:(UIButton *)sender {
    sender.selected = !sender.selected;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    NSArray* rowInfo = [super getContentForCellWithType:@"ResultCell" AtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    if (!(appDelegate.currentUser.idUser == nil))
    {
        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
        {
            // Perform request to follow user
            
            // Provide feedback to user
            [self stopActivityFeedback];
            
            if (sender.selected)
            {
                //Do follow
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_FOLLOWING_USER_MSG_", nil)];
                
                // Post the setFollow object
                
                setFollow * newFollow = [[setFollow alloc] init];
                
                [newFollow setFollow:[rowInfo objectAtIndex:6]];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newFollow, nil];
                
                [self performRestPost:FOLLOW_USER withParamaters:requestParameters];
            }else{
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UNFOLLOWING_USER_MSG_", nil)];
                
                // Post the unsetFollow object
                
                unsetFollow * newUnsetFollow = [[unsetFollow alloc] init];
                
                [newUnsetFollow setUnfollow:[rowInfo objectAtIndex:6]];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newUnsetFollow, nil];
                
                [self performRestPost:UNFOLLOW_USER withParamaters:requestParameters];
            }
        }
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FashionistaUserListViewCell* theCell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    NSArray* rowInfo = [super getContentForCellWithType:@"ResultCell" AtIndexPath:indexPath];
    if([rowInfo count]>6){
        NSString* previewImage = [rowInfo objectAtIndex:0];
        BOOL isFollowing = [[rowInfo objectAtIndex:2] boolValue];
        NSString* fashionistaName = [rowInfo objectAtIndex:3];
        theCell.userName.text = fashionistaName;
        if([rowInfo count]>7){
            theCell.userTitle.text = [rowInfo objectAtIndex:7];
        }
        theCell.fashionistaId = [rowInfo objectAtIndex:6];
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if([appDelegate.currentUser.idUser isEqualToString:theCell.fashionistaId]){
            theCell.followingButton.hidden = YES;
        }else{
            theCell.followingButton.hidden = NO;
            theCell.followingButton.tag = indexPath.row;
            theCell.followingButton.selected = isFollowing;
        }
        theCell.imageURL = previewImage;
        if ([UIImage isCached:previewImage])
        {
            UIImage * image = [UIImage cachedImageWithURL:previewImage];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            theCell.theImage.image = image;
        }
        else
        {
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                
                UIImage * image = [UIImage cachedImageWithURL:previewImage];
                
                if(image == nil)
                {
                    image = [UIImage imageNamed:@"no_image.png"];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Then set them via the main queue if the cell is still visible.
                    if ([tableView.indexPathsForVisibleRows containsObject:indexPath]&&[theCell.imageURL isEqualToString:previewImage])
                    {
                        theCell.theImage.image = image;
                    }
                });
            }];
            
            operation.queuePriority = NSOperationQueuePriorityHigh;
            
            [self.imagesQueue addOperation:operation];
        }
    }
    return theCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [super numberOfSectionsForCollectionViewWithCellType:@"ResultCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [super numberOfItemsInSection:section forCollectionViewWithCellType:@"ResultCell"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Tweak for reusing superclass function
    // Hide Add Terms text field
    UITextField* phantomTextField = [UITextField new];
    [self setAddTermTextField:phantomTextField];
    phantomTextField.hidden = YES;
    
    [super actionForSelectionOfCellWithType:@"ResultCell" AtIndexPath:indexPath];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset == 0)
    {
        // then we are at the top
    }
    else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
    {
        NSInteger currentItems = [super numberOfItemsInSection:0 forCollectionViewWithCellType:@"ResultCell"];
        NSInteger searchResults = [self.currentSearchQuery.numresults integerValue];
        if(currentItems<searchResults){
            [super updateSearch];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self performSearch];
    return YES;
}

- (void)performSearch
{
    [self.view endEditing:YES];
    [self resetSearch];
    NSString * sStringToSearchTrimmed = [self.searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self performSearchWithString:sStringToSearchTrimmed];
}

- (void)resetSearch{
    // Empty successful terms array
    [self.successfulTerms removeAllObjects];
    [self.searchTermsListView removeAllButtons];
    
    [self.suggestedFilters removeAllObjects];
    [self.suggestedFiltersObject removeAllObjects];
    
    // Empty not successful terms string
    self.notSuccessfulTerms = @"";
    [self setNotSuccessfulTermsText:@""];
    
    // Hide Filter Terms Label
    [self.noFilterTermsLabel setHidden:YES];
    
    int resultsBeforeUpdate = (int) [self.resultsArray count];
    
    // Empty old results array
    [self.resultsArray removeAllObjects];
    
    // Empty old results array
    [self.resultsGroups removeAllObjects];
    
    self.currentSearchQuery = nil;
    
    // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
    if ([self getFetchedResultsControllerForCellType:@"ResultCell" ] == nil)
    {
        [self initFetchedResultsController];
    }
    
    // Update Fetched Results Controller
    [self performFetchForCollectionViewWithCellType:@"ResultCell"];
    
    // Update collection view
    [super updateCollectionViewWithCellType:@"ResultCell" fromItem:0 toItem:resultsBeforeUpdate deleting:TRUE];
    
    // Set ALL as the default relationships filter for stylists search
    self.searchStylistRelationships = self.userListMode;
    
    if (self.foundSuggestions != nil)
    {
        [self.foundSuggestions removeAllObjects];
    }
    if(self.foundSuggestionsPC != nil)
    {
        [self.foundSuggestionsPC removeAllObjects];
    }
}

- (void)performSearchWithString:(NSString*)stringToSearch
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray * requestParameters = nil;
    
    
    NSLog(@"Performing search within fashionistas with terms: %@.", stringToSearch);
    
    // Perform request to get the search results
    
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    
    // TODO: Add post type filtering!
    
    NSString * currentUserId = @"";
    
    if(self.shownRelatedUser){
        currentUserId = self.shownRelatedUser.idUser;
    }else if(appDelegate.currentUser)
    {
        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
        {
            currentUserId = appDelegate.currentUser.idUser;
        }
    }

    if (self.userListMode == LIKEUSERS) {
        requestParameters = [[NSArray alloc] initWithObjects:_postId, stringToSearch, nil];
        
        [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAS_LIKE_POST withParamaters:requestParameters];
    }
    
    requestParameters = [[NSArray alloc] initWithObjects:stringToSearch, [super stringForStylistRelationship:self.userListMode], currentUserId, nil];
    
    [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAS withParamaters:requestParameters];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    [self.view endEditing:YES];
}
@end
