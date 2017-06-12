//
//  UserForgotPasswordController.h
//  GoldenSpear
//
//  Created by Alberto Seco on 8/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+UserManagement.h"
#import "BaseViewController+MainMenuManagement.h"

@interface UserForgotPasswordController : BaseViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailForgot;

@property (weak, nonatomic) IBOutlet UIView *viewNewPassword;

@property (weak, nonatomic) IBOutlet UILabel *lblExplanation;

- (IBAction)btnForgot:(UIButton *)sender;
- (IBAction)btnNewPassword:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITextField *txtCode;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtPasswordConfirm;

@end
