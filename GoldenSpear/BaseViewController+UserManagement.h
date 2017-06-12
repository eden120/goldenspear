//
//  BaseViewController+UserManagement.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 16/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseViewController (UserManagement) <UserDelegate>

// User management
//- (void)changeUserLogInStatus;
- (void)actionAfterLogIn;
- (void)actionAfterLogInWithError;
- (void)actionAfterLogOut;
- (void)actionAfterSignUp;
- (void)actionAfterSignUpWithError;
- (void)hideMessage;
- (void)updateUsernameLabel;

@end
