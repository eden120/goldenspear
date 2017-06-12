//
//  GSTaggingLocationSearchViewController.m
//  GoldenSpear
//
//  Created by Crane on 8/19/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
#import "GSTaggingLocationSearchViewController.h"
#import "FashionistaUserListViewController.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "AppDelegate.h"
#import "FashionistaUserListViewCell.h"
#import "InviteView.h"

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

@interface GSTaggingLocationSearchViewController ()

@end

@implementation GSTaggingLocationSearchViewController {
    NSMutableArray *locaitonArry;
    NSMutableArray *searchArry;
    BOOL searchActive;
}

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
    locaitonArry = [[NSMutableArray alloc]init];
    searchActive = NO;
}

- (void)operationAfterLoadingSearch:(BOOL)hasResults{
    if(!hasResults){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }else{
        [self stopActivityFeedback];
    }
}

- (IBAction)doSearchPush:(id)sender {
    NSString *searchtext = _searchTextField.text;
    if ([searchtext isEqualToString:@""]) {
        searchActive = NO;
        [self.userDisplayList reloadData];
        return;
    }
    
    if (searchArry == nil)
        searchArry = [[NSMutableArray alloc]init];
    else if (searchArry.count > 0)
        [searchArry removeAllObjects];
    
    for (POI *poi in locaitonArry) {
        NSString *name = poi.name;
        NSLog(@"sss  %@", name);
        NSRange range = [name  rangeOfString: searchtext options: NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [searchArry addObject:poi];
        }
    }
    
   
    searchActive = YES;
    
    [self.userDisplayList reloadData];
//    [self performSearch];
}

- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    switch (connection)
    {
        case GET_NEAREST_POI:
        {
            [locaitonArry removeAllObjects];
            
            for (POI * content in mappingResult)
            {
                if([content isKindOfClass:[POI class]])
                {
                    if(!(content.idPOI == nil))
                    {
                        if  (!([content.idPOI isEqualToString:@""]))
                        {
                            [locaitonArry addObject:content];
                        }
                    }
                }
            }
            [_userDisplayList reloadData];
            [self stopActivityFeedback];
            break;
        }
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FashionistaUserListViewCell* theCell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    if (searchActive) {
        POI *poi = [searchArry objectAtIndex:indexPath.row];
        theCell.userName.text = poi.name;
        theCell.userTitle.text = poi.address;

    } else {
        POI *poi = [locaitonArry objectAtIndex:indexPath.row];
        theCell.userName.text = poi.name;
        theCell.userTitle.text = poi.address;
    }
    return theCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (searchActive)
        return searchArry.count;
    
    return locaitonArry.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Tweak for reusing superclass function
    // Hide Add Terms text field
    if (searchActive) {
        POI *poi = [searchArry objectAtIndex:indexPath.row];
        if ([self.locationDelegate respondsToSelector:@selector(setLocation:)]) {
            [self.locationDelegate setLocation:poi];
            [self.currentPresenterViewController dismissControllerModal];
        }
    }  else {
        POI *poi = [locaitonArry objectAtIndex:indexPath.row];
        if ([self.locationDelegate respondsToSelector:@selector(setLocation:)]) {
            [self.locationDelegate setLocation:poi];
            [self.currentPresenterViewController dismissControllerModal];
        }
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
    NSString *searchtext = textField.text;
    if ([searchtext isEqualToString:@""]) {
        searchActive = NO;
        [self.userDisplayList reloadData];
        return YES;
    }
    
    if (searchArry == nil)
        searchArry = [[NSMutableArray alloc]init];
    else if (searchArry.count > 0)
        [searchArry removeAllObjects];
    
    for (POI *poi in locaitonArry) {
        NSString *name = poi.name;
        NSLog(@"sss  %@", name);
        NSRange range = [name  rangeOfString: searchtext options: NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [searchArry addObject:poi];
        }
    }
    
    
    searchActive = YES;
    
    [self.userDisplayList reloadData];
    
    return YES;
}

- (void)performSearch
{
    [self.view endEditing:YES];
    [self resetSearch];
    [self performSearchWithString:self.searchTextField.text];
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
    NSLog(@"Performing search within fashionistas with terms: %@", stringToSearch);
    
    // Perform request to get the search results
    
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *lat  = appDelegate.currentLocationLat;
    NSNumber *lng = appDelegate.currentLocationLon;
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:lat, lng, nil];
    [self performRestGet:GET_NEAREST_POI withParamaters:requestParameters];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    [self.view endEditing:YES];
}
@end
