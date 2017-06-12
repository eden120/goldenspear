//
//  GSSocialNetworkListViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 26/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialNetworkListViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "FashionistaUserListViewCell.h"
#import "BaseViewController+RestServicesManagement.h"
#import "GSImplementedSocialNetworkHandler.h"

@interface FashionistaUserListViewController (Protected)

- (void)performSearch;
- (NSString *) stringForStylistRelationship:(followingRelationships)stylistRelationShip;

@end

@implementation GSSocialNetworkListViewController{
    NSMutableArray* results;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    results = [NSMutableArray new];
    self.userListMode = SOCIAL_NETWORK;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(!theHandler){
        switch (self.networkOrigin) {
            case GSSocialNetworkOriginFacebook:
                theHandler = [GSSocialNetworkHandlerFacebook new];
                break;
             case GSSocialNetworkOriginTwitter:
                theHandler = [GSSocialNetworkHandlerTwitter new];
                break;
            case GSSocialNetworkOriginInstagram:
                theHandler = [GSSocialNetworkHandlerInstagram new];
                break;
                /*
            case GSSocialNetworkOriginLinkedIn:
                theHandler = [GSSocialNetworkHandlerLinkedIn new];
                break;
                 */
            case GSSocialNetworkOriginTumblr:
                theHandler = [GSSocialNetworkHandlerTumblr new];
                break;
            case GSSocialNetworkOriginFlicker:
                theHandler = [GSSocialNetworkHandlerFlicker new];
                break;
                
                 case GSSocialNetworkOriginPinterest:
                 theHandler = [GSSocialNetworkHandlerPinterest new];
                 break;
                 
            default:
                break;
        }
        theHandler.delegate = self;
    }
    [self performSearch];
}

- (void)performSearchWithString:(NSString*)stringToSearch
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray * requestParameters = nil;
    
    
    NSLog(@"Performing search within fashionistas with terms: %@", stringToSearch);
    
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
    
    NSString* token = @"";
    NSString* socialNetwork = @"";
    switch (self.networkOrigin) {
        case GSSocialNetworkOriginFacebook:
            token = appDelegate.currentUser.facebook_token;
            socialNetwork = @"facebook";
            break;
        case GSSocialNetworkOriginTwitter:
            token = appDelegate.currentUser.twitter_token;
            socialNetwork = @"twitter";
            break;
        case GSSocialNetworkOriginInstagram:
            token = appDelegate.currentUser.instagram_token;
            socialNetwork = @"instagram";
            break;
        case GSSocialNetworkOriginFlicker:
            token = appDelegate.currentUser.flicker_token;
            socialNetwork = @"flicker";
            break;
        case GSSocialNetworkOriginTumblr:
            token = appDelegate.currentUser.tumblr_token;
            socialNetwork = @"tumblr";
            break;
        default:
            break;
    }
    requestParameters = [[NSArray alloc] initWithObjects:[self composeStringhWithTermsOfArray:[NSArray arrayWithObject:stringToSearch] encoding:YES], [super stringForStylistRelationship:self.userListMode], currentUserId, token, socialNetwork, nil];
    
    [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAS withParamaters:requestParameters];
}

- (void)operationAfterLoadingSearch:(BOOL)hasResults{
    self.followAllButton.enabled = hasResults;
}

- (IBAction)followAllUsers:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray * requestParameters = nil;
    
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
    
    requestParameters = [[NSArray alloc] initWithObjects:currentUserId, self.currentSearchQuery, nil];
    
    [self performRestPost:POST_FOLLOW_SOCIALNETWORK_USERS withParamaters:requestParameters];
}

- (void)actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult{
    switch (connection) {
        case POST_FOLLOW_SOCIALNETWORK_USERS:
            [self stopActivityFeedback];
            [self performSearch];
            break;
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

@end
