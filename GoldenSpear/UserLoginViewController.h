//
//  UserLoginViewController.h
//  GoldenSpear
//
//  Created by Alberto Seco on 29/4/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+UserManagement.h"
#import "BaseViewController+MainMenuManagement.h"

@interface UserLoginViewController : BaseViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightSeparator;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextEdit;

@property (weak, nonatomic) IBOutlet UILabel *notMemberLabel;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIView *separatorLineView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topAlreadyAMemberConstraint;

// Current Ad shown
@property BackgroundAd * currentBackgroundAd;

// Background Ad
@property (weak, nonatomic) IBOutlet UIImageView *backgroundAdImageView;
@property (nonatomic, strong) NSOperationQueue *imagesQueue;
@property (weak, nonatomic) IBOutlet UILabel *backgroundAdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logo;


@end
