//
//  GSFriendListViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 26/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSFriendListViewController.h"
#import "GSSocialNetworkCollectionViewCell.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "GSSocialNetworkHandlerFacebook.h"
#import "BaseViewController+StoryboardManagement.h"
#import "SearchBaseViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "GSSocialNetworkListViewController.h"
#import "GSImplementedSocialNetworkHandler.h"

#define kSNTitle    @"title"
#define kSNIcon     @"icon"
#define kSNOnBack   @"onBackground"
#define kSNUserKey  @"userKey"

@implementation GSFriendListViewController{
    NSArray* socialNetworks;
    
    NSIndexPath* currentCellIndexPath;
    
    GSSocialNetworkHandler* theHandler;
    
    BaseViewController* currentController;
}

- (BOOL)shouldCenterTitle{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    socialNetworks = [NSArray arrayWithObjects:
                      @{kSNTitle:@"Facebook",kSNIcon:@"facebook.jpg",kSNOnBack:@"facebook_on.jpg",kSNUserKey:@"facebook"},
                      @{kSNTitle:@"Twitter",kSNIcon:@"twitter.jpg",kSNOnBack:@"twitter_on.jpg",kSNUserKey:@"twitter"},
                      @{kSNTitle:@"Instagram",kSNIcon:@"instagram.jpg",kSNOnBack:@"instagram_on.jpg",kSNUserKey:@"instagram"},
                      @{kSNTitle:@"Pinterest",kSNIcon:@"pintrest.jpg",kSNOnBack:@"pintrest_on.jpg",kSNUserKey:@"pinterest"},
                      @{kSNTitle:@"Tumblr",kSNIcon:@"tumblr.jpg",kSNOnBack:@"tumblr_on.jpg",kSNUserKey:@"tumblr"},
                      @{kSNTitle:@"Flicker",kSNIcon:@"flickr.jpg",kSNOnBack:@"flickr_on.jpg",kSNUserKey:@"flicker"},
                      @{kSNTitle:@"LinkedIn",kSNIcon:@"linkedin.jpg",kSNOnBack:@"linkedin_on.jpg",kSNUserKey:@"linkedin"},
                      @{kSNTitle:@"Snapchat",kSNIcon:@"snapchat.jpg",kSNOnBack:@"snapchat_on.jpg",kSNUserKey:@"snapchat"},
                      @{kSNTitle:@"EMail",kSNIcon:@"email.jpg",kSNOnBack:@"email_on.jpg"},nil];
    currentCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self loadGSFriendsController];
}


- (void)loadGSFriendsController{
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    BaseViewController *nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(USERLIST_VC) stringValue]];
    
    [self prepareViewController:nextViewController withParameters:nil];
    [(SearchBaseViewController*)nextViewController setSearchContext:FASHIONISTAS_SEARCH];
    [self changeCurrentController:nextViewController];
}

