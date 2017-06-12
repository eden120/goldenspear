//
//  GSFriendListViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 26/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "GSSocialNetworkHandler.h"
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface GSFriendListViewController : BaseViewController<UICollectionViewDelegate,UICollectionViewDataSource,GSSocialNetworkHandlerDelegate,MFMailComposeViewControllerDelegate,FBSDKAppInviteDialogDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *headerButtonsCollection;

@property (weak, nonatomic) IBOutlet UIView *vcContainer;

@end
