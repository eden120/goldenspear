//
//  GSLikesViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 14/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSLikesViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+StoryboardManagement.h"
@interface GSNewsFeedViewController (Protected)

- (NSInteger)getNumberOfPostsDownloaded;
- (void)preloadAllPosts;
- (void)fullPostReset;
- (void)reloadTheData;

@end

@implementation GSLikesViewController{
    //NSMutableArray* fashionistaPosts;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [postsDoubleDisplayController switchView];
    //fashionistaPosts = [NSMutableArray new];
}

- (void)thirdButtonBarAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if(sender.selected){
        [sender setImage:[UIImage imageNamed:@"thumbnails_icon.png"] forState:UIControlStateNormal];
    }else{
        [sender setImage:[self thirdButtonImage] forState:UIControlStateNormal];
    }
    [postsDoubleDisplayController switchView];
}

- (BOOL)shouldCreatethirdButton{
    return YES;
}

- (UIImage*)thirdButtonImage{
    return [UIImage imageNamed:@"continous_icon.png"];
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
                NSLog(@"Retrieving User Likes");
                
                // Perform request to get the search results
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:theUser.idUser,[NSNumber numberWithInteger:[self.postsArray count]], nil];
                
                self.bAskingForMoreDataInDoubleDisplay = YES;
                
                [self performRestGet:GET_USER_LIKES withParamaters:requestParameters];
            }
        }
    }
}

- (void)updateSearch
{
    [self getUserPosts];
    /*
        // Perform request to get the search results
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:self.currentSearchQuery, [NSNumber numberWithInteger:[self.postsArray count]], nil];
        
        
        [self performRestGet:GET_USER_LIKES withParamaters:requestParameters];
    */
}

- (NSInteger)numberOfSectionsInDataForDoubleDisplay:(GSDoubleDisplayViewController *)displayController forMode:(GSDoubleDisplayMode)displayMode{
    switch (displayMode) {
        case GSDoubleDisplayModeCollection:
            return 1;
            break;
        default:
            return [super numberOfSectionsInDataForDoubleDisplay:displayController forMode:displayMode];
            break;
    }
}

- (void)actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult{
    switch (connection) {
        case GET_USER_LIKES:
        {
            self.bAskingForMoreDataInDoubleDisplay = NO;

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
                                        [self.postsArray removeAllObjects];
                                        [downloadedPosts removeAllObjects];
                                        //[self cancelCurrentSearch];
                                    }
                                    isRefreshing = NO;
                                }
                                if(!([self.postsArray containsObject:result.fashionistaPostId]))
                                {
                                    if(result.content_type&&[result.content_type integerValue]==1){
                                        [self preLoadImage:result.content_url];
                                    }
                                    [self preLoadImage:result.preview_image];
                                    [self.postsArray addObject:result.fashionistaPostId];
                                    [downloadedPosts setObject:[result postParamsFromBaseElement] forKey:result.fashionistaPostId];
                                    [postsDoubleDisplayController newDataObjectGathered:[result postParamsFromBaseElement]];
                                }
                            }
                        }
                    }
                }
            }
            
            // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
            if ([self getFetchedResultsControllerForCellType:GSPOST_CELL ] == nil)
            {
                [self initFetchedResultsControllerForCollectionViewWithCellType:GSPOST_CELL WithEntity:@"FashionistaPost" andPredicate:@"idFashionistaPost IN %@" inArray:self.postsArray sortingWithKeys:[NSArray arrayWithObjects:@"createdAt", nil]  ascending:NO andSectionWithKeyPath:nil];
            }
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:GSPOST_CELL];
            //[self preloadAllPosts];
            [postsDoubleDisplayController refreshData];
            [self stopActivityFeedback];
            break;
        }
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

- (NSArray *)getSimplePostDataAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item>=[self.postsArray count]) {
        return nil;
    }
    NSString * tmpPost = [self.postsArray objectAtIndex:indexPath.item];
    
    BOOL bShowHanger = YES;
    NSArray* postData = [downloadedPosts objectForKey:tmpPost];
    NSArray * cellContent = [NSArray arrayWithObjects: postData, [NSNumber numberWithBool:bShowHanger], [NSNumber numberWithBool:NO], nil];
    
    return cellContent;
}

- (void)askForMoreDataInDoubleDisplay:(GSDoubleDisplayViewController *)vC{
    
        NSInteger currentItems = [self getNumberOfPostsDownloaded];
        NSInteger searchResults = [self.currentQuery.numresults integerValue];
        if(currentItems<searchResults){
            [self updateSearch];
            
        }
}

- (void)doubleDisplayLikeUpdatingFinished{
    [self fullPostReset];
    [self reloadTheData];
}

-(void)swipeRightAction {
    [self dismissViewController];
}

@end
