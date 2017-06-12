//
//  GSLinkAccountsViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 24/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSLinkAccountsViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "GSSocialNetworkCollectionViewCell.h"
#import "BaseViewController+StoryboardManagement.h"

#import "GSImplementedSocialNetworkHandler.h"

#define kSNTitle    @"title"
#define kSNIcon     @"icon"
#define kSNOnBack   @"onBackground"
#define kSNUserKey  @"userKey"

@implementation GSLinkAccountsViewController{
    NSArray* socialNetworks;
    NSInteger itemsPerRow;
    NSInteger cellWidth;
    
    NSIndexPath* currentCellIndexPath;
    
    GSSocialNetworkHandler* theHandler;
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
                      @{kSNTitle:@"Snapchat",kSNIcon:@"snapchat.jpg",kSNOnBack:@"snapchat_on.jpg",kSNUserKey:@"snapchat"},nil];
    itemsPerRow = 3;
    cellWidth = 0;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [socialNetworks count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseIdentifier = @"SocialAccountCell";
    GSSocialNetworkCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSDictionary* socialNetwork = [socialNetworks objectAtIndex:indexPath.row];
    
    // Configure the cell
    cell.networkTitle.text = [[socialNetwork objectForKey:kSNTitle] uppercaseString];
    
    [self setCellStatus:cell forItem:socialNetwork];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(cellWidth<=0){
        cellWidth = floor((collectionView.frame.size.width - (itemsPerRow-1))/itemsPerRow);
    }
    return CGSizeMake(cellWidth, cellWidth);
}

- (void)setCellStatus:(GSSocialNetworkCollectionViewCell*)cell forItem:(NSDictionary*)socialNetwork{
    User* theUser = ((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser;
    NSString* sn_idKey = [NSString stringWithFormat:@"%@_id",[socialNetwork objectForKey:kSNUserKey]];
    NSString* snId = [theUser valueForKey:sn_idKey];
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
    NSDictionary* socialNetwork = [socialNetworks objectAtIndex:indexPath.row];
    
    User* theUser = ((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser;
    NSString* sn_idKey = [NSString stringWithFormat:@"%@_id",[socialNetwork objectForKey:kSNUserKey]];
    NSString* snId = [theUser valueForKey:sn_idKey];
    currentCellIndexPath = indexPath;
    
    if(snId&&![snId isEqualToString:@""]){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_VCTITLE_9_", nil)
                                                        message:NSLocalizedString(@"_UNLINK_ACCOUNT_MSG_", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_NO_", nil)
                                              otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
        [alert show];
    }else{
        [self linkAccount:(GSSocialNetworkOrigin)indexPath.row];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex>0) {
        User* theUser = ((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser;
        NSDictionary* socialNetwork = [socialNetworks objectAtIndex:currentCellIndexPath.row];
        GSSocialNetworkCollectionViewCell *cell = (GSSocialNetworkCollectionViewCell*)[self collectionView:self.collectionView cellForItemAtIndexPath:currentCellIndexPath];
        NSString* sn_idKey = [NSString stringWithFormat:@"%@_id",[socialNetwork objectForKey:kSNUserKey]];
        NSString* sn_tokenKey = [NSString stringWithFormat:@"%@_token",[socialNetwork objectForKey:kSNUserKey]];
        [theUser setValue:@"" forKey:sn_idKey];
        [theUser setValue:@"" forKey:sn_tokenKey];
        [self setCellStatus:cell forItem:socialNetwork];
        [self.collectionView reloadData];
        [theUser updateUserToServerDBVerbose:YES];
    }
    currentCellIndexPath = nil;
}

#pragma mark - Link Account Methods

- (void)linkAccount:(GSSocialNetworkOrigin)account{
    theHandler = nil;
    switch (account) {
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
    NSDictionary* socialNetwork = [socialNetworks objectAtIndex:currentCellIndexPath.row];
    GSSocialNetworkCollectionViewCell *cell = (GSSocialNetworkCollectionViewCell*)[self collectionView:self.collectionView cellForItemAtIndexPath:currentCellIndexPath];
    NSString* sn_idKey = [NSString stringWithFormat:@"%@_id",[socialNetwork objectForKey:kSNUserKey]];
    NSString* sn_tokenKey = [NSString stringWithFormat:@"%@_token",[socialNetwork objectForKey:kSNUserKey]];
    [theUser setValue:[loginData objectForKey:kSNLoginToken] forKey:sn_tokenKey];
    [theUser setValue:[loginData objectForKey:kSNLoginId] forKey:sn_idKey];
    [self setCellStatus:cell forItem:socialNetwork];
    [self.collectionView reloadData];
    [self stopActivityFeedback];
    [theUser updateUserToServerDBVerbose:YES];
    [self dismissControllerModal];
}

- (void)loginDidFailedWithError:(NSError *)error{
    [self stopActivityFeedback];
    [self dismissControllerModal];
}

@end
