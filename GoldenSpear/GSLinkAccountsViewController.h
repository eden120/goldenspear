//
//  GSLinkAccountsViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 24/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "GSSocialNetworkHandler.h"

@interface GSLinkAccountsViewController : BaseViewController<UIAlertViewDelegate,GSSocialNetworkHandlerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