- (void)setupAutolayoutToEqualParent:(UIView*)theView{
    //Height
    NSLayoutConstraint* aConstraint = [NSLayoutConstraint constraintWithItem:theView.superview
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:theView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1
                                                                    constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Width
    aConstraint = [NSLayoutConstraint constraintWithItem:theView.superview
                                               attribute:NSLayoutAttributeWidth
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView
                                               attribute:NSLayoutAttributeWidth
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Center Hori
    aConstraint = [NSLayoutConstraint constraintWithItem:theView.superview
                                               attribute:NSLayoutAttributeCenterX
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView
                                               attribute:NSLayoutAttributeCenterX
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
    //Center Vert
    aConstraint = [NSLayoutConstraint constraintWithItem:theView.superview
                                               attribute:NSLayoutAttributeCenterY
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView
                                               attribute:NSLayoutAttributeCenterY
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
}

- (void)addControllerInContainer:(BaseViewController*)viewcontroller{
    [self.vcContainer addSubview:viewcontroller.view];
    [self setupAutolayoutToEqualParent:viewcontroller.view];
    [viewcontroller hideTopBar];
    [self.vcContainer layoutIfNeeded];
}

- (void)changeCurrentController:(BaseViewController*)destinationVC{
    [self cleanContainerController];
    [destinationVC willMoveToParentViewController:self];
    [self addControllerInContainer:destinationVC];
    [self addChildViewController:destinationVC];
    [destinationVC didMoveToParentViewController:self];
    currentController = destinationVC;
    [currentController createTopBar];
}

- (void)cleanContainerController{
    [currentController willMoveToParentViewController:nil];
    [currentController.view removeFromSuperview];
    [currentController removeFromParentViewController];
    currentController = nil;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [socialNetworks count]+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseIdentifier = @"SocialAccountCell";
    BOOL friendCell = NO;
    if (indexPath.row==0) {
        reuseIdentifier = @"FriendCell";
        friendCell = YES;
    }
    GSSocialNetworkCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(!friendCell){
        NSDictionary* socialNetwork = [socialNetworks objectAtIndex:indexPath.row-1];
        [self setCellStatus:cell forItem:socialNetwork];
    }else{
        UIImage* cellImage;
        if(currentCellIndexPath.row==0){
            cellImage = [UIImage imageNamed:@"add_friend_on.jpg"];
        }else{
            cellImage = [UIImage imageNamed:@"add_friend.jpg"];
        }
        cell.networkImage.image = cellImage;
    }
    cell.layer.borderWidth = 2;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if(currentCellIndexPath.row==indexPath.row){
        cell.layer.borderColor = [GOLDENSPEAR_COLOR CGColor];
    }else{
        cell.layer.borderColor = [[UIColor clearColor] CGColor];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(collectionView.frame.size.height, collectionView.frame.size.height);
}

- (void)setCellStatus:(GSSocialNetworkCollectionViewCell*)cell forItem:(NSDictionary*)socialNetwork{
    User* theUser = ((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser;
    
    NSString* userKey = [socialNetwork objectForKey:kSNUserKey];
    NSString* snId = nil;
    if(userKey){
        NSString* sn_idKey = [NSString stringWithFormat:@"%@_id",userKey];
        snId = [theUser valueForKey:sn_idKey];
    }
    UIImage* cellImage;
    if(snId&&![snId isEqualToString:@""]){
        cellImage = [UIImage imageNamed:[socialNetwork objectForKey:kSNOnBack]];
    }else{
        cellImage = [UIImage imageNamed:[socialNetwork objectForKey:kSNIcon]];
    }
    cell.networkImage.image = cellImage;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath: (NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    if (index==0) {
        if (currentCellIndexPath.row!=0) {
            //Load friends ViewController
            [self loadGSFriendsController];
        }
        currentCellIndexPath = indexPath;
    }else{
        index -= 1;
        if((GSSocialNetworkOrigin)index==GSSocialNetworkOriginEmail){
            //Send Mail
            [self showEmail];
        }
        /*
        else if((GSSocialNetworkOrigin)index==GSSocialNetworkOriginFacebook){
         
            [self inviteFacebook];
        }
         */
        else{
            NSDictionary* socialNetwork = [socialNetworks objectAtIndex:index];
            
            User* theUser = ((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser;
            NSString* sn_idKey = [NSString stringWithFormat:@"%@_id",[socialNetwork objectForKey:kSNUserKey]];
            NSString* snId = [theUser valueForKey:sn_idKey];
            currentCellIndexPath = indexPath;
            
            if(snId&&![snId isEqualToString:@""]){
                //Load ViewController
                [self loadSNFriendsControllerWithSN:(GSSocialNetworkOrigin)index];
            }else{
                [self linkAccount:(GSSocialNetworkOrigin)index];
            }
        }
    }
    [collectionView reloadData];
}

- (void)loadSNFriendsControllerWithSN:(GSSocialNetworkOrigin)socialNetwork{
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    BaseViewController *nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(SOCIALNETWORKLIST_VC) stringValue]];
    
    [self prepareViewController:nextViewController withParameters:nil];
    [(GSSocialNetworkListViewController*)nextViewController setNetworkOrigin:socialNetwork];
    [self changeCurrentController:nextViewController];
}

#pragma mark - ThirdParty Invites

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error{
    NSLog(@"%@",error.description);
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results{
    NSLog(@"%@",results);
}

- (void)inviteFacebook{
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/233488393697989"];
    content.promotionText = NSLocalizedString(@"_INVITE_SHORT_BODY_", nil);
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://a2.mzstatic.com/us/r30/Purple69/v4/82/51/00/82510044-34f5-64f0-2cd7-d404404bdaf1/icon175x175.jpeg"];
    
    // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
    
    [FBSDKAppInviteDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
}

#pragma mark - Mail Methods

- (void)showEmail
{
    // Get the Global Mail Composer
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([MFMailComposeViewController canSendMail])
    {
        [appDelegate cycleGlobalMailComposer];
        
        // Compose Email
        [appDelegate.globalMailComposer setSubject:NSLocalizedString(@"_INVITE_EMAIL_TITLE_", nil)];
        
        [appDelegate.globalMailComposer setMessageBody:NSLocalizedString(@"_INVITE_EMAIL_BODY_", nil) isHTML:NO];
        
        // Present mail view controller on screen
        appDelegate.globalMailComposer.mailComposeDelegate = self;
        
        [self presentViewController:appDelegate.globalMailComposer animated:YES completion:NULL];
    }
    else
    {
        [appDelegate cycleGlobalMailComposer];
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Link Account Methods

- (void)linkAccount:(GSSocialNetworkOrigin)account{
    theHandler = nil;
    switch (account) {
        case GSSocialNetworkOriginFacebook:
            theHandler = [GSSocialNetworkHandlerFacebook new];
            break;
        case GSSocialNetworkOriginInstagram:
            theHandler = [GSSocialNetworkHandlerInstagram new];
            break;
        case GSSocialNetworkOriginTwitter:
            theHandler = [GSSocialNetworkHandlerTwitter new];
            break;
            /*
        case GSSocialNetworkOriginLinkedIn:
            theHandler = [GSSocialNetworkHandlerLinkedIn new];
            break;
             */
        case GSSocialNetworkOriginFlicker:
            theHandler = [GSSocialNetworkHandlerFlicker new];
            break;
        case GSSocialNetworkOriginTumblr:
            theHandler = [GSSocialNetworkHandlerTumblr new];
            break;
            
        case GSSocialNetworkOriginPinterest:
            theHandler = [GSSocialNetworkHandlerPinterest new];
            break;
             
        default:
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_VCTITLE_9_", nil)
                                                            message:NSLocalizedString(@"_NOTYETIMPLMENETED_MSG_", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"_OK_BTN_", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
    }
    if(theHandler){
        theHandler.delegate = self;
        [self startActivityFeedbackWithMessage:@""];
        [theHandler loginUserToSocialNetwork];
    }
    
}

- (void)loginSuccessfulWithData:(NSDictionary*)loginData{
    User* theUser = ((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser;
    NSDictionary* socialNetwork = [socialNetworks objectAtIndex:currentCellIndexPath.row-1];
    GSSocialNetworkCollectionViewCell *cell = (GSSocialNetworkCollectionViewCell*)[self collectionView:self.headerButtonsCollection cellForItemAtIndexPath:currentCellIndexPath];
    NSString* sn_idKey = [NSString stringWithFormat:@"%@_id",[socialNetwork objectForKey:kSNUserKey]];
    NSString* sn_tokenKey = [NSString stringWithFormat:@"%@_token",[socialNetwork objectForKey:kSNUserKey]];
    [theUser setValue:[loginData objectForKey:kSNLoginToken] forKey:sn_tokenKey];
    [theUser setValue:[loginData objectForKey:kSNLoginId] forKey:sn_idKey];
    [self setCellStatus:cell forItem:socialNetwork];
    [self.headerButtonsCollection reloadData];
    [self stopActivityFeedback];
    [theUser updateUserToServerDBVerbose:NO];
}

- (void)loginDidFailedWithError:(NSError *)error{
    [self stopActivityFeedback];
}

@end
