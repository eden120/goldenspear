//
//  GSSocialNetworkListViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 26/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "FashionistaUserListViewController.h"
#import "GSSocialNetworkHandler.h"

@interface GSSocialNetworkListViewController : FashionistaUserListViewController<GSSocialNetworkHandlerDelegate>{
    GSSocialNetworkHandler* theHandler;
}

@property (nonatomic) GSSocialNetworkOrigin networkOrigin;
@property (weak, nonatomic) IBOutlet UIButton *followAllButton;

- (IBAction)followAllUsers:(id)sender;

@end
